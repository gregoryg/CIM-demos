#!/bin/bash
USER='gregj'
sudo yum -y install epel-release
sudo yum -y install python-pip wget curl telnet finger mlocate jq htop net-tools git
sudo pip install cm-api

echo "Setting up HDFS home data dir for user ${USER}"
sudo -u hdfs hdfs dfs -mkdir -p /user/${USER}/data
sudo -u hdfs hdfs dfs -chown -R ${USER} /user/${USER}

cmhost=`grep server_host= /etc/cloudera-scm-agent/config.ini |cut -d '=' -f2-`
if [ -z "$cmhost" ] ; then
    echo "Error: Cannot determine Cloudera Manager host address - does this host run Cloudera Manager Agent?"
    exit 1
fi
echo Cloudera Manager is running on $cmhost

# get cluster name
clustername=$(curl --silent -X GET -u admin:admin http://$cmhost:7180/api/v14/clusters | jq -r '.items[].name')
if [ 1 != `echo $clustername | wc -l` ] ; then
    echo "Error: I can only deal with 1 cluster managed by the CM - found: `echo $clustername`"
    exit 1
fi

# get version of cluster
cdhversion=$(curl --silent -u admin:admin http://${cmhost}:7180/api/v14/clusters/${clustername}|jq -r '.fullVersion')
cdhmajor=$(echo ${cdhversion} | cut -d'.' -f1)
cdhminor=$(echo ${cdhversion} | cut -d'.' -f2)

echo "Setting up defaults for impala-shell and Beeline"
impalad=$(curl --silent -u "admin:admin" "http://$cmhost:7180/api/v14/hosts?view=FULL" | jq -r '[.items[] | select(.roleRefs[].roleName | contains("-IMPALAD")) | .ipAddress] | first ')
echo "[impala]
impalad=${impalad}:21000
    " > ~/.impalarc
hiveserver2=$(curl --silent -u 'admin:admin' http://${cmhost}:7180/api/v14/hosts?view=full | jq -r '[.items[] | select(.roleRefs[].roleName | contains("HIVESERVER2")) .hostname] | first')
# start up a beeline command and then save config to ~/.beeline/beeline.properties
beeline -u "jdbc:hive2://${hiveserver2}:10000/default" -n ${USER} <<EOF
!save
!quit
EOF

echo "To run beeline without parameters, use 'beeline -r'"

echo "Fixing up .bashrc"
sudo yum -y install cowsay fortune-mod
tee -a ~/.bashrc <<EOF
export PS1='\u@aws-gateway: \w #$ '
if [[ \$- =~ "i" ]] ; then
    export cmhost="${cmhost}"
    export clustername="${clustername}"
    echo "CM API for cluster ${clustername} at http://${cmhost}:7180/api/v18/"
    # echo "Streamsets URL: http://`hostname -f`:18630/"
    # echo "Jupyter notebook URL: http://`hostname -f`:8880"
    # echo "RStudio URL: http://`hostname -f`:8787"
    ~/bin/cowme
fi
EOF
mkdir -p ~/bin
tee ~/bin/cowme << EOF
#!/bin/bash
if type fortune cowsay >/dev/null
then
    IFS=',' read -r -a cowopts <<< "b,g,p,s,t,w,y"
    if [ \$((RANDOM % 4)) == 0 ] ; then
        cowcmd="cowsay"
    else
        cowcmd="cowthink"
    fi
    fortune -s | \${cowcmd} -\${cowopts[\$((RANDOM % \${#cowopts[@]}))]}
fi
EOF
chmod 755 ~/bin/cowme
