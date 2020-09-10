#!/bin/bash
# Auto Deploy Tomcat For Jenkins Script 
# By Author WangHuan 2020-09-04

#取当前系统时间
time_now=$(date "+%Y%m%d%H%M%S")
# Test Tocmat Server 根目录地址
TOMCAT_ROOT_DIR="/home/webadm/tomcat_server_tst"
# Test Tocmat Server Webapps 目录地址
TOMCAT_WEB_DIR="$TOMCAT_ROOT_DIR/webapps"
# 查找Test Tocmat Server 进程 ID
TOMCAT_PID=`ps -ef | grep -v grep | grep tomcat_server_tst | awk '{print $2}'`
# 最新源码war地址
LAEST_SOURCECODE_DIR="/home/webadm/Web-Realease"
# Test Tocmat Server war 备份目录
BACKUP_DIR="$LAEST_SOURCECODE_DIR/war_backup_tst"
# Tomcat 下需要清除的work缓存目录地址
WORKCACHE_DIR="$TOMCAT_ROOT_DIR/work"

# war 版本保留的数量
KEEP_VERSION_NUMS=5

# War 包名字
WAR_NAME="ROOT.war"

# 判断war备份目录是否存在，不存在创建
if [ ! -d  $BACKUP_DIR ];
then
	# 递归创建目录
	mkdir -p $BACKUP_DIR
    echo -e "this is $BACKUP_DIR Create success ! "

else
	echo -e "$BACKUP_DIR directory already exists"
fi

# 判断当前Tomcat 进程是否alive，若存活则kill
if [ -n  "$TOMCAT_PID" ]; 
then
	# kill tomcat 进程
	# kill -9 $TOMCAT_PID
	ps -ef | grep -v grep | grep tomcat_server_tst | awk '{print $2}' | xargs kill -9
    echo -e "$TOMCAT_PID Tomcat Server Process kill success !"
fi
sleep 3

# 将之前版本代码移走备份
# 先判断War文件是否存在
if [ ! -f  $TOMCAT_WEB_DIR/$WAR_NAME ];then
    echo -e "$TOMCAT_WEB_DIR/$WAR_NAME is not exists ,mv backup Failed !"
else
    mv $TOMCAT_WEB_DIR/$WAR_NAME  $BACKUP_DIR/$WAR_NAME-$time_now
fi

# 上一步mv执行成功，返回0
if [ $? -eq 0 ]; then
    echo -e "$TOMCAT_WEB_DIR/$WAR_NAME Backup Success! "
else
    echo -e "$TOMCAT_WEB_DIR/$WAR_NAME Backup Failed!"
fi


# BACKUP_DIR 目录下只保留最近N个版本的war包 , 进入备份目录执行删除命令
cd $BACKUP_DIR
echo -e "cd $BACKUP_DIR Success! "
ALL_VERSION_NUMS=$(ls -l | grep $WAR_NAME | wc -l )
# DEL_VERSION_NUMS=`expr $ALL_VERSION_NUMS - $KEEP_VERSION_NUMS`
if [ $(ls -l | grep $WAR_NAME | wc -l ) -gt $KEEP_VERSION_NUMS ]; then
   rm -r $(ls -rt | head -n -$KEEP_VERSION_NUMS)
   # 删除备份版本执行成功，返回0
   if [ $? -eq 0 ]; then
	   echo -e "$BACKUP_DIR , Delete War Versions Before Latest $VERSION_NUMS Versions Success!"
   else
	   echo -e "$BACKUP_DIR , Delete War Versions Before Latest $VERSION_NUMS Versions Failed!"
   fi
else 
   echo -e "$BACKUP_DIR , Current War Version Nums  < Keep $VERSION_NUMS Versions !"
fi

# 删除解压出的ROOT WEB 目录
rm -rf $TOMCAT_WEB_DIR/ROOT
# 上一步mv执行成功，返回0
if [ $? -eq 0 ]; then
    echo -e "$TOMCAT_WEB_DIR/ROOT Directory Clean Up Success!"
else
    echo -e "$TOMCAT_WEB_DIR/ROOT Directory Clean Up Failed!"
fi

# 拷贝最新war包到Tomcat Server Webapps
cp $LAEST_SOURCECODE_DIR/$WAR_NAME $TOMCAT_WEB_DIR/$WAR_NAME
if [ $? -eq 0 ]; then
    echo -e "Laest $WAR_NAME Upload $TOMCAT_WEB_DIR Success !"
else
    echo -e "Laest $WAR_NAME Upload $TOMCAT_WEB_DIR Failed !"
	# 如果war 包上传失败，退出Shell ， 后续命令不执行
	exit
fi

# 清除Tomcat下的work缓存目录
rm -rf $WORKCACHE_DIR
if [ $? -eq 0 ]; then
    echo -e "$TOMCAT_WEB_DIR work Cache Clean Up Success ! "
else
    echo -e "$TOMCAT_WEB_DIR work Cache Clean Up Failed ! "
fi

# 启动Tomcat Tst server
$TOMCAT_ROOT_DIR/bin/startup.sh
sleep 5

TOMCAT_PID=`ps -ef | grep -v grep | grep tomcat_server_tst | awk '{print $2}'`
echo $TOMCAT_PID
# 判断当前Tomcat 进程是否启动成功
if [ -n  "$TOMCAT_PID" ]; 
then
    echo -e "Tomcat_tst_server  Start Success !"
else
	echo -e "Tomcat_tst_server  Start Failed  !"
	exit
fi

# 查看Tomcat 启动输出log
# tail -n 10 $TOMCAT_ROOT_DIR/logs/catalina.out





