title: Linux 上 C 语言的 socket 编程
date: 2013-03-22 23:42:19
tags: socket
---

这几天看了一下 Linux 上的 socket 编程，把主要几个 socket 编程用到的函数研究了一下，并记录下来备忘。

socket()
--------

```
#include <sys/socket.h>
int socket(int domain, int type, int protocol);
```

* **domain** 指定 socket 的通信协议集(AF_UNIX 和 AF_INET 等)

    AF_UNIX (与 AF_LOCAL 和 AF_FILE 相同) 只能够用于单一的 *nix 的系统上，使用 AF_UNIX 会在系统上创建一个 socket 文件，不同进程通过读写这个文件来实现通信。

    AF_INET 则是用于网络的，所以可以允许远程主机之间的通信。

    更多协议可以看 <bits/socket.h>

* **type** 指定 socket 的类型(SOCK_STREAM 和 SOCK_DGRAM 等)

    SOCK_STREAM 表明使用 TCP 协议，这就意味着会提供按顺序的、可靠、双向、面向连接的比特流。

    SOCK_DGRAM 表明使用 UDP 协议，这就意味着会提供定长的、不可靠、无连接的通信。

* **protocol** 指定实际使用的传输协议。最常见的就是 IPPROTO_TCP, IPPROTO_SCTP, IPPROTO_UDP, IPPROTO_DCCP。这些协议都在 <netinet/in.h> 中有详细说明。如果该项为 0 的话，即根据选定的domain和type选择使用缺省协议。

调用 socket() 函数后，成功会返回文件描述符，失败则返回 -1。

<!-- more -->

bind()
------

```
#include <sys/socket.h>
int bind(int socket, const struct sockaddr *address,
        socklen_t address_len);
```

bind() 为 socket 分配地址。当使用 socket() 创建套接字后，仅仅赋予了其所使用的协议，而没有分配地址。在接受其它主机连接前，必须先调用 bind() 为 socket 分配地址。

* **socket** 这是 socket 的描述符

* **address** 指向 sockaddr 结构（用于表示所分配地址）的指针

* **address_len** sockaddr 结构的长度

listen()
--------

```
#include <sys/socket.h>
int listen(int socket, int backlog);
```

当 socket 和一个地址绑定后，调用 listen() 函数开始监听连接请求。但是，这只能在有可靠数据流保证时使用，如 SOCK_STREAM, SOCK_SEQPACKET 。

* **socket** socket 的描述符

* **backlog** 一个决定监听队列大小的整数，当有一个连接请求到来，就会进入此监听队列，当队列满后，新的连接请求会返回错误。

如果成功监听返回 0，否则返回 -1 。

accept()
--------

```
#include <sys/socket.h>
int accept(int socket, struct sockaddr *restrict address,
        socklen_t *restrict address_len);
```

当应用程序监听来自其他主机的面对数据流的连接时，通过事件（比如Unix select()系统调用）通知它。必须用 accept()函数初始化连接。 Accept() 为每个连接创立新的套接字并从监听队列中移除这个连接。它使用如下参数：

* **socket** 监听的 socket 描述符

* **address** 指向sockaddr 结构体的指针，客户机地址信息。

* **address_len** 指向 socklen_t的指针，确定客户机地址结构体的大小 。

返回新的套接字描述符，出错返回-1。进一步的通信必须通过这个套接字。

Datagram 套接字不要求用accept()处理，因为接收方可能用监听套接字立即处理这个请求。

connect()
---------

```
#include <sys/socket.h>
int connect(int socket, const struct sockaddr *address,
        socklen_t address_len);
```

connect() 系统调用为一个套接字设置连接，参数有文件描述符和主机地址。

某些类型的套接字是无连接的，大多数是 UDP 协议。对于这些套接字，连接时这样的：默认发送和接收数据的主机由给定的地址确定，可以使用 send() 和 recv()。返回 -1 表示出错，0 表示成功。

socket 实例
-----------

*client.c 文件*

{% gist jkeylu/5275687 client.c %}

*server.c 文件*

{% gist jkeylu/5275687 server.c %}
