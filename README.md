# Stress Scan

**Aplicativo acadêmico de classificação experimental de níveis de estresse em estudantes universitários, com dashboard de resultados**

Projeto Integrador do curso de **Desenvolvimento de Software Multiplataforma (DSM)** da **FATEC Franca**.

O **Stress Scan** combina um aplicativo desenvolvido em **Flutter**, uma **API REST em FastAPI** hospedada em uma **máquina virtual (VM) na Microsoft Azure**, um modelo de **Machine Learning** e o **MongoDB Atlas** para classificar respostas a um questionário, consultar avaliações anteriores e visualizar um painel com a evolução das classificações.

> **Aviso:** o Stress Scan é um protótipo acadêmico. Suas classificações são experimentais, **não constituem diagnóstico clínico** e não substituem avaliação ou acompanhamento profissional.

## Objetivo e contexto

O projeto busca apoiar a reflexão sobre o estresse no ambiente universitário, com atenção especial à vivência de estudantes **pretos e pardos** e aos fatores sociais e acadêmicos que podem afetar seu bem-estar.

O aplicativo permite que o estudante autenticado responda a um questionário de 17 perguntas, receba uma classificação experimental, consulte o histórico individual e acompanhe suas classificações em um dashboard. Os níveis previstos são:

| Classe | Classificação |
| --- | --- |
| `0` | Estresse baixo |
| `1` | Estresse moderado |
| `2` | Estresse alto |

**Limitação metodológica:** o dataset utilizado não disponibiliza uma variável de raça/cor que permita avaliar o desempenho especificamente em estudantes pretos e pardos. Portanto, o projeto **não reivindica que seu modelo tenha sido validado para esse grupo**.

## Arquitetura

```mermaid
flowchart TD
    U[Estudante] --> F[Flutter - Windows / Android / Web]
    F -->|HTTPS e token JWT| N[Nginx - VM Azure]
    N --> A[FastAPI - Python]
    A --> M[Modelo de Regressão Logística]
    A <-->|Usuários e avaliações| D[(MongoDB Atlas)]
    A -->|Resultado em JSON| F
```

- **Flutter:** tela de boas-vindas, login, Home, questionário, tela de classificação, histórico individual e dashboard com gráfico.
- **FastAPI:** cadastro, autenticação JWT, verificação das credenciais, inferência e registro das avaliações.
- **Machine Learning:** modelo de Regressão Logística serializado em arquivo `.joblib`.
- **MongoDB Atlas:** armazenamento dos usuários e das avaliações associadas à identidade autenticada.
- **Azure VM:** hospedagem pública da API; o repositório inclui arquivos de configuração para Nginx, serviço `systemd` e implantação.
- **GitHub Actions:** validação automatizada da API e publicação **condicional** na VM Azure.

A versão Flutter é executada localmente durante o desenvolvimento e pode ser apresentada como aplicativo **Windows Desktop**. Não é necessário hospedar o Flutter na VM para que ele consuma a API.

## Tecnologias

| Camada | Tecnologias |
| --- | --- |
| Interface | Flutter, Dart, Material Design, `fl_chart` (gráfico de colunas) |
| Comunicação | HTTPS, pacote `http` do Dart |
| Backend | Python, FastAPI, Uvicorn, Pydantic, Pandas |
| Machine Learning | Scikit-learn, Regressão Logística, Joblib |
| Banco de dados | MongoDB Atlas, PyMongo |
| Autenticação | JWT (PyJWT) e hash de senhas Argon2 |
| Infraestrutura | Microsoft Azure VM, Linux, Nginx, `systemd`, SSH |
| Automação | GitHub Actions, script de deploy em shell |

## Machine Learning

