
#!/bin/bash

# function initialize {
#   export VAULT_ADDR=https://localhost:8200
#   export VAULT_CACERT=/vault/config/root.crt
#   export VAULT_INIT=$(vault operator init -format=json)
#   if [[ $? -eq 2 ]] ; then
#     echo "Vault initialization failed!"
#     exit 2
#   fi
#   export VAULT_TOKEN=$(echo $VAULT_INIT | jq .root_token | tr -d '"')
#   keybase encrypt $KEYBASE -m $VAULT_TOKEN -o ./"$KEYBASE"_VAULT_TOKEN.txt
#   if [[ $? -eq 2 ]] ; then
#     echo "Keybase encryption failed!"
#     exit 2
#   fi
#   for (( COUNTER=0; COUNTER<5; COUNTER++ ))
#   do
#     key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"$COUNTER"']' | tr -d '"')
#     vault operator unseal $key
#     keybase encrypt $KEYBASE -m $key -o ./"$KEYBASE"_UNSEAL_"$COUNTER".txt
#   done
#   unset VAULT_INIT
# }

# function install_plugin {
#   vault write sys/plugins/catalog/secret/ethereum-plugin \
#         sha_256="$(cat SHA256SUM)" \
#         command="vault-ethereum --ca-cert=./volumes/config/root.crt --client-cert=./volumes/config/vault.crt --client-key=./volumes/config/vault.key"

#   vault write sys/plugins/catalog/secret/ethereum-plugin \
#         sha_256="$(cat SHA256SUM)" \
#         command="vault-ethereum --ca-cert=/vault/config/root.crt --client-cert=/vault/config/vault.crt --client-key=/vault/config/vault.key"

#   if [[ $? -eq 2 ]] ; then
#     echo "Vault Catalog update failed!"
#     exit 2
#   fi

#   vault secrets enable -path=ethereum -plugin-name=ethereum-plugin plugin
#   if [[ $? -eq 2 ]] ; then
#     echo "Failed to mount Ethereum plugin!"
#     exit 2
#   fi
#   rm SHA256SUM
# }

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

gencerts
# # initialize
# install_plugin