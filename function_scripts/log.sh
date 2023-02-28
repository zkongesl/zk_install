#!/usr/bin/env bash

source $project_dir/env/env.sh

_err() {
  #echo -e "\033[31m  [$(date +'%Y-%m-%dT%H:%M:%S%z')]: $* \033[0m " >>$log_path
  echo -e " \e[1;31m $(date +'%Y-%m-%dT%H:%M:%S%z') $* \e[0m"  >>$log_path
}


_acc() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z'): $*" >>$log_path
}