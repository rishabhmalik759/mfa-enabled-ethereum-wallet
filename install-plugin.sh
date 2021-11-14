 #!/bin/bash

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

PLUGIN_VERSION="0.0.4"
PLUGIN_OS="linux"
1 = "linux"
2 = "0.0.4"