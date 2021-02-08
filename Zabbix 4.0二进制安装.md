# Zabbix 4.0二进制安装

**时间**：2020.08.14 23:56:00


## 安装环境

1. 查看Linux版本    

`cat /etc/redhat-release `
CentOS Linux release 7.8.2003 (Core)
## Zabbix二进制安装
### centos 7 添加阿里云镜像
```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
2.	下载新的 CentOS-Base.repo 到 /etc/yum.repos.d/
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
3.	运行 yum makecache 生成缓存
         yum -y makecache
4. yum install -y epel-release
```
### 安装常用的开发组件
```bash
yum -y groups install "Development Tools"
yum groups info  "Development Tools"
```


### 增加Zabbix4.0镜像源
```bash
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

若镜像源添加失败 ，添加yum源
cat <<EOF > /etc/yum.repos.d/zabbix.repo
[zabbix]
name=Zabbix Official Repository - \$basearch
baseurl=https://mirrors.aliyun.com/zabbix/zabbix/4.0/rhel/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591

[zabbix-non-supported]
name=Zabbix Official Repository non-supported - \$basearch
baseurl=https://mirrors.aliyun.com/zabbix/non-supported/rhel/7/\$basearch/
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
gpgcheck=1
EOF
```


### 关闭防火墙
```bash
systemctl stop firewalld.service
systemctl disable  firewalld.service
yum -y install vim
关闭SElinux
vim /etc/selinux/config
SELINUX=disable
```


### 重启操作系统
```bash
Reboot
yum -y install iptables-services
```


### 安装Zabbix Server和Frontend
```bash
yum install -y zabbix-server-mysql
yum install -y zabbix-web-mysql
```


### 安装MySQL
```bash
yum install -y mariadb-server
若已经安装Mysql 则会替代mariadb-server
```
### 启动数据库
```bash
systemctl  start mariadb.service
systemctl  start mysqld.service
```
### 查看数据库启动状态
```bash
systemctl  status mariadb.service
systemctl  status mysqld.service
mysql_secure_installation
```
### 是否需要修改root密码
```bash
Enter current password for root (enter for none):回车
```
### 是否设置root密码
```bash
Set root password? [Y/n] n
```
### 是否删除匿名用户
```bash
Remove anonymous users? [Y/n] y
```
### 是否禁止root登陆
```bash
Disallow root login remotely? [Y/n] n
```
### 是否删除测试数据库
```bash
Remove test database and access to it? [Y/n] y
```
### 重新加载权限
```bash
Reload privilege tables now? [Y/n] y
```
### 创建数据库
```bash
mysql -uroot -p
create database zabbix character set utf8 collate utf8_bin;
```
### 查看数据库
```bash
show databases;
```
### 创建数据库用户并赋予访问权限
```bash
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
```
### 刷新权限
```bash
Flush privileges;
```
### 退出数据库
```bash
quit
```
### 导入数据结构
```bash
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix@findsec123  zabbix
```
### 登录数据库
```bash
mysql -uroot -p
```
### 查看数据库
```bash
show databases;
```
### 登录zabbix库
```bash
use zabbix;
```
### 查看表
```bash
show tables;
quit
```
### 配置Zabbix Server
```bash
vim /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword= zabbix@findsec123
启动Zabbix Server
systemctl  start zabbix-server.service
systemctl  status zabbix-server.service
more /var/log/zabbix/zabbix_server.log
```
### 查看Zabbix Server版本
```bash
zabbix_server -V
zabbix_server --version
```
### 查看Zabbix Server版本
### 配置Zabbix frontend
```bash
vim /etc/php.ini
max_execution_time = 300
memory_limit = 128M
post_max_size = 16M
upload_max_filesize = 2M
max_input_time = 300
max_input_vars = 10000
always_populate_raw_post_data = -1
date.timezone = Asia/Shanghai
```
### 启动httpd
```bash
systemctl  start  httpd.service
systemctl  status  httpd.service
```
### 前端网页访问[http://192.168.2.7/zabbix/setup.php](http://192.168.159.130/zabbix/setup.php)
_**账号密码：Admin/zabbix**_
### 安装Zabbix Agent
```bash
yum install zabbix-agent
```
### 确认agent配置
```bash
vim /etc/zabbix/zabbix_agentd.conf
需要修改
Hostname=zabbix-server（需要和上面zabbix web安装界面设置的服务端的name一致）
systemctl  start zabbix-agent.service
```
