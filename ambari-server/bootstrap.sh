#!/bin/bash

ambari-agent start
ambari-server start

while true; do
   tail -f /var/log/ambari-*/ambari-*.log
done
