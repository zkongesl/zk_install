#!/bin/bash

source /usr/local/esl/scripts/env/env.sh
source $project_dir/function_scripts/log.sh

total=$(fdisk -l |egrep "磁盘 /dev|Disk /dev"|grep -wve "swap"|awk '{print $2}'|awk -F "：" '{print $2}')
array=($total)

function _disk_total(){
         for i in "${array[@]}"; 
         do 
           integer=$(echo "$i" | awk -F '.' '{print $1}')
           if [ "$integer" -ge "200" ]
           then
              _acc "The disk space meets the installation requirements. Installing the disk please wait"
              echo "The disk space meets the installation requirements. Installing the disk please wait"
              break
           else
              
              echo "The current environment does not meet installation conditions. Upgrade the configuration"
              _err "The current environment does not meet installation conditions. Upgrade the configuration"
              exit 1

           fi
         done
}


