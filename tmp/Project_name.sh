#!/bin/bash
#webhook="https://oapi.dingtalk.com/robot/send?access_token=4d15f6354cdddf9498f90131084c72e32e1bc3e028df8e8ae11201392b672840"
#公共服务保障小组
#webhook="https://oapi.dingtalk.com/robot/send?access_token=b5f6e5b56a03158cff14239d7fdc9ac50bdc3a8765a8a5bec3971d87bcff9a7c"
#普通客户告警群
webhook="https://oapi.dingtalk.com/robot/send?access_token=4d15f6354cdddf9498f90131084c72e32e1bc3e028df8e8ae11201392b672840"
Time=`date '+%F %T'`
Hostname=`hostname`
Host_IP=`/usr/sbin/ip a  | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}' | awk -F / '{print$1}'`
#function Project_Name (){
     echo "=================================================================="
     echo "Enter the name of the current project：                                         "
     echo "=================================================================="
     read -t 30 -p "Please enter project name：" Project_name
     if [ -z $Project_name ];then
        echo "none"
        exit 1
     fi
     sed '/Name/d' /etc/profile -i 
     echo  Name=${Project_name} >>/etc/profile
     source /etc/profile
     echo $Name >>/usr/local/esl/esl-install.log
     SendMsgToDingding >>/usr/local/esl/log/esl-install.log 2>&1 \n
 
#}
echo $Name  >>/usr/local/esl/log/esl-install.log
function SendMsgToDingding() {
            curl $webhook -H 'Content-Type: application/json' -d "
            {
               'msgtype': 'text',
               'text': {
               'content': '告警主题：$Name \n钉钉关键字: 1 \n告警时间: $Time \n告警主机名: $Hostname \n主机IP列表: $Host_IP \n当前状态: $Project_name-已接通钉钉告警 \n'
               },
               'at': {
               'isAtAll': false
               }
              }"
}
#Project_Name
SendMsgToDingding   >>/usr/local/esl/log/esl-install.log 2>&1 \n
