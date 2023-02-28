#!/bin/bash


source /usr/local/esl/scripts/env/env.sh
source /usr/local/esl/scripts/function_scripts/log.sh


function _disk_migration(){

     clear
     echo ""
     echo ""
     echo -e -n "\033[1;32m ===========================================================================================\n\033[0m"
     echo -e -n "\033[1;32m The current script is a disk migration script                                              \n\033[0m"     
     echo -e -n "\033[1;32m for example     /zkapp                                                                     \n\033[0m" 
     echo -e -n "\033[1;32m ===========================================================================================\n\033[0m"

     read -t 50 -p "Please enter the mount directory of the target disk: " disk_migration

 
     local Target_Mount="$disk_migration"

     if [ $"disk_migration" ];
     then
        #echo not null
        cd $itme_path && docker-compose stop   >>/dev/null 
        echo ""
        echo ""
        if [  -d $Target_Mount ];
        then 
            echo "Migrate esl to the $Target_Mount mount point"
            cd /usr/local && mv esl $Target_Mount
            ln -s $Target_Mount/esl $itme_path
            systemctl stop docker
            cd /var/lib/ && mv docker $Target_Mount
            ln -s $Target_Mount/docker /var/lib/docker
            systemctl daemon-reload 
            systemctl start docker systemctl enable docker
            cd /usr/local/esl/ &&  docker-compose up -d --build >>/dev/null
            echo ""
            echo "After the migration is complete, check the service"
            echo ""
            docker ps 

        else
            _err "The mount point does not exist. Please check"
            echo "The mount point does not exist. Please check"
        fi 

     else 
        
        echo "Null input is not allowed"
        _err "Null input is not allowed"
        exit 1

     fi




}

