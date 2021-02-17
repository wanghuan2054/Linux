# Zabbix 3.4.15 OGG监控部署

**时间**：2020.10.13 14:14:00


## 安装环境

1. 查看OS版本    
```shell
$ uname -a
HP-UX mdwdb2 B.11.31 U ia64 1314394670 unlimited-user license
```
## Zabbix Agent
### 修改/usr/local/etc/ 下zabbix_agentd.conf 配置
```bash
# 关键配置参数如下，其余配置项不在此列出
LogFile=/tmp/zabbix_agentd.log

Server=X.X.X.220

ServerActive=X.X.X.220

Hostname=fabdb2

AllowRoot=1

Timeout=20

# Include=/usr/local/etc/zabbix_agentd.userparams.conf
# Include=/usr/local/etc/zabbix_agentd.conf.d/
# 使用自定义脚本参数监控，必须制定该路径
Include=/opt/zabbix/zabbix_agents/conf/zabbix_agentd/userparameter_ogg.conf

UnsafeUserParameters=1
```
### 创建自定义参数模板 userparameter_ogg.conf
```bash
cd /opt/zabbix/zabbix_agents/conf/zabbix_agentd/
touch userparameter_ogg.conf
# 授权
chmod 777 userparameter_ogg.conf
UserParameter=ogg.status,cat /opt/zabbix/zabbix_agents/scripts/status.cache | wc -c
```


### 监控脚本
```bash
思路：shell中模拟ggsci shell ， 执行info all命令，过滤RUNNING进程，将查询出来的Process 进程为STOPPED和ABEDED状态的排序去重，写入临时文件 status.cache
cd /opt/zabbix/zabbix_agents/
mkdir scripts
chmod 777 scripts
touch ogg_status.sh

# ogg_status.sh 脚本内容如下
#!/sbin/sh
# HP-UX使用.命令加载当前用户目录下环境变量文件内容
. $HOME/.profile
OGG_HOME=/oracle/ogg
cd $OGG_HOME
echo "info all" | ./ggsci | awk '/^MANAGER|^EXTRACT|^REPLICAT/ {print $2}' | grep -v RUNNING  | sort | uniq > /opt/zabbix/zabbix_agents/scripts/status.cache
```
### 设置定时job

```bash
$ crontab -l
* * * * * /opt/zabbix/zabbix_agents/scripts/ogg_status.sh >/dev/null 2>&1
```
### 重启Agent
```bash
# 查看当前agent 进程
$ ps -ef | grep zabbix
    root 21195 21194  0 20:17:14 ?         0:29 ./zabbix_agentd
    root 21196 21194  0 20:17:14 ?         0:06 ./zabbix_agentd
    root 21194     1  0 20:17:14 ?         0:00 ./zabbix_agentd
    root 21199 21194  0 20:17:14 ?         0:01 ./zabbix_agentd
    root 21198 21194  0 20:17:14 ?         0:07 ./zabbix_agentd
    root 21197 21194  0 20:17:14 ?         0:06 ./zabbix_agentd
  oracle 11755  3348  0 14:38:35 pts/3     0:00 grep zabbix
# HP-UX Agent 进程目前使用手动关闭
$ kill -9  21195 21196  21194 21199 21198 21197
$ kill -9 `ps -ef | grep zabbix_agentd | grep -v grep | awk '{print $2}'`
# 重启Agent
$ cd /opt/zabbix/zabbix_agents/sbin

# 手动启动zabbix_agentd 脚本
#[/opt/zabbix/zabbix_agents/sbin]./zabbix_agentd
-- 或者直接启动
$ /opt/zabbix/zabbix_agents/sbin/zabbix_agentd

# 查看日志，zabbix是否启动成功
$ cd /tmp/
$ tail -10 zabbix_agentd.log
 5104:20201012:201658.473 Zabbix Agent stopped. Zabbix 2.0.8 (revision 38017).
 21194:20201012:201714.978 Starting Zabbix Agent [mdwdb2]. Zabbix 2.0.8 (revision 38017).
 21195:20201012:201714.979 agent #0 started [collector]
 21196:20201012:201714.981 agent #1 started [listener]
 21197:20201012:201714.981 agent #2 started [listener]
 21199:20201012:201714.982 agent #4 started [active checks]
 21198:20201012:201714.982 agent #3 started [listener]
 21199:20201012:211518.079 active check configuration update from [10.120.8.220:10051] started to fail (ZBX_TCP_READ() failed: [4] Interrupted system call)
 21199:20201012:211618.691 active check configuration update from [10.120.8.220:10051] is working again
```
## Zabbix web配置
### New Template App OGG
![图片.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1602573003743-f8167c93-e8b7-4db4-8087-66038bcd12dd.png#align=left&display=inline&height=778&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=778&originWidth=965&size=32226&status=done&style=none&width=965)


### 创建应用集OGG
![图片.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1602573033443-a5469aed-ca9e-4d22-bea9-a8c8a1b1ae20.png#align=left&display=inline&height=133&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=133&originWidth=1141&size=6809&status=done&style=none&width=1141)
### 创建监控项
![图片.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1602575653807-46dc6745-0179-4a66-b34c-22498ba98f8b.png#align=left&display=inline&height=978&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=978&originWidth=934&size=30395&status=done&style=none&width=934)
### 设置触发器
![图片.png](https://cdn.nlark.com/yuque/0/2020/png/595188/1602575741479-5546a9cf-8334-4d39-99c7-9d862c3f1259.png#align=left&display=inline&height=835&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=835&originWidth=866&size=28723&status=done&style=none&width=866)
