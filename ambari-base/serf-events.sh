#!/bin/bash

#for var in ${!SERF*}; do echo ${var}=${!var};done

while read line ;do
  NEXT_HOST=$(echo $line|cut -d' ' -f 1)
  NEXT_SHORT=${NEXT_HOST%%.*}
  NEXT_IP=$(echo $line|cut -d' ' -f 2)
  cat >> /etc/dnsmasq.d/0hosts <<EOF
address="/$NEXT_HOST/$NEXT_SHORT/$NEXT_IP"
EOF

done

service dnsmasq restart

:<<EOF
drun() {
  docker run -t -i -rm -dns 127.0.0.1 -h $1.vmati.com --name $1.vmati.com seq/ambari-base /bin/bash
}

serf agent -rpc-addr=$(hostname -i):7373 -bind=$(hostname -i) -event-handler=/etc/serf-events.sh -node=$(hostname -f)

serf agent -rpc-addr=$(hostname -i):7373 -bind=$(hostname -i) -event-handler=/etc/serf-events.sh -node=$(hostname -f) -join=172.17.0.2
EOF
