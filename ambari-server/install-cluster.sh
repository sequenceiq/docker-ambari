#!/bin/bash

export PATH=/usr/jdk64/jdk1.7.0_67/bin:$PATH

./ambari-shell.sh << EOF
blueprint defaults
cluster build --blueprint $BLUEPRINT
cluster autoAssign
cluster create --exitOnFinish true
EOF
