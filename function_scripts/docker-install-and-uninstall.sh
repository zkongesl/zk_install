#!/bin/bash
# Version: v0.0.1 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# Debian/Ubuntu Linux systems. (May 10, 2019)
# (GNU/General Public License version 2.0)
# For Centos 7 and up, Linux lzone_zkong_cluster_01 3.10.0-862.el7.x86_64.
# ...And away we go!

Package='/server/tools'
function tools {
    if [ ! -d "$Package" ]; then
        mkdir "$Package" -p
    fi
}

function INSTALL {

cp /usr/local/esl/scripts/package/docker-19.03.9.tgz $Package 

cd $Package && tar xf docker-19.03.9.tgz 
mv $Package/docker/* /usr/bin/

cat >/etc/systemd/system/docker.service <<-EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/docker.service

systemctl daemon-reload && systemctl start docker && systemctl enable docker.service >/dev/null 2>&1
for i in $(ls /usr/local/esl/docker-images)
do 

     docker load -i "$i" >/dev/null 2>&1
done
systemctl status docker >/dev/null 2>&1  
echo "Importing Docker image" 
Load_image
echo "Current Docker Version: $(docker -v)"

}



function Load_image {
     for image in $(ls /usr/local/esl/docker-images)
     do
        docker load -i /usr/local/esl/docker-images/"$image" >/dev/null 2>&1
     done
}

function UNINSTALL {
         cd /usr/local/esl/ && docker-compose stop && systemctl stop docker
         rpm -qa | grep docker | xargs yum remove -y >/dev/null 2>&1
         rm -rf /var/lib/docker
         sed -i  '/web_code.sh/d;/Monitoring.sh/d;/docker-log.sh/d' /var/spool/cron/root
         sed -i '/Monitoring/d;/Check/d;/Clear/d' /var/spool/cron/root 
         Package=$(rpm -qa|grep -c bridge-utils)    
         if [ "$(awk -F "=" 'NR==3{print $2}' /etc/os-release|sed 's#"centos"#centos#g')" != "centos" ];then
            echo ubuntu
         else
            rpm -ihv /usr/local/esl/scripts/package/bridge-utils-1.5-9.el7.x86_64.rpm 
            rpm -ivh /usr/local/esl/scripts/package/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
         fi
         systemctl stop docker 
         rm -rf /etc/systemd/system/docker.service.d
         rm -rf /etc/systemd/system/docker.service
         rm -rf /var/lib/docker
         umount  /run/docker/netns/default
         rm -rf /var/run/docker
         rm -rf /etc/docker
         rm -rf /usr/bin/docker* /usr/bin/containerd* /usr/bin/runc /usr/bin/ctr
         for list in $(brctl show |awk 'NR>1{print $1}')
         do
             ifconfig "$list" down
             brctl  delbr "$list"
         done
      



}

echo '
Please enter the action you want to perform:"install" | "uninstall"'
read -p "Please enter the action you want to perform: " action

case $action in
	install)
                tools
		INSTALL
	;;
	uninstall)
		UNINSTALL && echo 'Docker uninstall Successfully'
	;;
	*)
		echo '
			The action you entered is not supported. 
			Please enter the following format: install | uninstall'
		exit 1
esac
