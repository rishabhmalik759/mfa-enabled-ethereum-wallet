#!/bin/bash

CONFIG_DIR="/vault/config"
INIT_SCRIPT="/vault/config/init.sh"
CA_CERT="/vault/certs/root.crt"
CA_KEY="/vault/certs/root.key"
TLS_KEY="/vault/certs/vault.key"
TLS_CERT="/vault/certs/vault.crt"
# CSR="/vault/config/vault.csr"

# export VAULT_ADDR="https://127.0.0.1:9200"
# export VAULT_CACERT="$CA_CERT"


function gencerts {

  openssl req -subj '/O=Czech Technical University/C=CZ/CN=localhost' -new -newkey  rsa:4096 -sha256 -days 3650 -x509 -nodes -keyout root.key -out root.crt
  openssl req -subj '/O=Czech Technical University/C=CZ/CN=localhost' -new -newkey rsa:4096 -sha256 -nodes -out vault.csr -keyout vault.key
  echo 000a > serialfile
  touch certindex

cat << EOF > ./vault.cnf
[ ca ]
default_ca = myca
[ myca ]
new_certs_dir = .
unique_subject = no
certificate = ./root.crt
database = ./certindex
private_key = ./root.key
serial = ./serialfile
default_days = 365
default_md = sha256
policy = myca_policy
x509_extensions = myca_extensions
copy_extensions = copy
[ myca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = supplied
emailAddress = optional
organizationName = supplied
organizationalUnitName = optional
[ myca_extensions ]
basicConstraints = CA:false
subjectKeyIdentifier = hash
subjectAltName = @alt_names
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

  openssl ca -batch -config vault.cnf -notext -in vault.csr -out vault.crt
  mv *.crt /vault/certs
  mv *.key /vault/certs
  rm certindex
  rm serialfile
  rm serialfile.*
  rm vault.cnf
  rm vault.csr
  rm *.pem
  rm certindex.*
}

gencerts

nohup vault server -log-level=debug -config /vault/config/vault.hcl &
VAULT_PID=$!

which bash

if [ -f "$INIT_SCRIPT" ]; then
    /bin/bash $INIT_SCRIPT
fi

wait $VAULT_PID