#!/usr/bin/env bash
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  mv $TRAVIS_BUILD_DIR ~/.yadr
else
  local DOCKER_COMPOSE_VERSION=1.11.2
  sudo rm /usr/local/bin/docker-compose
  curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
  chmod +x docker-compose
  sudo mv docker-compose /usr/local/bin
fi
