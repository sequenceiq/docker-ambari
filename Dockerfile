FROM tianon/centos
MAINTAINER lalyos

# adds 
RUN curl -so /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/GA/ambari.repo

RUN yum repolist
RUN yum -y install ambari-server
RUN ambari-server setup --silent

EXPOSE 8080
