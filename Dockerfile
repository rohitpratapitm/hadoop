# build command is:
# docker build --no-cache --rm=true -t psu-hadoop .
# run command is :
# docker run -it --name psu-hadoop-container -p 22:22 -p 8042:8042 -p 9864:9864 -p 9870:9870 -p 8088:8088 -p 10000:10000 -p 19888:19888 psu-hadoop
# exec command is 
# docker exec -it <countainer_id> bash
# test
# docker run -it --name psu-hadoop-container -p 50070:50070 -p 50075:50075 -p 50010:50010 -p 50020:50020 -p 50090:50090 -p 8020:8020 -p 9000:9000 -p 9864:9864 -p 9870:9870 -p 10000:10000 -p 10020:10020 -p 19888:19888 -p 8088:8088 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 -p 22:22  psu-hadoop

FROM psu-ubuntu-java:latest

ENV HADOOP_HOME         /usr/local/hadoop 
ENV PIG_HOME            /usr/local/pig
ENV HIVE_HOME           /usr/local/hive
ENV HCAT_HOME           $HIVE_HOME/hcatalog
ENV JAVA_HOME           /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV SPARK_HOME          /usr/local/spark
ENV HADOOP_MAPRED_HOME  $HADOOP_HOME

ENV PIG_CONF_DIR       $PIG_HOME/conf
ENV HIVE_CONF_DIR      $HIVE_HOME/conf
ENV SPARK_CONF_DIR     $SPARK_HOME/conf

