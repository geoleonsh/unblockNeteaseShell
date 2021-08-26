#!/bin/bash
#注意：本脚本只适应于MacOS，迁移到其它系统请注意sed等命令的使用不同
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
#指定UnblockNeteaseMusic的目录
Saved_UnblockPath=/develop/crack163music

#指定node二进制文件的路径
Saved_NodeBin=node

#指定git仓库
GitLab="https://github.com/nondanee/UnblockNeteaseMusic"

start(){
grep -q "music.163.com" /etc/hosts
if [ 0 -eq $? ];then
  sed -i '/music.163.com/d' /etc/hosts
#  killall -HUP mDNSResponder
  systemd-resolve --flush-caches
fi
exclude_ip=$(ping -c 1 music.163.com | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | uniq)
echo "neteaseMusicIP:"$exclude_ip

PID=($(ps -ef | grep "NeteaseMusic/app.js" | grep -v grep | awk '{print $2}'))
if [ -n "${PID}" ];then
  echo "UnblockNeteaseMusic 已经在运行!!!"
  echo -e "127.0.0.1 music.163.com\n127.0.0.1 interface.music.163.com" >> /etc/hosts
  exit 1
fi

$Saved_NodeBin $Saved_UnblockPath/UnblockNeteaseMusic/app.js -p 80:443 -f $exclude_ip > /dev/null 2>&1 &
echo -e "127.0.0.1 music.163.com\n127.0.0.1 interface.music.163.com" >> /etc/hosts
if [ 0 -eq $? ];then
  echo "UnblockNeteaseMusic启动成功!!!"
  else
    echo "UnblockNeteaseMusic启动失败!!!"
fi
}

stop(){
  PID=$(ps -ef | grep "NeteaseMusic/app.js" | grep -v grep | awk '{print $2}')
  if [ -n "$PID" ];then
    kill -9 $PID
  fi
  sed -i '/music.163.com/d' /etc/hosts
  echo "UnblockNeteaseMusic关闭成功!!!"
}

restart(){
stop && start
}

update(){
  cd $Saved_UnblockPath/UnblockNeteaseMusic
  git pull origin master && echo "UnblockNeteaseMusic更新成功!!!"
}

install(){
echo -e "\033[31m请先自行安装NodeJS!!!\033[0m"
read -rp "请输入安装路径(默认为~/，直接回车使用默认值)：" UnblockPath
if [ -z $UnblockPath ];then
  sed -i 's/^\(Saved_UnblockPath\=\)\(.*\)/\1~\//' $0
else
  sed -i "s#^\(Saved_UnblockPath\=\)\(.*\)#\1${UnblockPath}#" $0
fi
read -rp "请输入node程序路径(默认为node，直接回车使用默认值)：" NodeBin
if [ -z $NodeBin ];then
  sed -i 's/^\(Saved_NodeBin\=\)\(.*\)/\1node/' $0
else
  sed -i "s#^\(Saved_NodeBin\=\)\(.*\)#\1${NodeBin}#" $0
fi

ls $UnblockPath > /dev/null 2>&1
if [ 0 -ne $? ];then
  mkdir -p $UnblockPath
fi

cd $UnblockPath
git clone $GitLab && echo "UnblockNeteaseMusic安装成功!!!"
}

uninstall(){
  stop && rm -rf $Saved_UnblockPath/UnblockNeteaseMusic && echo "UnblockNeteaseMusic已卸载!!!"
}

cat <<EOF
   网易云音乐解锁工具MacOS系统一键脚本
西窗浪人倾情之作(https://www.bigxd.com)
               _
 ____  _____ _| |_ _____ _____  ___ _____
|  _ \| ___ (_   _) ___ (____ |/___) ___ |
| | | | ____| | |_| ____/ ___ |___ | ____|
|_| |_|_____)  \__)_____)_____(___/|_____)

选项：
1.开始运行（需要sudo权限运行脚本）
2.结束运行（需要sudo权限运行脚本）
3.重新启动（需要sudo权限运行脚本）
4.更新源码版本
5.安装
6.卸载（需要sudo权限运行脚本）

注意：需要sudo权限运行的选项都是需要修改hosts文件的操作

EOF
read -rp "请输入操作选项(数字)：" selected

case $selected in
1)
  start
  ;;
2)
  stop
  ;;
3)
  restart
  ;;
4)
  update
  ;;
5)
  install
  ;;
6)
  uninstall
  ;;
*)
  echo "输入的选项无法识别!!!"
  ;;
esac
