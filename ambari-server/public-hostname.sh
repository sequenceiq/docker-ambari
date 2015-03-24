#!/bin/bash

GCC=$(curl -Ls -m 5 http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")

if [ -n "$GCC" ]; then
  echo $GCC
  exit 0
fi

AWS_STATUS=$(curl -s -m 5 -w "%{http_code}" http://169.254.169.254/latest/meta-data/public-hostname -o /dev/null)
AWS=$(curl -s -m 5 http://169.254.169.254/latest/meta-data/public-hostname)

if [ "$AWS_STATUS" == "200" ] && [ -n "$AWS" ]; then
  echo $AWS
  exit 0
fi

echo $(hostname -f)
