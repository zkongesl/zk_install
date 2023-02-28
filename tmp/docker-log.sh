#!/bin/bash
# Clean up container log - Jiu Wen (Version 1.1)
# Debian/Ubuntu Linux systems. (May 10, 2019)       
# (GNU/General Public License version 2.0)            
# For Centos 7 and up, Linux lzone_zkong_cluster_01 3.10.0-862.el7.x86_64.
# ...And away we go!
# 清理docker日志和镜像 
#set -xu
Container_PATH="/var/lib/docker/containers/"
Container() {
    echo -e "\033[44;37m The log size of the native docker container is as follows  \033[0m"
    for i in `find $Container_PATH -type f  -name *-json.log*`
          do
             ls -sh $i
    done
    echo -e "\033[44;37m Start cleaning up docker container log \033[0m"
    for i in `find $Container_PATH -type f  -name *-json.log*`
        do
             cat /dev/null > $i
    done
    echo -e "\033[44;37m Cleaning up dangling mirrors  \033[0m"
    docker rmi `docker images --filter dangling=true|awk '{print $3}'` 2> /dev/null
    echo -e "\033[44;37m Clean up \033[0m" 
    for i in `find $Container_PATH -name *-json.log*`
    do
             ls -sh $i
    done
}
Container

