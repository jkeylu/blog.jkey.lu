title: 重新配置我的树莓派
date: 2013-04-18 21:42:06
tags:
---

安装系统
--------

下载 Arch Linux ARM 系统镜像：[http://www.raspberrypi.org/downloads](http://www.raspberrypi.org/downloads)

解压出 .img 文件，然后使用以下命令把镜像写入 SD 卡中

```
dd if=archlinux-hf-2013-02-11.img of=/dev/sdb bs=1M
```

如果是 window 系统，可以下载 [Win32DiskImager](http://sourceforge.net/projects/win32diskimager/) 来把镜像写入 SD 卡。

<!-- more -->

设置内存
--------

由于主要把我的树莓派当作服务器用，所以没必要分配太多的 VIDEO RAM，可以设置/boot/config.txt：

```
gpu_mem=16
#gpu_mem_512=316
#gpu_mem_256=128
#cma_lwm=16
#cma_hwm=32
#cma_offline_start=16
```

更多关于 config.txt 文件的配置信息查看 [http://elinux.org/RPiconfig](http://elinux.org/RPiconfig)

调整分区大小
------------

```
echo -e "d\n2\nn\np\n\n\n\nw\n" | fdisk /dev/mmcblk0
reboot
```

重启后

```
resize2fs /dev/mmcblk0p2
```

更多关于[调整分区大小](http://elinux.org/RPi_Resize_Flash_Partitions#Manually_resizing_the_SD_card_on_Raspberry_Pi)

系统设置
--------

* 设置时区

```
timedatectl set-timezone Asia/Shanghai
```

更多关于[时区设置](https://wiki.archlinux.org/index.php/Time#Time_Zone)

* 设置 Hostname

```
hostnamectl set-hostname rpi
```

更多关于 [Hostname](https://wiki.archlinux.org/index.php/Network_Configuration#Set_the_hostname)

* 更新系统

```
pacman -Syu
```

* 安装 Sudo

```
pacman -S sudo
```

配置 sudo，执行 `visudo`，去掉下面这句注释

```
%wheel ALL=(ALL) ALL
```

更多关于 [Sudo](https://wiki.archlinux.org/index.php/Sudo)

* 添加用户

```
useradd -m -U -G wheel -s /bin/bash jkey
passwd jkey
```

更多关于[用户和组](https://wiki.archlinux.org/index.php/Users_and_Groups#User_groups)

* 配置 SSH

修改 /etc/ssh/sshd_config 文件，修改默认端口，禁止 root 登录，禁止使用密码登录

```
Port 8888
PermitRootLogin no
PasswordAuthentication no
```

锁住 root 用户

```
passwd -l root
```
