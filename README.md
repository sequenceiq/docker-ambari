# Ambari on docker

This projects aim is to help you to get started with ambari. The 2 easiest way
to have an ambari server:

- start an ec2 instance
- start a virtual instance on your dev box

Amazon is getting cheaper and cheaper, so its absolutely reasonable to spend the
price of a cappuccino to try ambari on EC22. But sometimes you want it for 'free'
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
centos-6 with preinstalled Ambari 1.7.0 ready to install HDP 2.2.

```
docker run -d -P -h amb0.mycorp.kom -e KEYCHAIN=<keychain@email> --name amb0  sequenceiq/ambari --tag ambari-server=true
```

The explanation of the parameters:

- **-d**: run as daemon
- **-P**: expose all ports defined in the Dockerfile
- **-h amb0.mycorp.kom**: sets the hostname
- **--name amb0**: sets the container name to **amb0** (no need to use )
- **-e KEYCHAIN=<email>** your keychain.io email. Keychain.io is a free service
  which can store, and serve pulic keys for ssh authentication.
  You can upload you public key as: `curl -s ssh.keychain.io/<email>/upload | bash`

## Cluster deployment via blueprint

Once the container is running, you can deploy a cluster. Instead of going to
the webui, we can use ambari-shell, which can interact with ambari via cli,
or perform automated provisioning. We will use the automated way, and of
course there is a docker image, with prepared ambari-shell in it:

```
docker run -e BLUEPRINT=single-node-hdfs-yarn --link amb0:ambariserver -t --rm --entrypoint /bin/sh sequenceiq/ambari-shell -c /tmp/install-cluster.sh
```

Ambari-shell uses Ambari's new [Blueprints](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
capability. It just simple posts a cluster definition JSON to the ambari REST api,
and 1 more json for cluster creation, where you specify which hosts go
to which hostgroup.

Ambari shell will show the progress in the upper right corner.
So grab a cup coffee, and after about 10 minutes, you have a ready HDP 2.2 cluster.

## Multi-node Hadoop cluster

For the multi node Hadoop cluster instructions please read our [blog](http://blog.sequenceiq.com/blog/2014/06/19/multinode-hadoop-cluster-on-docker/) entry or run this one-liner:

```
curl -Lo .amb j.mp/docker-ambari && . .amb && amb-deploy-cluster
```

_Note: there is a 1.7.0 Ambari early access in the v1.7.0-ea branch. if you are interested in a particular Ambari version, always check for the appropriate branch._

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/cf81b5b79a6a27e8b10daf467c576d87 "githalytics.com")](http://githalytics.com/sequenceiq/docker-ambari)
