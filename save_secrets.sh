#!/bin/bash

printf "DOCKER_API_VERSION=$DOCKER_API_VERSION\n" >> /set_env_vars.sh
printf "PROJECT_ID=$PROJECT_ID\n" >> /set_env_vars.sh
# zone
# app name? deployment name etc
# this should be a yml file in the future...
printf "CONTAINER_REGISTRY_SA='$CONTAINER_REGISTRY_SA'\n" >> /set_env_vars.sh
printf "GKE_SA='$GKE_SA'\n" >> /set_env_vars.sh
chmod +x /set_env_vars.sh

/usr/sbin/sshd -D
