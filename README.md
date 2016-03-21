# Ambari on Docker

This projects aim is to help you to get started with Ambari.

> Please note that this project is not officially supported by Hortonworks and may not be suitable for production use. It can be used to experiment with Hadoop on Docker but for a complete and supported solution please check out [Cloudbreak](https://github.com/sequenceiq/cloudbreak).

## Install Docker

Follow the description at the docker getting started page for your appropriate OS: ([Linux](http://docs.docker.com/linux/started/), [Mac](http://docs.docker.com/mac/started/), [Windows](http://docs.docker.com/windows/started/))

### OSX
Ambari containers started by ambari-function are using bridge networking. This means that you will not be able to communicate with containers directly
from host unless you specify the route to containers. You can do this with:

```
# Getting the IP of docker-machine or boot2docker
docker-machine ip <name-of-docker-vm>
# or
boot2docker ip

# Setting up the
sudo route add -net 172.17.0.0/16 <docker-machine or boot2docker>
# e.g:
sudo route add -net 172.17.0.0/16 192.168.99.100
```
**Note:**  the above mentioned route command will not survive a reboot and you need to execute again after reboot of your machine.


## Starting containers

This will start (and download if you never used it before) an image based on
Centos 7 with pre-installed Ambari 2.2.0 ready to install HDP 2.3.

This git repository also contains an ambari-functions script
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
52b563756d26        hortonworks/ambari-agent       "/usr/sbin/init syste"   Up 9 seconds        amb2
ddfc8f00d30a        hortonworks/ambari-agent       "/usr/sbin/init syste"   Up 10 seconds       amb1
ca87a0fb6306        hortonworks/ambari-server      "/usr/sbin/init syste"   Up 12 seconds       amb-server
7d18cc35a6b0        sequenceiq/consul:v0.5.0-v6   "/bin/start -server -"    Up 17 seconds       amb-consul
```

Now you can reach the Ambari UI on the amb-server container's 8080 port. Type the `amb-settings` for IP:
```
amb-settings
...
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

Ambari-shell uses Ambari's [Blueprints](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
capability. It posts a cluster definition JSON to the ambari REST api,
and 1 more json for cluster creation, where you specify which hosts go
to which hostgroup.

Ambari shell will show the progress in the upper right corner.

## Multi-node Hadoop cluster

For the multi node Hadoop cluster instructions please take a look at [Cloudbreak](http://hortonworks.com/hadoop/cloudbreak/).

If you don't want to check out the project from github, then just dowload the ambari-fuctions script, source it and deploy a
an Ambari cluster:
```
curl -Lo .amb j.mp/docker-ambari && source .amb && amb-deploy-cluster
```

