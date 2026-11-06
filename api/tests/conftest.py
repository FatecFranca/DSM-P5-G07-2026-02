import os
import sys
from pathlib import Path

import mongomock
import pytest

# Configuração fictícia: nenhum teste acessa o MongoDB real.
os.environ["MONGODB_URI"] = "mongodb://127.0.0.1:27017/"
os.environ["MONGODB_DATABASE"] = "stress_scan_test"
os.environ["JWT_SECRET_KEY"] = "chave-ficticia-exclusiva-dos-testes"

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import database  # noqa: E402

# Substitui o banco por um banco em memória ANTES de importar a aplicação,
# pois os módulos fazem `from database import db`.
database.db = mongomock.MongoClient()["stress_scan_test"]

from fastapi.testclient import TestClient  # noqa: E402

import main  # noqa: E402


@pytest.fixture(autouse=True)
def banco_limpo():
    database.db.usuarios.delete_many({})
    database.db.avaliacoes.delete_many({})
    database.db.usuarios.create_index("email", unique=True)
    yield


@pytest.fixture
def client():
    return TestClient(main.app)


QUESTIONARIO = {campo: 0 for campo in main.Questionario.model_fields}


@pytest.fixture
def questionario():
    return dict(QUESTIONARIO)


def criar_usuario(client, email="aluno@example.com", senha="senha-segura-123"):
    resposta = client.post("/cadastro", json={"email": email, "senha": senha})
    assert resposta.status_code == 201
    return email, senha


def token_de(client, email="aluno@example.com", senha="senha-segura-123"):
    criar_usuario(client, email, senha)
    resposta = client.post("/login", json={"email": email, "senha": senha})
    assert resposta.status_code == 200
    return resposta.json()["access_token"]


@pytest.fixture
def auth(client):
    def _auth(email="aluno@example.com"):
        return {"Authorization": f"Bearer {token_de(client, email)}"}

    return _auth
