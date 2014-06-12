#!/bin/bash

: ${IMAGE:="sequenceiq/ambari"}
: ${AMBARI_CONTAINER_NAME:=ambari-warm-container}
: ${WARM_IMAGE:=ambari-warm}
: ${BUILD_DIR:=/tmp/warmup}
: ${BLUEPRINT:=warmup}
: ${DEBUG:=1}

debug() {
  [ $DEBUG -gt 0 ] && echo [DEBUG] "$@" 1>&2
}

debug start standalone cluster
AMBARI_CONTAINER=$(docker run -d -p 8080 -h amb0.mycorp.kom --name $AMBARI_CONTAINER_NAME $IMAGE --tag ambari-server=true)
debug use ambari-shell blueprint to install cluster
docker run -e BLUEPRINT=$BLUEPRINT --link $AMBARI_CONTAINER_NAME:ambariserver -it --rm --entrypoint /bin/sh sequenceiq/ambari-shell -c /tmp/install-cluster.sh

debug commit resulted container as dirty
docker commit $AMBARI_CONTAINER $WARM_IMAGE:dirty

debug clean container
docker stop -t 0 $AMBARI_CONTAINER
#docker rm $AMBARI_CONTAINER

debug clean up image by reseting psql db

docker build --no-cache=true -t $WARM_IMAGE - <<EOF
FROM $WARM_IMAGE:dirty

RUN service postgresql restart ; ambari-server reset --silent
ENTRYPOINT ["/usr/local/serf/bin/start-serf-agent.sh"]
CMD ["--log-level", "debug"]
EOF
