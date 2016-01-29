#!/bin/bash

: ${CLOUD_PLATFORM:="none"}
: ${USE_CONSUL_DNS:="true"}

[[ "TRACE" ]] && set -x

debug() {
  [[ "DEBUG" ]]  && echo "[DEBUG] $@" 1>&2
}

get_nameserver_addr() {
  if [[ "$NAMESERVER_ADDR" ]]; then
    echo $NAMESERVER_ADDR
  else
    if ip addr show docker0 &> /dev/null; then
      ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
    else
      ip ro | grep default | cut -d" " -f 3
    fi
  fi
}

# --dns isn't available for: docker run --net=host
# sed -i /etc/resolf.conf fails:
# sed: cannot rename /etc/sedU9oCRy: Device or resource busy
# here comes the tempfile workaround ...
local_nameserver() {
  cat>/etc/resolv.conf<<EOF
nameserver $(get_nameserver_addr)
search service.consul node.dc1.consul
EOF
}

wait_for_db() {
  while : ; do
    PGPASSWORD=bigdata psql -h $POSTGRES_DB -U ambari -c "select 1"
    [[ $? == 0 ]] && break
    sleep 5
  done
}

# GCP overrides the /etc/hosts file with its internal hostname, so we need to change the
# order of the host resolution to try the DNS first
reorder_dns_lookup() {
  if [ "$CLOUD_PLATFORM" == "GCP" ] || [ "$CLOUD_PLATFORM" == "GCC" ]; then
    sed -i "/^hosts:/ s/ *files dns/ dns files/" /etc/nsswitch.conf
  fi
}

config_remote_jdbc() {
  if [ -z "$POSTGRES_DB" ]
  then
    ambari-server setup --silent --java-home $JAVA_HOME
  else
    echo Configure remote jdbc connection
    ambari-server setup --silent --java-home $JAVA_HOME --database postgres --databasehost $POSTGRES_DB --databaseport 5432 --databasename postgres \
         --postgresschema postgres --databaseusername ambari --databasepassword bigdata
    wait_for_db
    PGPASSWORD=bigdata psql -h $POSTGRES_DB -U ambari postgres < /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql
  fi
}

# https://issues.apache.org/jira/browse/AMBARI-14627
silent_security_setup() {

  cp /usr/sbin/ambari-server.py /usr/sbin/ambari-server_backup.py
  cp /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py /usr/lib/python2.6/site-packages/ambari_server/setupSecurity_backup.py
  sed -i '/^.*choice = get_validated_string_input/ s/.*/  choice = "2"/' /usr/sbin/ambari-server.py
  sed -i -e '/^.*Invalid choice/d' /usr/sbin/ambari-server.py
  sed -i '/^.*masterKey = get_validated_string_input/ s/.*/    masterKey = "bigdata"/' /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py
  sed -i '/^.*masterKey2 = get_validated_string_input/ s/.*/    masterKey2 = "bigdata"/' /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py
  sed -i -e '/^.*passwordPattern, passwordDescr/d' /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py
  sed -i '/^.*persist = / s/.*/    persist = True/' /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py
  sed -i -e '/^.*not to persist/,+4d' /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py
  ambari-server setup-security
  mv /usr/sbin/ambari-server_backup.py /usr/sbin/ambari-server.py
  mv /usr/lib/python2.6/site-packages/ambari_server/setupSecurity_backup.py /usr/lib/python2.6/site-packages/ambari_server/setupSecurity.py

}

main() {
  [[ "$USE_CONSUL_DNS" == "true" ]] && local_nameserver
  reorder_dns_lookup
  if [ ! -f "/var/ambari-init-executed" ]; then
    config_remote_jdbc
    silent_security_setup
  fi
  echo $(date +%Y-%m-%d:%H:%M:%S) >> /var/ambari-init-executed
}

main "$@"
