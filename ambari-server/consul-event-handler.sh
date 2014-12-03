#!/bin/bash

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
    echo $payload | base64 -d | \
      EVENT_ID=$id \
      EVENT_LTIME=$ltime \
      EVENT_VERSION=$version \
      plugn trigger $event
  done
}

main() {
  while read array ;do 
    echo $array | jq .[] -c | process_json 
  done
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"