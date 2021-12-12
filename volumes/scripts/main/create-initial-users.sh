#!/bin/sh

admin_policy=/vault/scripts/hcl/admin_policy.hcl
ethereum_policy=/vault/scripts/hcl/ethereum_root.hcl

# Logging in to vault with root token
vault login $(cat /vault/VAULT_TOKEN.TXT)

# Enabling Userpass authentication
vault auth enable userpass

# Adding admin policy to vault
vault policy write admin-policy $admin_policy

# Creating admin user with admin policy
vault write auth/userpass/users/admin \
    policies=admin-policy \
    ttl=10m \
    max_ttl=60m \
    password="long-password";


# Adding ethereum policy to ethereum
vault policy write ethereum $ethereum_policy

# Creating ethereum user bob with ethereum-policy
vault write auth/userpass/users/bob \
    policies=ethereum \
    ttl=10m \
    max_ttl=60m \
    password="long-password"; 