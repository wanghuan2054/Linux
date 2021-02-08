# Centos7内核从3.10.0升级到最新稳定版本

**时间**：2020.08.29 16:28:00


## 当前环境


服务器Linux 版本 ：CentOS Linux release 7.8.2003 (Core) 
内核版本为：3.10.0-1127.18.2.el7.x86_64
## Linux内核升级方式

- 1、源码安装：下载新版内核源码到服务器上，进行编译安装,这种方式可完全控制编译项,但是编译慢，而且容易失败。
- 2、yum安装：采用yum方式安装, 优点是快捷方便，而且成功率很高。
- **注意：在做内核升级前，我们一定要先做好服务器数据备份或者做好服务器快照。重要的事情说三遍：备份、备份、备份。**



### 1、查看当前内核版本
```bash
[root@devops software]# uname -r
3.10.0-1127.18.2.el7.x86_64
```


### 2、导入ELRepo公共秘钥和yum源
```bash
[root@devops software]# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

[root@devops software]# rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```
这里的`ELRepo`是Linux操作系统的第三方免费软件（RPM包)资源库。它支持红帽Linux(RHEL)及其衍生产品，如：Scientific Linux，CentOS等。上面的两条命令就是[elrepo官网](http://elrepo.org/tiki/tiki-index.php)提供。
### 3、安装内核
```bash
[root@devops software]# yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml
```
默认将安装mainline版本, 也就是最新的稳定版本
### 4、查看已安装内核
查看已安装的Linux内核版本，使用`rpm -qa kernel*`或`rpm -qa | grep -i kernel`命令
> ps：如果rpm -qa kernel*这条命令的kernel后面不加星号，是查看不到新安装的内核的。

```bash
[root@devops software]# rpm -qa | grep -i kernel
kernel-3.10.0-1127.18.2.el7.x86_64
kernel-tools-3.10.0-1127.18.2.el7.x86_64
kernel-headers-3.10.0-1127.18.2.el7.x86_64
kernel-ml-5.8.5-1.el7.elrepo.x86_64
kernel-ml-devel-5.8.5-1.el7.elrepo.x86_64
kernel-3.10.0-229.el7.x86_64
kernel-tools-libs-3.10.0-1127.18.2.el7.x86_64
```
从输出结果我们可以看到当前最新版的内核为`kernel-ml-5.8.5-1.el7.elrepo.x86_64x86_64`。
### 5、查找新安装内核的完整名称
使用`cat /boot/grub2/grub.cfg | grep menuentry`指令
```bash
[root@devops software]# cat /boot/grub2/grub.cfg | grep menuentry
if [ x"${feature_menuentry_id}" = xy ]; then
  menuentry_id_option="--id"
  menuentry_id_option=""
export menuentry_id_option
menuentry 'CentOS Linux (5.8.5-1.el7.elrepo.x86_64) 7 (Core)' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-229.el7.x86_64-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
menuentry 'CentOS Linux (5.8.5-1.el7.elrepo.x86_64) 7 (Core) with debugging' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-229.el7.x86_64-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
menuentry 'CentOS Linux (3.10.0-1127.18.2.el7.x86_64) 7 (Core)' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-229.el7.x86_64-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
menuentry 'CentOS Linux (3.10.0-1127.18.2.el7.x86_64) 7 (Core) with debugging' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-229.el7.x86_64-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
menuentry 'CentOS Linux 7 (Core), with Linux 3.10.0-229.el7.x86_64' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-229.el7.x86_64-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
menuentry 'CentOS Linux 7 (Core), with Linux 0-rescue-17de3882d4904b439acb8cb7d504ef82' --class rhel fedora --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-17de3882d4904b439acb8cb7d504ef82-advanced-b06a2560-eb02-4233-bb98-1d27bba4a373' {
```
从输出信息可以找到最新版的内核完整名称为：`'CentOS Linux (5.8.5-1.el7.elrepo.x86_64) 7 (Core)'`，我们将在第6步中使用这个名称。
### 6、设置默认启动内核为最新版

- a、使用`grub2-set-default '***'`指令设置默认启动内核。（`***` 代表第5步中输出的内核名称，注意这里的引号也是不能缺少的）
- b、因为新安装的内核默认排在第一位，所以我们使用`grub2-set-default 0`指令也可以设置默认启动内核。

```bash
[root@devops software]# grub2-set-default 'CentOS Linux (5.8.5-1.el7.elrepo.x86_64) 7 (Core)'
或
[root@devops software]# grub2-set-default 0

```
### 7、查看默认启动内核是否更改成功
使用`grub2-editenv list`命令查看
```bash
[root@devops software]# grub2-editenv list
saved_entry=CentOS Linux (5.8.5-1.el7.elrepo.x86_64) 7 (Core)
或
 saved_entry=0
```
从输出结果可以看出，默认启动内核已经被设置成了最新版。
### 8、重启服务器
确认默认启动内核为最新版后，我们就可以重启服务器了。
```bash
[root@devops software]# reboot
```
### 重启完成后，新内核就安装完成。此时我们可以再次使用`uname -r`命令查看当前的默认内核版本。


```bash
[root@devops software]# uname -r
5.8.5-1.el7.elrepo.x86_64
```
内核升级完成过后，有时候我们为了节省磁盘空间，可能会考虑删除旧的内核，下面是删除旧内核方式。
### 9、删除老版本内核（可选）
使用`rpm -qa kernel*`或`rpm -qa | grep -i kernel`命令查看已有的所有内核版本。
```bash
[root@devops software]# rpm -qa | grep -i kernel
kernel-tools-3.10.0-957.27.2.el7.x86_64
kernel-3.10.0-693.21.1.el7.x86_64
kernel-3.10.0-957.5.1.el7.x86_64
kernel-3.10.0-693.el7.x86_64
kernel-3.10.0-693.2.2.el7.x86_64
kernel-ml-5.2.8-1.el7.elrepo.x86_64
kernel-tools-libs-3.10.0-957.27.2.el7.x86_64
kernel-3.10.0-957.27.2.el7.x86_64
kernel-ml-devel-5.2.8-1.el7.elrepo.x86_64
kernel-headers-3.10.0-957.27.2.el7.x86_64
```
使用`yum remove [版本号...版本号]`或者`rpm -e [版本号...版本号]`命令卸载老版本内核（最好是复制内核版本信息，手动输很容易输错）。
**注意**_：强烈建议只卸载自己安装的内核，不要删除原系统的内核。_
内核卸载完，也需要重启下系统才能生效。

