#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
UnblockPath=/Users/mosque/Fix/UnblockNeteaseMusic
NodeBin=/Volumes/软件/usr/local/bin/node

start(){
exclude_ip=$(ping -c 1 music.163.com | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | uniq)
echo "neteaseMusicIP:"$exclude_ip
PID=($(ps -ef | grep "NeteaseMusic/app.js" | grep -v grep | awk '{print $2}'))
if [ ${#PID[@])} -ge 1 ];then
  echo "Already Run!!!"
  exit 1
fi
$NodeBin $UnblockPath/app.js -p 80:443 -f $exclude_ip > /dev/null 2>&1 &
echo -e "127.0.0.1 music.163.com\n127.0.0.1 interface.music.163.com" >> /etc/hosts
}

stop(){
  ps -ef | grep "NeteaseMusic/app.js" | grep -v grep | awk '{print $2}' | xargs kill -9
  sed -i "" '/music.163.com/d' /etc/hosts
}

update(){
  cd $UnblockPath
  git pull origin master && echo "Update Success"
}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
update)
  update
  ;;
*)
  echo "Usage: start| stop| update"
  ;;
esac