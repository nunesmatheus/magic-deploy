#!/bin/bash

printf "PROJECT_ID=$PROJECT_ID\n" >> /set_env_vars.sh
printf "DOCKER_API_VERSION=$DOCKER_API_VERSION\n" >> /set_env_vars.sh
printf "CONTAINER_REGISTRY_SA='$CONTAINER_REGISTRY_SA'\n" >> /set_env_vars.sh
printf "CLUSTER='$CLUSTER'\n" >> /set_env_vars.sh
printf "ZONE='$ZONE'\n" >> /set_env_vars.sh
echo $GKE_SA > /gke_sa.json

/usr/sbin/sshd -D
