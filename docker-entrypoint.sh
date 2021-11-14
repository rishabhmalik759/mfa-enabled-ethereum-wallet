 #!/bin/bash
 

cd /vault
git clone https://github.com/immutability-io/vault-ethereum.git 
cd ./vault-ethereum 
go build 
ls -l 
# mv ./vault-ethereum/vault-ethereum /vault_plugins/vault-ethereum 
# rm -r ./vault-ethereum 
# export SHASUM256_eth=$(sha256sum "/vault/vault_plugins/vault-ethereum" | cut -d' ' -f1) 

vault server -config=/vault/config/vault.hcl
