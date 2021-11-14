"default_lease_ttl" = "24h"
"disable_mlock" = "true"
"max_lease_ttl" = "24h"
"backend" "file" {
  "path" = "/vault/file"
}
"api_addr" = "https://0.0.0.0:8200"
"ui" = "true"
"listener" "tcp" {
  "address" = "0.0.0.0:8200"
  "tls_cert_file" = "/vault/config/vault.crt"
  "tls_client_ca_file" = "/vault/config/root.crt"
  "tls_key_file" = "/vault/config/vault.key"
}
"plugin_directory" = "/vault/vault_plugins"
