#!/usr/bin/bash
# Debian/Ubuntu Linux systems. (May 10, 2019)
# (GNU/General Public License version 2.0)
# For Centos 7 and up, Linux lzone_zkong_cluster_01 3.10.0-862.el7.x86_64.
# ...And away we go!

source /etc/profile
source ~/.bash_profile

current_directory=$(pwd)
Installation_Logs="./log/esl-install.log"
Kernel_conf=/etc/sysctl.conf
Iptables=net.bridge.bridge-nf-call-iptables=1
Ip6tables=net.bridge.bridge-nf-call-ip6tables=1
Ip_forward=net.ipv4.ip_forward=1
Log_time=`date +'%F %H:%M:%S'`

Have_Network(){
    echo -n -e "\033[1;32m $Log_time  Start install  \n\033[0m"
    source ./scripts/Project_name.sh
    cp -n docker-compose /usr/local/bin/
    if [ ! -f "/usr/bin/dockerd" ];then
           if [ ! -f "/etc/yum.repos.d/docker-ce.repo" ];then
           cp docker-ce.repo /etc/yum.repos.d/
           fi
    fi

    echo -n -e "\033[1;32m $Log_time Install Docker  \n\033[0m" > $Installation_Logs
    yum -y install docker-ce-19.03.4-3.el7 > $Installation_Logs 2>&1
    result=$?
    if [ $result == "0" ];then
        systemctl daemon-reload && systemctl start docker 
        systemctl enable docker.service >> $Installation_Logs 2>&1
        systemctl status docker  >> $Installation_Logs  && docker -v >> $Installation_Logs
    else
        echo 'Please make sure your network can access the public network and reinstall'
        exit
    fi

    echo -n -e "\033[1;32m $Log_time  Modify kernel parameters  \n\033[0m" >> $Installation_Logs
    echo $Iptables >> $Kernel_conf
    echo $Ip6tables >> $Kernel_conf
    echo $Ip_forward >> /etc/sysctl.conf
    sysctl -p >> $Installation_Logs 2>&1

    echo -n -e "\033[1;32m $Log_time Load mirror \n\033[0m" >> $Installation_Logs
    for image in `ls docker-images`
    do
        docker load -i docker-images/$image >> $Installation_Logs 2>&1
    done
    if [ $? -ne 0 ];then 
       exit 
    fi
    sed -i "s@/usr/local/esl@$current_directory@" docker-compose.yaml
    echo -n -e "\033[1;32m $Log_time Start Docker-compose..  \n\033[0m" >> $Installation_Logs
    docker-compose up -d >> $Installation_Logs 2>&1
    if [ $? -eq 0 ];then
        echo "The installation is complete" >>$Installation_Logs
    fi
    echo -n -e "\033[1;32m $Log_time Stop firewalld..  \n\033[0m" >> $Installation_Logs
    systemctl status firewalld | grep "running" >> $Installation_Logs  2>&1
    if [ $? -eq 0 ];then
       systemctl stop firewalld >> $Installation_Logs 2>&1
       systemctl disable firewalld >> $Installation_Logs 2>&1
    fi
    echo -n -e "\033[1;32m $Log_time Disabled Selinux  \n\033[0m" >> $Installation_Logs
    if [ `getenforce` != "Disabled" ];then
       sed -i 's/SELINUX=enabled/SELINUX=disabled/g' /etc/selinux/config >> $Installation_Logs 2>&1
       setenforce 0 >> $Installation_Logs 2>&1
    fi

    echo "$Log_time Installing qrencode" >> $Installation_Logs  2>&1
    #yum -y install qrencode  >> esl-install.log 2>&1
    echo Configure monitoring alarm >> $Installation_Logs  2>&1
    echo "#Monitoring alarm - CPU, memory, web, disk" >>/var/spool/cron/root
    echo "* * * * * bash /usr/local/esl/scripts/Monitoring.sh"  >>/var/spool/cron/root
    echo "#Clear docker log every Sunday" >>/var/spool/cron/root
    echo "0 0 * * 0 /bin/bash /usr/local/esl/scripts/docker-log.sh" >>/var/spool/cron/root
    echo "#Check Web Code " >>/var/spool/cron/root
    echo "*/3 * * * * bash /usr/local/esl/scripts/web_code.sh" >>/var/spool/cron/root

}
No_Network(){
     echo "=======================================================================================" 
     echo -n -e '\033[1;32m There is no external network on the current machine, and the offline installation script is being executed   \n\033[0m'
     sh /usr/local/esl/scripts/docker-install-and-uninstall.sh
     echo -n -e "\033[1;32m $Log_time  Modify kernel parameters  \n\033[0m" >> $Installation_Logs
     echo $Iptables >> $Kernel_conf
     echo $Ip6tables >> $Kernel_conf
     echo $Ip_forward >> /etc/sysctl.conf
     sysctl -p >> $Installation_Logs 2>&1
     echo -n -e "\033[1;32m $Log_time Load mirror \n\033[0m" >> $Installation_Logs
     for image in `ls docker-images`
     do
        docker load -i docker-images/$image >> $Installation_Logs 2>&1
     done
     sed -i "s@/usr/local/esl@$current_directory@" docker-compose.yaml

     echo -n -e "\033[1;32m $Log_time Start Docker-compose..  \n\033[0m" >> $Installation_Logs
     docker-compose up -d >> $Installation_Logs 2>&1
     if [ $? -eq 0 ];then
         echo "The installation is complete"
     fi
     echo -n -e "\033[1;32m $Log_time Stop firewalld..  \n\033[0m" >> $Installation_Logs
     systemctl status firewalld | grep "running" >> $Installation_Logs  2>&1
     if [ $? -eq 0 ];then
        systemctl stop firewalld >> $Installation_Logs 2>&1
        systemctl disable firewalld >> $Installation_Logs 2>&1
     fi
     echo -n -e "\033[1;32m $Log_time Disabled Selinux  \n\033[0m" >> $Installation_Logs
     if [ `getenforce` != "Disabled" ];then
        sed -i 's/SELINUX=enabled/SELINUX=disabled/g' /etc/selinux/config >> $Installation_Logs 2>&1
        setenforce 0 >> $Installation_Logs 2>&1
     fi

     echo -n -e '\033[1;32m  Running  docker-compose up -d --build  \n\033[0m'
     docker-compose up -d --build  >> $Installation_Logs 2>&1

     echo -n -e '\033[1;32m===========================================================================================================================================================================  \n\033[0m'
     docker ps
     echo -n -e '\033[1;32m===========================================================================================================================================================================  \n\033[0m'

}

