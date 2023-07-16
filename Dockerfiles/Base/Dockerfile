# build command is:
# docker build --rm=true -t psu-ubuntu-java .
# run command is :
# docker run -it --name psu-ubuntu-java psu-ubuntu-java bash 
# docker run -it -v C:\Temp\Data:/psuprojects --name psu-ubuntu-java psu-ubuntu-java bash
# exec command is 
# docker start <container_id>
# docker exec -it <container_id> bash 

# remove dangling images
# docker rmi $(docker images -f "dangling=true" -q)
# remove all containers: DO NOT DO IT
# docker stop $(docker ps -a -q)
# docker rm $(docker ps -a -q)


FROM ubuntu:latest

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# set environment variables
ENV JAVA_HOME /opt/jdk
ENV PATH $PATH:$JAVA_HOME/bin

# update list of software
#RUN apt-get update

# install software including the "nano" editor
RUN \
   apt-get update && \
   apt-get install -y --no-install-recommends \
      bzip2 \
      curl \
      unzip \
      wget \
      xz-utils \
      python3-pip \
      nano \
      software-properties-common 
      
# create student account enable firewall
RUN \
  useradd student && \
  echo -e "student\nstudent" | passwd student && \
  usermod -aG sudo student

#remove open-jdk
RUN \
   apt-get purge -y openjdk* && \
   apt-get autoremove -y

# Install Oracle Java 
RUN \
   wget -q -O ./jdk-11.0.8_linux-x64_bin.tar.gz https://pennstateoffice365-my.sharepoint.com/:u:/g/personal/asb16_psu_edu/EbYW_hTS4UdInGqNEzGDxZoBydtDVGx8oUA7EWilMfPy_A?download=1  && \
   tar -zxf jdk-11.0.8_linux-x64_bin.tar.gz  && \
   mv jdk-11.0.8 $JAVA_HOME && \
   rm jdk-11.0.8_linux-x64_bin.tar.gz && \
   mkdir /psuprojects && \
   update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 100 && \
   update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 100


VOLUME  ["/psuprojects"]



