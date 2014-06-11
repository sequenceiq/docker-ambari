#!/bin/bash

: cat <<SAMPLESERFEVENT
amb0    172.19.0.32             ambari-server=true,ambari-agent=true
SAMPLESERFEVENT

EXPECTED=$(cat << 'EOF'
[DEBUG] [DRY_RUN] ambari-server start
[DEBUG] [DRY_RUN] sed -i.bak /^hostname/ s/.*/hostname=amb0.mycorp.com/ /etc/ambari-agent/conf/ambari-agent.ini
[DEBUG] [DRY_RUN] ambari-agent start
EOF
)

DIR=$(dirname $0)

test-ambari-single() {
  handler=$1; : ${handler:? handler funtion is mandatory first parameter}
  printf 'amb0.mycorp.com\t172.19.0.34\t\tambari-server=true,ambari-agent=true\n' \
  | ( \
  SERF_EVENT=member-join \
  SERF_HOME=/usr/local/serf \
  SERF_SELF_NAME=amb0.mycorp.com \
  SERF_SELF_ROLE= \
  SERF_TAG_AMBARI_AGENT=true \
  SERF_TAG_AMBARI_SERVER=true  \
  $handler )
}

DEBUG=$(DRY_RUN=true test-ambari-single $DIR/../ambari-server/serf/handlers/ambari-bootstrap 2>&1)

cat <<EOF
============
$DEBUG
============

EOF

[ "$EXPECTED" == "$DEBUG" ] && echo SUCCESS || echo FAILED
