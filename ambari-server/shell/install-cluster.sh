#!/bin/bash

./ambari-shell.sh << EOF
blueprint add --url https://raw.githubusercontent.com/sequenceiq/ambari-rest-client/2.1.11/src/main/resources/blueprints/multi-node-hdfs-yarn
blueprint add --url https://raw.githubusercontent.com/sequenceiq/ambari-rest-client/2.1.11/src/main/resources/blueprints/single-node-hdfs-yarn
cluster build --blueprint $BLUEPRINT
cluster autoAssign
cluster create --exitOnFinish true
EOF
