#!/bin/sh

vault operator unseal $(cat /vault/UNSEAL_0.txt)
vault operator unseal $(cat /vault/UNSEAL_1.txt)
vault operator unseal $(cat /vault/UNSEAL_2.txt)