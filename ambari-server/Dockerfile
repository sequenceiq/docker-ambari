# Creates an Ambari Server base on vanilla centos
FROM sequenceiq/pam:centos-6.5
MAINTAINER SequenceIQ

ADD ambari.repo /etc/yum.repos.d/

RUN yum install -y ambari-server ambari-agent
RUN yum install -y tar git curl bind-utils wget
RUN ambari-server setup --silent

RUN wget http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz && tar xzf apache-maven-3.0.5-bin.tar.gz -C /usr/local && cd /usr/local && ln -s apache-maven-3.0.5 maven
ENV M2_HOME /usr/local/maven
ENV PATH $PATH:$M2_HOME/bin

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

RUN curl -L https://raw.githubusercontent.com/sequenceiq/docker-ssh/master/install-ssh.sh | bash

# warm up the image
ADD HDP.repo /etc/yum.repos.d/
ADD download-warmup-deps.sh /tmp/
RUN /tmp/download-warmup-deps.sh

# kerberos client
RUN yum install -y krb5-workstation 

# add ambari shell to the image so new users don't need the 1GB java image
RUN curl -o /tmp/ambari-shell.jar https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/ambari-shell/0.1.25/ambari-shell-0.1.25.jar
ADD install-cluster.sh /tmp/
ADD wait-for-host-number.sh /tmp/
ADD ambari-shell.sh /tmp/
ENV JAVA_HOME /usr/jdk64/jdk1.7.0_67
ENV PATH $PATH:$JAVA_HOME/bin
ENV PLUGIN_PATH /plugins
WORKDIR /tmp

RUN curl -o /var/lib/ambari-server/resources/views/hive-0.1.0-SNAPSHOT.jar https://s3-eu-west-1.amazonaws.com/sequenceiq/hive-0.1.0-20150306.030234-109.jar

# fixing pgsql issue
RUN rm -rf /tmp/.s.PGSQL.5432.*

# add a custom folder to the hadoop classpath
RUN mkdir -p /usr/lib/hadoop/lib
ENV HADOOP_CLASSPATH /usr/lib/hadoop/lib/*

ADD public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
ADD internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini

RUN mkdir /var/log/hadoop-metrics && chmod 777 /var/log/hadoop-metrics
ADD hadoop-metrics2.properties.j2 /var/lib/ambari-server/resources/stacks/HDP/2.0.6/hooks/before-START/templates/hadoop-metrics2.properties.j2

# SSH
RUN yum install -y openssh-server openssh-clients \
  && rm /etc/ssh/ssh_host_rsa_key  && rm /etc/ssh/ssh_host_dsa_key && rm /root/.ssh/id_rsa \
  && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
  && sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config \
  && echo "UsePAM no" >> /etc/ssh/sshd_config


COPY start-agent /start-agent
COPY start-server /start-server

# download jq binaries
RUN curl -o /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/bin/jq

RUN cd /var/lib/ambari-server/resources/stacks/HDP/2.2/services && git clone https://github.com/abajwa-hw/zeppelin-stack.git
RUN cd /root && git clone https://github.com/NFLabs/zeppelin && cd zeppelin && sed -i "s/<id>hadoop-2.4<\/id>/<id>hadoop-2.6<\/id>/g" pom.xml && sed -i "s/<hadoop.version>2.4.0<\/hadoop.version>/<hadoop.version>2.6.0<\/hadoop.version>/g" pom.xml && sed -i "s/<jets3t.version>0.9.0<\/jets3t.version>/<jets3t.version>0.9.3<\/jets3t.version>\n\t\t\t\t<codehaus.jackson.version>1.9.13<\/codehaus.jackson.version>/g" pom.xml && mvn clean package -Phadoop-2.6 -Dhadoop.version=2.6.0 -Pspark-1.2 -Pyarn -DskipTests

VOLUME /var/log

# increase agent timeout
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

EXPOSE 8080
CMD ["/start-server"]
