#!/bin/bash

: ${BRIDGE_IP:=127.0.0.1}
: ${CONSUL_HTTP_PORT:=8500}

get_field() {
  declare json="$1"
  declare field="$2"

  echo "$json"|jq ".$field" -r
}

process_json() {
  while read json; do
    [[ "$DEBUG" ]] && echo $json

    event=$(get_field $json Name)
    id=$(get_field $json ID)
    payload=$(get_field $json Payload)
    ltime=$(get_field $json LTime)
    version=$(get_field $json Version)

    curl -X PUT -d 'ACCEPTED' "http://$BRIDGE_IP:$CONSUL_HTTP_PORT/v1/kv/events/$id/$(hostname -f)"
    echo $payload | base64 -d | \
      EVENT_ID=$id \
      EVENT_LTIME=$ltime \
      EVENT_VERSION=$version \
    plugn trigger $event
    curl -X PUT -d 'FINISHED' "http://$BRIDGE_IP:$CONSUL_HTTP_PORT/v1/kv/events/$id/$(hostname -f)"
  done
}

main() {
  while read array ;do
    echo $array | jq .[] -c | process_json
  done
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
