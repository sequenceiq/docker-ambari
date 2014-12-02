# Creates an Ambari Server base on vanilla centos
FROM sequenceiq/pam:centos-6.5
MAINTAINER SequenceIQ

COPY ambari.repo /etc/yum.repos.d/
COPY hdp.repo /etc/yum.repos.d/

RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl bind-utils
RUN ambari-server setup --silent

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

# add ambari shell to the image so new users don't need the 1GB java image
RUN curl -o /tmp/ambari-shell.jar https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/ambari-shell/0.1.4/ambari-shell-0.1.4.jar
COPY install-cluster.sh /tmp/
COPY wait-for-host-number.sh /tmp/
COPY ambari-shell.sh /tmp/
ENV JAVA_HOME /usr/jdk64/jdk1.7.0_45
ENV PATH $PATH:$JAVA_HOME/bin
ENV PLUGIN_PATH /plugins
WORKDIR /tmp

# fixing pgsql issue
RUN rm -rf /tmp/.s.PGSQL.5432.*

COPY public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
COPY internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini

RUN mkdir /var/log/hadoop-metrics && chmod 777 /var/log/hadoop-metrics
COPY hadoop-metrics2.properties.j2 /var/lib/ambari-server/resources/stacks/HDP/2.0.6/hooks/before-START/templates/hadoop-metrics2.properties.j2

# Error: database disk image is malformed
#ADD 00_dbclean.sh /usr/local/init/00_dbclean.sh
# warmup
RUN yum install -y ambari-log4j hadoop hadoop-libhdfs hadoop-lzo hadoop-lzo-native hadoop-mapreduce hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-nodemanager hadoop-yarn-proxyserver hadoop-yarn-resourcemanager lzo net-snmp net-snmp-utils snappy snappy-devel unzip zookeeper

# SSH
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
  && sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config \
  && echo "UsePAM no" >> /etc/ssh/sshd_config


COPY start-agent /start-agent
COPY start-server /start-server

# download consul and plugn binaries
RUN curl -Lko /tmp/consul.zip https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip && unzip -d /bin /tmp/consul.zip && rm /tmp/consul.zip
RUN curl -Lk https://s3-eu-west-1.amazonaws.com/sequenceiq/plugn.tar.gz | tar -zxv -C /bin

# initialize a new plugn path and install default plugins
RUN plugn init
RUN plugn install https://github.com/sequenceiq/consul-plugins-install.git install
RUN plugn enable install

VOLUME /var/log

EXPOSE 8080
CMD ["/start-server"]
