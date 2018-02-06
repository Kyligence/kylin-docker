FROM java:8-jre

MAINTAINER Kyligence Inc

WORKDIR /tmp

RUN set -x \
    && apt-get update && apt-get install -y wget vim telnet ntp \
    && update-rc.d ntp defaults

ARG MIRROR=mirror.bit.edu.cn

# Installing Hadoop
ARG HADOOP_VERSION=2.7.4
# COPY hadoop-${HADOOP_VERSION}.tar.gz .
RUN set -x \
    && wget -q http://${MIRROR}/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local/ \
    && mv /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Installing Spark
ARG SPARK_VERSION=2.2.1
# COPY spark-${SPARK_VERSION}-bin-without-hadoop.tgz .
RUN set -x \
    && wget -q http://${MIRROR}/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && tar -xzvf spark-${SPARK_VERSION}-bin-without-hadoop.tgz -C /usr/local/ \
    && mv /usr/local/spark-${SPARK_VERSION}-bin-without-hadoop /usr/local/spark
ENV SPARK_HOME=/usr/local/spark
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH

# Installing Hive
ARG HIVE_VERSION=1.2.2
# COPY apache-hive-${HIVE_VERSION}-bin.tar.gz .
RUN set -x \
    && wget -q http://${MIRROR}/apache/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar -xzvf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /usr/local/ \
    && mv /usr/local/apache-hive-${HIVE_VERSION}-bin /usr/local/hive
ENV HIVE_HOME=/usr/local/hive
ENV HCAT_HOME=$HIVE_HOME/hcatalog
ENV HIVE_CONF=$HIVE_HOME/conf

# Installing HBase
ARG HBASE_VERSION=1.3.1
# COPY hbase-${HBASE_VERSION}-bin.tar.gz .
RUN set -x \
    && wget -q http://${MIRROR}/apache/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xzvf hbase-${HBASE_VERSION}-bin.tar.gz -C /usr/local/ \
    && mv /usr/local/hbase-${HBASE_VERSION} /usr/local/hbase
ENV HBASE_HOME=/usr/local/hbase

# Installing Kylin
ARG KYLIN_VERSION=2.2.0
# COPY apache-kylin-${KYLIN_VERSION}-bin-hbase1x.tar.gz .
RUN set -x \
    && wget -q http://${MIRROR}/apache/kylin/apache-kylin-${KYLIN_VERSION}/apache-kylin-${KYLIN_VERSION}-bin-hbase1x.tar.gz \
    && tar -xzvf apache-kylin-${KYLIN_VERSION}-bin-hbase1x.tar.gz -C /usr/local/ \
    && mv /usr/local/apache-kylin-${KYLIN_VERSION}-bin /usr/local/kylin
ENV KYLIN_HOME=/usr/local/kylin

# Setting the PATH environment variable
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$HIVE_HOME/bin:$HBASE_HOME/bin:$KYLIN_HOME/bin

COPY client-conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY client-conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY client-conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY client-conf/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY client-conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
COPY client-conf/hdfs-site.xml $HBASE_HOME/conf/hdfs-site.xml
COPY client-conf/hive-site.xml $HIVE_HOME/conf/hive-site.xml
COPY client-conf/mapred-site.xml $HIVE_HOME/conf/mapred-site.xml

# Cleanup
RUN rm -rf /tmp/*

WORKDIR /root
EXPOSE 7070

VOLUME /usr/local/kylin/logs

ENTRYPOINT ["sh", "-c", "/usr/local/kylin/bin/kylin.sh start; bash"]
