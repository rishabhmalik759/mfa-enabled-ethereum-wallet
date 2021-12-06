#!/bin/sh

vault login $(cat /vault/VAULT_TOKEN.TXT)

# Enabling Userpass authentication
vault auth enable userpass

# Creating admin user
vault policy write admin-policy /vault/config/admin_policy.hcl

vault write auth/userpass/users/admin \
    policies=admin-policy \
    ttl=10m \
    max_ttl=60m \
    password="long-password";


# Creating ethereum user
vault policy write ethereum /vault/config/ethereum_root.hcl

vault write auth/userpass/users/bob \
    policies=ethereum \
    ttl=10m \
    max_ttl=60m \
    password="long-password"; 