# Kylin on Docker
This repository trackes the code and files for building docker images with [Apache Kylin](http://kylin.apache.org).

Please note: this is the master branch, which doesn't have the scripts and Dockerfile; You need checkout the specific branch which named with Kylin version and Hadoop release name.

## Background

Apache Kylin is an open source Distributed Analytics Engine designed to provide SQL interface and multi-dimensional analysis (OLAP) on Hadoop supporting extremely large datasets. For more information you can visit Kylin home page at http://kylin.apache.org

Usually Kylin is deployed in a dedicated Hadoop client node, on which the Hadoop, HBase, Hive and other clients have been properly configured to communicate with the cluster; Kylin will use the client Jars and configuration files to work with other components; Besides, all Kylin metadata and cube data are persistended in HBase and HDFS, not in local, so all these make it very reasonable to build Kylin as a docker image for quick deploy.

## How to make it

The main idea is building Hadoop/HBase/Hive clients and Kylin binary package into one image; User can pull this image, and then just add client configuration files like core-site.xml, hdfs-site.xml, yarn-site.xml, hbase-site.xml, hive-site.xml and kylin.properties to the effective paths to make a new image (has verified), or upload these files during starting up (not verified yet);

Before start, you need do some preparations:
* check the Hadoop versions, and make sure the client libs in the image are compitable with the cluster;
* prepare a kylin.properties file for this deployment;
* ensure the Hadoop security constraint will not block Docker's adoption; you may need run additional component in the container if kerberos is enabled.

## Steps

Below is a sample of building and running a docker image for Hortonworks HDP 2.2 cluster.

1. Collect the client configuration files
  Get the *-site.xml files from a working Hadoop client node, to a local folder say "~/hadoop-conf/";

2. Prepare kylin.properties 

  The kylin.properties file is the main configuration file for Kylin; you need prepare such a file and put it to the "~/hadoop-conf/" folder, together with other conf files; suggest to double check the parameters in it; e.g, the "kylin.metadata.url" points to the right metadata table, "kylin.hdfs.working.dir" is an existing HDFS folder and you have permission to write, etc.

3. Clone this repository, checkout the correct branch;
  ```
  git clone https://github.com/Kyligence/kylin-docker  
  cd kylin-docker  
  git checkout kylin152-hdp22  
  ```  

4. Copy the client configuration files to "kylin-docker/conf" folder, overwriting those template files;
  ```
  cp -rf ~/hadoop-conf/* conf/
  ```

5. Build docker image, which may take a while, just take a cup of tea; 
  ```
  docker build -t kyligence/kylin:152 .
  ```

  After the build finished, should be able to see the image with "docker images" commmand;
  ```
  [root@ip-10-0-0-38 ~]# docker images  
  REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE  
  kyligence/kylin     152                 7ece32097fa3        About an hour ago   3.043 GB  
  ```

6. Now you can run a contianer with the bootstrap command (in which will start Kylin server). The "-bash" argument is telling to keep in bash so you can continue to run bash commands; If don't need, you can use the "-d" argument:
  ```
[root@ip-10-0-0-38 ~]# docker run -i -t -p 7070:7070 kyligence/kylin:152 /etc/bootstrap.sh -bash  
Generating SSH1 RSA host key:                              [  OK  ]  
Starting sshd:                                             [  OK  ]  
KYLIN_HOME is set to /usr/local/kylin/bin/../  
kylin.security.profile is set to ldap  
16/06/30 04:50:31 WARN conf.HiveConf: HiveConf of name hive.optimize.mapjoin.mapreduce does not exist  
16/06/30 04:50:31 WARN conf.HiveConf: HiveConf of name hive.heapsize does not exist  
16/06/30 04:50:31 WARN conf.HiveConf: HiveConf of name hive.server2.enable.impersonation does not exist  
16/06/30 04:50:31 WARN conf.HiveConf: HiveConf of name hive.auto.convert.sortmerge.join.noconditionaltask does not exist  
Logging initialized using configuration in file:/etc/hive/conf/hive-log4j.properties  
HCAT_HOME not found, try to find hcatalog path from hadoop home  
A new Kylin instance is started by , stop it using "kylin.sh stop"  
Please visit http://<ip>:7070/kylin  
You can check the log at /usr/local/kylin/bin/..//logs/kylin.log  
  ```

7. After a minute, you can open web browser with address http://host:7070/kylin , here the "host" is the hostname or IP address of the hosting machine which runs Docker; Its 7070 port will redirect to the contianer's 7070 port as we specified in the "docker run" command; You can change to other port as you like.

8. Now you can use Kylin as usually: import Hive tables, design cubes, build, query, etc. 

## Thanks

Thanks to SequenceIQ's [hadoop-docker](https://github.com/sequenceiq/hadoop-docker/) and other projects, which inspires us on developing this. 


