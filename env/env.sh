#!/bin/bash

#客户环境信息
name="zkong一键安装包测试"



# 一键安装包变量
web_code="200"
target="www.baidu.com"
itme_path="/usr/local/esl"
Global_time=$(date '+%F %T')
project_dir="/usr/local/esl/scripts"
code_status=$(curl -I -m 6 -o /dev/null -s -w %{http_code} $target)
log_path="/usr/local/esl/scripts/log/esl-install.log"
firewalld_status=$( systemctl status firewalld|awk  'NR==3{print $3}'| cut -d '(' -f2 | cut -d ')' -f1)
rely_on="yum-utils device-mapper-persistent-data  redhat-lsb lvm2 ntpdate mysql vim net-tools"

#公共服务保障小组
webhook="https://oapi.dingtalk.com/robot/send?access_token=fb6af63cf0b79b902922ebb43809d71f9014d4906aa0ae6f417174543b4408a7"



#系统巡检变量
centosVersion=$(awk '{print $(NF-1)}' /etc/redhat-release)
VERSION="2023.2.24"
