output "postgres_server_name" {
  description = "Nome do Postgres Flexible Server — usado pelos outros repositórios para localizar o banco via data source."
  value       = azurerm_postgresql_flexible_server.oficina_db.name
}

output "postgres_fqdn" {
  description = "FQDN do Postgres Flexible Server."
  value       = azurerm_postgresql_flexible_server.oficina_db.fqdn
}

output "billing_database_name" {
  description = "Nome do database do Billing Service no Postgres Flexible Server."
  value       = azurerm_postgresql_flexible_server_database.billing.name
}
