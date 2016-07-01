# Creates a kylin 1.5.2 + HDP 2.2 image

FROM sequenceiq/pam:centos-6.5
MAINTAINER Kyligence Inc

USER root

ADD HDP.repo /etc/yum.repos.d/HDP.repo
ADD HDP-UTILS.repo /etc/yum.repos.d/HDP-UTILS.repo

RUN rpm -iUvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# hadoop, hive, hbase
RUN yum install -y hbase tez hadoop snappy snappy-devel hadoop-libhdfs ambari-log4j hive hive-hcatalog hive-webhcat webhcat-tar-hive mysql-connector-java 
RUN yum -y remove java*

# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-7u71-linux-x64.rpm
RUN rm jdk-7u71-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

# kylin 1.5.2
RUN curl -s https://www-us.apache.org/dist/kylin/apache-kylin-1.5.2.1/apache-kylin-1.5.2.1-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./apache-kylin-1.5.2.1-bin kylin
ENV KYLIN_HOME /usr/local/kylin

# fixing the libhadoop.so like a boss
RUN mkdir -p /usr/local/hadoop/lib/native/
RUN curl -Ls http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.6.0.tar | tar -x -C /usr/local/hadoop/lib/native/

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

CMD ["/etc/bootstrap.sh", "-d"]

ENV JAVA_LIBRARY_PATH /usr/local/hadoop/lib/native:/usr/hdp/2.2.9.0-3393/hadoop/lib/native:$JAVA_LIBRARY_PATH

# Kylin and Other ports
EXPOSE 7070 7443 49707 2122

ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV HBASE_CONF_DIR /etc/hbase/conf
ENV HIVE_CONF_DIR /etc/hive/conf

# Add configuration files
ADD conf/core-site.xml $HADOOP_CONF_DIR/core-site.xml
ADD conf/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
ADD conf/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
ADD conf/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml
ADD conf/hbase-site.xml $HBASE_CONF_DIR/hbase-site.xml
ADD conf/hdfs-site.xml $HBASE_CONF_DIR/hdfs-site.xml
ADD conf/hive-site.xml $HIVE_CONF_DIR/hive-site.xml
ADD conf/mapred-site.xml $HIVE_CONF_DIR/mapred-site.xml
ADD conf/kylin.properties $KYLIN_HOME/conf/kylin.properties
