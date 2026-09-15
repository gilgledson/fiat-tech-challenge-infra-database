# oficina-infra-banco-dados

Infraestrutura como código (Terraform) do banco de dados gerenciado —
Azure Database for PostgreSQL Flexible Server. Um dos 4 repositórios do
Tech Challenge Fase 3 — ver os outros:

- [oficina-app](https://github.com/SEU_USUARIO/oficina-app) — aplicação principal, consome este banco
- [oficina-infra-kubernetes](https://github.com/SEU_USUARIO/oficina-infra-kubernetes) — dono do Resource Group + cluster AKS
- [oficina-lambda-auth-cpf](https://github.com/SEU_USUARIO/oficina-lambda-auth-cpf) — Function Serverless, também consome este banco

> Atualize os links acima com as URLs reais assim que os repositórios forem
> criados no GitHub.

## Propósito

Provisiona o **Postgres Flexible Server** (`oficina-postgres-server`) usado
tanto pela aplicação principal (`oficina-app`) quanto pela Function de
autenticação por CPF (`oficina-lambda-auth-cpf`) — o mesmo banco, duas
formas de acesso independentes (ver
[RFC-003](https://github.com/SEU_USUARIO/oficina-app/blob/main/docs/architecture/rfc-003-estrategia-de-autenticacao.md)
no repositório da aplicação principal).

Depende do Resource Group já existir (repositório
`oficina-infra-kubernetes` aplicado primeiro) — lido aqui via `data
source`, nunca recriado.

## Justificativa da escolha (PostgreSQL)

Ver a
[justificativa formal completa](https://github.com/SEU_USUARIO/oficina-app/blob/main/docs/architecture/justificativa-banco-de-dados.md)
e o [RFC-002](https://github.com/SEU_USUARIO/oficina-app/blob/main/docs/architecture/rfc-002-escolha-do-banco-de-dados.md)
no repositório `oficina-app` — inclui o Diagrama ER completo (11 tabelas,
14 relacionamentos) e a análise de alternativas (MySQL, SQL Server, NoSQL).

## Tecnologias

- Terraform (`provider "azurerm"`)
- Azure Database for PostgreSQL Flexible Server (versão 13, SKU `B_Standard_B1ms`)

## Como aplicar

```bash
cd infra
terraform init
export TF_VAR_db_admin_password="uma-senha-forte-aqui"   # mínimo 12 caracteres
terraform plan
terraform apply
```

> A senha definida aqui precisa ser a **mesma** configurada como
> `DB_PASSWORD`/`DB_APP_PASSWORD` nos repositórios `oficina-app` e
> `oficina-lambda-auth-cpf` — são o mesmo banco, credenciais
> dessincronizadas já causaram falhas reais durante o desenvolvimento deste
> projeto (ver histórico de ADRs no repositório `oficina-app`).

Para destruir (evitar custo quando não estiver em uso):

```bash
terraform destroy
```

## ⚠️ Nota de segurança conhecida

A regra de firewall `allow_all` libera `0.0.0.0`–`255.255.255.255` — o
banco fica acessível publicamente de qualquer IP. Isso existe desde a
Fase 2 e não foi corrigido nesta fase (ver `TODO.md` do repositório
`oficina-app`, seção "Achado à parte"). Recomendação para evolução futura:
restringir a `AllowAzureServices` + os IPs de saída conhecidos do AKS.

## Por que o `terraform apply` é manual (não roda em CI)

Mesma decisão adotada nos outros repositórios de infraestrutura deste
projeto: o `terraform plan` roda automaticamente em todo Pull Request (ver
[`.github/workflows/ci.yml`](.github/workflows/ci.yml)), mas alterar um
banco de dados gerenciado automaticamente a cada merge é um risco
desproporcional para este projeto — aplicado manualmente, com revisão do
`plan` antes.

## Custos

O Postgres Flexible Server fica **ligado 24/7** e cobra por tempo,
independente de uso. `terraform destroy` quando não estiver trabalhando
ativamente no projeto.
