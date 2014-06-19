#!/bin/bash

: ${AMBARI_HOST:=$AMBARISERVER_PORT_8080_TCP_ADDR}
: ${BLUEPRINT:=single-node-hdfs-yarn}

echo AMBARI_HOST=${AMBARI_HOST:? ambari server address is mandatory, fallback is a linked containers exposed 8080}

./wait-for-host-number.sh

java -jar ambari-shell.jar --ambari.host=$AMBARI_HOST
