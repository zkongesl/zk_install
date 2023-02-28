#!/usr/bin/env bash

source /usr/local/esl/scripts//env/env.sh
source /usr/local/esl/scripts/function_scripts/log.sh

check_firewalld(){

       if [ "$firewalld_status" != 'running' ];then
          _iptables=0
       else
          _iptables=1
       fi
      
}

firewall_stats(){

   check_firewalld
   num2=0
   if test $[_iptables] -ne $[num2] 
   then 
         clear
         echo ""
         echo "Close the firewall. If it fails to close, please try to close it manually"
         sleep 3
         systemctl stop firewalld
         _acc "[info] stop firewalld services"
   else
         _err "[info] The firewall component is turned off"
   fi
}

