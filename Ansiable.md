# 自动化运维之Ansiable

**时间**：2021.02.12 06:14:00

## Python安装

### Python 当前版本查看

```bash
[root@devops ~]# python
Python 2.7.5 (default, Apr  2 2020, 13:16:51) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-39)] on linux2

# 当前系统版本查看
[root@devops python-3.6.8]# cat /etc/redhat-release 
CentOS Linux release 7.8.2003 (Core)
```

### 下载python-3.6.8安装包

```bash
cd /home
mkdir software  #创建一个专门存放软件的目录
cd software/
wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz
```

### 安装

```bash
yum  -y install gcc zlib*  #提前安装依赖包，避免之后报错
cd /home/software/  #进入软件目录
tar -xvf Python-3.6.8.tgz  #解压
cd Python-3.6.8/   #进入解压目录
./configure --prefix=/usr/local/python-3.6.8  # prefix：设定安装目录
make
make install
```

### 设置软链接

```bash
# python 3 安装过程中会导致 Linux下python软连接失效 
mv /usr/bin/python /usr/bin/python2.7.bak   #备份原链接
ln -s /usr/local/python-3.6.8/bin/python3 /usr/bin/python  #设置新链接
```

### 验证升级是否成功

```bash
[root@devops bin]# python
Python 3.6.8 (default, Feb 12 2021, 07:30:39) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-44)] on linux
```

### 更改yum配置

因为yum需要使用python2，将/usr/bin/python改为python3后，yum就不能正常运行了，因此需要更改一下yum的配置。

```bash
vim /usr/bin/yum
vim /usr/libexec/urlgrabber-ext-down
```

编辑这两个文件，将文件头的`#!/usr/bin/python`改为`#!/usr/bin/python2`即可。

### **Tweak-tool设置**

```bash
vi /usr/bin/gnome-tweak-tool 

# 打开文件，然后将首行的 #!/usr/bin/python 改为 #!/usr/bin/python2.7，:wq保存退出即可。
```

##### pip3命令找不到的解决方法

```bash
# 因为我用的是 python3 ，所以我执行的命令为：
sudo python3 -m pip install --upgrade --force-reinstall pip

# 重新设置python home 和 path路径
[root@devops opt]# vim /etc/profile
PYTHON_HOME=/usr/local/python-3.6.8
export PATH=$PATH:$PYTHON_HOME/bin
```



## Ansible 安装和入门

### Ansible安装

ansible的安装方法有多种

##### EPEL源的rpm包安装:（推荐）

```bash
# 推荐使用Centos 7 安装 ， 默认安装的是python 2.7 版本 
# 1. 第1种基于python2.7版本安装ansible
# 2. 第2种升级python2.7版本到3.X版本，需要手动创建ansible配置文件及目录等
[root@devops ~]# yum install ansible

# yum 卸载ansible
[root@devops bin]# yum remove ansible
# 更新软件
# yum update 软件名称
```
##### Centos 8安装方式（推荐）

```bash
# Ansible 包不在 CentOS 8 默认的软件包仓库中。因此，我们需要执行以下命令启用 EPEL 仓库：
[root@devops bin]# dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

#启用 epel 仓库后，执行以下 dnf 命令安装 Ansible：
[root@devops bin]#  dnf install ansible

#成功安装 Ansible 后，运行以下命令验证它的版本：
[root@devops bin]# ansible --version
ansible 2.9.17
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.6/site-packages/ansible
  executable location = /bin/ansible
  python version = 3.6.8 (default, Aug 24 2020, 17:57:11) [GCC 8.3.1 20191121 (Red Hat 8.3.1-5)]
```

##### 编译安装

```bash
yum -y install python-jinja2 PyYAML python-paramiko python-babel python-crypto
tar xf ansible-1.5.4.tar.gz
cd ansible-1.5.4
python setup.py build
python setup.py install
mkdir /etc/ansible
cp -r examples/* /etc/ansible
```

##### Git方式

```bash
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
source ./hacking/env-setup
```
##### pip 安装

