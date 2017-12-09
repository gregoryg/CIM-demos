#!/bin/bash
## TODO: Add Anaconda parcel setup
###  https://repo.continuum.io/pkgs/misc/parcels/
### curl -u "admin:admin" "http://${cmhost}:7180/api/v14/cm/config?view=full" |jq '{ "items": [.items[] | if .name=="REMOTE_PARCEL_REPO_URLS" then .value=.value + ",https://repo.continuum.io/pkgs/misc/parcels/" else . end]}'  > /tmp/gort2.json
### curl --silent -X PUT -H "Content-Type:application/json" -u "admin:admin" -d /tmp/gort.json

# if [ -z ${SSH_AUTH_SOCK} ] ; then
#     echo "SSH agent forwarding is not active in this shell session."
#     echo "Agent forwarding is required to install the Streamsets parcel on the CM host."
#     exit 1
# fi

# echo "Pulling cdh-projects, including the lovely notebooks/ subdirectory"
# cd
# git clone git@github.com:gregoryg/cdh-projects.git

# echo "Now setting up Streamsets"
# cd
# wget -q 'https://archives.streamsets.com/datacollector/2.2.1.0/rpm/streamsets-datacollector-2.2.1.0-all-rpms.tgz'
# tar -xzf streamsets-datacollector-2.2.1.0-all-rpms.tgz
# sudo yum -y localinstall streamsets*.rpm
# rm streamsets-datacollector-2.2.1.0-all-rpms.tgz streamsets*.rpm
# sudo service sdc start
# echo "Streamsets installed - browse to http://`hostname -f`:18630/"

echo "Compiling Scala programs needed for the demo"
wget -q http://mirrors.koehn.com/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -zxf apache-maven-3.3.9-bin.tar.gz
export JAVA_HOME=$(readlink -e /usr/java/default)
export PATH=$PATH:`pwd`/apache-maven-3.3.9/bin:$JAVA_HOME/bin
echo " ... copying Connected Car demo directory"
mkdir -p demos
hdfs dfs -copyToLocal -p s3a://gregoryg/demos/ConnectedCarDemo demos/ConnectedCarDemo
cd demos/ConnectedCarDemo/demo/entity360
mvn clean package
cd bin/
# cmhost, data collector host
# zkhost=$(curl -u "admin:admin" "http://$cmhost:7180/api/v14/hosts?view=FULL" | jq -r '[.items[] | select(.roleRefs[].roleName | contains("ZOOKEEPER")) | .ipAddress] | first')
echo "Set up Jupyter notebook because notebooks are cool"
echo "And now update .bashrc"
tee -a ~/.bashrc <<EOF
# set environment variables for pyspark
export PYSPARK_DRIVER_PYTHON=/opt/cloudera/parcels/Anaconda/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880"
export PYSPARK_PYTHON=/opt/cloudera/parcels/Anaconda/bin/python
export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH:~/bin

EOF
echo "TODO: add env var to all nodes, including this gateway"
## export PYSPARK_PYTHON=/opt/cloudera/parcels/Anaconda/bin/python

echo "Downloading Jupyter notebook directory and starting Jupyter"
hdfs dfs -copyToLocal s3a://gregoryg/notebooks .
(cd notebooks ; nohup pyspark2 &)


echo 'All done!'
