"default_lease_ttl" = "24h"
"disable_mlock" = "true"
"max_lease_ttl" = "24h"
"backend" "file" {
  "path" = "/vault/file"
}
"api_addr" = "http://0.0.0.0:8200"
"ui" = "true"
"listener" "tcp" {
  "address" = "0.0.0.0:8200"
  "tls_disable" = "1"
}
"plugin_directory" = "/vault/plugins"
