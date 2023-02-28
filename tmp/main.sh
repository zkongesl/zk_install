#!/usr/bin/env bash
#Date:2022-12-02
#Author: Zkong
#Version: v-5.4.0
#One key installation tool for ubantu system -v.2
#Environment foundation check firewall SELinux port occupancy
#System compatibility kernel 4.15.0-137-generic Release 18.04
# (GNU/General Public License version 2.0)
# ...And away we go!

#set -xv
Global_time=$(date '+%F %T')
Global_esl_log="./log/esl-install.log"



err() {
      printf "[$Global_time]: \033[31m $* \033[0m\n " >>$Global_esl_log
}

#check if user is root
check_user(){
	user="$(id -un 2>/dev/null || true)"
	if [ "$user" != 'root' ]; then
           err "Error: this installer needs the ability to run commands as root.
	   We are unable to find either "sudo" or "su" available to make this happen."
	   exit 1
	fi

}

#Get operating system
get_system_version(){
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"


}


check_firewalld(){
       local firewalld_status=$(firewall-cmd --state  2>/dev/null)
       local fir_stat="not running"
       if [ "$firewalld_status" = 'running' ];then
          systemctl stop firewalld
          err "[info] stop firewalld services"
       else
          err "[info] The firewall component is turned off"
       fi

}


check_selinux(){
     local selinux_status=""
     if [ -r /etc/selinux/config ]; then 
        selinux_status=$( . /etc/selinux/config && echo $SELINUX)
        if [ $selinux_status = "enforcing" ];
        then
            echo "Currently selinux is not closed, trying to close it temporarily"
            setenforce 0
            echo "Permanently close selinux and modify the configuration file /etc/selinux/config SELINUX=disabled, then restart the server"
        fi
     fi  


}

check_os(){
	lsb_dist=$( get_system_version )
        lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
   
        case "$lsb_dist" in
              ubuntu)
                     echo ubuntu
              ;;

              centos)
                  local web_code="200"
                  local target="www.baidu.com"
                  local net_status=$(curl -I -m 6 -o /dev/null -s -w %{http_code} $target)
                  if [ $[net_status] -eq $[web_code] ]
                  then
                       err "[info] External network normal "
                       check_firewalld
                       check_selinux  
                  else
                       err "[error] Perform offline installation "
                  fi
              ;;
             
              *)
                        echo "The current one-click installation package is used for centos7-9 version, it is not recommended to use other versions for installation"               

              ;;             
        esac
}



main(){
    check_user
    check_os
}

main "$@" 

