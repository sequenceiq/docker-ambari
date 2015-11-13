#!/bin/bash

curl -s -m 3 http://169.254.169.254/latest/meta-data/public-ipv4 || dig +short myip.opendns.com @resolver1.opendns.com