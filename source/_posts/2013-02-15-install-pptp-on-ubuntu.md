title: Ubuntu 上安装 pptp
date: 2013-02-15 21:55:35
tags:
---

好吧，这其这篇是很久很久以前用 Wordpress 时写的，但是，过去了很久，又快忘了。所以，再写一遍。

先说一下我安装 pptp 的环境是 buyvm 上 128m 的 vps，安装了 ubuntu 系统。

1. 首先到 /dev/ 和 /dev/net/ 下确认是否有 ppp 和 tun 两个设备

	```
	/dev/ppp
	/dev/net/tun
	```

2. 安装 pptpd

	```
	apt-get install pptpd
	```

	<!-- more -->

3. 编辑 /etc/pptpd.conf 文件

	```
	vim /etc/pptpd.conf
	```

	去掉一下几句前面的 # 号

	```
	option /etc/ppp/pptpd-options
	localip 192.168.0.1
	remoteip 192.168.0.234-238,192.168.0.245
	```

4. 编辑 /etc/ppp/pptpd-options 文件，设置 DNS

	```
	vim /etc/ppp/pptpd-options
	```

	找到 ms-dns 去掉 # 号，并修改 DNS 地址

	```
	ms-dns 8.8.8.8
	ms-dns 8.8.4.4
	```

5. 编辑 /etc/ppp/chap-secrets ，加入用户

	```
	用户名 pptpd 密码 *
	```

	解释一下：分别用你自己想要的用户名和密码去替换‘用户名’ 和 ‘密码’，你当然可以添加 n 个，每行一个。

	以上设置完后基本上可以在 windows 上新建 vpn 连接后可以连接了，只是以上的设置只能访问服务器资源，而不能访问这台服务器以外的资源。所以，我们在进行配置。

6. 编辑 /etc/sysctl.conf 文件，找到以下行，去掉 # 号注释符号

	```
	net.ipv4.ip_forward=1
	```

	然后在运行以下命令使配置生效

	```
	sysctl -p
	```

7. 安装 iptables

	```
	apt-get install iptables
	```

8. 向 nat 表中添加一条规则：

	```
	iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o venet0 -j MASQUERADE
	//venet0是物理网卡，用 ifconfig 查看
	```

	如果执行这条命令后提示

	```
	iptables: No chain/target/match by that name.
	```

	那么改为以下命令重新执行：

	```
	iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o venet0 -j SNAT --to-source xxx.xxx.xxx.xxx
	```

	最后的 xxx.xxx.xxx.xxx 是你 vps 的 ip 地址。

9. 虽然现在设置好了 iptables 但是下次重启时会被清除，所以我们需要把它保存下来

	```
	iptables-save > /etc/iptables-rules
	```

	然后修改 /etc/network/interfaces 文件，找到 venet0 的结点，添加 pre-up 那一行：

	```
	auto venet0
	iface venet0 inet static
	pre-up iptables-restore < /etc/iptables-rules
	```

	这样重启后会自动加载之前设置好的 iptables 规则。

	但是有可能每次重启后 interfaces 都会被重写还原,那么上面方法就失效了。

	而我用的方法是在 /etc/rc.local 文件中添加一行 `iptables-restore /etc/iptables-rules`

	当然你也可以在每次重启后手动执行 `iptables-restore /etc/iptables-rules`

	好了这样就设置好了。

参考文章：

1. [OpenVZ VPS 上架设 PPTP VPN](http://wiki.wowubuntu.com/linux/openvz-archlinux-pptp-vpn)

2. [Debian/Ubuntu快速搭建PPTP VPN](http://qiaodahai.com/personal/article/2010/debian-ubuntu-setup-pptp-vpn.htm)

3. [Install and Configure OpenVPN](http://pityonline.info/?p=1054)
