#!/bin/bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT 

container_name="vault"

docker-compose up & > docker-compose-log.txt

flagStarted=0
while [ $flagStarted == 0 ];
do
    if [ "$( docker container inspect -f '{{.State.Status}}' $container_name )" == "running" ]; 
    then 
        flagStarted=1
        docker exec vault /bin/sh "/vault/initialize-vault.sh" &
        break;
    else 
        echo "sleeping for 2 mins 30 seconds"
        sleep 2m 30s
    fi;
done

# vault login "$(cat /vault/VAULT_TOKEN.TXT)"
# wait 3s
# vault secrets list


wait
