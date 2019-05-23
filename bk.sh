#!/bin/bash

#######################
db_user=""
db_passwd=""
db_defaults_file="/etc/my.cnf"
db_socket="/tmp/mysql.sock"
db_backup="/data/backup/"
db_backup_log="/data/backup/log/"

#用于压缩并转移源文件
time="$(date +"back_%d-%m-%Y")"
time_rm=`date -d "1 days ago" +"back_%d-%m-%Y"`
time_8=`date -d "30 days ago" +"back_%d-%m-%Y"`
logfile=$db_backup_log/result.log
logger() {
    echo $(date +"%Y-%m-%d %H:%M:%S") "[$1]" "$2" >> $logfile
}


if [ ! -d ${db_backup_log} ];then
    mkdir -p ${db_backup_log}
fi

#todo
echo '全备份'
backup_full=${time_rm}
logger INFO "Start backup at $(date)"
/data/xtrabackup/bin/innobackupex --defaults-file=$db_defaults_file --no-timestamp --user=${db_user} --password=${db_passwd} --no-lock  --socket=$db_socket ${db_backup}${backup_full}/ >> $logfile 2>&1

if [ -d ${db_backup}${time_rm} ]; then
       su - root -c "tar -czPvf ${db_backup}${time_rm}_full_dd.tar.gz ${db_backup}${time_rm}"
       su - root -c  "rm -rf ${db_backup}${time_rm}"
       logger INFO "压缩目录rm $db_backup${time_rm} $(date)"
fi

if [ $? -eq 0 ]; then
   logger INFO "备份成功!!! $(date)"
else
   logger ERROR "备份失败??? $(date)"
fi

if [ -f ${db_backup}${time_8}_full.tar.gz ];then
    su - root -c  "rm -rf ${db_backup}${time_8}_full_dd.tar.gz"
    logger INFO "已删除${db_backup}${time_8}_full_dd.tar.gz备份 $(date)"
fi
