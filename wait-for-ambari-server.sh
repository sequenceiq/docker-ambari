#!/bin/bash

: ${AMBARI_SERVER_NAME:=amb0}
: ${SLEEP_TIME:=2}
: ${DEBUG:=1}

debug() {
  [ $DEBUG -gt 0 ] && echo [DEBUG] "$@"
}

wait-for-grep-command() {
  local STR_TO_GREP=$1
  shift
  local CMD="$@"
  #debug [WAIT] CMD=$CMD STR_TO_GREP=$STR_TO_GREP
  while ! ($CMD|grep $STR_TO_GREP) &> /dev/null ;do
    echo -n .
    sleep $SLEEP_TIME
  done
  debug [DONE]
}

wait-for-container-ip() {
  AMBARI_HOST=$(docker inspect --format "{{.NetworkSettings.IPAddress}}" $AMBARI_SERVER_NAME)
  debug [OK] AMBARI_HOST=${AMBARI_HOST:?"coudn't get ip of container: $AMBARI_SERVER_NAME"}
}

wait-for-postgres() {
  debug wait for postgresql starting up in $AMBARI_SERVER_NAME
  wait-for-grep-command "postgres" "docker top $AMBARI_SERVER_NAME"
}

wait-for-ambari-agent() {
  debug wait for ambari_agent python procces is up in $AMBARI_SERVER_NAME
  wait-for-grep-command "ambari_agent" "docker top $AMBARI_SERVER_NAME"
}

wait-for-ambari-server() {
  debug wait for ambar-server java process is up in $AMBARI_SERVER_NAME
  wait-for-grep-command "org.apache.ambari.server.controller.AmbariServer" "docker top $AMBARI_SERVER_NAME"
}

wait-for-running-state() {
  CHECK_URL="$AMBARI_HOST:8080/api/v1/check"

  debug wait for ambari server RUNNIN state at $CHECK_URL
  wait-for-grep-command RUNNING "curl -s -u admin:admin $CHECK_URL"
}

wait-for-running-state() {
  CHECK_URL="$AMBARI_HOST:8080/api/v1/check"

  debug wait for ambari server RUNNIN state at $CHECK_URL
  wait-for-grep-command RUNNING "curl -s -u admin:admin $CHECK_URL"
}

wait-for-self-connected-agent() {
  debug wait for self connected ambari-agent
  wait-for-grep-command $AMBARI_HOST "curl -s -u admin:admin $AMBARI_HOST:8080/api/v1/hosts"
}

alias r='docker-kill-all ;docker run -d -P -h amb0.mycorp.kom -e KEYCHAIN=$KEYCHAIN --name amb0  sequenceiq/ambari --tag ambari-role=server,agent'

wait-for-container-ip
wait-for-postgres
wait-for-ambari-agent
wait-for-ambari-server
wait-for-running-state
wait-for-self-connected-agent
