from datetime import datetime, timedelta, timezone

import jwt

import database
from login import ALGORITHM, SECRET_KEY


# ---------- Cadastro ----------

def test_cadastro_sucesso_e_senha_nao_fica_em_texto_puro(client):
    r = client.post("/cadastro", json={"email": "A@Example.com", "senha": "senha-segura-123"})
    assert r.status_code == 201
    assert r.json()["email"] == "a@example.com"

    usuario = database.db.usuarios.find_one({"email": "a@example.com"})
    assert usuario["senha_hash"] != "senha-segura-123"
    assert usuario["senha_hash"].startswith("$argon2")


def test_cadastro_email_duplicado_retorna_409(client):
    dados = {"email": "dup@example.com", "senha": "senha-segura-123"}
    assert client.post("/cadastro", json=dados).status_code == 201
    assert client.post("/cadastro", json=dados).status_code == 409


def test_cadastro_email_duplicado_ignora_maiusculas(client):
    client.post("/cadastro", json={"email": "x@example.com", "senha": "senha-segura-123"})
    r = client.post("/cadastro", json={"email": "X@EXAMPLE.COM", "senha": "senha-segura-123"})
    assert r.status_code == 409


def test_cadastro_senha_curta_retorna_422(client):
    r = client.post("/cadastro", json={"email": "a@example.com", "senha": "123"})
    assert r.status_code == 422


def test_cadastro_email_invalido_retorna_422(client):
    r = client.post("/cadastro", json={"email": "nao-e-email", "senha": "senha-segura-123"})
    assert r.status_code == 422


def test_cadastro_rejeita_campos_extras(client):
    r = client.post(
        "/cadastro",
        json={"email": "a@example.com", "senha": "senha-segura-123", "admin": True},
    )
    assert r.status_code == 422


# ---------- Login ----------

def test_login_sucesso_retorna_jwt_valido(client):
    token = None
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    r = client.post("/login", json={"email": "a@example.com", "senha": "senha-segura-123"})
    assert r.status_code == 200
    corpo = r.json()
    assert corpo["token_type"] == "bearer"
    token = jwt.decode(corpo["access_token"], SECRET_KEY, algorithms=[ALGORITHM])
    assert token["type"] == "access"


def test_login_senha_errada_retorna_401(client):
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    r = client.post("/login", json={"email": "a@example.com", "senha": "errada-errada"})
    assert r.status_code == 401


def test_login_usuario_inexistente_tem_mesma_resposta_da_senha_errada(client):
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    errada = client.post("/login", json={"email": "a@example.com", "senha": "errada-errada"})
    inexistente = client.post("/login", json={"email": "z@example.com", "senha": "qualquer-coisa"})
    assert inexistente.status_code == errada.status_code == 401
    assert inexistente.json() == errada.json()  # não revela se o e-mail existe


# ---------- Autenticação ----------

def test_rotas_protegidas_exigem_token(client, questionario):
    assert client.get("/me").status_code == 401
    assert client.get("/historico").status_code == 401
    assert client.post("/prever", json=questionario).status_code == 401


def test_token_invalido_retorna_401(client):
    r = client.get("/historico", headers={"Authorization": "Bearer abc"})
    assert r.status_code == 401


def test_token_expirado_retorna_401(client):
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    usuario = database.db.usuarios.find_one({"email": "a@example.com"})
    agora = datetime.now(timezone.utc)
    expirado = jwt.encode(
        {"sub": str(usuario["_id"]), "type": "access",
         "iat": agora - timedelta(hours=2), "exp": agora - timedelta(hours=1)},
        SECRET_KEY, algorithm=ALGORITHM,
    )
    r = client.get("/me", headers={"Authorization": f"Bearer {expirado}"})
    assert r.status_code == 401


def test_token_assinado_com_outra_chave_retorna_401(client):
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    usuario = database.db.usuarios.find_one({"email": "a@example.com"})
    forjado = jwt.encode(
        {"sub": str(usuario["_id"]), "type": "access",
         "exp": datetime.now(timezone.utc) + timedelta(hours=1)},
        "outra-chave-qualquer-com-32-bytes-ok!", algorithm=ALGORITHM,
    )
    r = client.get("/me", headers={"Authorization": f"Bearer {forjado}"})
    assert r.status_code == 401


def test_token_com_tipo_diferente_de_access_retorna_401(client):
    client.post("/cadastro", json={"email": "a@example.com", "senha": "senha-segura-123"})
    usuario = database.db.usuarios.find_one({"email": "a@example.com"})
    token = jwt.encode(
        {"sub": str(usuario["_id"]), "type": "refresh",
         "exp": datetime.now(timezone.utc) + timedelta(hours=1)},
        SECRET_KEY, algorithm=ALGORITHM,
    )
    assert client.get("/me", headers={"Authorization": f"Bearer {token}"}).status_code == 401


def test_token_de_usuario_removido_retorna_401(client, auth):
    headers = auth()
    database.db.usuarios.delete_many({})
    assert client.get("/me", headers=headers).status_code == 401


def test_me_retorna_o_usuario_autenticado(client, auth):
    r = client.get("/me", headers=auth("a@example.com"))
    assert r.status_code == 200
    assert r.json()["email"] == "a@example.com"


