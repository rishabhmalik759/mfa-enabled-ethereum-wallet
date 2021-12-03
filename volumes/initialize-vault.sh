#!/bin/sh

export VAULT_SKIP_VERIFY='true'

function initialize {
  echo "Initializing server"
  vault operator init -status
  if [[ $? -eq 0 ]] ; then
    echo "Vault already initialized"
    exit 2
  fi

  export VAULT_INIT=$(vault operator init -format=json)
  if [[ $? -eq 2 ]] ; then
    echo "Vault initialization failed!"
    exit 2
  fi
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq .root_token | tr -d '"')
  echo $VAULT_TOKEN > /vault/VAULT_TOKEN.TXT
  if [[ $? -eq 2 ]] ; then
    echo "TOKEN SAVING FAILED!"
    exit 2
  fi

  key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"0"']' | tr -d '"')
  vault operator unseal $key
  echo $key > /vault/UNSEAL_"0".txt

  key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"1"']' | tr -d '"')
  vault operator unseal $key
  echo $key > /vault/UNSEAL_"1".txt

  key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"2"']' | tr -d '"')
  vault operator unseal $key
  echo $key > /vault/UNSEAL_"2".txt

  key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"3"']' | tr -d '"')
  vault operator unseal $key
  echo $key > /vault/UNSEAL_"3".txt

  key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"4"']' | tr -d '"')
  vault operator unseal $key
  echo $key > /vault/UNSEAL_"4".txt
  unset VAULT_INIT
}

function install_plugin {
  vault write sys/plugins/catalog/secret/ethereum-plugin \
        sha_256="$(cat /vault/SHASUM256_eth)" \
        command="vault-ethereum --ca-cert=/vault/config/root.crt --client-cert=/vault/config/vault.crt --client-key=/vault/config/vault.key"

  if [[ $? -eq 2 ]] ; then
    echo "Vault Catalog update failed!"
    exit 2
  fi

  vault secrets enable -path=ethereum -plugin-name=ethereum-plugin plugin
  if [[ $? -eq 2 ]] ; then
    echo "Failed to mount Ethereum plugin!"
    exit 2
  fi
  rm /vault/SHASUM256_eth
}

function gencerts {

  openssl req -subj '/O=My Company Name LTD./C=US/CN=localhost' -new -newkey  rsa:4096 -sha256 -days 3650 -x509 -nodes -keyout root.key -out root.crt
  openssl req -subj '/O=My Company Name LTD./C=US/CN=localhost' -new -newkey rsa:4096 -sha256 -nodes -out vault.csr -keyout vault.key
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
  mv *.crt /vault/config
  mv *.key /vault/config
  rm certindex
  rm serialfile
  rm serialfile.*
  rm vault.cnf
  rm vault.csr
  rm *.pem
  rm certindex.*
}

gencerts > ./gencerts-log.txt

echo "Generated certs"

initialize > ./initialize-log.txt

echo "Initialized Vault"

install_plugin > ./install-plugin-log.txt

echo "Installed ethereum plugin"
