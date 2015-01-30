#!/bin/bash

: ${LOGFILE:=/tmp/consul_handler.log}
: ${BRIDGE_IP:=127.0.0.1}
: ${CONSUL_HTTP_PORT:=8500}

debug(){
  [[ "$DEBUG" ]] && echo "[DEBUG] $*" >> $LOGFILE
}

get_field() {
  declare json="$1"
  declare field="$2"

  echo "$json"|jq ".$field" -r
}

process_json() {
  while read json; do
    debug $json

    event=$(get_field $json Name)
    id=$(get_field $json ID)
    payload=$(get_field $json Payload)
    ltime=$(get_field $json LTime)
    version=$(get_field $json Version)

    curl -X PUT -d 'ACCEPTED' "http://$BRIDGE_IP:$CONSUL_HTTP_PORT/v1/kv/events/$id/$(hostname -f)"

    PAYLOAD=$(echo "$payload" | base64 -d) \
    EVENT_ID=$id \
    EVENT_LTIME=$ltime \
    EVENT_VERSION=$version \
    CONSUL_HOST=$BRIDGE_IP \
    CONSUL_HTTP_PORT=$CONSUL_HTTP_PORT \
    LOGFILE=$LOGFILE \
    plugn trigger $event

    if [ $? -eq 0 ]; then
      debug "Triggered plugins finished successfully"
      curl -X PUT -d 'FINISHED' "http://$BRIDGE_IP:$CONSUL_HTTP_PORT/v1/kv/events/$id/$(hostname -f)"
    else
      debug "Triggered plugins failed to finish successfully"
      curl -X PUT -d 'FAILED' "http://$BRIDGE_IP:$CONSUL_HTTP_PORT/v1/kv/events/$id/$(hostname -f)"
    fi
  done
}

main() {
  while read array ;do
    echo $array | jq .[] -c | process_json
  done
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
