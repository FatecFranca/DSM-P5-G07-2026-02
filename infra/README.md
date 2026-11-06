# Hospedagem — Stress Scan

## Endereços

- API: https://stressscan.southafricanorth.cloudapp.azure.com
- Documentação: https://stressscan.southafricanorth.cloudapp.azure.com/docs

No Flutter, usar o endereço da API como URL base, sem /docs.

## Arquitetura

Flutter → HTTPS/Nginx → FastAPI e modelo → MongoDB Atlas.

- VM Azure com Ubuntu 24.04.
- Uvicorn escutando somente em 127.0.0.1:8000.
- Serviço systemd: stress-scan, habilitado na inicialização.
- Nginx encaminhando as requisições para a API.
- Certificado Let's Encrypt gerenciado pelo Certbot.
- Renovação automática configurada e simulação de renovação concluída.
- IP público da VM autorizado no MongoDB Atlas.
- Credenciais mantidas somente em api/.env, com permissão 600.

## Arquivos

- stress-scan.service: configuração do serviço.
- stress-scan.nginx.conf: configuração do Nginx após ativar HTTPS.

A configuração HTTPS referencia certificados existentes na VM.
Para reproduzir em outra máquina, emitir novos certificados com o Certbot.
As chaves e o arquivo .env não devem ser versionados.

## Operação

Verificar serviço:

    sudo systemctl status stress-scan --no-pager

Consultar logs:

    sudo journalctl -u stress-scan -n 50 --no-pager

Reiniciar API:

    sudo systemctl restart stress-scan

Testar renovação do certificado:

    sudo certbot renew --dry-run

## Concluído

- Integração contínua da API (validação, testes automatizados com pytest) e
  do Flutter (análise estática e testes).
- Publicação contínua na VM a partir da main.
- Aplicativo Flutter integrado à API por HTTPS.

## Verificações realizadas

Cadastro, login, autenticação, classificação com dados fictícios e
recuperação da avaliação no histórico foram testados na VM.
O login também foi testado pelo endereço público HTTPS sem túnel SSH.

Esses testes verificam a integração técnica, não a qualidade do modelo.

## Pendências

- Definir e implementar a estratégia de escala automática.
- Implementar rollback automático do deploy.
- Limitar a taxa de requisições em /login e /cadastro (Nginx).
- Configurar monitoramento e alertas.

## Publicação automática

O workflow valida a API antes de publicar alterações da main.
Pull requests executam apenas a validação.

Configuração no GitHub Actions:

- Secret AZURE_SSH_PRIVATE_KEY: chave exclusiva da publicação.
- Secret AZURE_SSH_KNOWN_HOSTS: identidade SSH conferida na própria VM.
- Variable AZURE_HOST: nome DNS público da VM.
- Variable ENABLE_AZURE_DEPLOY: true para ativar a publicação.

O script infra/deploy.sh foi instalado na VM em:
 /home/nathan/.local/bin/stress-scan-deploy

A chave SSH usa comando obrigatório e restrições de encaminhamento.
O sudo permite reiniciar o serviço stress-scan sem senha.
O script preserva o .env, recusa alterações locais e verifica se o
commit pertence à main. A cópia da VM fica no SHA publicado.

Há breve interrupção durante o reinício. Não há rollback automático.
O deploy ainda não implementa escala automática.
