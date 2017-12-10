#!/bin/sh
echo "exclude=jdk*,openjdk*" >> /etc/yum.conf
yum remove --assumeyes *openjdk* jdk
rpm -ivh "http://archive.cloudera.com/director/redhat/7/x86_64/director/2.5.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
sudo alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_121-cloudera/jre/bin/java 100
sudo rm -v /usr/java/default /usr/java/latest
sudo ln -s /usr/java/jdk1.8.0_121-cloudera /usr/java/default
sudo ln -s /usr/java/jdk1.8.0_121-cloudera /usr/java/latest
exit 0
