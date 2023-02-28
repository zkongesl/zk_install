#!/bin/bash


source /usr/local/esl/scripts/env/env.sh
source /usr/local/esl/scripts/check_os/check_network.sh



function getSystemStatus(){
Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
CPU_Arch=$(uname -m)
    echo ""
    echo "System patrol scripts：Version $VERSION"
    echo ""
    echo ""
    echo "#################################### System patrol ##################################"
    if [ -e /etc/sysconfig/i18n ];then
        default_LANG="$(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
    else
        default_LANG=$LANG
    fi
    export LANG="en_US.UTF-8"
    Release=$(cat /etc/redhat-release 2>/dev/null)
    Kernel=$(uname -r)
    OS=$(uname -o)
    Hostname=$(uname -n)
    SELinux=$(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')
    LastReboot=$(who -b | awk '{print $3,$4}')
    uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
    iptable=$(firewall-cmd --state  >/dev/null 2>&1) 
    Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
    Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
    CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
    CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
    CPU_Arch=$(uname -m)
    check_netWork=$(check_network)
    echo -e " \n  system: $OS"
    echo "  Release: $Release"
    echo "host_name: $Hostname"
    echo "  SELinux: $SELinux"
    echo "Current_user: $(whoami)"
    echo "current_time: $(date +'%F %T')"
    echo "network_situation: $check_netWork"
    echo "firewalld_satatus: $firewalld_status"
    echo "Number_of_physical_CPUs: $Physical_CPUs"
    echo "Number_of_logical_CPUs:  $Virt_CPUs"
    echo "Number_of_cores_per_CPU: $CPU_Kernels"
    echo "    CPU_model: $CPU_Type"
    echo "    CPU_architecture: $CPU_Arch"
    echo "Disk_capacity/number: `fdisk -l | grep "Disk /dev" | cut -d, -f1`"
    echo "Offline installation, uninstallation script: /usr/local/esl/scripts/function_scripts/docker-install-and-uninstall.sh"
    echo ""
echo -e "\033[33m [Warning] \033[0m ""please check whether the current system configuration meets the installation conditions. It is recommended that the server 
\n be configured with 4 core 16g 500g storage. If not, it is recommended to upgrade the server configuration \033[0m"
    echo ""
    echo "######################################## END #######################################"

}

main (){
   getSystemStatus
}

main "$@" 

