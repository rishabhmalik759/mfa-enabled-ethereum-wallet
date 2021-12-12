default_lease_ttl = "24h"
disable_mlock = "true"
max_lease_ttl = "43800h"

backend "file" {
path = "/vault/file"
}

api_addr = "https://localhost:9200"
ui = "true"

plugin_directory = "/vault/plugins"
listener "tcp" {
address = "0.0.0.0:9200"
tls_cert_file = "/vault/certs/vault.crt"
tls_client_ca_file = "/vault/certs/root.crt"
tls_key_file = "/vault/certs/vault.key"
}