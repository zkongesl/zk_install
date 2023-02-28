#!/bin/bash

source /usr/local/esl/scripts/env/env.sh
source /usr/local/esl/scripts/function_scripts/log.sh

function check_network(){
     if test $((code_status)) -eq $((web_code))
     then
         yum -y install mysql vim net-tools >/dev/null 2>&1
         local net='true'
         echo $net
         _acc "The current system has an external network. Checking the current operating system"
         
     else
         local net='false'
         echo $net
         _err "The current system does not have an internet, and offline installation script is being executed"
     fi

}
