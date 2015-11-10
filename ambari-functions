:<<USAGE
########################################
curl -Lo .amb j.mp/docker-ambari && . .amb
########################################

full documentation: https://github.com/sequenceiq/docker-ambari
USAGE

: ${NODE_PREFIX=amb}
: ${AMBARI_SERVER_NAME:=${NODE_PREFIX}-server}
: ${IMAGE:="sequenceiq/ambari:2.1.2-v1"}
: ${DOCKER_OPTS:=""}
: ${CONSUL:="${NODE_PREFIX}-consul"}
: ${CONSUL_IMAGE:="sequenceiq/consul:v0.5.0-v6"}
: ${CLUSTER_SIZE:=3}
: ${DEBUG:=1}
: ${SLEEP_TIME:=2}
: ${DNS_PORT:=53}
: ${EXPOSE_DNS:=false}
: ${DRY_RUN:=false}

run-command() {
  CMD="$@"
  if [[ "$DRY_RUN" == "false" ]]; then
    debug "$CMD"
    "$@"
  else
    debug [DRY_RUN] "$CMD"
  fi
}

amb-clean() {
  unset NODE_PREFIX AMBARI_SERVER_NAME IMAGE DOCKER_OPTS CONSUL CONSUL_IMAGE DEBUG SLEEP_TIME AMBARI_SERVER_IP DRY_RUN
}

get-ambari-server-ip() {
  AMBARI_SERVER_IP=$(get-host-ip ${AMBARI_SERVER_NAME})
}

get-consul-ip() {
  get-host-ip $CONSUL
}

get-host-ip() {
  HOST=$1
  docker inspect --format="{{.NetworkSettings.IPAddress}}" ${HOST}
}

amb-members() {
  curl http://$(get-consul-ip):8500/v1/catalog/nodes | sed -e 's/,{"Node":"ambari-8080.*}//g' -e 's/,{"Node":"consul.*}//g'
}

amb-settings() {
  cat <<EOF
  NODE_PREFIX=$NODE_PREFIX
  CLUSTER_SIZE=$CLUSTER_SIZE
  AMBARI_SERVER_NAME=$AMBARI_SERVER_NAME
  IMAGE=$IMAGE
  DOCKER_OPTS=$DOCKER_OPTS
  AMBARI_SERVER_IP=$AMBARI_SERVER_IP
  CONSUL=$CONSUL
  CONSUL_IMAGE=$CONSUL_IMAGE
  DRY_RUN=$DRY_RUN
EOF
}

debug() {
  [ ${DEBUG} -gt 0 ] && echo "[DEBUG] $@" 1>&2
}

docker-ps() {
  #docker ps|sed "s/ \{3,\}/#/g"|cut -d '#' -f 1,2,7|sed "s/#/\t/g"
  docker inspect --format="{{.Name}} {{.NetworkSettings.IPAddress}} {{.Config.Image}} {{.Config.Entrypoint}} {{.Config.Cmd}}" $(docker ps -q)
}

docker-psa() {
  #docker ps|sed "s/ \{3,\}/#/g"|cut -d '#' -f 1,2,7|sed "s/#/\t/g"
  docker inspect --format="{{.Name}} {{.NetworkSettings.IPAddress}} {{.Config.Image}} {{.Config.Entrypoint}} {{.Config.Cmd}}" $(docker ps -qa)
}

amb-start-cluster() {
  local act_cluster_size=$1
  : ${act_cluster_size:=$CLUSTER_SIZE}
  echo starting an ambari cluster with: $act_cluster_size nodes

  amb-start-first
  [ $act_cluster_size -gt 1 ] && for i in $(seq $((act_cluster_size - 1))); do
    amb-start-node $i
  done
}

_amb_run_shell() {
  COMMAND=$1
  : ${COMMAND:? required}
  get-ambari-server-ip
  NODES=$(docker inspect --format="{{.Config.Image}} {{.Name}}" $(docker ps -q)|grep $IMAGE|grep $NODE_PREFIX|wc -l|xargs)
  run-command docker run -it --rm -e EXPECTED_HOST_COUNT=$((NODES-1)) -e BLUEPRINT=$BLUEPRINT --link ${AMBARI_SERVER_NAME}:ambariserver --entrypoint /bin/sh $IMAGE -c $COMMAND
}

amb-shell() {
  _amb_run_shell /tmp/ambari-shell.sh
}