# ---------- Classificação ----------

def test_prever_retorna_classe_valida_e_registra_avaliacao(client, auth, questionario):
    r = client.post("/prever", json=questionario, headers=auth())
    assert r.status_code == 200
    corpo = r.json()
    assert corpo["nivel_estresse"] in (0, 1, 2)
    assert corpo["classificacao"] in ("Estresse baixo", "Estresse moderado", "Estresse alto")
    assert database.db.avaliacoes.count_documents({}) == 1


def test_prever_nao_armazena_as_respostas_individuais(client, auth, questionario):
    client.post("/prever", json=questionario, headers=auth())
    registro = database.db.avaliacoes.find_one({})
    assert set(registro) == {"_id", "usuario_id", "nivel_estresse", "classificacao", "criado_em"}


def test_prever_valor_fora_do_intervalo_retorna_422(client, auth, questionario):
    questionario["anxiety_level"] = 999
    assert client.post("/prever", json=questionario, headers=auth()).status_code == 422


def test_prever_campo_faltando_retorna_422(client, auth, questionario):
    del questionario["bullying"]
    assert client.post("/prever", json=questionario, headers=auth()).status_code == 422


def test_prever_campo_extra_retorna_422(client, auth, questionario):
    questionario["extra"] = 1
    assert client.post("/prever", json=questionario, headers=auth()).status_code == 422


def test_prever_respostas_extremas_dao_classes_diferentes(client, auth, questionario):
    # Sanidade do modelo: perfis opostos não podem cair na mesma classe.
    headers = auth()
    baixo = dict(questionario)
    alto = dict(questionario, anxiety_level=21, depression=27, bullying=5,
                peer_pressure=5, future_career_concerns=5, headache=5, noise_level=5,
                study_load=5, self_esteem=0, sleep_quality=0, basic_needs=0, safety=0,
                social_support=0, living_conditions=0, academic_performance=0)
    a = client.post("/prever", json=baixo, headers=headers).json()["nivel_estresse"]
    b = client.post("/prever", json=alto, headers=headers).json()["nivel_estresse"]
    assert a != b
    assert b == 2


# ---------- Histórico ----------

def test_historico_vazio(client, auth):
    r = client.get("/historico", headers=auth())
    assert r.status_code == 200
    assert r.json()["avaliacoes"] == []


def test_historico_ordem_decrescente(client, auth, questionario):
    headers = auth()
    for _ in range(3):
        client.post("/prever", json=questionario, headers=headers)
    datas = [a["criado_em"] for a in client.get("/historico", headers=headers).json()["avaliacoes"]]
    assert len(datas) == 3
    assert datas == sorted(datas, reverse=True)


def test_historico_limitado_a_50(client, auth, questionario):
    headers = auth()
    usuario = database.db.usuarios.find_one({})
    agora = datetime.now(timezone.utc)
    database.db.avaliacoes.insert_many([
        {"usuario_id": str(usuario["_id"]), "nivel_estresse": 0,
         "classificacao": "Estresse baixo", "criado_em": agora - timedelta(minutes=i)}
        for i in range(60)
    ])
    r = client.get("/historico", headers=headers).json()
    assert r["total_retornado"] == 50


def test_historico_isolado_entre_usuarios(client, auth, questionario):
    headers_a = auth("a@example.com")
    headers_b = auth("b@example.com")

    client.post("/prever", json=questionario, headers=headers_a)
    client.post("/prever", json=questionario, headers=headers_a)
    client.post("/prever", json=questionario, headers=headers_b)

    a = client.get("/historico", headers=headers_a).json()
    b = client.get("/historico", headers=headers_b).json()

    assert a["total_retornado"] == 2
    assert b["total_retornado"] == 1
    ids_a = {x["avaliacao_id"] for x in a["avaliacoes"]}
    ids_b = {x["avaliacao_id"] for x in b["avaliacoes"]}
    assert ids_a.isdisjoint(ids_b)
    assert a["usuario_id"] != b["usuario_id"]


def test_historico_ignora_parametro_de_usuario_na_url(client, auth, questionario):
    headers_a = auth("a@example.com")
    headers_b = auth("b@example.com")
    client.post("/prever", json=questionario, headers=headers_b)
    outro_id = client.get("/historico", headers=headers_b).json()["usuario_id"]

    r = client.get(f"/historico?usuario_id={outro_id}", headers=headers_a)
    assert r.json()["total_retornado"] == 0


# ---------- Geral ----------

def test_rotas_publicas(client):
    assert client.get("/").json()["aplicacao"] == "Stress Scan"
    assert client.get("/modelo").json()["quantidade_atributos"] == 17


def test_cors_permite_localhost_e_bloqueia_origem_externa(client):
    base = {"Access-Control-Request-Method": "POST"}
    ok = client.options("/login", headers={**base, "Origin": "http://localhost:5000"})
    assert ok.headers.get("access-control-allow-origin") == "http://localhost:5000"

    ruim = client.options("/login", headers={**base, "Origin": "https://evil.com"})
    assert "access-control-allow-origin" not in ruim.headers