ENV PIG_CLASSPATH      $HIVE_HOME/lib/*:$PIG_HOME/lib/*:$HCAT_HOME/share/hcatalog/*
ENV HADOOP_CLASSPATH $JAVA_HOME/lib/tools.jar:$HIVE_HOME/lib/*.jar
ENV PATH             $JAVA_HOME/bin:$PATH:$HIVE_HOME/bin:$HIVE_HOME/conf:$PIG_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV CLASSPATH        $CLASSPATH:$HADOOP_HOME/lib/*:$HIVE_HOME/lib/*:$PIG_HOME/lib/*:.

ENV HDFS_NAMENODE_USER          root
ENV HDFS_DATANODE_USER          root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER   root
ENV YARN_NODEMANAGER_USER       root

RUN \
#    apt-get purge openjdk-*                         && \
#    update-alternatives --remove "java" "/opt/jdk/" && \
#    rm -Rf /opt/jdk                                 && \
    apt-get update -y                               && \
    apt-get install  -y                                \
        ant                                            \
        curl                                           \
	gzip                                           \
	nano                                           \
	net-tools                                      \
	openjdk-8-jdk                                  \
	python3                                         \
	pdsh                                           \
	psmisc                                         \
	rsync                                          \
	software-properties-common                     \
	ssh                                            \
	sudo                                           \
	tar                                            \
	telnet                                         \
	vim                                            \
        wget                                        && \
    apt-get autoremove -y                           && \
    cd /usr/bin/                                    && \
    rm python -f                                    && \
    ln -s python3 python                            && \
    cd /root

RUN \ 
    ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa                 && \
    cat /root/.ssh/id_rsa.pub>>/root/.ssh/authorized_keys        && \
    chmod 0600 /root/.ssh/authorized_keys                        && \
    rm -f /root/.ssh/config                                      && \
    echo "Host *"                         >> /root/.ssh/config   && \
    echo "  UserKnownHostsFile /dev/null" >> /root/.ssh/config   && \
    echo "  StrictHostKeyChecking no"     >> /root/.ssh/config   && \
    echo "  LogLevel quiet"               >> /root/.ssh/config   && \
    chmod 600 /root/.ssh/config                                  && \
    chown root:root /root/.ssh/config                            && \
    echo "ssh" > /etc/pdsh/rcmd_default                          && \
    /etc/init.d/ssh start && update-rc.d ssh defaults && systemctl enable ssh.socket


RUN \
    wget -q -O hadoop-3.3.0.tar.gz https://pennstateoffice365-my.sharepoint.com/:u:/g/personal/asb16_psu_edu/EVxvAVX8ZTVGnMbjxpIvdKcBhSho_jh_fn5706GtNIXrYg?download=1 && \
    tar zxvf hadoop-3.3.0.tar.gz                                                                       && \
    mv  hadoop-3.3.0 $HADOOP_HOME                                                                      && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    rm hadoop-3.3.0.tar.gz                                                                             && \
    for user in hadoop hdfs yarn mapred hue; do                                                           \
        useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user};                                          \
    done                                                                                               && \
    for user in root hdfs yarn mapred hue; do                                                             \
        usermod -G hadoop ${user};                                                                        \
    done                                                                                               && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh                && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh                    && \
    mkdir -p $HADOOP_HOME/share/hadoop/mapreduce/lib

RUN \
    rm $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"                      >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "<configuration>"                                                 >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "    <property>"                                                  >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "        <name>fs.defaultFS</name>"                               >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "        <value>hdfs://localhost:9000</value>"                    >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "    </property>"                                                 >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo "</configuration>"                                                >> $HADOOP_HOME/etc/hadoop/core-site.xml 


# COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
RUN \
    rm $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"                      >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "<configuration>"                                                 >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "    <property>"                                                  >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "        <name>dfs.replication</name>"                            >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "        <value>1</value>"                                        >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "    </property>"                                                 >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "    <property>"                                                  >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "        <name>dfs.permissions</name>"                            >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "        <value>false</value>"                                    >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "    </property>"                                                 >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo "</configuration>"                                                >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/
RUN \
    rm $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "<?xml version=\"1.0\"?>"                             >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "<configuration>"                                     >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "    <property>"                                      >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "        <name>yarn.nodemanager.aux-services</name>"  >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "        <value>mapreduce_shuffle</value>"            >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "    </property>"                                     >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "    <property>"                                      >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "        <name>yarn.nodemanager.env-whitelist</name>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>" >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "    </property>"                                     >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo "</configuration>"                                    >> $HADOOP_HOME/etc/hadoop/yarn-site.xml 

RUN \
    rm $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    echo "<?xml version=\"1.0\"?>"                                      >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"  >> $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    echo "<configuration>"                                              >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "    <property>"                                               >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "        <name>mapreduce.framework.name</name>"                >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "        <value>yarn</value>"                                  >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "    </property>"                                              >> $HADOOP_HOME/etc/hadoop/mapred-site.xml     && \
    echo "</configuration>"                                             >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
 
 RUN \
   echo '#!/bin/bash'                                                        >> /etc/bootstrap.sh && \
   echo 'rm /tmp/*.pid'                                                      >> /etc/bootstrap.sh && \
   echo '/etc/init.d/ssh start'                                              >> /etc/bootstrap.sh && \
   echo '/usr/local/hadoop/etc/hadoop/hadoop-env.sh'                         >> /etc/bootstrap.sh && \
   echo '/usr/local/hadoop/sbin/start-dfs.sh'                                >> /etc/bootstrap.sh && \
   echo '/usr/local/hadoop/sbin/start-yarn.sh'                               >> /etc/bootstrap.sh && \
   echo '/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver' >> /etc/bootstrap.sh && \
   echo 'jps'                                                                >> /etc/bootstrap.sh && \
   chown root:root /etc/bootstrap.sh                                                              && \
   chmod 700 /etc/bootstrap.sh                                                                    && \
   chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh                                                 

# Install pig
RUN \
    wget -q -O pig-0.17.0.tar.gz https://pennstateoffice365-my.sharepoint.com/:u:/g/personal/asb16_psu_edu/ESiEb8ymN9pPiWMDCLI8M-8BUc5tsbUh6leDk7I5XQljIw?download=1 && \
    tar xzf pig-0.17.0.tar.gz                                                                                               && \
    mv pig-0.17.0 $PIG_HOME                                                                                                 && \
    rm pig-0.17.0.tar.gz                                                                                                    && \
    echo "pig.load.default.statements=$PIGHOME/.pigbootup"                                 >> $PIG_HOME/conf/pig.properties && \
    echo "REGISTER /usr/local/hive/hcatalog/share/hcatalog/hive-hcatalog-core-3.1.2.jar; " >> $PIGHOME/.pigbootup           && \
    echo "REGISTER /usr/local/hive/lib/hive-exec-3.1.2.jar;"                               >> $PIGHOME/.pigbootup           && \
    echo "REGISTER /usr/local/hive/lib/hive-metastore-3.1.2.jar;"                          >> $PIGHOME/.pigbootup

# install hive
RUN \
    wget -q -O apache-hive-3.1.2-bin.tar.gz https://pennstateoffice365-my.sharepoint.com/:u:/g/personal/asb16_psu_edu/EZn2rf0UgMpDrAJpi10dXOIBmvbZbB2v80sd2b2LtzNFcw?download=1 && \
    tar xzf apache-hive-3.1.2-bin.tar.gz                                           && \
    mv apache-hive-3.1.2-bin $HIVE_HOME                                            && \
    rm apache-hive-3.1.2-bin.tar.gz                                                && \
    rm -f $HIVE_HOME/conf/hive-env.sh                                              && \
    cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh            && \
    echo "export HADOOP_HOME=/usr/local/hadoop" >> $HIVE_HOME/conf/hive-env.sh     && \
    rm -f $HIVE_HOME/lib/guava*.jar                                                && \
    cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/       && \
    echo "alias bl='beeline -u jdbc:hive2://localhost:10000 -n root '" >> /root/.bashrc

# copy $HIVE_HOME/conf/hive-site.xml
RUN \
    rm -f $HIVE_HOME/conf/hive-site.xml                                                                     && \
    echo "<?xml version=\"1.0\"?> "                                        >> $HIVE_HOME/conf/hive-site.xml && \
    echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $HIVE_HOME/conf/hive-site.xml && \
    echo "<configuration>"                                                 >> $HIVE_HOME/conf/hive-site.xml && \
    echo "<property>"                                                      >> $HIVE_HOME/conf/hive-site.xml && \
    echo "    <name>hive.metastore.event.db.notification.api.auth</name>"  >> $HIVE_HOME/conf/hive-site.xml && \
    echo "     <value>false</value>"                                       >> $HIVE_HOME/conf/hive-site.xml && \
    echo "     <description>"                                              >> $HIVE_HOME/conf/hive-site.xml && \
    echo "       Should metastore do auth against db notif related APIs."  >> $HIVE_HOME/conf/hive-site.xml && \
    echo "       If true, only the superusers the permission"              >> $HIVE_HOME/conf/hive-site.xml && \
    echo "     </description>"                                             >> $HIVE_HOME/conf/hive-site.xml && \
    echo "   </property>"                                                  >> $HIVE_HOME/conf/hive-site.xml && \
    echo "</configuration>"                                                >> $HIVE_HOME/conf/hive-site.xml
 
 #RUN \
 #   hdfs dfs -mkdir -p  /tmp                             && \
 #   hdfs dfs -chmod g+w /tmp                             && \
 #   hdfs dfs -mkdir -p  /user/hive/warehouse             && \
 #   hdfs dfs -chmod g+w /user/hive/warehouse             
 #   $HIVE_HOME/bin/schematool -dbType derby -initSchema  && \
 #   sleep 10
 
RUN \
   rm -Rf /tmp/*                                                                                  && \
   echo '#!/usr/bin/env bash'                                                >> /entry.sh         && \
   echo "if [ ! -d \"/tmp/hadoop-root/dfs/name\" ]; then"                    >> /entry.sh         && \
   echo "        $HADOOP_HOME/bin/hdfs namenode -format"                     >> /entry.sh         && \
   echo "        hdfs dfs -mkdir -p  /tmp"                                   >> /entry.sh         && \
   echo "        hdfs dfs -chmod g+w /tmp"                                   >> /entry.sh         && \
   echo "        hdfs dfs -mkdir -p  /user/hive/warehouse"                   >> /entry.sh         && \
   echo "        hdfs dfs -chmod g+w /user/hive/warehouse"                   >> /entry.sh         && \
   echo "        $HIVE_HOME/bin/schematool -dbType derby -initSchema & "     >> /entry.sh         && \
   echo "fi"                                                                 >> /entry.sh         && \
   echo "/etc/bootstrap.sh -d & "                                               >> /entry.sh         && \
   echo "hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=ERROR,DRFA --hiveconf hive.server2.enable.doAs=false & " >> /entry.sh && \
   echo "tail -f /dev/null"                                                  >> /entry.sh         && \
   chmod a+x /entry.sh    
   
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10000 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

ENTRYPOINT ["/entry.sh"]

  
# ps -ef | grep spark-shell
# beeline exit is !q 
# pig exit is quit
# spark python exit is exit()
# spark scala exit System.exit(0)
# start spark master $SPARK_HOME/sbin/start-master.sh
# start spark worker $SPARK_HOME/sbin/start-slave.sh spark://localhost:7077
# start spark shell (scala)  $SPARK_HOME/bin/spark-shell
# start spark shell (python)  $SPARK_HOME/bin/pyspark
 