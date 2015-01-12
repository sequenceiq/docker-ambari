#!/bin/bash

#The exit of download_deps needs to be trapped because the Docker build exits

function download_deps {
  yum install -y yum-plugin-downloadonly
  yum install -y --downloadonly hadoop_2_2_* slider_2_2_* storm_2_2_* hadoop_2_2_*-yarn hadoop_2_2_*-mapreduce snappy snappy-devel hadoop_2_2_*-libhdfs ambari-log4j falcon_2_2_* flume_2_2_* httpd python-rrdtool-1.4.5 libganglia-3.5.0-99 ganglia-devel-3.5.0-99 ganglia-gmetad-3.5.0-99 ganglia-web-3.5.7-99.noarch ganglia-gmond-3.5.0-99 ganglia-gmond-modules-python-3.5.0-99 hbase_2_2_* hive_2_2_* mysql mysql-server kafka_2_2_* knox_2_2_* extjs oozie_2_2_* pig_2_2_* sqoop_2_2_* tez_2_2_* fping nagios-plugins-1.4.9 nagios-3.5.0-99 nagios-www-3.5.0-99 nagios-devel-3.5.0-99
}
trap download_deps EXIT
