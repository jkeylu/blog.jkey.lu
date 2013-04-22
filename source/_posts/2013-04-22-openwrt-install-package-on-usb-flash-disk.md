title: openwrt 把包装到u盘上
date: 2013-04-22 20:47:24
tags: openwrt
---

买了个可以刷 openwrt 的路由器，但是路由器始终是路由器。ROM 大小只有 16M，想装个 python 包到上面显然有些不现实。不过也是有办法把包装到u盘上的，当然前提是路由器上有个 usb 口。

* u盘查到路由器上，然后挂载u盘。

* 在u盘上创建文件夹，用于安装包

```
mkdir /mnt/sdb1/packages
```

* 创建 /opt 软连接

```
ln -s /mnt/sdb1/packages /opt
```
<!-- more -->

* 然后编辑 /etc/opkg.conf 文件，添加一行如下

```
dest usb /opt
```

* 在 /etc/profile 文件中添加环境变量

```
export PATH=$PATH:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/usr/sbin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/lib:/opt/usr/lib
```

* 安装包到u盘上

```
opkg update
opkg -dest usb install python
```

* 如果安装的包中有启动服务的脚本，可以在 /etc/init.d 中添加软连接

```
ln -s /opt/etc/init.d/nginx /etc/init.d/nginx
```

更多详细：[http://wiki.openwrt.org/doc/techref/opkg#mount.point](http://wiki.openwrt.org/doc/techref/opkg#mount.point)