amb-deploy-cluster() {
  local act_cluster_size=$1
  : ${act_cluster_size:=$CLUSTER_SIZE}

  if [[ $# -gt 1 ]]; then
    BLUEPRINT=$2
  else
    [ $act_cluster_size -gt 1 ] && BLUEPRINT=multi-node-hdfs-yarn || BLUEPRINT=single-node-hdfs-yarn
  fi

  : ${BLUEPRINT:?" required (single-node-hdfs-yarn / multi-node-hdfs-yarn / hdp-singlenode-default / hdp-multinode-default)"}

  amb-start-cluster $act_cluster_size
  _amb_run_shell /tmp/install-cluster.sh
}

amb-start-first() {
  local dns_port_command=""
  if [[ "$EXPOSE_DNS" == "true" ]]; then
     dns_port_command="-p 53:$DNS_PORT/udp"
  fi
  run-command docker run -d $dns_port_command --name $CONSUL -h $CONSUL.service.consul $CONSUL_IMAGE -server -bootstrap
  sleep 5

  run-command docker run -d -e BRIDGE_IP=$(get-consul-ip) $DOCKER_OPTS --name $AMBARI_SERVER_NAME -h $AMBARI_SERVER_NAME.service.consul $IMAGE /start-server

  get-ambari-server-ip

  _consul-register-service $AMBARI_SERVER_NAME $AMBARI_SERVER_IP
  _consul-register-service ambari-8080 $AMBARI_SERVER_IP
}

amb-copy-to-hdfs() {
  get-ambari-server-ip
  FILE_PATH=${1:?"usage: <FILE_PATH> <NEW_FILE_NAME_ON_HDFS> <HDFS_PATH>"}
  FILE_NAME=${2:?"usage: <FILE_PATH> <NEW_FILE_NAME_ON_HDFS> <HDFS_PATH>"}
  DIR=${3:?"usage: <FILE_PATH> <NEW_FILE_NAME_ON_HDFS> <HDFS_PATH>"}
  amb-create-hdfs-dir $DIR
  DATANODE=$(curl -si -X PUT "http://$AMBARI_SERVER_IP:50070/webhdfs/v1$DIR/$FILE_NAME?user.name=hdfs&op=CREATE" |grep Location | sed "s/\..*//; s@.*http://@@")
  DATANODE_IP=$(get-host-ip $DATANODE)
  curl -T $FILE_PATH "http://$DATANODE_IP:50075/webhdfs/v1$DIR/$FILE_NAME?op=CREATE&user.name=hdfs&overwrite=true&namenoderpcaddress=$AMBARI_SERVER_IP:8020"
}

amb-create-hdfs-dir() {
  get-ambari-server-ip
  DIR=$1
  curl -X PUT "http://$AMBARI_SERVER_IP:50070/webhdfs/v1$DIR?user.name=hdfs&op=MKDIRS" > /dev/null 2>&1
}

amb-scp-to-first() {
  get-ambari-server-ip
  FILE_PATH=${1:?"usage: <FILE_PATH> <DESTINATION_PATH>"}
  DEST_PATH=${2:?"usage: <FILE_PATH> <DESTINATION_PATH>"}
  scp $FILE_PATH root@$AMBARI_SERVER_IP:$DEST_PATH
}

amb-start-node() {
  get-ambari-server-ip
  : ${AMBARI_SERVER_IP:?"AMBARI_SERVER_IP is needed"}
  NUMBER=${1:?"please give a <NUMBER> parameter it will be used as node<NUMBER>"}
  if [[ $# -eq 1 ]]; then
    MORE_OPTIONS="-d"
  else
    shift
    MORE_OPTIONS="$@"
  fi

  run-command docker run $MORE_OPTIONS -e BRIDGE_IP=$(get-consul-ip) $DOCKER_OPTS --name ${NODE_PREFIX}$NUMBER -h ${NODE_PREFIX}${NUMBER}.service.consul $IMAGE /start-agent

  _consul-register-service ${NODE_PREFIX}${NUMBER} $(get-host-ip ${NODE_PREFIX}$NUMBER)
}

_consul-register-service() {
  curl -X PUT -d "{
    \"Node\": \"$1\",
    \"Address\": \"$2\",
    \"Service\": {
      \"Service\": \"$1\"
    }
  }" http://$(get-consul-ip):8500/v1/catalog/register
}
