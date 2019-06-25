#!/bin/sh

set -x

function stop_docker() {
  docker kill container-jfr
}

stop_docker

set -e

trap stop_docker EXIT

docker run \
  -d --rm \
  --name container-jfr \
  --hostname container-jfr \
  --mount source="container-jfr",target=/flightrecordings \
  -p 9090:9090 -p 9091:9091 -p 80:8080 \
  -e CONTAINER_JFR_DOWNLOAD_HOST=localhost \
  -e CONTAINER_JFR_DOWNLOAD_PORT=8080 \
  quay.io/rh-jmc-team/container-jfr

if [ -z "$GRAFANA_DATASOURCE_URL" ]; then
  export GRAFANA_DATASOURCE_URL="http://$(hostname -I | cut -d' ' -f1)"
fi

if [ -z "$GRAFANA_DASHBOARD_URL" ]; then
  export GRAFANA_DASHBOARD_URL="http://example.com"
fi

if [ -z "$CONTAINER_JFR_URL" ]; then
  export CONTAINER_JFR_URL="ws://localhost:9090/command"
fi

node mockapi.server.js