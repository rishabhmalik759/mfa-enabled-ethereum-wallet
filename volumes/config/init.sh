#!/bin/bash

OPERATOR_JSON="/vault/config/operator.json"
OPERATOR_SECRETS=$(cat $OPERATOR_JSON)
UNSEAL_SCRIPT="/vault/scripts/main/unseal-vault.sh"
CREATE_INITIAL_USERS_SCRIPT="/vault/scripts/main/create-initial-users.sh"
DEMO_SCRIPT="/vault/scripts/main/demo.sh"

function banner() {
  echo "+----------------------------------------------------------------------------------+"
  printf "| %-80s |\n" "`date`"
  echo "|                                                                                  |"
  printf "| %-80s |\n" "$@"
  echo "+----------------------------------------------------------------------------------+"
}

function authenticate() {
    banner "Authenticating to $VAULT_ADDR as root"
    # ROOT=$(echo $OPERATOR_SECRETS | jq -r .root_token)
    export VAULT_TOKEN=$(cat /vault/VAULT_TOKEN.TXT)
}

function unauthenticate() {
    banner "Unsetting VAULT_TOKEN"
    unset VAULT_TOKEN
}

function unseal() {
    if [ -f "$UNSEAL_SCRIPT" ]; then
        /bin/bash $UNSEAL_SCRIPT
    fi
    banner "Unsealing $VAULT_ADDR..."
}

function configure() {
    # Copying SHA256 to a file
    echo $SHASUM256_eth > /vault/SHASUM256_eth

    banner "Installing vault-ethereum plugin at $VAULT_ADDR..."
	SHA256SUMS=`cat /vault/SHASUM256_eth | awk '{print $1}'`
	vault write sys/plugins/catalog/secret/vault-ethereum \
		  sha_256="$SHA256SUMS" \
		  command="vault-ethereum --ca-cert=$CA_CERT --client-cert=$TLS_CERT --client-key=$TLS_KEY"

	if [[ $? -eq 2 ]] ; then
	  echo "vault-ethereum couldn't be written to the catalog!"
	  exit 2
	fi

	vault secrets enable -path=vault-ethereum -plugin-name=vault-ethereum plugin
	if [[ $? -eq 2 ]] ; then
	  echo "vault-ethereum couldn't be enabled!"
	  exit 2
	fi
    vault audit enable file file_path=stdout
}

function status() {
    vault status
}

function runDemoScript() {
    if [ -f "$DEMO_SCRIPT" ]; then
        /bin/bash $DEMO_SCRIPT
    fi
    banner "Running demo script generating log at /vault/logs/demo_logs.txt"
}

function createInitialUsers() {
    if [ -f "$CREATE_INITIAL_USERS_SCRIPT" ]; then
        /bin/bash $CREATE_INITIAL_USERS_SCRIPT
    fi
    banner "Creating initial users at $VAULT_ADDR..."
}

function init() {
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

# Preparing plugin to install
cp /vault/vault-ethereum/vault-ethereum /vault/plugins/

# Creating SHASUM256 for ethereum plugin
SHASUM256_eth=$(sha256sum "/vault/plugins/vault-ethereum" | cut -d' ' -f1)


if [ -f "$OPERATOR_JSON" ]; then
    unseal
    status
else
    init
    # unseal
    authenticate
    configure
    createInitialUsers
    runDemoScript
    unauthenticate
    status
fi