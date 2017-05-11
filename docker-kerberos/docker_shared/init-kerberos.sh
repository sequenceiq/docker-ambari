#!/bin/bash

: ${KERB_MASTER_KEY:=masterkey}
: ${REALM:=SERVICE.CONSUL}
: ${KERB_ADMIN_USER:=admin}
: ${KERB_ADMIN_PASS:=admin}

create_config() {
  cp /docker_shared/krb5.conf /etc/krb5.conf
}

create_db() {
  /usr/sbin/kdb5_util -P $KERB_MASTER_KEY -r $REALM create -s
}

create_admin_user() {
  kadmin.local -q "addprinc -pw $KERB_ADMIN_PASS $KERB_ADMIN_USER/admin"
  echo "*/admin@$REALM *" > /var/kerberos/krb5kdc/kadm5.acl
}

fix_hostname() {
  sed -i "/^hosts:/ s/ *files dns/ dns files/" /etc/nsswitch.conf
}

create_db() {
  /usr/sbin/kdb5_util -P $KERB_MASTER_KEY -r $REALM create -s
}

start_kdc() {
  mkdir -p /var/log/kerberos

  chkconfig krb5kdc on
  chkconfig kadmin on
 
  /sbin/service krb5kdc start #/etc/rc.d/init.d/krb5kdc start
  /sbin/service kadmin start #/etc/rc.d/init.d/kadmin start
}

restart_kdc() {
  /etc/rc.d/init.d/krb5kdc restart
  /etc/rc.d/init.d/kadmin restart
}

create_admin_user() {
  kadmin.local -q "addprinc -pw $KERB_ADMIN_PASS $KERB_ADMIN_USER/admin"
  echo "*/admin@$REALM *" > /var/kerberos/krb5kdc/kadm5.acl
}

main() {
  ln -s /docker_shared/etc/resolv.conf /tmp/resolv.conf
  cp /tmp/resolv.conf /etc/resolv.conf

  mkdir -p /var/log/kerberos

  if [ ! -f /var/kerberos/kerberos_initialized ]; then
    create_config
    create_db
    create_admin_user
    start_kdc

    touch /var/kerberos/kerberos_initialized
  fi

  tail -f /dev/null
  #fix_hostname
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
