# Creates an Ambari Server base on vanilla centos
# To build the image use:
#
# git checkout 1.7.0
# docker build -t sequenceiq/ambari:1.7.0 ./ambari-server/

FROM sequenceiq/dnsmasq:pam-fix
MAINTAINER SequenceIQ

ADD ambari.repo /etc/yum.repos.d/
RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl
RUN ambari-server setup --silent

ADD serf /usr/local/serf

# instead of starting the docker file FROM sequenceiq/ssh:
RUN yum install -y curl
RUN curl -L https://api.github.com/repos/sequenceiq/docker-ssh/tarball/master|tar -xz -C /usr/local/serf --strip-components=2 --touch \*/serf
RUN curl -L https://raw.githubusercontent.com/sequenceiq/docker-ssh/master/install-ssh.sh | bash

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

# warm up the image
ADD hdp.repo /etc/yum.repos.d/
ADD download-warmup-deps.sh /tmp/
RUN chmod +x  /tmp/download-warmup-deps.sh
RUN /tmp/download-warmup-deps.sh
RUN yum install -y ambari-log4j hadoop hadoop-libhdfs hadoop-lzo hadoop-lzo-native hadoop-mapreduce hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-nodemanager hadoop-yarn-proxyserver hadoop-yarn-resourcemanager lzo net-snmp net-snmp-utils snappy snappy-devel unzip zookeeper hbase

# add ambari shell to the image so new users don't need the 1GB java image
RUN curl -o /tmp/ambari-shell.jar https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/ambari-shell/0.1.23/ambari-shell-0.1.23.jar
ADD install-cluster.sh /tmp/
ADD wait-for-host-number.sh /tmp/
ADD ambari-shell.sh /tmp/
ENV JAVA_HOME /usr/jdk64/jdk1.7.0_67
ENV PATH $PATH:$JAVA_HOME/bin
WORKDIR /tmp

# fixing pgsql issue
RUN rm -rf /tmp/.s.PGSQL.5432.*

ADD public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
ADD internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini

RUN mkdir /var/log/hadoop-metrics && chmod 777 /var/log/hadoop-metrics
ADD hadoop-metrics2.properties.j2 /var/lib/ambari-server/resources/stacks/HDP/2.0.6/hooks/before-START/templates/hadoop-metrics2.properties.j2

# Error: database disk image is malformed
#ADD 00_dbclean.sh /usr/local/init/00_dbclean.sh

VOLUME /var/log

# increase agent timeout
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

EXPOSE 8080
ENTRYPOINT ["/usr/local/serf/bin/start-serf-agent.sh"]
CMD ["--log-level", "debug"]
