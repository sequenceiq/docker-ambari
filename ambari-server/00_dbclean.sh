#!/bin/bash

echo yum clean all
echo $(yum clean all)
echo mv /var/cache/yum/ /tmp/
echo $(mv /var/cache/yum/ /tmp/)
echo mv /var/lib/rpm/__db* /tmp/
echo $(mv /var/lib/rpm/__db* /tmp/)
echo rpm –rebuilddb
echo $(rpm –rebuilddb)
