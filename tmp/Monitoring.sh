#!bin/bash
#Nailing alarm: disk, memory, CPU, web status code monitoring alarm - WJ (Version 1.1)
# Debian/Ubuntu Linux systems. (May 10, 2019)
# (GNU/General Public License version 2.0)
# For Centos 7 and up, Linux lzone_zkong_cluster_01 3.10.0-862.el7.x86_64.
# ...And away we go!
set -ue
Container_PATH="/var/lib/docker/containers/"
Time=`date '+%F %T'`
url="http://127.0.0.1:9999/user/getNewPublicKey?loginType=1"
Hostname=`hostname`
#公共服务保障小组
#webhook="https://oapi.dingtalk.com/robot/send?access_token=b5f6e5b56a03158cff14239d7fdc9ac50bdc3a8765a8a5bec3971d87bcff9a7c"
Host_IP=`/usr/sbin/ip a  | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}' | awk -F / '{print$1}'`
#普通客户告警群
webhook="https://oapi.dingtalk.com/robot/send?access_token=4d15f6354cdddf9498f90131084c72e32e1bc3e028df8e8ae11201392b672840"

Check_Network(){
    massage=`ping -c 3 www.baidu.com 2>/dev/null` 
    if [ $? = 0 ]; then
        echo "Smooth network"
    else
        echo "$message"
        exit 1
    fi


}

logError()
{
    echo -n '[Error]:   '  $*
    echo -en '\033[120G \033[31m' && echo [ Error ]
    echo -en '\033[0m'
}


function Item_Mem(){
Mem_Total=`free -m | awk -F '[ :]+' 'NR==2{print $2}'`
Mem_Used=`free -m | awk -F '[ :]+' 'NR==2{print $3}'`
Monitoring_Indicators=`awk 'BEGIN{printf "%.0f\n",('$Mem_Used'/'$Mem_Total')*100}'`
Alarm_Subject="内存使用率告警"

      if [[ "$Monitoring_Indicators" > 80 ]];then
           SendMsgToDingding 
           if [ $? != 0 ];then
              logError
              exit -1
           fi             
      fi

}

Item_Disk () {
Alarm_Subject="磁盘使用率告警"
Monitoring_Indicators=`df | egrep -n '/dev/vda1|/dev/sda3' | awk '{print $5}' | sed 's/[^0-9\.]//g'`
if [[ "$Monitoring_Indicators" > 85 ]]
    then
      SendMsgToDingding 
    if [ $? != 0 ];then
       logError
       exit -1
    fi
    else
        echo "disk ok!!!" >/dev/null 2>&1
fi 
}
Item_Cpu () {
Alarm_Subject="CPU使用率告警"
cpu_us=`vmstat | awk '{print $13}' | sed -n '$p'`
cpu_sy=`vmstat | awk '{print $14}' | sed -n '$p'`
cpu_id=`vmstat | awk '{print $15}' | sed -n '$p'`
Monitoring_Indicators=$(($cpu_us+$cpu_sy))
if(($Monitoring_Indicators > 80))
  then
  SendMsgToDingding
  if [ $? != 0 ];then
     logError
     exit -1
  fi
fi
}
function SendMsgToDingding() {
            Pname=`cat /etc/profile|grep Name|awk -F "=" '{print $2}'` 
            curl $webhook -H 'Content-Type: application/json' -d "
            {
               'msgtype': 'text',
               'text': {
               'content': '告警主题：$Pname-$Alarm_Subject \n钉钉关键字: 1 \n告警时间: $Time \n告警主机名: $Hostname \n主机IP: $Host_IP \n当前监控指标: $Monitoring_Indicators \n'
               },
               'at': {
               'isAtAll': false
               }
              }"
}


Running() {
   Check_Network 
   Item_Mem
   Item_Disk
   Item_Cpu
}
Running
