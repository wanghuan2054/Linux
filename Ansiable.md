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

#### 利用sshpass批量实现基于key验证 

此工具通过ssh协议，实现对远程主机的配置管理、应用部署、任务执行等功能

建议：使用此工具前，先配置ansible主控端能基于密钥认证的方式联系各个被管理节点

范例：利用sshpass批量实现基于key验证 （一般建议以root身份验证）

```bash
#!/bin/bash
# 在主控端使用root生成密钥对
ssh-keygen -f /root/.ssh/id_rsa  -P ''
NET=192.168.2
# 设置密码，最好所有主机密码一样或者有规律
export SSHPASS=hadoop
# 批量发送公钥到各个被控节点
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

#### **ansible查看当前控制的主机列表**

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

#### **ansible的Host-pattern**

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

#### **ansible命令执行过程** 

1.加载自己的配置文件 默认/etc/ansible/ansible.cfg

2.加载自己对应的模块文件，如：command

3.通过ansible将模块或命令生成对应的临时py文件，并将该文件传输至远程服务器的对应执行用户$HOME/.ansible/tmp/ansible-tmp-数字/XXX.PY文件

4.给文件+x执行

5.执行并返回结果

6.删除临时py文件，退出

#### **ansible 的执行状态：**

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
# 修改脚本的所有者和权限
ansible all -m file -a "path=/root/test.sh owner=wang mode=755“

# 删除文件
ansible all -m  file  -a 'path=/data/test.txt state=absent'

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
```

## Playbook

### playbook介绍

