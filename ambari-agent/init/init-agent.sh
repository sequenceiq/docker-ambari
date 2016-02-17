#!/bin/bash

: ${CLOUD_PLATFORM:="none"}
: ${USE_CONSUL_DNS:="true"}
: ${AMBARI_SERVER_ADDR:="ambari-8080.service.consul"}

[[ "TRACE" ]] && set -x

debug() {
  [[ "DEBUG" ]]  && echo "[DEBUG] $@" 1>&2
}

get_nameserver_addr() {
  if [[ "$NAMESERVER_ADDR" ]]; then
    echo $NAMESERVER_ADDR
  else
    if ip addr show docker0 &> /dev/null; then
      ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
    else
      ip ro | grep default | cut -d" " -f 3
    fi
  fi
}

# --dns isn't available for: docker run --net=host
# sed -i /etc/resolf.conf fails:
# sed: cannot rename /etc/sedU9oCRy: Device or resource busy
# here comes the tempfile workaround ...
local_nameserver() {
  cat>/etc/resolv.conf<<EOF
nameserver $(get_nameserver_addr)
search service.consul node.dc1.consul
EOF
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
  [[ "$USE_CONSUL_DNS" == "true" ]] && local_nameserver
  ambari_server_addr
  reorder_dns_lookup
}

main "$@"

