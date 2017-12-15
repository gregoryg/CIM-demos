#!/bin/bash
# prep Centos 7.x for use as server with AWS Cloud9

sudo yum -y erase cloudera-data-science-workbench
sudo yum -y autoremove
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install gcc gcc-c++ make tmux ncurses-devel mlocate docker git jq
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum -y install nodejs
sudo groupadd docker
