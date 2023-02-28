#!/bin/bash

source /usr/local/esl/scripts/env/env.sh 

function SendMsgToDingding() {
            # 删除告警模板空格
            sed s/[[:space:]]//g /usr/local/esl/scripts/alarm_template/init_temp -i
            msg=$(sed -n '6,20p' /usr/local/esl/scripts/alarm_template/init_temp)

            curl $webhook -H 'Content-Type: application/json' -d "
            {
               'msgtype': 'text',
               'text': {
               'content': '告警主题：$name \n钉钉关键字: 一键安装  \n巡检内容: \n  $msg\n'
               },
               'at': {
               'isAtAll': false
               }
              }"
}

