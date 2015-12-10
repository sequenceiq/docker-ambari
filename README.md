# Ambari on Docker

[![DockerPulls](https://img.shields.io/docker/pulls/sequenceiq/ambari.svg)](https://registry.hub.docker.com/u/sequenceiq/ambari/)
[![DockerStars](https://img.shields.io/docker/stars/sequenceiq/ambari.svg)](https://registry.hub.docker.com/u/sequenceiq/ambari/)


This projects aim is to help you to get started with ambari. The 2 easiest way
to have an ambari server:

- start an ec2 instance
- start a virtual instance on your dev box

Amazon is getting cheaper and cheaper, so its absolutely reasonable to spend the
price of a cappuccino to try ambari on EC2. But sometimes you want it for 'free'
or for whatever reason you don't want to use AWS.

You could go than for a virtual instance, and the use `virtualbox` or `vmware`,
but Docker has some benefits:

- starting containers under a second
- taking snapshots, its freaking quick (its just settinga label)
- snapshots are cheap, thanks to the layering nature of the underlaying aufs
- memory management is easier, as docker is using the same memory as the hosts,
  while for several virtual instances, you have to declare memory limits one by one

## Install Docker

Follow the description at the docker [getting started](https://www.docker.io/gettingstarted/#h_installation)

**Note:** If you are using `boot2docker` make sure you forward all ports from docker:
http://docs.docker.io/en/latest/installation/mac/#forwarding-vm-port-range-to-host

## Starting the container

This will start (and download if you never used it before) an image based on
centos-6 with pre-installed Ambari 2.1.0 ready to install HDP 2.3. This git repository contains an ambari-functions script
which will launch all the necessary containers to create a fully functional cluster. Download the file and source it:
```
. ambari-functions or source ambari-functions
```
Now you can issue commands with `amb-`prefix like:
```
amb-settings
```
To start a 3 node cluster:
```
amb-start-cluster 3
```
It will launch containers like this (1 Ambari server 2 agents 1 consul server):
```
CONTAINER ID        IMAGE                          COMMAND                  STATUS              NAMES
089f7f9e0b9e        sequenceiq/ambari:2.1.2-v1     "/start-agent"           Up 5 seconds        amb2
0bd64322fe07        sequenceiq/ambari:2.1.2-v1     "/start-agent"           Up 6 seconds        amb1
c7225f18fb0c        sequenceiq/ambari:2.1.2-v1     "/start-server"          Up 7 seconds        amb-server
bdca911bf416        sequenceiq/consul:v0.5.0-v6    "/bin/start -server -"   Up 13 seconds       amb-consul
```
Now you can reach the Ambari UI on the amb-server container's 8080 port. `amb-settings` for IP:
```
AMBARI_SERVER_IP=172.17.0.17
```

## Cluster deployment via blueprint

Once the container is running, you can deploy a cluster. Instead of going to
the webui, we can use ambari-shell, which can interact with ambari via cli,
or perform automated provisioning. We will use the automated way, and of
course there is a docker image, with prepared ambari-shell in it:

```
amb-shell
```

Ambari-shell uses Ambari's new [Blueprints](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
capability. It just simple posts a cluster definition JSON to the ambari REST api,
and 1 more json for cluster creation, where you specify which hosts go
to which hostgroup.

Ambari shell will show the progress in the upper right corner.
So grab a cup coffee, and after about 10 minutes, you have a ready HDP 2.3 cluster.

## Multi-node Hadoop cluster

For the multi node Hadoop cluster instructions please read our [blog](http://blog.sequenceiq.com/blog/2014/06/19/multinode-hadoop-cluster-on-docker/) entry or run this one-liner:

```
curl -Lo .amb j.mp/docker-ambari && . .amb && amb-deploy-cluster
```

