FROM centos:6.6
MAINTAINER SequenceIQ

# EPEL
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# kerberos
RUN yum install -y krb5-server krb5-libs krb5-auth-dialog krb5-workstation 
