#!/usr/bin/env bash

#Date:2022-12-02
#Author: Zkong
#Version: v-5.4.0
#Compatible with centos series version, test environment version 3.10.0-1160.el7.x86_ sixty-four
#System compatibility kernel 4.15.0-137-generic Release 18.04
# (GNU/General Public License version 2.0)
# And away we go!

source /usr/local/esl/scripts/env/env.sh
source $project_dir/function_scripts/log.sh
source $project_dir/check_os/check_user.sh
source $project_dir/check_os/check_network.sh 
source $project_dir/check_os/check_selinux.sh
source $project_dir/check_os/check_os_name.sh
source $project_dir/check_os/check_firewalld.sh
source $project_dir/function_scripts/disk_total.sh


#source ./alarm_template/init.sh
#source ./alarm_template/Patrol_temp.sh

function _system(){
    
        check_user        
        status=$( check_network )
        echo $status
        if [ "$status" = 'true' ]
        then
           clear
           echo ""
           _acc "Installing service, about five minutes, please wait"
           echo "Installing service, about five minutes, please wait"
           sleep 3
           clear
           echo ""
           if [ $(get_system_version) = "centos" ]
           then
              #巡检内容
              clear
              source $project_dir/function_scripts/alarm_project.sh
              echo ""
              cat /usr/local/esl/scripts/alarm_template/init_temp
              sleep 3 
              echo ""
              clear
              firewall_stats #check_iptables
              check_selinux  #check_selinux

              
            else
               echo "Ubuntu"
            fi
            
        else
           echo  "The current server has no internet, please execute the offline installation script /usr/local/esl/scripts/function_ Scripts/docker-install-and-uninstall.sh"
           _err  "The current server has no internet, please execute the offline installation script /usr/local/esl/scripts/function_ Scripts/docker-install-and-uninstall.sh"
               
        fi
}
 



 

main(){
    _system
    _disk_total    
    

}


main "$@"
