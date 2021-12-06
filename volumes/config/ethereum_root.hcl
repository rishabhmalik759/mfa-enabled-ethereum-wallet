path "ethereum*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/userpass/users/admin/password" {
  capabilities = ["update"]
}