![Ansible-Playbook详解插图](http://www.yunweipai.com/wp-content/uploads/2020/06/image-20191102181113906-780x281.png)

playbook 剧本是由一个或多个“play”组成的列表
 play的主要功能在于将预定义的一组主机，装扮成事先通过ansible中的task定义好的角色。Task实际是调用ansible的一个module，将多个play组织在一个playbook中，即可以让它们联合起来，按事先编排的机制执行预定义的动作
 Playbook 文件是采用YAML语言编写的

### YAML 语言

#### YAMl 语言介绍

YAML是一个可读性高的用来表达资料序列的格式。YAML参考了其他多种语言，包括：XML、C语言、Python、Perl以及电子邮件格式RFC2822等。Clark Evans在2001年在首次发表了这种语言，另外Ingy döt Net与Oren  Ben-Kiki也是这语言的共同设计者,目前很多软件中采有此格式的文件，如:ubuntu，anisble，docker，k8s等
 YAML：YAML Ain’t Markup Language，即YAML不是XML。不过，在开发的这种语言时，YAML的意思其实是："Yet Another Markup Language"（仍是一种标记语言）

YAML 官方网站：[http://www.yaml.org](http://www.yunweipai.com/go?_=f2fb54694baHR0cDovL3d3dy55YW1sLm9yZw==)

#### YAML 语言特性

- YAML的可读性好
- YAML和脚本语言的交互性好
- YAML使用实现语言的数据类型
- YAML有一个一致的信息模型
- YAML易于实现
- YAML可以基于流来处理
- YAML表达能力强，扩展性好

#### YAML语法简介

- 在单一文件第一行，用连续三个连字号“-” 开始，还有选择性的连续三个点号( … )用来表示文件的结尾
- 次行开始正常写Playbook的内容，一般建议写明该Playbook的功能
- 使用#号注释代码
- 缩进必须是统一的，不能空格和tab混用
- 缩进的级别也必须是一致的，同样的缩进代表同样的级别，程序判别配置的级别是通过缩进结合换行来实现的
   YAML文件内容是区别大小写的，key/value的值均需大小写敏感
- 多个key/value可同行写也可换行写，同行使用，分隔
- v可是个字符串，也可是另一个列表
- 一个完整的代码块功能需最少元素需包括 name 和 task
- 一个name只能包括一个task
- YAML文件扩展名通常为yml或yaml

YAML的语法和其他高阶语言类似，并且可以简单表达清单、散列表、标量等数据结构。其结构（Structure）通过空格来展示，序列（Sequence）里的项用"-"来代表，Map里的键值对用":"分隔，下面介绍常见的数据结构。

##### List列表

列表由多个元素组成，每个元素放在不同行，且元素前均使用“-”打头，或者将所有元素用 [  ] 括起来放在同一行
 范例：

```
# A list of tasty fruits
- Apple
- Orange
- Strawberry
- Mango

[Apple,Orange,Strawberry,Mango]
```

##### Dictionary字典

字典由多个key与value构成，key和value之间用 ：分隔，所有k/v可以放在一行，或者每个 k/v 分别放在不同行

范例：

```yaml
# An employee record
name: Example Developer
job: Developer
skill: Elite
也可以将key:value放置于{}中进行表示，用,分隔多个key:value

# An employee record
{name: “Example Developer”, job: “Developer”, skill: “Elite”}
```

YAML

范例：

```yaml
name: John Smith
age: 41
gender: Male
spouse:
  name: Jane Smith
  age: 37
  gender: Female
children:
  - name: Jimmy Smith
    age: 17
    gender: Male
  - name: Jenny Smith
    age 13
    gender: Female
```

YAML

##### 三种常见的数据格式

- XML：Extensible Markup Language，可扩展标记语言，可用于数据交换和配置
- JSON：JavaScript Object Notation, JavaScript 对象表记法，主要用来数据交换或配置，不支持注释
- YAML：YAML Ain’t Markup Language  YAML 不是一种标记语言， 主要用来配置，大小写敏感，不支持tab

![Ansible-list-Dictionary-数据格式插图](http://www.yunweipai.com/wp-content/uploads/2020/06/image-20191102190516045-780x255.png)

**可以用工具互相转换，参考网站：**

[https://www.json2yaml.com/](http://www.yunweipai.com/go?_=60bb30fe06aHR0cHM6Ly93d3cuanNvbjJ5YW1sLmNvbS8=)

[http://www.bejson.com/json/json2yaml/](http://www.yunweipai.com/go?_=07b1ecff68aHR0cDovL3d3dy5iZWpzb24uY29tL2pzb24vanNvbjJ5YW1sLw==)

### Playbook核心元素

- Hosts   执行的远程主机列表
- Tasks   任务集
- Variables 内置变量或自定义变量在playbook中调用
- Templates  模板，可替换模板文件中的变量并实现一些简单逻辑的文件
- Handlers  和 notify 结合使用，由特定条件触发的操作，满足条件方才执行，否则不执行
- tags 标签   指定某条任务执行，用于选择运行playbook中的部分代码。ansible具有幂等性，因此会自动跳过没有变化的部分，即便如此，有些代码为测试其确实没有发生变化的时间依然会非常地长。此时，如果确信其没有变化，就可以通过tags跳过此些代码片断

#### hosts 组件

Hosts：playbook中的每一个play的目的都是为了让特定主机以某个指定的用户身份执行任务。hosts用于指定要执行指定任务的主机，须事先定义在主机清单中

```bash
one.example.com
one.example.com:two.example.com
192.168.1.50
192.168.1.*
Websrvs:dbsrvs      #或者，两个组的并集
Websrvs:&dbsrvs     #与，两个组的交集
webservers:!phoenix  #在websrvs组，但不在dbsrvs组
```

案例：

```yaml
- hosts: websrvs:appsrvs
```

#### remote_user 组件

remote_user: 可用于Host和task中。也可以通过指定其通过sudo的方式在远程主机上执行任务，其可用于play全局或某任务；此外，甚至可以在sudo时使用sudo_user指定sudo时切换的用户

```yaml
- hosts: websrvs
  remote_user: root

  tasks:
    - name: test connection
      ping:
      remote_user: magedu
      sudo: yes                 #默认sudo为root
      sudo_user:wang        #sudo为wang
```

#### task列表和action组件

play的主体部分是task list，task list中有一个或多个task,各个task 按次序逐个在hosts中指定的所有主机上执行，即在所有主机上完成第一个task后，再开始第二个task
 task的目的是使用指定的参数执行模块，而在模块参数中可以使用变量。模块执行是幂等的，这意味着多次执行是安全的，因为其结果均一致
 每个task都应该有其name，用于playbook的执行结果输出，建议其内容能清晰地描述任务执行步骤。如果未提供name，则action的结果将用于输出

**task两种格式：**
 (1) action: module arguments
 (2) module: arguments      建议使用

注意：shell和command模块后面跟命令，而非key=value

范例：

```yaml
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: install httpd
      yum: name=httpd 
    - name: start httpd
      service: name=httpd state=started enabled=yes
```

#### 其它组件

某任务的状态在运行后为changed时，可通过“notify”通知给相应的handlers
 任务可以通过"tags“打标签，可在ansible-playbook命令上使用-t指定进行调用

### playbook 命令

格式

```bash
ansible-playbook <filename.yml> ... [options]
```

Bash

常见选项

```bash
-C --check          #只检测可能会发生的改变，但不真正执行操作
--list-hosts        #列出运行任务的主机
--list-tags         #列出tag
--list-tasks        #列出task
--limit 主机列表      #只针对主机列表中的主机执行
-v -vv  -vvv        #显示过程
```

Bash

范例

```bash
ansible-playbook  file.yml  --check #只检测
ansible-playbook  file.yml  
ansible-playbook  file.yml  --limit websrvs
```

### playbook实战案例

#### Centos 6 更换yum源

```yaml
- hosts: hadoopsrvs
  remote_user: root
  tasks:
     - name: "备份yum源"
       shell: "mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup"
     - name: "从主控端拷贝配置文件到被控端"
       copy: src=/root/playbook/CentOS-Base.repo dest=/etc/yum.repos.d/
       #- name: "下载CentOS 6的yum源"
       #shell: "wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo"
     - name: "清理缓存"
       shell: "yum clean all"
     - name: "生成新缓存"
       shell: "yum makecache"
       
* 注意：将 $releasever 全部换成6，将 $basearch 全部换成 x86_64
$releasever 是获取你centos的版本号的，例如我的centos的版本号为6.7，获取到的为6，但是已经找不到了，所以直接全局改成7即可
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#
 
[base]
name=CentOS-7 - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/7/os/$basearch/
        http://mirrors.aliyuncs.com/centos/7/os/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/7/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6
 
#released updates 
[updates]
name=CentOS-7 - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/7/updates/$basearch/
        http://mirrors.aliyuncs.com/centos/7/updates/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/7/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6
 
#additional packages that may be useful
[extras]
name=CentOS-7 - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/7/extras/$basearch/
        http://mirrors.aliyuncs.com/centos/7/extras/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/7/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-7 - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/7/centosplus/$basearch/
        http://mirrors.aliyuncs.com/centos/7/centosplus/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/7/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6
 
#contrib - packages by Centos Users
[contrib]
name=CentOS-7 - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/7/contrib/$basearch/
        http://mirrors.aliyuncs.com/centos/7/contrib/$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/7/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6
```

#### ShellScripts VS  Playbook 案例(httpd)

```yaml
#SHELL脚本实现
#!/bin/bash
# 安装Apache
yum install --quiet -y httpd 
# 复制配置文件
cp /tmp/httpd.conf /etc/httpd/conf/httpd.conf
cp/tmp/vhosts.conf /etc/httpd/conf.d/
# 启动Apache，并设置开机启动
systemctl enable --now httpd 

#Playbook实现
---
- hosts: hadoopsrvs
  remote_user: root
  tasks:
    - name: "安装Apache"
      yum: name=httpd
    #- name: "复制配置文件"
      #copy: src=/tmp/httpd.conf dest=/etc/httpd/conf/
    #- name: "复制配置文件"
      #copy: src=/tmp/vhosts.conf dest=/etc/httpd/conf.d/
    - name: "启动Apache，并设置开机启动"
      service: name=httpd state=started enabled=yes

# 到指定机器验证httpd服务是否启动
[root@devops ~]# ansible all -a "service httpd status"
或者
[root@hadoopnode3 ~]# service httpd status
httpd (pid  9623) is running...
```

#### 利用 playbook 创建 mysql 用户

范例：mysql_user.yml

```yaml
---
- hosts: dbsrvs
  remote_user: root

  tasks:
    - {name: create group, group: name=mysql system=yes gid=306}
    - name: create user
      user: name=mysql shell=/sbin/nologin system=yes group=mysql uid=306 home=/data/mysql create_home=no      
```

#### 利用 playbook 安装 nginx

范例：install_nginx.yml

```yaml
---
# install nginx 
- hosts: websrvs
  remote_user: root  
  tasks:
    - name: add group nginx
      user: name=nginx state=present
    - name: add user nginx
      user: name=nginx state=present group=nginx
    - name: Install Nginx
      yum: name=nginx state=present
    - name: web page
      copy: src=files/index.html dest=/usr/share/nginx/html/index.html
    - name: Start Nginx
      service: name=nginx state=started enabled=yes
```

#### 利用 playbook 安装和卸载 httpd

范例：install_httpd.yml 

```bash
---
#install httpd 
- hosts: websrvs
  remote_user: root
  gather_facts: no

  tasks:
    - name: Install httpd
      yum: name=httpd state=present
    - name: Install configure file
      copy: src=files/httpd.conf dest=/etc/httpd/conf/
    - name: web html
      copy: src=files/index.html  dest=/var/www/html/
    - name: start service
      service: name=httpd state=started enabled=yes

ansible-playbook   install_httpd.yml --limit 10.0.0.8
```

范例：remove_httpd.yml

```yaml
#remove_httpd.yml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: remove httpd package
      yum: name=httpd state=absent
    - name: remove apache user 
      user: name=apache state=absent
    - name: remove config file
      file: name=/etc/httpd  state=absent
    - name: remove web html
      file: name=/var/www/html/index.html state=absent
```

#### 利用 playbook 安装mysql

**范例：安装mysql-5.6.46-linux-glibc2.12**

```bash
[root@ansible ~]#ls -l /data/ansible/files/mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz 
-rw-r--r-- 1 root root 403177622 Dec  4 13:05 /data/ansible/files/mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz

[root@ansible ~]#cat /data/ansible/files/my.cnf 
[mysqld]
socket=/tmp/mysql.sock
user=mysql
symbolic-links=0
datadir=/data/mysql
innodb_file_per_table=1
log-bin
pid-file=/data/mysql/mysqld.pid

[client]
port=3306
socket=/tmp/mysql.sock

[mysqld_safe]
log-error=/var/log/mysqld.log

[root@ansible ~]#cat /data/ansible/files/secure_mysql.sh 
#!/bin/bash
/usr/local/mysql/bin/mysql_secure_installation <<EOF

y
hadoop
hadoop
y
y
y
y
EOF

[root@ansible ~]#tree /data/ansible/files/
/data/ansible/files/
├── my.cnf
├── mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz
└── secure_mysql.sh

0 directories, 3 files

[root@ansible ~]#cat /data/ansible/install_mysql.yml
---
# install mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz
- hosts: dbsrvs
  remote_user: root
  gather_facts: no

  tasks:
    - name: install packages
      yum: name=libaio,perl-Data-Dumper,perl-Getopt-Long
    - name: create mysql group
      group: name=mysql gid=306 
    - name: create mysql user
      user: name=mysql uid=306 group=mysql shell=/sbin/nologin system=yes create_home=no home=/data/mysql
    - name: copy tar to remote host and file mode 
      unarchive: src=/data/ansible/files/mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz dest=/usr/local/ owner=root group=root 
    - name: create linkfile  /usr/local/mysql 
      file: src=/usr/local/mysql-5.6.46-linux-glibc2.12-x86_64 dest=/usr/local/mysql state=link
    - name: data dir
      shell: chdir=/usr/local/mysql/  ./scripts/mysql_install_db --datadir=/data/mysql --user=mysql
      tags: data
    - name: config my.cnf
      copy: src=/data/ansible/files/my.cnf  dest=/etc/my.cnf 
    - name: service script
      shell: /bin/cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
    - name: enable service
      shell: /etc/init.d/mysqld start;chkconfig --add mysqld;chkconfig mysqld on  
      tags: service
    - name: PATH variable
      copy: content='PATH=/usr/local/mysql/bin:$PATH' dest=/etc/profile.d/mysql.sh
    - name: secure script
      script: /data/ansible/files/secure_mysql.sh
      tags: script
```

Bash

**范例：install_mariadb.yml**

```bash
---
#Installing MariaDB Binary Tarballs
- hosts: dbsrvs
  remote_user: root
  gather_facts: no

  tasks:
    - name: create group
      group: name=mysql gid=27 system=yes
    - name: create user
      user: name=mysql uid=27 system=yes group=mysql shell=/sbin/nologin home=/data/mysql create_home=no
    - name: mkdir datadir
      file: path=/data/mysql owner=mysql group=mysql state=directory
    - name: unarchive package
      unarchive: src=/data/ansible/files/mariadb-10.2.27-linux-x86_64.tar.gz dest=/usr/local/ owner=root group=root
    - name: link
      file: src=/usr/local/mariadb-10.2.27-linux-x86_64 path=/usr/local/mysql state=link 
    - name: install database
      shell: chdir=/usr/local/mysql   ./scripts/mysql_install_db --datadir=/data/mysql --user=mysql
    - name: config file
      copy: src=/data/ansible/files/my.cnf  dest=/etc/ backup=yes
    - name: service script
      shell: /bin/cp  /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld
    - name: start service
      service: name=mysqld state=started enabled=yes
    - name: PATH variable
      copy: content='PATH=/usr/local/mysql/bin:$PATH' dest=/etc/profile.d/mysql.sh
```

## Playbook中使用变量

变量名：仅能由字母、数字和下划线组成，且只能以字母开头

**变量定义：**

```
variable=value
```

范例：

```
http_port=80
```

**变量调用方式：**

通过{{ variable_name }} 调用变量，且变量名前后建议加空格，有时用“{{ variable_name }}”才生效

**变量来源：**

1.ansible 的 setup facts 远程主机的所有变量都可直接调用

2.通过命令行指定变量，优先级最高

```bash
   ansible-playbook -e varname=value
```

Bash

3.在playbook文件中定义

```bash
   vars:
     - var1: value1
     - var2: value2
```

Bash

4.在独立的变量YAML文件中定义

```
   - hosts: all
     vars_files:
       - vars.yml
```

5.在 /etc/ansible/hosts 中定义

主机（普通）变量：主机组中主机单独定义，优先级高于公共变量
 组（公共）变量：针对主机组中所有主机定义统一变量

6.在role中定义

### 使用 setup 模块中变量

本模块自动在playbook调用，不要用ansible命令调用

案例：使用setup变量

```bash
---
#var.yml
- hosts: all
  remote_user: root
  gather_facts: yes

  tasks:
    - name: create log file
      file: name=/data/{{ ansible_nodename }}.log state=touch owner=wang mode=600

ansible-playbook  var.yml
```

### 在playbook 命令行中定义变量

范例：

```
vim var2.yml
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: install package
      yum: name={{ pkname }} state=present

ansible-playbook  –e pkname=httpd  var2.yml
```

### 在playbook文件中定义变量

范例：

```bash
vim var3.yml
---
- hosts: websrvs
  remote_user: root
  vars:
    - username: user1
    - groupname: group1

  tasks:
    - name: create group
      group: name={{ groupname }} state=present
    - name: create user
      user: name={{ username }} group={{ groupname }} state=present

ansible-playbook -e "username=user2 groupname=group2”  var3.yml
```

Bash

### 使用变量文件

可以在一个独立的playbook文件中定义变量，在另一个playbook文件中引用变量文件中的变量，比playbook中定义的变量优化级高

```bash
vim vars.yml
---
# variables file
package_name: mariadb-server
service_name: mariadb

vim  var4.yml
---
#install package and start service
- hosts: dbsrvs
  remote_user: root
  vars_files:
    - /root/vars.yml

  tasks:
    - name: install package
      yum: name={{ package_name }}
      tags: install
    - name: start service
      service: name={{ service_name }} state=started enabled=yes
```

范例：

```bash
cat  vars2.yml
---
var1: httpd
var2: nginx

cat  var5.yml
---         
- hosts: web
  remote_user: root
  vars_files:
    - vars2.yml

   tasks:
     - name: create httpd log
       file: name=/app/{{ var1 }}.log state=touch
     - name: create nginx log
       file: name=/app/{{ var2 }}.log state=touch
```

### 主机清单文件中定义变量

#### 主机变量

在inventory 主机清单文件中为指定的主机定义变量以便于在playbook中使用

范例：

```
[websrvs]
www1.magedu.com http_port=80 maxRequestsPerChild=808
www2.magedu.com http_port=8080 maxRequestsPerChild=909
```

#### 组（公共）变量

在inventory 主机清单文件中赋予给指定组内所有主机上的在playbook中可用的变量，如果和主机变是同名，优先级低于主机变量

范例：

```
[websrvs]
www1.magedu.com
www2.magedu.com

[websrvs:vars]
ntp_server=ntp.magedu.com
nfs_server=nfs.magedu.com
```

范例：

```bash
vim /etc/ansible/hosts

[websrvs]
192.168.0.101 hname=www1 domain=magedu.io
192.168.0.102 hname=www2 

[websvrs:vars]
mark=“-”
domain=magedu.org

ansible  websvrs  –m hostname –a ‘name={{ hname }}{{ mark }}{{ domain }}’
bash
#命令行指定变量： 
ansible  websvrs  –e domain=magedu.cn –m hostname –a    ‘name={{ hname }}{{ mark }}{{ domain }}’
```

## template 模板

模板是一个文本文件，可以做为生成文件的模版，并且模板文件中还可嵌套jinja语法

### jinja2语言

网站：`https://jinja.palletsprojects.com/en/2.11.x/`

jinja2 语言使用字面量，有下面形式：
 字符串：使用单引号或双引号
 数字：整数，浮点数
 列表：[item1, item2, …]
 元组：(item1, item2, …)
 字典：{key1:value1, key2:value2, …}
 布尔型：true/false
 算术运算：+, -, *, /, //, %, **
 比较操作：==, !=, >, >=, <, <=
 逻辑运算：and，or，not
 流表达式：For，If，When

**字面量：**

表达式最简单的形式就是字面量。字面量表示诸如字符串和数值的 Python 对象。如“Hello World”
 双引号或单引号中间的一切都是字符串。无论何时你需要在模板中使用一个字符串（比如函数调用、过滤器或只是包含或继承一个模板的参数），如42，42.23
 数值可以为整数和浮点数。如果有小数点，则为浮点数，否则为整数。在 Python 里， 42 和 42.0 是不一样的

**算术运算：**

Jinja 允许用计算值。支持下面的运算符
 +：把两个对象加到一起。通常对象是素质，但是如果两者是字符串或列表，你可以用这 种方式来衔接它们。无论如何这不是首选的连接字符串的方式！连接字符串见 ~ 运算符。 {{ 1 + 1 }} 等于 2
 -：用第一个数减去第二个数。 {{ 3 – 2 }} 等于 1
 /：对两个数做除法。返回值会是一个浮点数。 {{ 1 / 2 }} 等于 {{ 0.5 }}
 //：对两个数做除法，返回整数商。 {{ 20 // 7 }} 等于 2
 %：计算整数除法的余数。 {{ 11 % 7 }} 等于 4
 *：用右边的数乘左边的操作数。 {{ 2*  2 }} 会返回 4 。也可以用于重 复一个字符串多次。 {{ ‘=’  *80 }} 会打印 80 个等号的横条\
 **：取左操作数的右操作数次幂。 {{ 2**3 }} 会返回 8 

**比较操作符**
 ==  比较两个对象是否相等
 !=  比较两个对象是否不等

> 如果左边大于右边，返回 true
>  = 如果左边大于等于右边，返回 true
>  <   如果左边小于右边，返回 true
>  <=  如果左边小于等于右边，返回 true

**逻辑运算符**
 对于 if 语句，在 for 过滤或 if 表达式中，它可以用于联合多个表达式
 and 如果左操作数和右操作数同为真，返回 true
 or  如果左操作数和右操作数有一个为真，返回 true
 not 对一个表达式取反
 (expr)表达式组
 true / false true 永远是 true ，而 false 始终是 false 

### template

template功能：可以根据和参考模块文件，动态生成相类似的配置文件
 template文件必须存放于templates目录下，且命名为 .j2 结尾
 yaml/yml 文件需和templates目录平级，目录结构如下示例：
 ./
 ├── temnginx.yml
 └── templates
 └── nginx.conf.j2

范例：利用template 同步nginx配置文件

```
#准备templates/nginx.conf.j2文件
vim temnginx.yml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: template config to remote hosts
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

 ansible-playbook temnginx.yml
```

**template变更替换**

范例：

```yaml
#修改文件nginx.conf.j2 
mkdir templates
vim templates/nginx.conf.j2
worker_processes {{ ansible_processor_vcpus }};

vim temnginx2.yml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: install nginx
      yum: name=nginx
    - name: template config to remote hosts
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf 
    - name: start service
      service: name=nginx state=started enable=yes

ansible-playbook temnginx2.yml
```

YAML

**template算术运算**

范例：

```
vim nginx.conf.j2 
worker_processes {{ ansible_processor_vcpus**2 }};    
worker_processes {{ ansible_processor_vcpus+2 }}; 
```

范例：

```bash
[root@ansible ansible]#vim templates/nginx.conf.j2
worker_processes {{ ansible_processor_vcpus**3 }};

[root@ansible ansible]#cat templnginx.yml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: install nginx
      yum: name=nginx
    - name: template config to remote hosts
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
      notify: restart nginx
    - name: start service
      service: name=nginx state=started enabled=yes

  handlers:
    - name: restart nginx
      service: name=nginx state=restarted

ansible-playbook  templnginx.yml --limit 10.0.0.8
```

### template中使用流程控制 for 和 if

template中也可以使用流程控制 for 循环和 if 条件判断，实现动态生成文件功能

范例

```yaml
#temlnginx2.yml
---
- hosts: websrvs
  remote_user: root
  vars:
    nginx_vhosts:
      - 81
      - 82
      - 83
  tasks:
    - name: template config
      template: src=nginx.conf.j2 dest=/data/nginx.conf

#templates/nginx.conf2.j2
{% for vhost in  nginx_vhosts %}
server {
   listen {{ vhost }}
}
{% endfor %}

ansible-playbook -C  templnginx2.yml  --limit 10.0.0.8

#生成的结果：
server {
   listen 81   
}
server {
   listen 82   
}
server {
   listen 83   
}
```

范例：

```bash
#temlnginx3.yml
---
- hosts: websrvs
  remote_user: root
  vars:
    nginx_vhosts:
      - listen: 8080
  tasks:
    - name: config file
      template: src=nginx.conf3.j2 dest=/data/nginx3.conf

#templates/nginx.conf3.j2
{% for vhost in nginx_vhosts %}   
server {
  listen {{ vhost.listen }}
}
{% endfor %}

ansible-playbook   templnginx3.yml  --limit 10.0.0.8

#生成的结果
server {
  listen 8080  
}
```

范例：

```yaml
#templnginx4.yml
- hosts: websrvs
  remote_user: root
  vars:
    nginx_vhosts:
      - listen: 8080
        server_name: "web1.magedu.com"
        root: "/var/www/nginx/web1/"
      - listen: 8081
        server_name: "web2.magedu.com"
        root: "/var/www/nginx/web2/"
      - {listen: 8082, server_name: "web3.magedu.com", root: "/var/www/nginx/web3/"}
  tasks:
    - name: template config 
      template: src=nginx.conf4.j2 dest=/data/nginx4.conf

# templates/nginx.conf4.j2
{% for vhost in nginx_vhosts %}
server {
   listen {{ vhost.listen }}
   server_name {{ vhost.server_name }}
   root {{ vhost.root }}  
}
{% endfor %}

ansible-playbook  templnginx4.yml --limit 10.0.0.8

#生成结果：
server {
    listen 8080
    server_name web1.magedu.com
    root /var/www/nginx/web1/  
}
server {
    listen 8081
    server_name web2.magedu.com
    root /var/www/nginx/web2/  
}
server {
    listen 8082
    server_name web3.magedu.com
    root /var/www/nginx/web3/  
} 
```

在模版文件中还可以使用 if条件判断，决定是否生成相关的配置信息

范例：

```yaml
#templnginx5.yml
- hosts: websrvs
  remote_user: root
  vars:
    nginx_vhosts:
      - web1:
        listen: 8080
        root: "/var/www/nginx/web1/"
      - web2:
        listen: 8080
        server_name: "web2.magedu.com"
        root: "/var/www/nginx/web2/"
      - web3:
        listen: 8080
        server_name: "web3.magedu.com"
        root: "/var/www/nginx/web3/"
  tasks:
    - name: template config to 
      template: src=nginx.conf5.j2 dest=/data/nginx5.conf

#templates/nginx.conf5.j2
{% for vhost in  nginx_vhosts %}
server {
   listen {{ vhost.listen }}
   {% if vhost.server_name is defined %}
server_name {{ vhost.server_name }}
   {% endif %}
root  {{ vhost.root }}
}
{% endfor %}

#生成的结果
server {
   listen 8080
   root  /var/www/nginx/web1/
}
server {
   listen 8080
   server_name web2.magedu.com
   root  /var/www/nginx/web2/
}
server {
   listen 8080
   server_name web3.magedu.com
   root  /var/www/nginx/web3/
}
```

## playbook使用 when

when语句，可以实现条件测试。如果需要根据变量、facts或此前任务的执行结果来做为某task执行与否的前提时要用到条件测试,通过在task后添加when子句即可使用条件测试，jinja2的语法格式

范例：

```yaml
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: "shutdown RedHat flavored systems"
      command: /sbin/shutdown -h now
      when: ansible_os_family == "RedHat"
```

范例：

```yaml
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: add group nginx
      tags: user
      user: name=nginx state=present
    - name: add user nginx
      user: name=nginx state=present group=nginx
    - name: Install Nginx
      yum: name=nginx state=present
    - name: restart Nginx
      service: name=nginx state=restarted
      when: ansible_distribution_major_version == “6”
```

范例：

```yaml
---
- hosts: websrvs
  remote_user: root
  tasks: 
    - name: install conf file to centos7
      template: src=nginx.conf.c7.j2 dest=/etc/nginx/nginx.conf
      when: ansible_distribution_major_version == "7"
    - name: install conf file to centos6
      template: src=nginx.conf.c6.j2 dest=/etc/nginx/nginx.conf
      when: ansible_distribution_major_version == "6"
```

## playbook 使用迭代 with_items

迭代：当有需要重复性执行的任务时，可以使用迭代机制
 对迭代项的引用，固定变量名为”item“
 要在task中使用with_items给定要迭代的元素列表

**列表元素格式：**

- 字符串
- 字典

范例：

```bash
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: add several users
      user: name={{ item }} state=present groups=wheel
      with_items:
        - testuser1
        - testuser2
#上面语句的功能等同于下面的语句
    - name: add user testuser1
      user: name=testuser1 state=present groups=wheel
    - name: add user testuser2
      user: name=testuser2 state=present groups=wheel
```

范例：

```bash
---
#remove mariadb server
- hosts: appsrvs:!192.168.38.8
  remote_user: root

  tasks:
    - name: stop service
      shell: /etc/init.d/mysqld stop
    - name:  delete files and dir
      file: path={{item}} state=absent
      with_items:
        - /usr/local/mysql
        - /usr/local/mariadb-10.2.27-linux-x86_64
        - /etc/init.d/mysqld
        - /etc/profile.d/mysql.sh
        - /etc/my.cnf
        - /data/mysql
    - name: delete user
      user: name=mysql state=absent remove=yes 
```

范例：

```bash
---
- hosts：websrvs
  remote_user: root

  tasks
    - name: install some packages
      yum: name={{ item }} state=present
      with_items:
        - nginx
        - memcached
        - php-fpm 
```

范例：

```bash
---
- hosts: websrvs
  remote_user: root
  tasks:
    - name: copy file
      copy: src={{ item }} dest=/tmp/{{ item }}
      with_items:
        - file1
        - file2
        - file3
    - name: yum install httpd
      yum: name={{ item }}  state=present 
      with_items:
        - apr
        - apr-util
        - httpd
```

**迭代嵌套子变量：**在迭代中，还可以嵌套子变量，关联多个变量在一起使用

示例：

```yaml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: add some groups
      group: name={{ item }} state=present
      with_items:
        - nginx
        - mysql
        - apache
    - name: add some users
      user: name={{ item.name }} group={{ item.group }} state=present
      with_items:
        - { name: 'nginx', group: 'nginx' }
        - { name: 'mysql', group: 'mysql' }
        - { name: 'apache', group: 'apache' }
```

范例：

```bash
cat with_item2.yml
---
- hosts: websrvs
  remote_user: root

  tasks:
    - name: add some groups
      group: name={{ item }} state=present
      with_items:
        - g1
        - g2
        - g3
    - name: add some users
      user: name={{ item.name }} group={{ item.group }} home={{ item.home }} create_home=yes state=present
      with_items:
        - { name: 'user1', group: 'g1', home: '/data/user1' }
        - { name: 'user2', group: 'g2', home: '/data/user2' }
        - { name: 'user3', group: 'g3', home: '/data/user3' }
```

# 管理节点过多导致的超时问题解决方法

默认情况下，Ansible将尝试并行管理playbook中所有的机器。对于滚动更新用例，可以使用serial关键字定义Ansible一次应管理多少主机，还可以将serial关键字指定为百分比，表示每次并行执行的主机数占总数的比例

范例：

```
#vim test_serial.yml
---
- hosts: all
  serial: 2  #每次只同时处理2个主机
  gather_facts: False

  tasks:
    - name: task one
      comand: hostname
    - name: task two
      command: hostname
```

范例：

```bash
- name: test serail
  hosts: all
  serial: "20%"   #每次只同时处理20%的主机
```

# roles角色

角色是ansible自1.2版本引入的新特性，用于层次性、结构化地组织playbook。roles能够根据层次型结构自动装载变量文件、tasks以及handlers等。要使用roles只需要在playbook中使用include指令即可。简单来讲，roles就是通过分别将变量、文件、任务、模板及处理器放置于单独的目录中，并可以便捷地include它们的一种机制。角色一般用于基于主机构建服务的场景中，但也可以是用于构建守护进程等场景中

运维复杂的场景：建议使用roles，代码复用度高

roles：多个角色的集合， 可以将多个的role，分别放至roles目录下的独立子目录中
 roles/
 mysql/
 httpd/
 nginx/
 redis/

## Ansible Roles目录编排

roles目录结构如下所示

![Ansible-roles角色详解插图](http://www.yunweipai.com/wp-content/uploads/2020/06/image-20191105111132014-780x396.png)

每个角色，以特定的层级目录结构进行组织

### **roles目录结构：**

 playbook.yml
 roles/
 project/
 tasks/
 files/
 vars/
 templates/
 handlers/
 default/
 meta/       

### **Roles各目录作用**

 roles/project/ :项目名称,有以下子目录

- files/ ：存放由copy或script模块等调用的文件
- templates/：template模块查找所需要模板文件的目录
- tasks/：定义task,role的基本元素，至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
- handlers/：至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
- vars/：定义变量，至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
- meta/：定义当前角色的特殊设定及其依赖关系,至少应该包含一个名为main.yml的文件，其它文件需在此文件中通过include进行包含
- default/：设定默认变量时使用此目录中的main.yml文件，比vars的优先级低

### 创建 role

创建role的步骤
 (1) 创建以roles命名的目录
 (2) 在roles目录中分别创建以各角色名称命名的目录，如webservers等
 (3) 在每个角色命名的目录中分别创建files、handlers、meta、tasks、templates和vars目录；用不到的目录可以创建为空目录，也可以不创建
 (4) 在playbook文件中，调用各角色

针对大型项目使用Roles进行编排
 范例：roles的目录结构

```bash
nginx-role.yml 
roles/
└── nginx 
     ├── files
     │    └── main.yml 
     ├── tasks
     │    ├── groupadd.yml 
     │    ├── install.yml 
     │    ├── main.yml 
     │    ├── restart.yml 
     │    └── useradd.yml 
     └── vars 
          └── main.yml 
```

### playbook调用角色

#### **调用角色方法1：**

```yaml
---
- hosts: websrvs
  remote_user: root
  roles:
    - mysql
    - memcached
    - nginx   
```

​     

#### **调用角色方法2：**

键role用于指定角色名称，后续的k/v用于传递变量给角色

```yaml
---
- hosts: all
  remote_user: root
  roles:
    - mysql
    - { role: nginx, username: nginx }
```

#### **调用角色方法3：**

还可基于条件测试实现角色调用

```yaml
---
- hosts: all
  remote_user: root
  roles:
    - { role: nginx, username: nginx, when: ansible_distribution_major_version == ‘7’  }
```

### roles 中 tags 使用

```yaml
#nginx-role.yml
---
- hosts: websrvs
  remote_user: root
  roles:
    - { role: nginx ,tags: [ 'nginx', 'web' ] ,when: ansible_distribution_major_version == "6“ }
    - { role: httpd ,tags: [ 'httpd', 'web' ]  }
    - { role: mysql ,tags: [ 'mysql', 'db' ] }
    - { role: mariadb ,tags: [ 'mariadb', 'db' ] }

ansible-playbook --tags="nginx,httpd,mysql" nginx-role.yml
```