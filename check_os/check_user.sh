#!/usr/bin/env bash

check_user(){
        user="$(id -un 2>/dev/null || true)"
        if [ "$user" != 'root' ]; then
           err "Error: this installer needs the ability to run commands as root.
           We are unable to find either "sudo" or "su" available to make this happen."
           exit 1
        fi

}
