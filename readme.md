# Ethereum MFA wallet using hashicorp vault and vault-ethereum plugin

## Cloning the repo

```
cd /preferred/directory
```

```
git clone https://github.com/rishabhmalik759/mfa-enabled-ethereum-wallet.git
```
```
cd mfa-enabled-ethereum-wallet
```

## Run the installation
```
docker-compose up
```

----
**NOTE**
This installation guide creates a docker image for vault and opens it to the port localhost:8200. Image also creates the initial user to communicate with vault.
----