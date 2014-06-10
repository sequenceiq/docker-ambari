# Creates an Ambari Server base on vanilla centos
FROM sequenceiq/dnsmasq
MAINTAINER SequenceIQ

ADD hdp.repo /etc/yum.repos.d/
ADD ambari.repo /etc/yum.repos.d/
RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl
RUN mkdir -p /usr/jdk64/ && curl http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-7u45-linux-x64.tar.gz | tar -xz -C /usr/jdk64/
RUN ambari-server setup --silent -j /usr/jdk64/jdk1.7.0_45
#ambari-server setup --silent -j /usr/jdk64/jdk1.7.0_45 -r /var/lib/ambari-server/resources/Ambari-DDL-Postgres-DROP.sql -v

RUN sed -i.bak "/^hostname/ s/.*/hostname=amb0.mycorp.kom/" /etc/ambari-agent/conf/ambari-agent.ini

ADD serf /usr/local/serf

# instead of starting the docker file FROM sequenceiq/ssh:
RUN yum install -y curl
RUN curl -L https://api.github.com/repos/sequenceiq/docker-ssh/tarball/master|tar -xz -C /usr/local/serf --strip-components=2 --touch \*/serf
RUN curl -L https://raw.githubusercontent.com/sequenceiq/docker-ssh/master/install-ssh.sh | bash

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

ENTRYPOINT ["/usr/local/serf/bin/start-serf-agent.sh"]
CMD ["--log-level", "debug"]
