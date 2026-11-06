from datetime import datetime, timezone
from fastapi import Depends
from auth import obter_usuario_atual
from database import db
from historico import router as historico_router

from login import router as login_router
from cadastro import router as cadastro_router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, ConfigDict
from pathlib import Path
import joblib
import pandas as pd
from auth import router as auth_router

# Criando a API
app = FastAPI(
    title="Stress Scan API",
    description="API para classificação dos níveis de estresse de estudantes universitários",
    version="1.0.0"
)

# CORS: libera apenas o Flutter Web em desenvolvimento (localhost, qualquer porta).
# A autenticação usa o header Authorization (JWT), sem cookies.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(cadastro_router)
app.include_router(login_router)
app.include_router(auth_router)
app.include_router(historico_router)

# Carregando o modelo treinado
caminho_modelo = Path(__file__).resolve().parent / "modelo_estresse_LR.joblib"

pacote = joblib.load(caminho_modelo)

modelo = pacote["modelo"]
colunas = pacote["colunas"]


# Estrutura das respostas do questionário
class Questionario(BaseModel):
    model_config = ConfigDict(extra="forbid")

    anxiety_level: int = Field(ge=0, le=21)
    self_esteem: int = Field(ge=0, le=30)
    depression: int = Field(ge=0, le=27)
    headache: int = Field(ge=0, le=5)
    sleep_quality: int = Field(ge=0, le=5)
    noise_level: int = Field(ge=0, le=5)
    living_conditions: int = Field(ge=0, le=5)
    safety: int = Field(ge=0, le=5)
    basic_needs: int = Field(ge=0, le=5)
    academic_performance: int = Field(ge=0, le=5)
    study_load: int = Field(ge=0, le=5)
    teacher_student_relationship: int = Field(ge=0, le=5)
    future_career_concerns: int = Field(ge=0, le=5)
    social_support: int = Field(ge=0, le=3)
    peer_pressure: int = Field(ge=0, le=5)
    extracurricular_activities: int = Field(ge=0, le=5)
    bullying: int = Field(ge=0, le=5)


# Rota inicial
@app.get("/")
def inicio():
    return {
        "aplicacao": "Stress Scan",
        "status": "API funcionando!"
    }


# Verificar modelo
@app.get("/modelo")
def verificar_modelo():
    return {
        "algoritmo": "Regressão Logística",
        "quantidade_atributos": len(colunas),
        "atributos": colunas,
        "status": "Modelo carregado com sucesso!"
    }


# Realizar classificação e salvar avaliação
@app.post("/prever")
def prever(
    dados: Questionario,
    usuario=Depends(obter_usuario_atual)
):

    # Converter respostas em DataFrame
    respostas = dados.model_dump()
    entrada = pd.DataFrame([respostas], columns=colunas)

    # Realizar previsão
    previsao = int(modelo.predict(entrada)[0])

    # Interpretar resultado
    classificacoes = {
        0: "Estresse baixo",
        1: "Estresse moderado",
        2: "Estresse alto"
    }

    # Registrar avaliação no MongoDB
    avaliacao = {
        "usuario_id": str(usuario["_id"]),
        "nivel_estresse": previsao,
        "classificacao": classificacoes[previsao],
        "criado_em": datetime.now(timezone.utc)
    }

    resultado = db.avaliacoes.insert_one(avaliacao)

    # Retornar resultado ao aplicativo
    return {
        "avaliacao_id": str(resultado.inserted_id),
        "nivel_estresse": previsao,
        "classificacao": classificacoes[previsao],
        "mensagem": "Classificação experimental, sem finalidade de diagnóstico clínico."
    }
