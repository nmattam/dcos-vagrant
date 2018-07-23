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
# Should have landed traefik as an app, but...
dcos package install traefik --yes

sleep 30
dcos marathon app add my-dcos-apps/hello-mesos.json
dcos marathon app add my-dcos-apps/hello-nmattam.json

# Open traefik dashboard
open http://192.168.65.60:8080/dashboard/status

sleep 15

# Generate some traffic
# 200
curl -s -H Host:hello-mesos.marathon.localhost >/dev/null http://192.168.65.60
curl -s -H Host:hello-nmattam.marathon.localhost >/dev/null http://192.168.65.60
# 404
curl -s -H Host:hello-nmattam.marathon.localhost >/dev/null http://192.168.65.60/404
