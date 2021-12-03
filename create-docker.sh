#!/bin/bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT 

docker-compose up & > docker-compose-log.txt

chmod +x ./initialize-vault.sh

sleep 9m


docker exec vault /bin/sh "/vault/initialize-vault.sh" &

wait
