---
layout: post
title: Unix域套接字
date: 2019-01-22 16:34:19
tags: apue 
categories: linux
---
# Unix域套接字
Unix域套接字通信是比较高级的通信方式,也是IPC通信的一种。相较于普通IPC通信，它们使用跟网络完全一样的接口。

<!--more-->

## Unix套接字的优势
有以下三个优势：
-   Unix域套接字比通信两端位于同一个主机的TCP套接字快出一倍。（TCPv3 223~224）
-   Unix域套接字可以再同一主机上传递描述符。强大
-   可以提供额外的凭证。
sockaddr_un结构在不同系统有不同的定义。

```c
//linux 3.2 solaris 10
struct sockaddr_un{
    sa_family_t     sun_family;
    char            sun_path[108];
}

//FreeBSD 8.0 Mac OS X 10.6
struct sockaddr_un{
    unsigned char sun_len;
    sa_family_t    
}
```

使用中的一些注意事项:
-   无法将一个socket绑定到一个既有路径上，一个socket只能绑定到一个路径上。
-   通常绑定到一个绝对路径上。
-   当不需要一个socket时，可以使用unlink(remove)删除。

POSIX的基本要求，但是实现可能并不是这样的:  
1.  由bind创建的路径名默认访问权限为0777,并按照当前umask值进行修改。   
2. 与Unix域套接字关联的路径名应该是一个绝对路径，而不是一个相对路径。(POSIX声称绑定相对路径可能有不可预计的后果)  
3. 在connect调用中指定的路径名必须是一个当前绑定在某个打开的Unix域套接字上的路径名，而且他们的套接字类型也必须一致。
4. 调用connect连接一个Unix域套接字设计的权限测试等同于调用open以只写方式访问相应的路径名。
5. Unix域字节流套接字类似TCP套接字：他们都为进程提供一个无记录边界的字节流接口。
6. 如果对于某个Unix域字节流套接字的connect调用发现这个监听套接字的队列已满，调用就立即返回一个ECONNREFUSED错误，而TCP套接字会忽略新到达的SYN，这会导致发起端继续发送SYN重试。
7. Unix域数据报套接字类似于UDP套接字:他们都提供一个保留记录边界的不可靠的数据报服务。
8. 在一个未绑定的Unix域套接字上发送数据报不会自动给这个套接字绑定一个路径名，这点不同于UDP套接字，UDP会开一个临时端口。

注意：如果不为Unix域套接字显式地绑定名字，内核会代表我们隐式地绑定一个地址且不会再文件系统创建文件来表示这个套接字。

Unix域套接字提供流和数据包两种接口。


