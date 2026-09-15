resource "azurerm_postgresql_flexible_server" "oficina_db" {
  name                   = "oficina-postgres-server"
  resource_group_name    = data.azurerm_resource_group.oficina_rg.name
  location               = data.azurerm_resource_group.oficina_rg.location
  version                = "13"
  administrator_login    = "adminuser"
  administrator_password = var.db_admin_password
  sku_name               = "B_Standard_B1ms"
  zone                   = "1"

  # A Azure nunca devolve a senha administrativa pro Terraform conferir, então
  # depois de um `terraform import` esse campo sempre aparece como "mudança
  # pendente" mesmo sem ter mudado de fato — ignorar evita que um `apply`
  # de rotina troque a senha do banco em produção sem intenção.
  lifecycle {
    ignore_changes = [administrator_password]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  # start_ip = end_ip = 0.0.0.0 é o valor especial que a Azure interpreta
  # como "permitir acesso de qualquer serviço Azure dentro da mesma
  # assinatura/tenant" (AKS, Azure Functions etc.) — não é o mesmo que
  # abrir pra internet. É o que os pods da aplicação (repositório
  # oficina-app) e a Function de autenticação por CPF (repositório
  # oficina-lambda-auth-cpf) usam de fato pra conectar.
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.oficina_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Regra "AllowAll" (0.0.0.0-255.255.255.255, banco acessível de qualquer IP
# da internet) removida — nada no fluxo real do projeto precisa disso,
# nem a aplicação (roda no AKS), nem a Function (Azure), nem migrações
# (rodadas pela própria aplicação via Flyway no startup, dentro do AKS).
# Se precisar conectar de uma máquina local pontualmente (ex: psql direto),
# adicione uma regra temporária escopada só ao seu IP público, e remova
# depois.
