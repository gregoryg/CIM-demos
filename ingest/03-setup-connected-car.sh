#!/bin/bash
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
