#!/bin/bash

service ntpd start
service dnsmasq start
service sshd start

JOIN_OPTS=""
if [[ -n $JOIN_IP ]]; then
  JOIN_OPTS="-join=$JOIN_IP"
fi

serf agent -rpc-addr=$(hostname -i):7373 -bind=$(hostname -i) -event-handler=/etc/serf-events.sh -node=$(hostname -f) "$JOIN_OPTS"
