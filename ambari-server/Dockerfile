# Creates an Ambari Server base on vanilla centos
FROM centos:centos6
MAINTAINER SequenceIQ

ADD ambari.repo /etc/yum.repos.d/
RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl
RUN ambari-server setup --silent

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

# add ambari shell to the image so new users don't need the 1GB java image
RUN curl -o /tmp/ambari-shell.jar https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/ambari-shell/0.1.4/ambari-shell-0.1.4.jar
ADD install-cluster.sh /tmp/
ADD wait-for-host-number.sh /tmp/
ADD ambari-shell.sh /tmp/
ENV JAVA_HOME /usr/jdk64/jdk1.7.0_45
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

EXPOSE 8080
ENTRYPOINT ["/usr/local/serf/bin/start-serf-agent.sh"]
CMD ["--log-level", "debug"]
