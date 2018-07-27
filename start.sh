#!/bin/bash
# install vagrant and brew before running this script.
# Vagrant up will prompt your password because it has to modify your /etc/hosts
# 192.168.65.60 is public agent IP
cp VagrantConfig-1m-1a-1p.yaml VagrantConfig.yaml
vagrant up

brew install jq
bash ci/dcos-install-cli.sh

dcos marathon app list >/dev/null
if [[ $? != 0 ]]
then
  echo "Follow the instructions printed below for authentication."
  dcos auth login
fi

open http://m1.dcos/\#/services/overview/

dcos marathon app add my-dcos-apps/hello-mesos.json
dcos marathon app add my-dcos-apps/hello-nmattam.json
sleep 15

dcos marathon app add my-dcos-apps/traefik.json

sleep 45

# Open traefik dashboard
open http://192.168.65.60:8080/dashboard/status

# Generate some traffic
# 200
curl -s -H Host:hello.marathon.localhost >/dev/null http://192.168.65.60
curl -s -H Host:hello-nmattam.marathon.localhost >/dev/null http://192.168.65.60
# 404
curl -s -H Host:hello-nmattam.marathon.localhost >/dev/null http://192.168.65.60/404
