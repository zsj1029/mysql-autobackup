#!/bin/bash
# backup.sh: backup mysql databases
#  
# ${db_user} is mysql username  
# ${db_password} is mysql password  
# ${db_host} is mysql host   
# —————————–  
# /root/backup.sh
# everyday 3:00 AM execute database backup
# 0 3 * * * /root/mysql_backup.sh
# /etc/cron.daily

# 需要备份的多个数据库 #待备份库名 host 账号 密码
all_db=('database1 192.168.0.1 root password' 'database2 192.168.0.2 root password')
# 备份服务器地址共享目录
SMB_BACKUP_SOURCE="//192.168.0.3/share/"
# 备份服务器账号
SMB_BACKUP_USER="administrator"
# 备份服务器密码
SMB_BACKUP_PASSWORD="password"
# 映射本地保存路径
SMB_BACKUP_DIR="/mnt/backup/"
# mysql bin路径  #
mysql="/usr/bin/mysql"
mysqldump="/usr/bin/mysqldump"
#如果用于映射 Samba 远程目录的备份目录不存在，就创建：
[[ ! -d "$SMB_BACKUP_DIR" ]] && mkdir -p $SMB_BACKUP_DIR

# fuser -mv -k ${SMB_BACKUP_DIR}
#挂载服务器共享目录
mount -t cifs "$SMB_BACKUP_SOURCE" "$SMB_BACKUP_DIR" -o username="$SMB_BACKUP_USER",password="$SMB_BACKUP_PASSWORD"

# 要保留的备份天数 #
backup_day=30

#数据库备份日志文件存储的路径
logfile="/var/log/mysql_backup.log"

# date format for backup file (dd-mm-yyyy)  #
time="$(date +"%Y-%m-%d")"


#备份数据库函数#
mysql_backup()
{
    # 循环需要备份的数据库名 #
   
    for ((i=0;i<${#all_db[@]};i++))
    do
        eval db=(${all_db[i]})
        # echo ${db}
        db_name=${db[0]}
        db_host=${db[1]}
        db_user=${db[2]}
        db_password=${db[3]}
       
        backname=${db_name}.${time}
        # echo ${db_host} ${db_user} ${db_password}
        dumpfile=${SMB_BACKUP_DIR}${backname}
        
        # #将备份的时间、数据库名存入日志
        echo "------"$(date +'%Y-%m-%d %T')" Beginning database "${db_name}" backup--------" >>${logfile}
        ${mysqldump} -F -u${db_user} -h${db_host} -p${db_password} ${db_name} > ${dumpfile}.sql 2>>${logfile} 2>&1
        
        echo -e "------"$(date +'%Y-%m-%d %T')" Ending database "${db_name}" backup-------\n" >>${logfile}   
       
    done
}

delete_old_backup()
{    
    echo "delete backup file:" >>${logfile}
    # 删除旧的备份 查找出当前目录下30天前生成的文件，并将之删除
    find ${SMB_BACKUP_DIR} -type f -mtime +${backup_day} | tee delete_list.log | xargs rm -rf
    # cat delete_list.log >>${logfile}
    umount $SMB_BACKUP_DIR
}


mysql_backup
delete_old_backup

echo -e "========================mysql backup && rsync done at "$(date +'%Y-%m-%d %T')"============================\n\n">>${logfile}
cat ${logfile}
