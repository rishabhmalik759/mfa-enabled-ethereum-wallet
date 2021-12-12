path "ethereum/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/userpass/users/bob/password" {
  capabilities = ["update"]
}