---
layout: post
title: netlink通信机制-用户层
date: 2018-08-01 04:40:10
categories:
	kernel
tags: kernel 
---
内核层与用户层通信方式的话有很多种，比如procfs、sysfs、syscall、seq_file、netlink等几种吧。
IBM社区有篇文章作了更详细的介绍。
[用户空间与内核空间数据交换的方式](https://www.ibm.com/developerworks/cn/linux/l-kerns-usrs/)    
最常用的算是netlink。

<!-- more -->

## 用户层

### 首先创建描述符
```c
    int skfd = socket(AF_NETLINK, SOCK_RAW, NETLINK_TEST);
```
### 初始化一个sockaddr_nl结构，与网络描述符绑定    
    sockaddr_nl 结构
```c
    struct sockaddr_nl {
    __kernel_sa_family_t    nl_family;   /* AF_NETLINK （跟AF_INET对应）*/
    unsigned short  nl_pad;              /* zero */
    __u32       nl_pid;                 /* port ID  （通信端口号）*/
    __u32       nl_groups;              /* multicast groups mask */
    };
```
```c
    struct sockaddr_nl nladdr;
    
    /*init netlink socket */
    nladdr.nl_family = AF_NETLINK;	/* AF_NETLINK or PE_NETLINK */
    nladdr.nl_pad = 0;				/* not use */
    nladdr.nl_pid = 0;				/* 传送到内核 */
    nladdr.nl_groups = 0;			/* 单播*/
	
    /* bing 绑定netlink socket 与socket */
    bind(skfd, (struct sockaddr *)&nladdr, sizeof(struct sockaddr_nl))
```

### 组装需要发送的消息msghdr结构
```c
    struct msghdr msg;
    memset(&msg, 0, sizeof(msg));
    msg.msg_name = (void *)&(nladdr);
    msg.msg_namelen = sizeof(nladdr);

    #define MAX_MSGSIZE 1024
    char buffer[] = "hello kernel!!!";

    /* netlink 消息头 */
    struct nlmsghdr *nlhdr;
    nlhdr = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_MSGSIZE));

    strcpy(NLMSG_DATA(nlhdr),buffer);

    nlhdr->nlmsg_len = NLMSG_LENGTH(strlen(buffer));
    nlhdr->nlmsg_pid = getpid();  /* self pid */
    nlhdr->nlmsg_flags = 0;


    struct iovec iov;

    iov.iov_base = (void *)nlhdr;
    iov.iov_len = nlhdr->nlmsg_len;
    msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
```
上段代码总的来说分两大块。   
1. msg.msg_name 目的地址信息
2. msg.msg_iov 源地址信息+源地址数据   
等价于以下代码
```c
	iov.iov_base = nlhdr = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_MSGSIZE));
```
结构如下图:

![piage](netlink.png)

结构体说明
```c
    struct msghdr {
        void         *msg_name;       /* optional address */
        socklen_t     msg_namelen;    /* size of address */
        struct iovec *msg_iov;        /* scatter/gather array */
        size_t        msg_iovlen;     /* # elements in msg_iov */
        void         *msg_control;    /* ancillary data, see below */
        size_t        msg_controllen; /* ancillary data buffer len */
        int           msg_flags;      /* flags on received message */
    };
    /*  msg_name： 数据的目的地址，网络包指向sockaddr_in, netlink则指向sockaddr_nl;
        msg_namelen: msg_name 所代表的地址长度
        msg_iov: 指向的是缓冲区数组
        msg_iovlen: 缓冲区数组长度
        msg_control: 辅助数据，控制信息(发送任何的控制信息)
        msg_controllen: 辅助信息长度
        msg_flags: 消息标识
    */
```
```c 
    
    struct iovec {                    /* Scatter/gather array items */
        void  *iov_base;              /* Starting address */
        size_t iov_len;               /* Number of bytes to transfer */
    };
    /* iov_base: iov_base指向数据包缓冲区，即参数buff，iov_len是buff的长度。msghdr中允许一次传递多个buff，
        以数组的形式组织在 msg_iov中，msg_iovlen就记录数组的长度 （即有多少个buff）
    */
```

```c
/* struct nlmsghd 是netlink消息头*/
struct nlmsghdr {   
    __u32       nlmsg_len;  /* Length of message including header */
    __u16       nlmsg_type; /* Message content */
    __u16       nlmsg_flags;    /* Additional flags */ 
    __u32       nlmsg_seq;  /* Sequence number */
    __u32       nlmsg_pid;  /* Sending process port ID */
};
```
### 发送消息到内核
```c
    sendmsg(skfd, &msg, 0);
```
### 接收来自内核的消息
```c
    sendmsg(skfd, &msg, 0);
```

### 代码
```c
/**
 *	@file:	ktest.c
 *	@brief: kernel example
 *	@author: lflish
 *	@date: 2018-8-1
 *	@email:	hxy.gold@gmail.com	
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>


/* /usr/include/linux/netlink.h */
#include <linux/netlink.h>

#define NETLINK_TEST 30
int main()
{
	/* 建立socket */
	int skfd = socket(AF_NETLINK, SOCK_RAW, NETLINK_TEST);
	if(skfd == -1){
		perror("create socket error\n");
		return -1;
	}

	/* netlink socket */
	struct sockaddr_nl nladdr;
	
	/*init netlink socket */
	nladdr.nl_family = AF_NETLINK;	/* AF_NETLINK or PE_NETLINK */
	nladdr.nl_pad = 0;				/* not use */
	nladdr.nl_pid = 0;				/* 传送到内核 */
	nladdr.nl_groups = 0;			/* 单播*/
	
	/* bing 绑定netlink socket 与socket */
	if( 0 != bind(skfd, (struct sockaddr *)&nladdr, sizeof(struct sockaddr_nl))){
		perror("bind() error\n");
		close(skfd);
		return -1;
	}

	/* 构造msg消息*/
	struct msghdr msg;
	memset(&msg, 0, sizeof(msg));
	msg.msg_name = (void *)&(nladdr);
	msg.msg_namelen = sizeof(nladdr);

	#define MAX_MSGSIZE 1024
	char buffer[] = "hello kernel!!!";

	/* netlink 消息头 */
	struct nlmsghdr *nlhdr;
	nlhdr = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_MSGSIZE));

	strcpy(NLMSG_DATA(nlhdr),buffer);

	nlhdr->nlmsg_len = NLMSG_LENGTH(strlen(buffer));
	nlhdr->nlmsg_pid = getpid();  /* self pid */
	nlhdr->nlmsg_flags = 0;


	struct iovec iov;

	iov.iov_base = (void *)nlhdr;
	iov.iov_len = nlhdr->nlmsg_len;
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
		
	sendmsg(skfd, &msg, 0);

	/* recv */
	//memset((char *)NLMSG_DATA(nlhdr), 0, 1024);
	recvmsg(skfd, &msg, 0);

	printf("kernel: %s\n", NLMSG_DATA(nlhdr));
	//printf("kernel: %s\n", nlmsg_data(nlhdr));

	close(skfd);
	free(nlhdr);

	return 0;
}
```
以上是用户层的通信模型  

[git实例源码](https://gist.github.com/lflish/15e85da8bb9200794255439d0563b195)

## 参考文档   
结构、宏等说明实例 https://www.cnblogs.com/wenqiang/p/6306727.html   
rfc3549 https://tools.ietf.org/html/rfc3549   
这哥们的不错，但是是低版本内核 http://blog.chinaunix.net/uid-23069658-id-3405954.html
https://wenku.baidu.com/view/4d6af81da417866fb84a8eb5.html
