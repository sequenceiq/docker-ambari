#!/bin/bash

: ${CLOUD_PLATFORM:="none"}
: ${USE_CONSUL_DNS:="true"}
: ${AMBARI_SERVER_ADDR:="ambari-8080.service.consul"}

[[ "TRACE" ]] && set -x

debug() {
  [[ "DEBUG" ]]  && echo "[DEBUG] $@" 1>&2
}

ambari_server_addr() {
  sed -i "s/^hostname=.*/hostname=${AMBARI_SERVER_ADDR}/" /etc/ambari-agent/conf/ambari-agent.ini
}

# GCP overrides the /etc/hosts file with its internal hostname, so we need to change the
# order of the host resolution to try the DNS first
reorder_dns_lookup() {
  if [ "$CLOUD_PLATFORM" == "GCP" ] || [ "$CLOUD_PLATFORM" == "GCC" ]; then
    sed -i "/^hosts:/ s/ *files dns/ dns files/" /etc/nsswitch.conf
  fi
}

main() {
  ln -s /docker_shared/etc/resolv.conf /tmp/resolv.conf
  cp /tmp/resolv.conf /etc/resolv.conf

  [[ "$USE_CONSUL_DNS" == "true" ]] && local_nameserver
  ambari_server_addr
  reorder_dns_lookup
}

main "$@"

