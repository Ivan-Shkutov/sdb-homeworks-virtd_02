#!/bin/bash
set -x

mkdir -p /opt/; cd /opt/

git clone https://github.com/dR4KoN87/shvirtd-example-python.git

cd shvirtd-example-python
docker compose up -d
