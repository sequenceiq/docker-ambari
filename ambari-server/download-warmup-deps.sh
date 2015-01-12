#!/bin/bash

#The exit of download_deps needs to be trapped because the Docker build exits 

function download_deps {
  yum install -y yum-plugin-downloadonly
  yum install -y --downloadonly hadoop_2_2_* slider_2_2_* storm_2_2_*
}
trap download_deps EXIT