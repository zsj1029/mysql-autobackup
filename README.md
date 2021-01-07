# mysql-autobackup
每日定时 从多个数据库 全局备份mysql 到独立的共享目录

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
# 要保留的备份天数 #
backup_day=30


