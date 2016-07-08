 # Prove of concept for ambari on kubernetes

I was interested in if it is generally possible to run ambari on top of kubernetes.
If this is a good idea  is a separate discussion, I just wanted to see if it is
teoretically Possible.

## Installing

run:
```
  kubectl create -f kubernetes/ in the root folder of this Project
```

this brings up a cluster with 1 ambari server and 5 ambari agent nodes.

```
kubectl get pods --namespace=ambari
NAME                  READY     STATUS    RESTARTS   AGE
amb-agent-btj80       1/1       Running   0          13h
amb-agent-cn5qe       1/1       Running   0          13h
amb-agent-fwfre       1/1       Running   0          13h
amb-agent-sk80u       1/1       Running   0          13h
amb-agent-uxaec       1/1       Running   0          13h
ambari-server-leqn7   1/1       Running   0          13h
```

get a terminal in the master node:

```
kubectl exec -ti --namespace=ambari /bin/bash
```

and paste

```
export BLUEPRINT=multi-node-hdfs-yarn
export EXPECTED_HOST_COUNT=5
/tmp/install-cluster.sh
```

### Acces the ambari web interface

In order to access the web interface you have to modify the file ambari-web-service-sc.yml
to provice an external loadbalancer / url to acces according to your kubernetes cluster.


## Issues

I had to modify the setting dfs.namenode.datanode.registration.ip-hostname-check to false in hdfs-site.xml.
I Used the ambari web ui for doing this, and restarted the affected servies.
Without this the datanodes where not starting.

It would be nice if I could use the ambari shell to set this property befor starting the cluster.

Next issue is that there are a lot of other extarnal services / web uis running
on different nodes in the cluster which kubernetes is not aware of. So I could
not use the kubernetes native means to expose them to the internet. One solution
might be to do a port mapping for every possible service port on every agent pod,
but to do so I need a list of the possible ports that have to be accessable from
the internet.

## TODO

* provide something similar to docker functions in ambari-functions for kubernetes
* find a solution for exposing the different web interfaces exposed by services in the cluster.
* This is a poc that shows that it is possible to run ambari on kubernetes.
Still the question is if it makes sense. To have an on demand hadoop infrastructure
it is probably ok. To run this as a long living cluster it would be probably necessary
to dedicated nodes in the cluster for the different services. For example containers
that only do map reduce and kind of "know" there purpose. These could maby use
the ambari rest api to register them selves into the cluster, and also deregister
if they are stopped.
This way you could use kubernetes autoscaling groups for these containers and it
would be easyser to use kubernetes services to discover hadoop services. But I don't
know if the rest api / ambari shell is powerful enoug to do this.
