# Creates an Ambari Server base on vanilla centos
FROM maci0/systemd
MAINTAINER SequenceIQ

ADD ambari.repo /etc/yum.repos.d/

# increase timeouts to avoid "No more mirrors to try" if yum repos are busy for a few minutes
RUN echo "retries=0" >> /etc/yum.conf
RUN echo "timeout=60" >> /etc/yum.conf

RUN yum install -y tar git curl bind-utils unzip

# install Ambari specified 1.7 jdk
ADD http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-7u67-linux-x64.tar.gz /usr/jdk64/
RUN cd /usr/jdk64 && tar -xf jdk-7u67-linux-x64.tar.gz && rm -f jdk-7u67-linux-x64.tar.gz
ENV JAVA_HOME /usr/jdk64/jdk1.7.0_67
ENV PATH $PATH:$JAVA_HOME/bin
# jce
ADD http://public-repo-1.hortonworks.com/ARTIFACTS/UnlimitedJCEPolicyJDK7.zip $JAVA_HOME/jre/lib/security/
RUN cd $JAVA_HOME/jre/lib/security && unzip UnlimitedJCEPolicyJDK7.zip && rm -f UnlimitedJCEPolicyJDK7.zip && mv UnlimitedJCEPolicy/*jar . && rm -rf UnlimitedJCEPolicy

RUN yum install -y ambari-server ambari-agent
RUN sed -i 's/\/usr\/bin\/env service/\/usr\/bin\/env systemctl/' /usr/lib/python2.6/site-packages/ambari_server/dbConfiguration_linux.py
RUN sed -i 's/PG_ST_CMD = "%s %s status"/PG_ST_CMD = "%s status %s"/' /usr/lib/python2.6/site-packages/ambari_server/dbConfiguration_linux.py
RUN sed -i 's/PG_START_CMD = "%s %s start"/PG_START_CMD = "%s start %s"/' /usr/lib/python2.6/site-packages/ambari_server/dbConfiguration_linux.py
RUN sed -i 's/PG_RESTART_CMD = "%s %s restart"/PG_RESTART_CMD = "%s restart %s"/' /usr/lib/python2.6/site-packages/ambari_server/dbConfiguration_linux.py
RUN sed -i 's/PG_HBA_RELOAD_CMD = "%s %s reload"/PG_HBA_RELOAD_CMD = "%s reload %s"/' /usr/lib/python2.6/site-packages/ambari_server/dbConfiguration_linux.py
RUN ambari-server setup --silent --java-home $JAVA_HOME

# fix annoying PAM error 'couldnt open session'
RUN sed -i "/pam_limits/ s/^/#/" /etc/pam.d/*

RUN curl -L https://raw.githubusercontent.com/sequenceiq/docker-ssh/master/install-ssh.sh | bash

# kerberos client
RUN yum install -y krb5-workstation

# add ambari shell to the image so new users don't need the 1GB java image
RUN curl -o /tmp/ambari-shell.jar https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/ambari-shell/0.1.25/ambari-shell-0.1.25.jar
ADD install-cluster.sh /tmp/
ADD wait-for-host-number.sh /tmp/
ADD ambari-shell.sh /tmp/
ENV PLUGIN_PATH /plugins
WORKDIR /tmp

# fixing pgsql issue
RUN rm -rf /tmp/.s.PGSQL.5432.*

# add a custom folder to the hadoop classpath
RUN mkdir -p /usr/lib/hadoop/lib
ENV HADOOP_CLASSPATH /usr/lib/hadoop/lib/*

# add mysql connector to ambari-server so it can be downloaded by services (e.g.: Ranger)
ADD mysql-connector-java-5.1.17.jar /var/lib/ambari-server/resources/mysql-jdbc-driver.jar

ADD public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
ADD internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini

# RUN mkdir /var/log/hadoop-metrics && chmod 777 /var/log/hadoop-metrics
# ADD hadoop-metrics2.properties.j2 /var/lib/ambari-server/resources/stacks/HDP/2.0.6/hooks/before-START/templates/hadoop-metrics2.properties.j2

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

VOLUME /var/log

# increase agent timeout
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

# always connect to Ambari server registered in consul dns
RUN sed -i "s/^hostname=.*/hostname=ambari-8080.service.consul/" /etc/ambari-agent/conf/ambari-agent.ini

# do not use the docker0 interface
RUN sed -i "s/\"ifconfig\"/\"ifconfig eth0\"/" /usr/lib/python2.6/site-packages/ambari_agent/Facter.py

ENV PS1 "[\u@docker-ambari \W]# "

EXPOSE 8080
CMD ["/start-server"]
