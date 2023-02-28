#!/usr/bin/env bash


source /usr/local/esl/scripts/env/env.sh
source $project_dir/function_scripts/log.sh


check_selinux(){
     local selinux_status=""
     if [ -r /etc/selinux/config ]; then

        selinux_status=$( . /etc/selinux/config && echo $SELINUX)
        
        if [ $selinux_status = "enforcing" ];
        then
            clear
            echo ""
            echo "Shutting down selinux"
            selinux_status=$( sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config  -i )
            _err "Shutting down selinux"
            
            echo "Selinux is closed. Please confirm whether to restart the server"
            sleep 5
            #倒计时确认重启
			for ((I=15;I>0;I--))
			do 
                clear
				echo  "Automatically restart the operation server after ${I} seconds"
				sleep 1 >/dev/null
			done

            echo ""
            echo "Please enter yes or no"

            read  -t 30 -p "Please confirm whether to restart the server：" Y
            
            if [ $Y = "yes" ];
            then
                 /sbin/reboot
            elif [ $Y = "no" ];
            then
                  _acc "Please restart by yourself, and continue to execute after restarting"
                  echo "Please restart by yourself, and continue to execute after restarting"
            else
                  echo "Please enter yes or no "
                  _err "Please enter yes or no"
            fi


        else 
        #selinux 已关闭
            _acc "Selinux is closed"
        fi
     fi


}
