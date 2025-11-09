#!/bin/bash

    sudo apt install -y docker docker-compose-v2

if [ ! -d "/opt" ] ; then
    sudo git clone https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02
else
    cd /opt
    sudo git pull
fi

pwd

sudo docker compose -f compose.yaml up
