#!/bin/bash

# Read password from keyboard
# Usage: Read_Passwd <varname>
Read_Passwd()
{
[ $# == 1 ] || { echo "Usage: Read_Passwd <varname>"; return 1; }
local char
local varname=${1}
local password=''

while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $password ]] && password=${password%?}
      # Erase '*' to the left.
      printf '\b \b'
  else
    # Add typed char to output variable.
    password+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done
eval ${varname}=${password}
}

# Find all packages
find_packages()
{
PACKAGES=()
for dir in $(find $(readlink -f "$(dirname '${0}')/../") -type d -maxdepth 1 2>/dev/null); do
[ -f "${dir}/PKGBUILD" ] && PACKAGES+=($(basename ${dir}))
done
}

# Set network proxy
set_net_proxy()
{
[ -n "${NET_PROXY_HOST}" ] || { echo "You must set NET_PROXY_HOST firstly."; return 1; }
[ -n "${NET_PROXY_PORT}" ] || { echo "You must set NET_PROXY_PORT firstly."; return 1; }

echo "" | telnet ${NET_PROXY_HOST} ${NET_PROXY_PORT} &>/dev/null || { unset_net_proxy; return 0; }

export http_proxy=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export HTTP_PROXY=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export https_proxy=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export HTTPS_PROXY=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export ftp_proxy=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export FTP_PROXY=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export rsync_proxy=${NET_PROXY_HOST}:${NET_PROXY_PORT}
export RSYNC_PROXY=${NET_PROXY_HOST}:${NET_PROXY_PORT}

which git &>/dev/null && {
#git config --global core.gitproxy git://${NET_PROXY_HOST}:${NET_PROXY_PORT}
git config --global http.proxy http://${NET_PROXY_HOST}:${NET_PROXY_PORT}
git config --global https.proxy https://${NET_PROXY_HOST}:${NET_PROXY_PORT}
}
}

# Unset network proxy
unset_net_proxy()
{
export http_proxy=
export HTTP_PROXY=
export https_proxy=
export HTTPS_PROXY=
export ftp_proxy=
export FTP_PROXY=
export rsync_proxy=
export RSYNC_PROXY=

which git &>/dev/null && {
#git config --global --unset core.gitproxy
git config --global --unset http.proxy
git config --global --unset https.proxy
}
}

# Run from here ......
TASK_NUM=20
TASK_PKGS=()
NET_PROXY_HOST=127.0.0.1
NET_PROXY_PORT=1080

echo "Enter the password to extract rar file."
Read_Passwd RAR_FILE_SECRET
export RAR_FILE_SECRET=${RAR_FILE_SECRET}

set_net_proxy
find_packages

for ((i=0; i<${#PACKAGES[@]}; i++)); do
TASK_PKGS+=(${PACKAGES[i]})
([ "${#TASK_PKGS[@]}" == "${TASK_NUM}" ] || [ ${i} == $((${#PACKAGES[@]}-1)) ]) && {
mintty -i /msys2.ico -e bash -l -c "$(readlink -f "$(dirname '${0}')")/ci-build.sh ${TASK_PKGS[*]}" &
TASK_PKGS=()
}
done
