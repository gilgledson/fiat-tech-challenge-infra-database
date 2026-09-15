variable "db_admin_password" {
  description = "Senha do administrador do Azure Database for PostgreSQL Flexible Server. Nunca definir um valor aqui — fornecer via TF_VAR_db_admin_password ou um arquivo *.tfvars (gitignored). Precisa ser a mesma senha usada pelos repositórios oficina-app e oficina-lambda-auth-cpf para se conectar ao banco."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_admin_password) >= 12
    error_message = "A senha do banco deve ter pelo menos 12 caracteres."
  }
}
