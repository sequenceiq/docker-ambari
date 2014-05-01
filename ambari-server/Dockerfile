# Creates an Ambari Server base on vanilla centos
#
# docker build -t seq/ambari ambari-server

FROM tianon/centos
MAINTAINER SequenceIQ

ADD hdp.repo /etc/yum.repos.d/
ADD ambari.repo /etc/yum.repos.d/
RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl
RUN mkdir -p /usr/jdk64/ && curl http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-7u45-linux-x64.tar.gz | tar -xz -C /usr/jdk64/
RUN ambari-server setup --silent -j /usr/jdk64/jdk1.7.0_45
#ambari-server setup --silent -j /usr/jdk64/jdk1.7.0_45 -r /var/lib/ambari-server/resources/Ambari-DDL-Postgres-DROP.sql -v

ADD system-auth /etc/pam.d/
RUN sed -i.bak "/^hostname/ s/.*/hostname=server.ambari.com/" /etc/ambari-agent/conf/ambari-agent.ini

ADD bootstrap.sh /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

EXPOSE 8080 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030
