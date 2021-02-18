# Zabbix 运维监控

**时间**：2021.02.10 10:08:00

## 账号密码

```bash
# 虚拟机账号密码（XX.XX.XX.220）
root/root

# MYSQL 管理员账号密码及监控用户密码
root/Gg117664..
zabbix/Gg117664..

# zabbix 管理员
admin/zabbix
```



## 安装环境

### zabbix server安装信息

```shell
#  zabbix_server 版本
[root@0daycrack conf]# zabbix_server -V
zabbix_server (Zabbix) 3.4.15
Revision 86739 12 November 2018, compilation time: Nov 12 2018 10:55:19

Copyright (C) 2018 Zabbix SIA
License GPLv2+: GNU GPL version 2 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it according to
the license. There is NO WARRANTY, to the extent permitted by law.

This product includes software developed by the OpenSSL Project
for use in the OpenSSL Toolkit (http://www.openssl.org/).

Compiled with OpenSSL 1.0.1e-fips 11 Feb 2013
Running with OpenSSL 1.0.1e-fips 11 Feb 2013

# 操作系统版本
[root@0daycrack conf]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 

IP : 10.120.8.220

# server安装路径
[root@0daycrack zabbix]# pwd
/opt/zabbix

# conf 配置文件路径
# 配置文件有限选择zabbix server 同层及目录下的conf ， 也可以启动zabbix server 时指定conf文件路径
[root@0daycrack conf]# pwd
/opt/zabbix/conf
[root@0daycrack conf]# ls
zabbix_agentd  zabbix_agentd.conf
[root@0daycrack conf]# 

# 部分Unix server conf文件位于/usr/local/etc下
[root@0daycrack etc]# pwd
/usr/local/etc
[root@0daycrack etc]# ls
zabbix_agentd.conf  zabbix_agentd.conf.d
[root@0daycrack etc]# 

```


### 重启操作系统
```bash
reboot
```

### Zabbix server重启

```shell
#  查看server  状态
systemctl status zabbix-server.service

# 重启server 
systemctl start zabbix-server.service

# 停止server 
systemctl stop zabbix-server.service

# 重启zabbix即可
systemctl restart zabbix-server.service
```

### Zabbix agent重启(Unix&Linux)

```bash
# 强行kill 
$ kill -9 `ps -ef | grep zabbix_agentd | grep -v grep | awk '{print $2}'`

# 进入zabbix server 目录下， sbin下执行脚本 /opt/zabbix/zabbix_agents/sbin/zabbix_agentd
$ /opt/zabbix/zabbix_agents/sbin/zabbix_agentd

# 查看启动之后pid
ps -ef | grep zabbix_agentd | grep -v grep | awk '{print $2}'
```

### MySQL维护

```bash
# 启动数据库
systemctl  start mysqld.service

# 查看数据库启动状态
systemctl  status mysqld.service

# 停止数据库
systemctl  stop mysqld.service

### 登录数据库

​```bash
mysql -uroot -p
​```

### 查看数据库

​```bash
show databases;
​```

### 登录zabbix库

​```bash
use zabbix;
​```

### 查看表

​```bash
show tables;
quit
​```
### 
```
### 查看agent启动日志
```bash
tailf /var/log/zabbix/zabbix_agentd.log 
如下 ： 
  9900:20200817:220053.340 TLS support:           YES
  9900:20200817:220053.340 **************************
  9900:20200817:220053.340 using configuration file: /etc/zabbix/zabbix_agentd.conf
  9900:20200817:220053.341 agent #0 started [main process]
  9901:20200817:220053.341 agent #1 started [collector]
  9902:20200817:220053.341 agent #2 started [listener #1]
  9903:20200817:220053.341 agent #3 started [listener #2]
  9904:20200817:220053.342 agent #4 started [listener #3]
  9905:20200817:220053.342 agent #5 started [active checks #1]
  9905:20200817:220053.346 no active checks on server [192.168.2.7:10051]: host [node1_server] not found
```
### 启动httpd
```shell
# 启动httpd服务
systemctl  start  httpd.service

# 停止httpd服务
systemctl  stop  httpd.service

# 查看httpd服务
systemctl  status  httpd.service
```

## orabbix启动

```bash
# orabbix 启动
/opt/init.d/orabbix start
```



### 检查监控是否正常

1.    zabbix agent 日志是否有报错
```bash
tail -f /var/log/zabbix/zabbix_agentd.log
```


2.  zabbix agent 是否启动正常
```bash
ps aux | grep zabbix-agent
```
```bash
 telnet 192.168.2.100 10050
```
## Windows agent安装
## 启动zabbix-agent客户端
```bash
E:\zabbix\bin\win64>zabbix_agentd.exe -c E:\zabbix\conf\zabbix_agentd.win.conf -s

# 控制台信息
zabbix_agentd.exe [3176]: service [Zabbix Agent] started successfully

# windows下相关操作具体参照一下文档
https://www.cnblogs.com/xqzt/p/5130469.html
```
### 查看Windows端口监听情况
```bash
netstat -ano | findstr "10050"

tasklist | findstr zabbix
```
### 关闭防火墙
```bash
Windows 系统防火墙关闭或者开放10050端口 ， 自行百度
```
### 设置zabbix_agentd服务自启动
```bash
win+R,运行services.msc,默认是自动
```

## 日志及配置管理

```verilog
Zabbix server配置文件:/etc/zabbix/zabbix_server.conf
日志文件: /var/log/zabbix/zabbix_server.log
mysql数据库配置文件: /etc/my.cnf
日志文件：/var/log/mysqld.log
apache php参数: /etc/httpd/conf.d/zabbix.conf
orabbix配置：/opt/orabbix/conf/config.props
日志文件：/opt/orabbix/logs/orabbix.log
```



