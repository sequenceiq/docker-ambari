FROM centos:7
MAINTAINER Hortonworks

RUN yum install epel-release -y && yum clean all
RUN yum update -y && yum clean all

#Setting up systemd
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/usr/sbin/init"]

RUN yum install -y systemd* && yum clean all

RUN yum install -y yum-utils yum-plugin-ovl tar git curl bind-utils unzip wget && yum clean all

# Setup sshd
RUN yum install -y openssh-server openssh-clients && yum clean all
RUN systemctl enable sshd

# kerberos client
RUN yum install -y krb5-workstation && yum clean all

# initscripts (service wrapper for servicectl) is need othewise the Ambari is unable to start postgresql
RUN yum install -y initscripts && yum clean all

RUN curl -o /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/bin/jq

ENV JDK_ARTIFACT jdk-7u67-linux-x64.tar.gz
ENV JDK_VERSION jdk1.7.0_67

# install Ambari specified 1.7 jdk
RUN mkdir /usr/jdk64 && cd /usr/jdk64 && wget http://public-repo-1.hortonworks.com/ARTIFACTS/$JDK_ARTIFACT && \
    tar -xf $JDK_ARTIFACT && rm -f $JDK_ARTIFACT
ENV JAVA_HOME /usr/jdk64/$JDK_VERSION
ENV PATH $PATH:$JAVA_HOME/bin

# jce
ADD http://public-repo-1.hortonworks.com/ARTIFACTS/UnlimitedJCEPolicyJDK7.zip $JAVA_HOME/jre/lib/security/
RUN cd $JAVA_HOME/jre/lib/security && unzip UnlimitedJCEPolicyJDK7.zip && rm -f UnlimitedJCEPolicyJDK7.zip && mv UnlimitedJCEPolicy/*jar . && rm -rf UnlimitedJCEPolicy

ADD etc/yum.conf /etc/yum.conf 

ENV PS1 "[\u@docker-ambari \W]# "
