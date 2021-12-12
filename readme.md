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

## Make create-docker.sh executable
```
chmod +x create-docker.sh
```

## Run the installation
```
./create-docker.sh
```

----
**NOTE**
This installation guide creates a docker image for vault and opens it to the port localhost:8200. Image also creates the initial user to communicate with vault.
----