O modelo foi treinado com o dataset [Student Stress Monitoring Datasets (Kaggle)](https://www.kaggle.com/datasets/mdsultanulislamovi/student-stress-monitoring-datasets), que contém **1.100 observações**.

Após análise e seleção, a aplicação utiliza **17 atributos**, distribuídos em cinco grupos:

| Grupo | Atributos usados no questionário |
| --- | --- |
| Psicológicos | `anxiety_level`, `depression`, `self_esteem` |
| Fisiológicos | `headache`, `sleep_quality` |
| Ambientais | `noise_level`, `living_conditions`, `safety`, `basic_needs` |
| Acadêmicos | `academic_performance`, `study_load`, `teacher_student_relationship`, `future_career_concerns` |
| Sociais | `social_support`, `peer_pressure`, `extracurricular_activities`, `bullying` |

O modelo adotado foi a **Regressão Logística**, com as seguintes métricas obtidas nos testes com o dataset:

| Métrica | Resultado |
| --- | --- |
| Acurácia no conjunto de teste | **90,45%** |
| Acurácia média em validação cruzada de 10 folds | **87,50%** |
| Recall da classe de estresse alto (2) | **94,59%** |

As alternativas qualitativas do aplicativo são convertidas em valores numéricos para uso pelo modelo. **Essa correspondência é uma adaptação experimental, ainda não validada com usuários reais.** Assim, as métricas acima não representam necessariamente o desempenho do questionário em uso real.

## Estrutura do repositório

```text
stress_scan/
├── .github/
│   └── workflows/
│       └── api.yml               # CI e CD condicional da API
├── api/
│   ├── main.py                   # Endpoints e inferência
│   ├── cadastro.py               # Cadastro
│   ├── login.py                  # Login e geração de JWT
│   ├── auth.py                   # Validação de JWT e /me
│   ├── historico.py              # Consulta de avaliações
│   ├── database.py               # Conexão MongoDB Atlas
│   ├── setup_db.py               # Índices e configuração inicial
│   ├── modelo_estresse_LR.joblib  # Modelo treinado
│   └── requirements.txt
├── infra/
│   ├── README.md                 # Guia específico de infraestrutura
│   ├── deploy.sh                 # Script de implantação
│   ├── stress-scan.nginx.conf    # Configuração do proxy Nginx
│   └── stress-scan.service       # Definição de serviço systemd
└── mobile/
    ├── assets/images/
    │   ├── logo.png
    │   ├── bemvindo.png
    │   ├── questionario.png
    │   └── resultado.png
    ├── lib/
    │   ├── config/api_config.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   ├── cadastro_service.dart
    │   │   ├── previsao_service.dart
    │   │   └── historico_service.dart
    │   ├── telas/
    │   │   ├── cadastro_page.dart
    │   │   ├── login_page.dart
    │   │   ├── home_page.dart
    │   │   ├── questionario_page.dart
    │   │   ├── resultado_page.dart
    │   │   ├── historico_page.dart
    │   │   └── dashboard_page.dart
    │   └── main.dart
    └── pubspec.yaml
```

> A listagem destaca arquivos relevantes. Pastas geradas pelo Flutter, arquivos de configuração locais e outros arquivos auxiliares foram omitidos.

## API hospedada na Azure

**Endereço-base:** `https://stressscan.southafricanorth.cloudapp.azure.com`

**Documentação interativa (Swagger):** https://stressscan.southafricanorth.cloudapp.azure.com/docs

A aplicação Flutter utiliza esse endereço em `mobile/lib/config/api_config.dart` e envia requisições autenticadas em HTTPS.

| Método | Rota | Função | Token JWT |
| --- | --- | --- | --- |
| `GET` | `/` | Verificação básica da aplicação | Não |
| `GET` | `/modelo` | Informações do modelo | Não |
| `POST` | `/cadastro` | Criação de conta | Não |
| `POST` | `/login` | Autenticação e emissão de token | Não |
| `GET` | `/me` | Identificação do usuário autenticado | Sim |
| `POST` | `/prever` | Classificação e registro da avaliação | Sim |
| `GET` | `/historico` | Histórico individual do estudante | Sim |

O endpoint `/prever` recebe as 17 respostas numéricas e retorna, entre outros campos, `avaliacao_id`, `nivel_estresse` e `classificacao`. O endpoint `/historico` retorna até **50 avaliações mais recentes** do estudante autenticado, em ordem decrescente de data. O filtro usa o identificador obtido do JWT, não um identificador informado pelo cliente na URL.

As senhas são armazenadas com **hash Argon2**. O JWT é emitido no login; na implementação atual do Flutter, ele é mantido **em memória enquanto o aplicativo está em execução** e descartado ao sair da conta ou quando a API responde 401 (token expirado ou inválido), caso em que o app volta para a tela inicial. Não há persistência de sessão entre reinicializações.

## Funcionalidades do aplicativo Flutter

O aplicativo é desenvolvido para execução local, com testes no **Windows Desktop** e comunicação com a API publicada na Azure.

| Tela | Função | Situação |
| --- | --- | --- |
| Boas-vindas | Identidade visual e opções de acesso | Implementada e testada |
| Login | Autenticação por e-mail e senha, com JWT | Implementada e testada com a Azure |
| Home | Navegação para questionário, resultados e histórico | Implementada e testada |
| Questionário | 17 perguntas distribuídas em cinco categorias | Implementada e testada |
| Resultado | Exibe a classificação produzida pela API após o envio | Implementada e testada |
| Meu histórico | Lista avaliações anteriores com data, hora e nível de estresse | Implementada e testada com a Azure |
| Meus resultados | Dashboard com resumo e gráfico das últimas avaliações | Implementado e testado com a Azure |
| Criar conta | Formulário de cadastro (e-mail, senha e confirmação) integrado ao `POST /cadastro` | Implementada e testada com a Azure |

### Dashboard — Meus resultados

O painel utiliza o pacote **`fl_chart`** e reaproveita o `HistoricoService`, que consulta `GET /historico` com o JWT do usuário. O dashboard foi implementado para mostrar:

- **Última avaliação:** classificação mais recente do estudante.
- **Avaliações exibidas:** quantidade de registros retornados na consulta (até 50 na API atual), não necessariamente o total histórico de toda a vida da conta.
- **Gráfico de colunas:** até as **10 avaliações mais recentes**, apresentadas da mais antiga para a mais recente e diferenciadas por cor: baixo (verde), moderado (laranja) e alto (vermelho).
- **Atualização dos dados:** comando para consultar novamente a API; além de mensagens para histórico vazio ou falhas de conexão.

**Interpretação correta:** o modelo retorna classes discretas (`0`, `1`, `2`), não uma escala contínua ou uma pontuação clínica. Para tornar a classe zero visível, as barras usam alturas gráficas `1`, `2` e `3` para baixo, moderado e alto, respectivamente. Esse deslocamento é **apenas visual**, sem alterar as classificações armazenadas. A sequência representa categorias sucessivas; não deve ser interpretada como medida clínica de piora ou melhora.

A tela **Meu histórico** complementa o dashboard com os registros individuais e suas datas; a tela **Resultado** exibe o retorno de uma avaliação recém-concluída.

## Infraestrutura Azure e CI/CD

O projeto possui uma VM na **Microsoft Azure** para executar a API. Os arquivos de infraestrutura adicionados ao repositório estão na pasta [`infra/`](infra/README.md):

- [`deploy.sh`](infra/deploy.sh): script de implantação disponibilizado pela equipe.
- [`stress-scan.nginx.conf`](infra/stress-scan.nginx.conf): configuração do Nginx.
- [`stress-scan.service`](infra/stress-scan.service): definição do serviço da aplicação no Linux.

As orientações operacionais específicas para configurar ou manter a VM devem seguir o arquivo [`infra/README.md`](infra/README.md). Os detalhes internos desses scripts não são reproduzidos aqui.

### CI — validação automática

O workflow [`.github/workflows/api.yml`](.github/workflows/api.yml), denominado **Validar API**, é acionado por:

- Pull requests que alteram `api/**`, `infra/**` ou o próprio workflow;
- Pushes na branch `main` que alteram esses mesmos caminhos;
- Execução manual (`workflow_dispatch`).

O job `validar` utiliza **Ubuntu 24.04** e **Python 3.12** para instalar dependências, executar `pip check`, compilar os arquivos Python e fazer verificações programáticas do carregamento da API, da correspondência entre campos do questionário e atributos do modelo e da execução de uma inferência.

**Atenção:** essas verificações não equivalem a uma suíte completa de testes funcionais, de segurança ou de integração com o banco de dados.

### CD — publicação condicional na VM Azure

O job `publicar` depende do sucesso do job `validar` e só pode executar quando:

1. a execução ocorre na branch `main`;
2. o evento não é um pull request;
3. a variável de repositório `ENABLE_AZURE_DEPLOY` possui o valor `true`.

A publicação utiliza conexão **SSH** com informações configuradas em GitHub Actions:

| Tipo | Nome | Finalidade |
| --- | --- | --- |
| Secret | `AZURE_SSH_PRIVATE_KEY` | Autenticação SSH |
| Secret | `AZURE_SSH_KNOWN_HOSTS` | Verificação da identidade do servidor |
| Variable | `AZURE_HOST` | Endereço da VM |
| Variable | `ENABLE_AZURE_DEPLOY` | Habilita ou desabilita o deploy automático |

O workflow envia à VM o identificador do commit (`github.sha`) e, após a etapa remota, executa uma verificação HTTP do endereço público da aplicação.

**Importante:** apenas fazer `git push` **não garante** a publicação na Azure: os filtros de arquivos, as condições do job, as credenciais, a conectividade e o resultado da execução precisam estar corretos. O status pode ser acompanhado na aba **Actions** do GitHub.

**O workflow atual não faz CI/CD do Flutter:** alterações exclusivas na pasta `mobile/` não acionam automaticamente o workflow da API.

## Como executar o aplicativo Flutter

Pré-requisitos: Flutter SDK configurado e ambiente de compilação disponível para a plataforma escolhida.

No terminal:

```powershell
cd mobile
flutter pub get
flutter run -d windows
```

Para executar os testes automatizados dos serviços:

```powershell
flutter test
```

Para testar no navegador:

```powershell
flutter run -d chrome
```

No Windows Desktop, a aplicação abre em uma janela independente. Como a API está disponível na Azure, **não é necessário iniciar a FastAPI no computador** para utilizar o aplicativo. É necessária conexão de rede com a API e o MongoDB Atlas deve estar acessível ao backend.

> A API habilita **CORS** apenas para origens `localhost` e `127.0.0.1` (qualquer porta), o que permite testar o Flutter Web em desenvolvimento. Para hospedar a versão web em um domínio próprio, essa origem precisa ser adicionada em `api/main.py`.

Para gerar uma versão de distribuição no Windows:

```powershell
flutter build windows --release
```

A distribuição deve incluir os arquivos de suporte gerados junto ao executável, não apenas o `.exe` isolado.

## Como executar a API localmente (desenvolvimento)

Na pasta `api`, crie um ambiente virtual e instale as dependências:

```powershell
cd api
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Configure localmente um arquivo `api/.env` com seus próprios valores:

```dotenv
MONGODB_URI=mongodb+srv://USUARIO:SENHA@HOST/...
MONGODB_DATABASE=stress_scan
JWT_SECRET_KEY=CHAVE_SECRETA_ALEATORIA_E_FORTE
```

Em seguida:

```powershell
.\.venv\Scripts\python.exe -m uvicorn main:app --reload
```

Swagger local: http://127.0.0.1:8000/docs

**Segurança:** não envie arquivos `.env`, credenciais do Atlas, tokens JWT ou chaves SSH para o GitHub. Utilize variáveis de ambiente e GitHub Actions Secrets/Variables conforme necessário.

## Estado atual do desenvolvimento

| Funcionalidade | Situação |
| --- | --- |
| Modelo de Regressão Logística treinado e integrado | Implementado |
| API FastAPI e documentação Swagger | Implementado |
| Cadastro de usuários via API | Implementado |
| Login e validação JWT via API | Implementado |
| Armazenamento e histórico individual no MongoDB Atlas | Implementado no backend |
| API hospedada em VM Azure | Acessível por HTTPS nos testes realizados |
| Workflow de CI e CD condicional | Configurado no repositório; execução de deploy depende das condições |
| Flutter Windows Desktop e tela de boas-vindas | Implementado e testado |
| Interface de login Flutter integrada à Azure | Implementado e testado |
| Home do estudante autenticado | Implementado e testado |
| Questionário Flutter com 17 perguntas | Implementado e testado |
| Envio do questionário e classificação via Azure | Implementado e testado |
| Tela personalizada do resultado | Implementada e testada após a classificação |
| Serviço e tela Flutter de histórico individual | Implementados e testados com a Azure |
| Dashboard com gráfico `fl_chart` | Implementado e testado com a Azure |
| Tela Flutter de cadastro | Implementada e testada com a Azure |
| Logout com confirmação (descarta o token em memória) | Implementado e testado |
| Tratamento de expiração do JWT (volta ao login ao receber 401) | Implementado |
| Testes automatizados dos serviços Flutter (erros HTTP, rede, timeout, 401) | 22 testes (`flutter test`) |
| Verificações de autenticação na API de produção (sem token, token forjado, `alg=none`, CORS externo) | Executadas manualmente; resultado esperado (401/400) |
| Persistência segura de sessão entre reinicializações | Pendente |
| Validação das respostas qualitativas com usuários reais | Pendente |


## Responsabilidade e privacidade

O uso de perguntas relacionadas a ansiedade, tristeza, autoestima e outras experiências pessoais exige cuidado com privacidade. A API atual registra o **resultado, a data e o vínculo com o usuário**, sem armazenar o conteúdo das 17 respostas individuais. O acesso ao histórico é protegido por JWT e filtrado por usuário autenticado.

---

**FATEC Franca — Desenvolvimento de Software Multiplataforma — Projeto Integrador**