pip 是安装Python包的管理器，类似 yum

```bash
yum install python-pip python-devel
yum install gcc glibc-devel zibl-devel  rpm-bulid openssl-devel
pip install  --upgrade pip
pip install ansible --upgrade

# 使用pip安装后，需要在/usr/bin/ansible  兴建软链接指向 /usr/local/python-3.6.8/bin/ansible
[root@devops bin]# ln -s /usr/local/python-3.6.8/bin/ansible /usr/bin/ansible 
[root@devops bin]# ls ansi* -l
lrwxrwxrwx 1 root root 35 2月  13 07:37 ansible -> /usr/local/python-3.6.8/bin/ansible
```
##### 查看安装版本
```bash
[root@devops bin]# ansible --version
ansible 2.10.5
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/python-3.6.8/lib/python3.6/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.6.8 (default, Feb 12 2021, 07:30:39) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```


参考文档：http://www.yunweipai.com/34676.html

## 配置文件

## Ansible目录结构

```
可以使用：rpm -ql ansible | less  来查看ansible安装的所有路径
配置文件目录：  ``/etc/ansible
执行文件目录： ``/usr/bin
lib库依赖目录：``/usr/lib/python2``.7``/site-packages/ansible
help文档目录：``/usr/share/doc/ansible-2``.7.5
man``文档目录：``/usr/share/man/man1/
```

```bash
# 默认使用yum 安装完成后，自动升成配置文件/etc/ansible
[root@devops ansible]# ls
ansible.cfg  hosts  roles
```

### 配置文件

- /etc/ansible/ansible.cfg   主配置文件，配置ansible的工作特性

- /etc/ansible/hosts  主机清单

- /etc/ansible/roles  存放角色的目录

  ```bash
  默认配置
  这里的配置项有很多，这里主要介绍一些常用的
  [defaults]
  #inventory      = /etc/ansible/hosts                        #被控端的主机列表文件
  #library        = /usr/share/my_modules/                    #库文件存放目录
  #remote_tmp     = ~/.ansible/tmp                            #临时文件远程主机存放目录
  #local_tmp      = ~/.ansible/tmp                            #临时文件本地存放目录
  #forks          = 5                                         #默认开启的并发数
  #poll_interval  = 15                                        #默认轮询时间间隔(单位秒)
  #sudo_user      = root                                      #默认sudo用户
  #ask_sudo_pass = True                                       #是否需要sudo密码
  #ask_pass      = True                                       #是否需要密码
  #transport      = smart                                     #传输方式
  #remote_port    = 22                                        #默认远程主机的端口号
  建议开启修改以下两个配置参数(取消掉注释即可)
  #host_key_checking = False                                  #检查对应服务器的host_key
  #log_path=/var/log/ansible.log                              #开启ansible日志
  ```

## Ansible相关工具

```bash
# /usr/bin/ansible 主程序，临时命令执行工具
# /usr/bin/ansible-doc 查看配置文档，模块功能查看工具
# /usr/bin/ansible-galaxy 下载/上传优秀代码或Roles模块的官网平台
# /usr/bin/ansible-playbook 定制自动化任务，编排剧本工具
# /usr/bin/ansible-pull 远程执行命令的工具
# /usr/bin/ansible-vault 文件加密工具
# /usr/bin/ansible-console 基于Console界面与用户交互的执行工具

# 利用ansible实现管理的主要方式：

    Ad-Hoc 即利用ansible命令，主要用于临时命令使用场景
    Ansible-playbook 主要用于长期规划好的，大型项目的场景，需要有前期的规划过程
```

### **利用ansible实现管理的方式**

- Ad-Hoc 即利用ansible命令，主要用于临时命令使用场景
- Ansible-playbook 主要用于长期规划好的，大型项目的场景，需要有前期的规划过程

### ansible-doc

此工具用来显示模块帮助

```bash
ansible-doc [options] [module...]
-l, --list          #列出可用模块
-s, --snippet       #显示指定模块的playbook片段

# 范例：
#列出所有模块
ansible-doc -l  
#查看指定模块帮助用法
ansible-doc ping  
#查看指定模块帮助用法
ansible-doc -s  ping 
```