ESL_directory_migration() {
Project_Path="/usr/local/esl"
Default_Path="/usr/local"
Docker_Default_Path="/var/lib/docker"
Command=`./docker-compose stop >>$Installation_Logs 2>&1`
     echo -e -n "\033[1;32m ================================================================================================================\n\033[0m"
     echo -e -n "\033[1;32m The migration is in progress. Please do not leave the terminal...                                               \n\033[0m"     
     echo -e -n "\033[1;32m Select system maximum disk migration.                                                                           \n\033[0m"
     echo -e -n "\033[1;32m for example:                                                                                                    \n\033[0m"
     echo -e -n "\033[1;32m       input /data Migrate the default installation path of ESL and docker to the /data directory                \n\033[0m"
     echo -e -n "\033[1;32m       If the input is empty, the default installation location is /usr/local/. Exit the program                 \n\033[0m"
     echo -e -n "\033[1;32m       /usr/local is the default installation location /usr/local/, exit the program                             \n\033[0m"
     echo -e -n "\033[1;32m ================================================================================================================\n\033[0m"

     read -t 50  -p "Please select the largest disk of the current system :" Storage_disk
     if [ -z $Storage_disk ];then
          echo "The value is empty"
          cd $Project_Path && ./docker-compose up -d --build >>$Installation_Logs 2>&1`
          exit 1 
     elif [ "$Storage_disk" = "$Default_Path" ];then
          echo "Install to default path $Default_Path"
          cd $Project_Path && ./docker-compose up -d --build >>$Installation_Logs 2>&1`
          exit 1
     else 
          echo "正在迁移esl目录至$Storage_disk..."
          cd $Project_Path && $Command >>$Installation_Logs 2>&1
          if [ $? -ne 0 ];then
             exit 1
          fi 
          mv $Project_Path $Storage_disk
          if [ -d $Project_Path ];then
             rm -f $Project_Path
          fi
          ln -s $Storage_disk/esl $Project_Path && cd $Project_Path && ./docker-compose up -d --build >>$Installation_Logs 2>&1 
          echo -e -n "\033[1;32m ESL迁移到$Storage_disk 成功,请检查$Project_Path 目录是否为软连接目录..\n\033[0m"
          
     fi

     echo -e -n "\033[1;32m 正在迁移Docker默认安装路径到$Storage_disk 目录...\n\033[0m"
     cd $Project_Path &&  $Command >>$Installation_Logs 2>&1
     systemctl stop docker.service 
     mv /var/lib/docker $Storage_disk
     ln -s $Storage_disk/docker $Docker_Default_Path
     systemctl start docker.service
     echo "Docker安装目录已迁移到$Storage_disk 目录完成,请检查$Docker_Default_Path 是否为软连接目录..."
     echo "正在检查服务状态.."
     echo -n -e '\033[1;32m===========================================================================================================================================================================  \n\033[0m'
     docker ps
     echo -n -e '\033[1;32m===========================================================================================================================================================================  \n\033[0m'
          
     
}




Cront_Jobs(){
Job_Path="/var/spool/cron/root"
         sed -i  '/web_code.sh/d;/Monitoring.sh/d;/docker-log.sh/d' $Job_Path
         sed -i '/Monitoring/d;/Check/d;/Clear/d' $Job_Path
         Package=`rpm -qa|grep bridge-utils|wc -l`       
         if [ $Package -ne 1 ];then
            yum -y install bridge-utils
         fi
         BRIDGE_LIST=$( brctl show | cut -f 1 | grep br-)
         ifconfig $BRIDGE_LIST  down
         brctl delbr $BRIDGE_LIST
}

#Turn off CentOS 6 7 firewall
Env_init() {
     if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
        systemctl stop firewalld
        systemctl disable firewalld
     elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null; then
        service iptables stop
        chkconfig iptables off
     fi
}

#Close_Selinux 
Close_SELinux() {
         sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
}

Network(){
Network=`ping -c 3 www.baidu.com >> $Installation_Logs 2>&1`

   if [ $? == 0 ];then
        Cront_Jobs
 #       Have_Network
 #       ESL_directory_migration 
 #       Env_init
 #       Linux_kernel
 #       Close_SELinux
   else 
        No_Network
        Env_init
        Close_SELinux
   fi
}


Network
