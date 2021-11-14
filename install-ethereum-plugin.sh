#!/bin/bash
PLUGIN_VERSION="0.0.4"
PLUGIN_OS="linux"
1 = "linux"
2 = "0.0.4"

vault server -config=/vault/config/vault.hcl

function grab_plugin {
  echo "OS: $1"
  echo "Version: $2"

  wget --progress=bar:force -O ./$1.zip https://github.com/immutability-io/vault-ethereum/releases/download/v$2/vault-ethereum_$2_$1_amd64.zip
  wget --progress=bar:force -O ./SHA256SUMS https://github.com/immutability-io/vault-ethereum/releases/download/v$2/SHA256SUMS
  wget --progress=bar:force -O ./SHA256SUMS.sig https://github.com/immutability-io/vault-ethereum/releases/download/v$2/SHA256SUMS.sig
  keybase pgp verify -d ./SHA256SUMS.sig -i ./SHA256SUMS
  if [[ $? -eq 2 ]] ; then
    echo "Plugin Validation Failed: Signature doesn't verify!"
    exit 2
  fi
  rm ./SHA256SUMS.sig
  rm ./SHA256SUMS
}

function move_plugin {
  echo "OS: $1"
  unzip ./$1.zip
  rm ./$1.zip
  go build github.com/immutability-io/vault-ethereum
  mv /root/go/bin/vault-ethereum ./volumes/vault_plugins/vault-ethereum
}


function initialize {
  export VAULT_ADDR=https://localhost:8200
  export VAULT_CACERT=./volumes/config/root.crt
  export VAULT_INIT=$(vault operator init -format=json)
  if [[ $? -eq 2 ]] ; then
    echo "Vault initialization failed!"
    exit 2
  fi
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq .root_token | tr -d '"')
  keybase encrypt $KEYBASE -m $VAULT_TOKEN -o ./"$KEYBASE"_VAULT_TOKEN.txt
  if [[ $? -eq 2 ]] ; then
    echo "Keybase encryption failed!"
    exit 2
  fi
  for (( COUNTER=0; COUNTER<5; COUNTER++ ))
  do
    key=$(echo $VAULT_INIT | jq '.unseal_keys_hex['"$COUNTER"']' | tr -d '"')
    vault operator unseal $key
    keybase encrypt $KEYBASE -m $key -o ./"$KEYBASE"_UNSEAL_"$COUNTER".txt
  done
  unset VAULT_INIT
}

function install_plugin {
  vault write sys/plugins/catalog/secret/ethereum-plugin \
        sha_256="941ad5a1481b341fa17adac7cc58943f315b7921f1b183a0747981a254c67df1" \
        command="vault-ethereum --ca-cert=./volumes/config/root.crt --client-cert=./volumes/config/vault.crt --client-key=./volumes/config/vault.key"

  vault write sys/plugins/catalog/secret/ethereum-plugin \
        sha_256="941ad5a1481b341fa17adac7cc58943f315b7921f1b183a0747981a254c67df1" \
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
  rm SHA256SUM
}

touch "./.${shell_profile}"
{
    echo '# Vault'
    echo 'export VAULT_ADDR=https://localhost:8200'
    echo 'export VAULT_CACERT=./volumes/config/root.crt'
} >> "./.${shell_profile}"

# grab_plugin $PLUGIN_OS $PLUGIN_VERSION
# move_plugin $PLUGIN_OS
install_plugin


echo -e "./.${shell_profile} has been modified."
echo -e "============================================="
echo -e "The following were set in your shell profile:"
echo -e "export VAULT_ADDR=$VAULT_ADDR"
echo -e "export VAULT_CACERT=$VAULT_CACERT"
echo -e "You need to source your shell profile or export these for them to take effect."
echo -e "============================================="
echo -e "Your root token is below. You need to export this to be authenticated (as root):"
echo -e "export VAULT_TOKEN=$(keybase decrypt -i $KEYBASE""_VAULT_TOKEN.txt)" 
echo -e "The root token is NOT set in your shell profile!"
echo -e "============================================="
echo -e "You will need to execute this to authenticate as root in the future:"
echo 'export VAULT_TOKEN=$(keybase decrypt -i '$KEYBASE'_VAULT_TOKEN.txt)'

echo -e "=============================================\n"
echo -e "Please read README.md for your next steps.\n"