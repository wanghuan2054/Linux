# Zabbix 主机监控部署

**时间**：2020.08.17 21:18:00


## 安装环境

1. zabbix server版本    

`  Zabbix 4.0.23`
## Linux agent安装
### centos 7.6 添加阿里云镜像
```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
2.	下载新的 CentOS-Base.repo 到 /etc/yum.repos.d/
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
3.	yum install -y epel-release
```


### 增加Zabbix4.0镜像源
```bash
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
rpm安装完之后，会在/etc/yum.repos.d下面创建zabbix.repo仓库，如果创建失败可以采用手动创建
若镜像源添加失败 ，手动添加yum源
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


如果出现以下CA证书错误，说明本地时间不正确。
https的证书是有开始时间和失效时间的。因此本地时间要在这个证书的有效时间内。不过最好的方式，还是能够把时间进行同步。
```bash
ntpdate pool.ntp.org
```
![图片.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597672257228-f146955d-8383-46f3-a1a6-6e9a330b3432.png#align=left&display=inline&height=240&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=481&originWidth=1716&size=49397&status=done&style=none&width=858)
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
reboot
```


### 安装Zabbix agent
```bash
yum install -y zabbix-agent
```


### 修改配置文件
```bash
vim /etc/zabbix/zabbix_agentd.conf 
修改1 ， zabbix server服务器IP 被动模式
Server=192.168.2.7 
修改2 zabbix server服务器IP 主动模式
ServerActive=192.168.2.7
修改3 ， 前端web监控将配置的主机名（必须一致）
Hostname=node1_server

```
### 启动agent
```bash
启动agent
systemctl start zabbix-agent
查看启动状态
systemctl status zabbix-agent
设置开机自启动
systemctl enable zabbix-agent
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
### zabbix server 前端页面添加
Host Name 必须和agentd.conf中hostname一致
![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597673446447-b7d1aa68-50d2-40d8-8914-c5ad71007ae2.png#align=left&display=inline&height=895&margin=%5Bobject%20Object%5D&name=error.png&originHeight=895&originWidth=1893&size=44457&status=done&style=none&width=1893)
配置监控模板
![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597673518544-7130ef50-de24-42ba-a2f1-b0d45a46c575.png#align=left&display=inline&height=534&margin=%5Bobject%20Object%5D&name=error.png&originHeight=534&originWidth=1088&size=25278&status=done&style=none&width=1088)
### 检查监控是否正常

1.    zabbix agent 日志是否有报错
```bash
tailf /var/log/zabbix/zabbix_agentd.log
```


2.  zabbix agent 是否启动正常
```bash
ps aux | grep zabbix-agent
```
![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597673930145-88313ecf-2ec0-427f-bb4e-0be71fb8e9b0.png#align=left&display=inline&height=104&margin=%5Bobject%20Object%5D&name=error.png&originHeight=249&originWidth=1797&size=31740&status=done&style=none&width=747)

3. zabbix server telnet agent
```bash
 telnet 192.168.2.100 10050
```
### ![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597674114748-6e0d82e9-f695-4a71-8fb1-e422d78f5506.png#align=left&display=inline&height=169&margin=%5Bobject%20Object%5D&name=error.png&originHeight=169&originWidth=770&size=10697&status=done&style=none&width=770)

4. web 前端

![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597674443645-a18586d9-aa5a-4c85-810c-09dcb065d4ef.png#align=left&display=inline&height=627&margin=%5Bobject%20Object%5D&name=error.png&originHeight=627&originWidth=1920&size=43334&status=done&style=none&width=1920)
## Windows agent安装
### 官网下载对应版本
![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597677525234-f1d44f29-fb1e-45c8-93ad-00558db42dbf.png#align=left&display=inline&height=926&margin=%5Bobject%20Object%5D&name=error.png&originHeight=926&originWidth=1719&size=69810&status=done&style=none&width=1719)


### 指定盘创建文件目录
```bash
1. D盘创建zabbix-agent目录
2. 将下载的archive包解压到该目录下， bin和conf目录
```
### 修改配置文件
```bash
修改1 ， zabbix server服务器IP 被动模式
Server=192.168.2.7 
修改2 zabbix server服务器IP 主动模式
ServerActive=192.168.2.7
修改3 ， 前端web监控将配置的主机名（必须一致）
Hostname=node1_server
```
### 用CMD（需有管理员权限）将Zabbix Agent安装为Windows系统的服务
```bash
在windows控制台下执行以下命令：找到CMD所在目录，C:\Windows\System32，右键cmd.exe，以管理员身份运行以下命令
D:\zabbix-agent\bin\zabbix_agentd.exe -i -c D:\zabbix-agent\conf\zabbix_agentd.conf

输出结果：
zabbix_agentd.exe [15816]: service [Zabbix Agent] installed successfully
zabbix_agentd.exe [15816]: event source [Zabbix Agent] installed successfully
```
## 启动zabbix-agent客户端
```bash
 D:\zabbix-agent\conf\zabbix_agentd.conf
 
 输出结果：
 zabbix_agentd.exe [16176]: service [Zabbix Agent] started successfully
```
### 查看Windows端口监听情况
```bash
netstat -ano | findstr "10050"

tasklist | findstr zabbix
```
### ![error.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597702978023-cac249c8-643f-4084-b198-5739efdc1ade.png#align=left&display=inline&height=391&margin=%5Bobject%20Object%5D&name=error.png&originHeight=391&originWidth=1066&size=25193&status=done&style=none&width=1066)
### 查看任务管理器
![image.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597703024553-3f80bb90-6b17-4b62-85e8-25bcd82ef13b.png#align=left&display=inline&height=369&margin=%5Bobject%20Object%5D&name=image.png&originHeight=737&originWidth=1275&size=111403&status=done&style=none&width=637.5)
### 查看zabbix_agent的启动日志zabbix_agentd.log
![image.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597703101070-7df72ee2-43f4-448b-9d09-1f0903ecb1bf.png#align=left&display=inline&height=260&margin=%5Bobject%20Object%5D&name=image.png&originHeight=519&originWidth=1516&size=112464&status=done&style=none&width=758)
### 关闭防火墙
```bash
Windows 系统防火墙关闭或者开放10050端口 ， 自行百度
```
### 设置zabbix_agentd服务自启动
```bash
win+R,运行services.msc,默认是自动
```




## 在Zabbix Web UI创建主机，查看监控结果
![image.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1597704286808-a8631dfa-c904-4493-863b-7ba8534f0468.png#align=left&display=inline&height=309&margin=%5Bobject%20Object%5D&name=image.png&originHeight=618&originWidth=1917&size=78019&status=done&style=none&width=958.5)

