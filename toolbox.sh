#!/usr/bin/env bash

cd $(dirname $0)

PHP_CONTAINER_ID=$(docker ps --format '{{.ID}}\t{{.Names}}' | grep rg_php | cut -f1)

function docker_up() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -p $VOLUME_DIR -f docker-compose.yml up $@
}

function docker_shutdown() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -p $VOLUME_DIR -f docker-compose.yml down $@
}

function ssh() {
  if [ -z $1 ]; then
    docker exec -ti $PHP_CONTAINER_ID /bin/bash
  else
    # search container
    CONTAINER=$(docker ps --format 'table {{.Names}}' | grep $1 | tr -d ' ')
    if [ -e $CONTAINER ]; then
      echo "Container '$1' is not running!. Please select container from this list:"
      docker ps
    else
      docker exec -ti $CONTAINER /bin/bash
    fi
  fi
}

case "$1" in
up)
  shift
  docker_up $@
  exit
  ;;
down)
  shift
  docker_shutdown $@
  exit
  ;;
ssh)
  ssh $2
  exit
  ;;
esac