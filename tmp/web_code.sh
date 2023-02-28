#!/bin/bash
#WEB状态码监控
url=http://127.0.0.1/zk/user/getNewPublicKey?loginType=1
Hostname=${hostname}
Host_IP=`hostname -i|awk -F " " '{print $1}'`
Hostname=`hostname`
Time=`date '+%F %T'`
Status_Code=`curl -I -m 6 -o /dev/null -s -w %{http_code} $url`


log(){
    local acc_time=`date "+%Y-%m-%d %H:%M:%S"`
    local acc_log="/usr/local/esl/log/web_status.log"
    printf "[$acc_time]: $* \n" >>$acc_log
}


Status_Code(){
   local Success_status="200"

   if test  $[Status_Code] -eq $[Success_status] 
   then
      log "[info] Status code $Status_Code is normal"
   else
       
      log "[error] The status code id $Status_Code error output "
      log "[error] Verification code error Restarting back end... "
      docker restart zk-refactor-esl-business
 
      
      
   fi      
} 

main() {
    Status_Code
}

main "$@"


