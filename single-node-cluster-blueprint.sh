docker run -p 8080 -i -t -h server.ambari.com --name ambari-test ambari-test /bin/bash
AMBARI_ID=$(docker run -d -p 8080 -h server.ambari.com --name ambari-test ambari-test)

AMBARI_URL=$(docker port $AMBARI_ID 8080)
AMBARI_FQDN=server.ambari.com
########################
# create the BLUEPRINT
########################
curl -H "X-Requested-By: ambari" -u admin:admin http://$AMBARI_URL/api/v1/blueprints/single-node-hdfs-yarn -d @- <<EOF
{
  "host_groups" : [
    {
      "name" : "host_group_1",
      "components" : [
      {
        "name" : "NAMENODE"
      },
      {
        "name" : "SECONDARY_NAMENODE"
      },
      {
        "name" : "DATANODE"
      },
      {
        "name" : "HDFS_CLIENT"
      },
      {
        "name" : "RESOURCEMANAGER"
      },
      {
        "name" : "NODEMANAGER"
      },
      {
        "name" : "YARN_CLIENT"
      },
      {
        "name" : "HISTORYSERVER"
      },
      {
        "name" : "MAPREDUCE2_CLIENT"
      },
      {
        "name" : "ZOOKEEPER_SERVER"
      },
      {
        "name" : "ZOOKEEPER_CLIENT"
      },
      {
        "name" : "GANGLIA_SERVER"
      },
      {
        "name" : "GANGLIA_MONITOR"
      }
      ],
      "cardinality" : "1"
    }
  ],
  "Blueprints" : {
    "blueprint_name" : "single-node-hdfs-yarn",
    "stack_name" : "HDP",
    "stack_version" : "2.1"
  }
}
EOF

########################
# create the cluster
########################

curl -H "X-Requested-By: ambari" -u admin:admin http://$AMBARI_URL/api/v1/clusters/MySingleNodeCluster -d @- <<EOF
{
  "blueprint" : "single-node-hdfs-yarn",
  "host-groups" :[
    {
      "name" : "host_group_1",
      "hosts" : [
        {
          "fqdn" : "$AMBARI_FQDN"
        }
      ]
    }
  ]
}
EOF


## check status
: <<EOF

EOF
