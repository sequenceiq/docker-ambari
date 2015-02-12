#!/bin/bash

export PATH=/usr/jdk64/jdk1.7.0_67/bin:$PATH

: ${AMBARI_HOST:=$AMBARISERVER_PORT_8080_TCP_ADDR}
: ${BLUEPRINT:=single-node-hdfs-yarn}

echo AMBARI_HOST=${AMBARI_HOST:? ambari server address is mandatory, fallback is a linked containers exposed 8080}

./wait-for-host-number.sh

export PATH=/usr/jdk64/jdk1.7.0_67/bin:$PATH
java -jar ambari-shell.jar --ambari.host=$AMBARI_HOST