### ansible

此工具通过ssh协议，实现对远程主机的配置管理、应用部署、任务执行等功能

建议：使用此工具前，先配置ansible主控端能基于密钥认证的方式联系各个被管理节点

范例：利用sshpass批量实现基于key验证 （一般建议以root身份验证）

```bash
#!/bin/bash
ssh-keygen -f /root/.ssh/id_rsa  -P ''
NET=192.168.2
export SSHPASS=hadoop
for IP in {54..55};do
    sshpass -e ssh-copy-id -i /root/.ssh/id_rsa.pub  hadoop@$NET.$IP
done

# 正常如果没有使用用户名，默认使用的是root，如果采用普通用户连接过去，ansible好多模块使用会有权限限制。
# ssh-copy-id 将key写到远程机器的 ~/ .ssh/authorized_key.文件中
# -e 采用设置env环境变量的方式传递密码 , -p 采用明文密码传递， -f 采用文件第一行存储密码方式传递
```

**格式：**

```bash
ansible <host-pattern> [-m module_name] [-a args]
```

**选项说明**

```bash
--version           #显示版本
-m module           #指定模块，默认为command
-v                  #详细过程 –vv  -vvv更详细
--list-hosts        #显示主机列表，可简写 --list
-k, --ask-pass      #提示输入ssh连接密码，默认Key验证    
-C, --check         #检查，并不执行
-T, --timeout=TIMEOUT #执行命令的超时时间，默认10s
-u, --user=REMOTE_USER #执行远程执行的用户
-b, --become        #代替旧版的sudo 切换
--become-user=USERNAME  #指定sudo的runas用户，默认为root
-K, --ask-become-pass  #提示输入sudo时的口令
```

**ansible查看当前控制的主机列表**

```bash
[root@devops .ssh]# ansible all  --list
  hosts (3):
    192.168.2.7
    192.168.2.54
    192.168.2.55
[root@devops .ssh]# ansible all  --list-hosts
  hosts (3):
    192.168.2.7
    192.168.2.54
    192.168.2.55
[root@devops .ssh]# ansible all  --list-host
  hosts (3):
    192.168.2.7
    192.168.2.54
    192.168.2.55
    
# 按照主机组去查询IP
[root@devops .ssh]#  ansible hadoopsrvs  --list
  hosts (2):
    192.168.2.54
    192.168.2.55
[root@devops .ssh]#  ansible testsrvs  --list
  hosts (1):
    192.168.2.7

```



**ansible的Host-pattern**
 用于匹配被控制的主机的列表
 All ：表示所有Inventory中的所有主机

范例

```bash
ansible all –m ping

# 采用输入密码验证方式
ansible all -k -m ping# 采用输入密码验证方式
```

Bash

*:通配符

```
ansible "*" -m ping
ansible  192.168.1.* -m ping
ansible  srvs  -m ping
```

**或关系** 

```
ansible testsrvs:appsrvs  -m ping 
ansible 192.168.1.10:192.168.1.20  -m ping
```

**逻辑与**

```bash
#在websrvs组并且在dbsrvs组中的主机
ansible websrvs:&dbsrvs –m ping 
```

Bash

**逻辑非**

```bash
#在websrvs组，但不在dbsrvs组中的主机
#注意：此处为单引号
ansible ‘websrvs:!dbsrvs’ –m ping 
```

Bash

**综合逻辑**

```bash
ansible ‘websrvs:dbsrvs:&appsrvs:!ftpsrvs’ –m ping
```

Bash

**正则表达式**

```bash
ansible websrvs:dbsrvs –m ping 
ansible “~(web|db).*\.magedu\.com” –m ping 
```

Bash

**ansible命令执行过程** 

1.加载自己的配置文件 默认/etc/ansible/ansible.cfg

2.加载自己对应的模块文件，如：command

3.通过ansible将模块或命令生成对应的临时py文件，并将该文件传输至远程服务器的对应执行用户$HOME/.ansible/tmp/ansible-tmp-数字/XXX.PY文件

