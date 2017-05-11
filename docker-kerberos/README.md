## Docker kerberos
This image
is designed to support the Hadoop clusters launched by Cloudbreak. The default realm is `NODE.DC1.CONSUL` and the default admin principal is `admin/admin`. All the default values can be modified with environment variables.

### Usage

The image can be started in bootstrap mode and non-bootstrap mode. Bootstrap mode means
when the container is launched it will create the DB for kerberos along with the admin user and start the KDC. 
This use-case is convenient for a quick start. The non-bootstrap mode relies on that a third party will do the necessary steps to create the appropriate principals thus the KDC will start only once they are created. 
Cloudbreak does this with a [consul plugn](https://github.com/sequenceiq/consul-plugins-kerberos).

#### Quick start
```
docker run -d --net=host -v /etc/krb5.conf:/etc/krb5.conf -v /dev/urandom:/dev/random --name kerberos -e BOOTSTRAP=0 sequenceiq/kerberos
```
The containers have a pretty bad entropy level so the KDC won't start because of this. We can overcome this by using `/dev/urandom` which is less secure but does not care about entropy. 
The `/etc/krb5.conf` is shared with the host so the generated configuration will be present on the host as well. We need to share this configuration with the `ambari-server` container as well or you need to take care of the copying.
Once the container is running you can enable kerberos with `Ambari`.

Useful environment variables:

| Environmenr variables | Description |
| --------------------- | ----------------------------- |
| `REALM`               | the Kerberos realm            |
| `DOMAIN_REALM`        | the DNS domain for the realm  |
| `KERB_MASTER_KEY`     | master key for the KDC        |
| `KERB_ADMIN_USER`     | administrator account name    |
| `KERB_ADMIN_PASS`     | administrator's password      |
| `SEARCH_DOMAINS`      | domain suffix search list     |

### Test
Once kerberos is enabled you need a `ticket` to execute any job on the cluster. Here's an example to get a ticket:
```
kinit -V -kt /etc/security/keytabs/smokeuser.headless.keytab ambari-qa-sparktest-rec@NODE.DC1.CONSUL
```
Example job:
```java
export HADOOP_LIBS=/usr/hdp/current/hadoop-mapreduce-client
export JAR_EXAMPLES=$HADOOP_LIBS/hadoop-mapreduce-examples.jar
export JAR_JOBCLIENT=$HADOOP_LIBS/hadoop-mapreduce-client-jobclient.jar

hadoop jar $JAR_EXAMPLES teragen 10000000 /user/ambari-qa/terasort-input

hadoop jar $JAR_JOBCLIENT mrbench -baseDir /user/ambari-qa/smallJobsBenchmark -numRuns 5 -maps 10 -reduces 5 -inputLines 10 -inputType ascending
```
