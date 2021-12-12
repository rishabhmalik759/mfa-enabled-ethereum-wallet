path "sys/plugins/catalog*" {
  capabilities = ["sudo", "create", "read", "update", "delete", "list"]
}
path "sys/auth*" {
  capabilities = ["sudo", "create", "read", "update", "delete", "list"]
}
path "sys/mounts*" {
  capabilities = ["sudo", "create", "read", "update", "delete", "list"]
}
path "sys/policy*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/userpass/users*" {
  capabilities = ["create", "delete", "list"]
}
