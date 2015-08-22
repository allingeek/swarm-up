#!/bin/bash

if [ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]; then echo "DIGITALOCEAN_ACCESS_TOKEN is unset"; exit; fi

# getopts

export DIGITALOCEAN_SIZE=1gb
export DIGITALOCEAN_REGION=sfo1

# Make sure the swarm image is installed locally
docker pull swarm

# Run a local container to register a new swarm cluster ID
SWARM_TOKEN=`docker run swarm create`
echo "Creating new swarm with ID: $SWARM_TOKEN"

echo 'Creating swarm-master...'
docker-machine create \
	-d digitalocean \
        --swarm \
	--swarm-master \
        --swarm-strategy "binpack" \
	--swarm-discovery token://$SWARM_TOKEN \
	gb-swarm-master

eval $(docker-machine env gb-swarm-master)
docker stop swarm-agent

echo 'Creating swarm-node01...'
docker-machine create \
	-d digitalocean \
	--swarm \
	--swarm-discovery token://$SWARM_TOKEN \
	gb-swarm-node01

echo 'Creating swarm-node02...'
docker-machine create \
	-d digitalocean \
	--swarm \
	--swarm-discovery token://$SWARM_TOKEN \
	gb-swarm-node02

echo 'Creating swarm-node03...'
docker-machine create \
	-d digitalocean \
	--swarm \
	--swarm-discovery token://$SWARM_TOKEN \
	gb-swarm-node03
