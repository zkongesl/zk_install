#!/bin/bash
#公共服务保障小组

source /usr/local/esl/scripts/env/env.sh
source /usr/local/esl/scripts/alarm_template/init.sh
#source ../alarm_template/init_temp
#source /usr/local/esl/scripts/check_os/check_all.sh 
source /usr/local/esl/scripts/alarm_template/Patrol_temp.sh

#发送告警
SendMsgToDingding  >>/usr/local/esl/scripts/log/esl-install.log 2>&1 \n

