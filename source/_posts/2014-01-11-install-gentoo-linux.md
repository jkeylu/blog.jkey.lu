title: 安装 Gentoo
date: 2014-01-11 13:35:13
tags: [linux, gentoo]
---

最近组了一台电脑想用做 nas，配置为

* 奔腾G2100T
* 华擎 B75M-ITX 主板
* DDR3 1600 2G 内存
* 先马 230W 电源
* 一块 64G SSD 加上另外三块从笔记本上拆下来的硬盘。

原本 CPU 想用赛扬的，但是看中的一块淘宝上缺货了，所以用奔腾G2100T替代。所有都装好后进 BIOS 对 CPU 降低电压，稳定在 0.8V。装好 Gentoo 后，开机差不多在 37W 左右，编译的时候 45W 左右。虽然，对于当 nas 来用，37W 还是有点高的，但是，平时还可以在上面做其他的事，那么还是可以接受的。

第一次用 Gentoo，根据 Gentoo 手册 [http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1](http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1) 一步一步安装的，下面是安装过程中遇到的一些问题。

<!-- more -->

### 编译内核的一些选项

[http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1#book_part1_chap7](http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?full=1#book_part1_chap7)

网卡

```
Device Drivers  --->
  [*] Network device support  --->
    [*] Ethernet driver support  --->
      [*] Realtek devices
      <*>   Realtek 8169 gigabit ethernet support
```

lm sensors

[http://wiki.gentoo.org/wiki/Lm_sensors](http://wiki.gentoo.org/wiki/Lm_sensors)


电源管理

[http://wiki.gentoo.org/wiki/Power_management/Processor](http://wiki.gentoo.org/wiki/Power_management/Processor)

ntfs

[https://wiki.gentoo.org/wiki/NTFS](https://wiki.gentoo.org/wiki/NTFS)

iptables

[http://wiki.gentoo.org/wiki/Iptables](http://wiki.gentoo.org/wiki/Iptables)

ntp

[https://wiki.gentoo.org/wiki/Ntp](https://wiki.gentoo.org/wiki/Ntp)

### 编译 node.js 是报错

```
ImportError: This platform lacks a functioning sem_open implementation, therefore, the required synchronization primitives needed will not function, see issue 3770.
```

解决方法: [http://forums-lb.gentoo.org/viewtopic-t-976004.html](http://forums-lb.gentoo.org/viewtopic-t-976004.html)

1. Add this line to /etc/fstab EDITED: When using OpenRC, otherwise comment it out 

	```
	tmpfs   /dev/shm    tmpfs   defaults        0   0
	```

2. Mount /dev/shm EDITED: When running OpenRC 

	```
	mount /dev/shm
	```

3. Rebuild Python 

	```
	emerge -qa python:2.7 python
	```

4. Rebulid all Python stuff 

	```
	python-updater
	```
