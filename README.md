# Ambari on docker

This projects aim is to help you to get started with ambari. The 2 easiest way
to have an ambari server:

- start an ec2 instance
- start a virtual instance on your dev box

Amazon is getting cheaper and cheaper, so its absolutely reasonable to spend the
price of a cappuccino to try ambari on ec2. But sometimes you want it for 'free'
or for whatever reason you don't want to use aws.

You could go than for a virtual instance, and the use `virtualbox` or 'vmware',
but docker has some benefits:

- starting containers under a second
- taking snapshots, its freaking quick (its just settinga label)
- snapshots are cheap, thanks to the layering nature of the underlaying aufs
- memory management is easier, as docker is using the same memory as the hosts,
  while for several virtual instances, you have to declare memory limits one by one

## Install docker

Follow the description at the docker [getting started](https://www.docker.io/gettingstarted/#h_installation)

**Note:** If you are using `boot2docker` make sure you forward all ports from docker:
http://docs.docker.io/en/latest/installation/mac/#forwarding-vm-port-range-to-host

## Getting the image

To download the docker image, with preinstalled ambari 1.6

```
docker pull  sequenceiq/ambari
```

## Starting the container

```
docker run -d -P -h server.ambari.com --name ambari-singlenode sequenceiq/ambari -d

```
The explanation of the parameters:

- -d: run as daemon
- -P: expse all ports defined in the Dockerfile
- -h server.ambari.com: sets the hostname

## Cluster deployment via blueprint

Once the image is backen you need a single step:
```
git clone git@github.com:sequenceiq/ambari-docker.git
cd ambari-docker
./single-node-cluster-blueprint.sh
```
This script uses Ambari's new [Blueprints](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
capability. You just simple post a cluster definition JSON to the ambari REST api,
grab a cup coffee, and after about 15 minutes, you have a ready HDP 2.1 cluster.

## Check the progress

It took me about 18 minutes until ambari installs and starts these components:
- DATANODE
- GANGLIA_MONITOR
- GANGLIA_SERVER
- HDFS_CLIENT
- HISTORYSERVER
- MAPREDUCE2_CLIENT
- NAMENODE
- NODEMANAGER
- RESOURCEMANAGER
- SECONDARY_NAMENODE
- YARN_CLIENT
- ZOOKEEPER_CLIENT
- ZOOKEEPER_SERVER

To check the process you can either watch the web interface at
`http://localhost:491XX/`
You can find out the exact portnumber by:
```
docker port $(docker ps -q -l) 8080
```
## Coming soon

This documents described a pseudo distributed ambari cluster. Stay tuned for the
real cluster ...
