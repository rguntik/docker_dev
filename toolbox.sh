#!/usr/bin/env bash

cd $(dirname $0)
export CURRENT_UID=$(id -u):$(id -g)

PHP_CONTAINER_ID=$(docker ps --format '{{.ID}}\t{{.Names}}' | grep rg_php | cut -f1)

function docker_up() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -f docker-compose.yml up $@
}

function docker_shutdown() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -f docker-compose.yml down $@
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

function npm() {
    docker build -t tmp_ui_npm:latest - << EOF
FROM alpine

RUN apk update
RUN apk add nodejs-npm
RUN mkdir /.npm /.config && chown -R $CURRENT_UID /.npm /.config
USER $CURRENT_UID
WORKDIR /www
CMD npm $@
EOF
    docker run -v "$VOLUME_DIR:/www" -it tmp_ui_npm:latest
    docker image rm -f tmp_ui_npm:latest
}

function show_help() {
    printf "
Usage:
$ ./toolbox.sh COMMAND [COMMAND_ARGS...]

commands:
* ssh
* up
* down
* npm
"
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
npm)
  shift
  npm $@
  exit
  ;;
esac

show_help