4.给文件+x执行

5.执行并返回结果

6.删除临时py文件，退出

**ansible 的执行状态：**

```bash
[root@centos8 ~]#grep -A 14 '\[colors\]' /etc/ansible/ansible.cfg 
[colors]
#highlight = white
#verbose = blue
#warn = bright purple
#error = red
#debug = dark gray
#deprecate = purple
#skip = cyan
#unreachable = red
#ok = green
#changed = yellow
#diff_add = green
#diff_remove = red
#diff_lines = cyan
```

Bash

- 绿色：执行成功并且不需要做改变的操作
- 黄色：执行成功并且对目标主机做变更
- 红色：执行失败

**ansible使用范例**

```bash
#以wang用户执行ping存活检测
ansible all -m ping -u wang  -k
#以wang sudo至root执行ping存活检测
ansible all -m ping -u wang -k -b
#以wang sudo至mage用户执行ping存活检测
ansible all -m ping -u wang -k -b --become-user=mage
#以wang sudo至root用户执行ls 
ansible all -m command  -u wang -a 'ls /root' -b --become-user=root   -k -K
```

### ansible-galaxy

此工具会连接 [https://galaxy.ansible.com](http://www.yunweipai.com/go?_=ae1f7f3df2aHR0cHM6Ly9nYWxheHkuYW5zaWJsZS5jb20=) 下载相应的roles

范例：

```bash
#列出所有已安装的galaxy
ansible-galaxy list
#安装galaxy
ansible-galaxy install geerlingguy.mysql
ansible-galaxy install geerlingguy.redis
#删除galaxy
ansible-galaxy remove geerlingguy.redis
```

### ansible-playbook

此工具用于执行编写好的 playbook 任务

范例：

```bash
ansible-playbook hello.yml
cat  hello.yml
---
#hello world yml file
- hosts: websrvs
  remote_user: root  
  tasks:
    - name: hello world
      command: /usr/bin/wall hello world
```

### ansible-vault

此工具可以用于加密解密yml文件

格式：

```bash
ansible-vault [create|decrypt|edit|encrypt|rekey|view]
```

范例

```bash
ansible-vault encrypt hello.yml     #加密
ansible-vault decrypt hello.yml     #解密
ansible-vault view hello.yml        #查看
ansible-vault edit  hello.yml       #编辑加密文件
ansible-vault rekey  hello.yml      #修改口令
ansible-vault create new.yml        #创建新文件
```

### ansible-console

此工具可交互执行命令，支持tab，ansible 2.0+新增

提示符格式：

```
执行用户@当前操作的主机组 (当前组的主机数量)[f:并发数]$
```

常用子命令：

- 设置并发数： forks n  例如： forks 10
- 切换组： cd 主机组  例如： cd web
- 列出当前组主机列表： list
- 列出所有的内置命令： ?或help

范例

```
[root@ansible ~]#ansible-console
Welcome to the ansible console.
Type help or ? to list commands.

root@all (3)[f:5]list
10.0.0.8
10.0.0.7
10.0.0.6
root@all (3)[f:5] cd websrvs
root@websrvs (2)[f:5]list
10.0.0.7
10.0.0.8
root@websrvs (2)[f:5] forks 10
root@websrvs (2)[f:10]cd appsrvs
root@appsrvs (2)[f:5] yum name=httpd state=present
root@appsrvs (2)[f:5]$ service name=httpd state=started
```

## Ansible常用模块

2015年底270多个模块，2016年达到540个，2018年01月12日有1378个模块，2018年07月15日1852个模块,2019年05月25日（ansible 2.7.10）时2080个模块，2020年03月02日有3387个模块

虽然模块众多，但最常用的模块也就2，30个而已，针对特定业务只用10几个模块

常用模块帮助文档参考：

```
https://docs.ansible.com/ansible/latest/modules/modules_by_category.html
```

### Command 模块

功能：在远程主机执行命令，此为默认模块，可忽略-m选项

注意：此命令不支持 $VARNAME <  >  |  ; &  通配符 等，用shell模块实现

范例：

```bash
[root@ansible ~]#ansible websrvs -m command -a 'chdir=/etc cat centos-release'
10.0.0.7 | CHANGED | rc=0 >>
CentOS Linux release 7.7.1908 (Core)
10.0.0.8 | CHANGED | rc=0 >>
CentOS Linux release 8.1.1911 (Core)
[root@ansible ~]#ansible websrvs -m command -a 'chdir=/etc creates=/data/f1.txt cat centos-release'
10.0.0.7 | CHANGED | rc=0 >>
CentOS Linux release 7.7.1908 (Core)
10.0.0.8 | SUCCESS | rc=0 >>
skipped, since /data/f1.txt exists
[root@ansible ~]#ansible websrvs -m command -a 'chdir=/etc removes=/data/f1.txt cat centos-release'
10.0.0.7 | SUCCESS | rc=0 >>
skipped, since /data/f1.txt does not exist
10.0.0.8 | CHANGED | rc=0 >>
CentOS Linux release 8.1.1911 (Core)

ansible websrvs -m command -a ‘service vsftpd start’ 
ansible websrvs -m command -a ‘echo magedu |passwd --stdin wang’   
ansible websrvs -m command -a 'rm -rf /data/'
ansible websrvs -m command -a 'echo hello > /data/hello.log'
ansible websrvs -m command -a "echo $HOSTNAME"
```

### Shell模块

功能：和command相似，用shell执行命令

范例：

```bash
[root@ansible ~]#ansible websrvs -m shell -a "echo HOSTNAME"
10.0.0.7 | CHANGED | rc=0 >>
ansible
10.0.0.8 | CHANGED | rc=0 >>
ansible
[root@ansible ~]#ansible websrvs -m shell -a 'echoHOSTNAME'
10.0.0.7 | CHANGED | rc=0 >>
centos7.wangxiaochun.com
10.0.0.8 | CHANGED | rc=0 >>
centos8.localdomain

[root@ansible ~]#ansible websrvs -m shell -a 'echo centos | passwd --stdin wang'
10.0.0.7 | CHANGED | rc=0 >>
Changing password for user wang.
passwd: all authentication tokens updated successfully.
10.0.0.8 | CHANGED | rc=0 >>
Changing password for user wang.
passwd: all authentication tokens updated successfully.
[root@ansible ~]#ansible websrvs -m shell -a 'ls -l /etc/shadow'
10.0.0.7 | CHANGED | rc=0 >>
---------- 1 root root 889 Mar  2 14:34 /etc/shadow
10.0.0.8 | CHANGED | rc=0 >>
---------- 1 root root 944 Mar  2 14:34 /etc/shadow
[root@ansible ~]#ansible websrvs -m shell -a 'echo hello > /data/hello.log'
10.0.0.7 | CHANGED | rc=0 >>

10.0.0.8 | CHANGED | rc=0 >>

[root@ansible ~]#ansible websrvs -m shell -a 'cat  /data/hello.log'
10.0.0.7 | CHANGED | rc=0 >>
hello
10.0.0.8 | CHANGED | rc=0 >>
hello
```

注意：调用bash执行命令 类似 cat /tmp/test.md | awk -F‘|’ ‘{print 1,1,1,2}’ &> /tmp/example.txt 这些复杂命令，即使使用shell也可能会失败，解决办法：写到脚本时，copy到远程，执行，再把需要的结果拉回执行命令的机器

范例：将shell模块代替command，设为模块

```bash
[root@ansible ~]#vim /etc/ansible/ansible.cfg
#修改下面一行
module_name = shell
```

### Script模块

功能：在远程主机上运行ansible服务器上的脚本，有一个远程主机推送脚本到所有服务器的一个操作过程

范例：

```bash
[root@devops data]# pwd
/data
[root@devops data]# cat a.sh 
#!/bin/bash
echo $HOSTNAME

ansible websrvs  -m script -a /data/test.sh
```

### Copy模块

功能：从ansible服务器主控端复制文件到远程主机

```bash
#如目标存在，默认覆盖，此处指定先备份
ansible websrvs -m copy -a “src=/root/test1.sh dest=/tmp/test2.sh    owner=wang  mode=600 backup=yes” 
#指定内容，直接生成目标文件    
ansible websrvs -m copy -a "content='test line1\ntest line2' dest=/tmp/test.txt"
#复制/etc/下的文件，不包括/etc/目录自身
ansible websrvs -m copy -a “src=/etc/ dest=/backup”
```

### Fetch模块

功能：从远程主机提取文件至ansible的主控端，copy相反，目前不支持目录

功能：从远程主机提取文件至ansible的主控端，copy相反，目前不支持目录

范例：

```
ansible websrvs -m fetch -a ‘src=/root/test.sh dest=/data/scripts’ 
```

范例：

```
[root@ansible ~]#ansible   all -m  fetch -a 'src=/etc/redhat-release dest=/data/os'
[root@ansible ~]#tree /data/os/
/data/os/
├── 10.0.0.6
│   └── etc
│       └── redhat-release
├── 10.0.0.7
│   └── etc
│       └── redhat-release
└── 10.0.0.8
    └── etc
        └── redhat-release

6 directories, 3 files
```

### File模块

功能：设置文件属性

范例：

```bash
#创建空文件
ansible all -m  file  -a 'path=/data/test.txt state=touch'
ansible all -m  file  -a 'path=/data/test.txt state=absent'
ansible all -m file -a "path=/root/test.sh owner=wang mode=755“
#创建目录
ansible all -m file -a "path=/data/mysql state=directory owner=mysql group=mysql"
#创建软链接
ansible all -m file -a ‘src=/data/testfile  dest=/data/testfile-link state=link’
```

### unarchive模块

功能：解包解压缩

实现有两种用法：
 1、将ansible主机上的压缩包传到远程主机后解压缩至特定目录，设置copy=yes
 2、将远程主机上的某个压缩包解压缩到指定路径下，设置copy=no 

常见参数：

- copy：默认为yes，当copy=yes，拷贝的文件是从ansible主机复制到远程主机上，如果设置为copy=no，会在远程主机上寻找src源文件
- remote_src：和copy功能一样且互斥，yes表示在远程主机，不在ansible主机，no表示文件在ansible主机上
- src：源路径，可以是ansible主机上的路径，也可以是远程主机上的路径，如果是远程主机上的路径，则需要设置copy=no
- dest：远程主机上的目标路径
- mode：设置解压缩后的文件权限

范例：

```bash
ansible all -m unarchive -a 'src=/data/foo.tgz dest=/var/lib/foo'
ansible all -m unarchive -a 'src=/tmp/foo.zip dest=/data copy=no mode=0777'
ansible all -m unarchive -a 'src=https://example.com/example.zip dest=/data copy=no'
```

### Archive模块

功能：打包压缩

范例：

```bash
ansible websrvs -m archive  -a 'path=/var/log/ dest=/data/log.tar.bz2 format=bz2  owner=wang mode=0600'
```

### Hostname模块

功能：管理主机名

范例：

```bash
ansible node1 -m hostname -a “name=websrv” 
ansible 192.168.100.18 -m hostname -a 'name=node18.magedu.com'
```

### Cron模块

功能：计划任务
 支持时间：minute，hour，day，month，weekday

范例：

```bash
#备份数据库脚本
[root@centos8 ~]#cat mysql_backup.sh 
mysqldump -A -F --single-transaction --master-data=2 -q -uroot |gzip > /data/mysql_date +%F_%T.sql.gz
#创建任务
ansible 10.0.0.8 -m cron -a 'hour=2 minute=30 weekday=1-5 name="backup mysql" job=/root/mysql_backup.sh'
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 &>/dev/null' name=Synctime"
#禁用计划任务
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 &>/dev/null' name=Synctime disabled=yes"
#启用计划任务
ansible websrvs   -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.20.0.1 &>/dev/null' name=Synctime disabled=no"
#删除任务
ansible websrvs -m cron -a "name='backup mysql' state=absent"
ansible websrvs -m cron -a 'state=absent name=Synctime'
```

### Yum模块

功能：管理软件包，只支持RHEL，CentOS，fedora，不支持Ubuntu其它版本

范例：

```bash
ansible websrvs -m yum -a ‘name=httpd state=present’  #安装
ansible websrvs -m yum -a ‘name=httpd state=absent’  #删除
```

### Service模块

功能：管理服务

范例：

```bash
ansible all -m service -a 'name=httpd state=started enabled=yes'
ansible all -m service -a 'name=httpd state=stopped'
ansible all -m service -a 'name=httpd state=reloaded’
ansible all -m shell -a "sed -i 's/^Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf"
ansible all -m service -a 'name=httpd state=restarted' 
```

### User模块

功能：管理用户

范例：

```bash
#创建用户
ansible all -m user -a 'name=user1 comment=“test user” uid=2048 home=/app/user1 group=root'

ansible all -m user -a 'name=nginx comment=nginx uid=88 group=nginx groups="root,daemon" shell=/sbin/nologin system=yes create_home=no  home=/data/nginx non_unique=yes'

#删除用户及家目录等数据
ansible all -m user -a 'name=nginx state=absent remove=yes'
```

### Group模块

功能：管理组

范例：

```bash
#创建组
ansible websrvs -m group  -a 'name=nginx gid=88 system=yes'
#删除组
ansible websrvs -m group  -a 'name=nginx state=absent'
```

### Lineinfile模块

ansible在使用sed进行替换时，经常会遇到需要转义的问题，而且ansible在遇到特殊符号进行替换时，存在问题，无法正常进行替换 。其实在ansible自身提供了两个模块：lineinfile模块和replace模块，可以方便的进行替换

功能：相当于sed，可以修改文件内容

范例：

```bash
ansible all -m   lineinfile -a "path=/etc/selinux/config regexp='^SELINUX=' line='SELINUX=enforcing'"
ansible all -m lineinfile  -a 'dest=/etc/fstab state=absent regexp="^#"'
```

### Replace模块

该模块有点类似于sed命令，主要也是基于正则进行匹配和替换

范例：

```bash
ansible all -m replace -a "path=/etc/fstab regexp='^(UUID.*)' replace='#\1'"  
ansible all -m replace -a "path=/etc/fstab regexp='^#(.*)' replace='\1'"
```

### Setup模块

功能： setup 模块来收集主机的系统信息，这些 facts 信息可以直接以变量的形式使用，但是如果主机较多，会影响执行速度，可以使用`gather_facts: no` 来禁止 Ansible 收集 facts 信息

范例：

```bash
ansible all -m setup
ansible all -m setup -a "filter=ansible_nodename"
ansible all -m setup -a "filter=ansible_hostname"
ansible all -m setup -a "filter=ansible_domain"
ansible all -m setup -a "filter=ansible_memtotal_mb"
ansible all -m setup -a "filter=ansible_memory_mb"
ansible all -m setup -a "filter=ansible_memfree_mb"
ansible all -m setup -a "filter=ansible_os_family"
ansible all -m setup -a "filter=ansible_distribution_major_version"
ansible all -m setup -a "filter=ansible_distribution_version"
ansible all -m setup -a "filter=ansible_processor_vcpus"
ansible all -m setup -a "filter=ansible_all_ipv4_addresses"
ansible all -m setup -a "filter=ansible_architecture"
ansible all -m  setup  -a "filter=ansible_processor*"
```

范例：

```bash
[root@ansible ~]#ansible all  -m  setup -a 'filter=ansible_python_version'
10.0.0.7 | SUCCESS => {
    "ansible_facts": {
        "ansible_python_version": "2.7.5",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
10.0.0.6 | SUCCESS => {
    "ansible_facts": {
        "ansible_python_version": "2.6.6",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
10.0.0.8 | SUCCESS => {
    "ansible_facts": {
        "ansible_python_version": "3.6.8",
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}
[root@ansible ~]#
```