#!/bin/bash

./ambari-shell.sh << EOF
blueprint defaults
cluster build --blueprint $BLUEPRINT
cluster autoAssign
cluster create --exitOnFinish true
EOF
