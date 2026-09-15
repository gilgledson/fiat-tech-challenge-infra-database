resource "azurerm_postgresql_flexible_server" "oficina_db" {
  name                   = "oficina-postgres-server"
  resource_group_name    = data.azurerm_resource_group.oficina_rg.name
  location               = data.azurerm_resource_group.oficina_rg.location
  version                = "13"
  administrator_login    = "adminuser"
  administrator_password = var.db_admin_password
  sku_name               = "B_Standard_B1ms"
  zone                   = "1"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.oficina_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.oficina_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
