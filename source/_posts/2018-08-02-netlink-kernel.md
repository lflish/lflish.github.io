---
layout: post
title: netlink通信机制-内核层
date: 2018-08-02 02:01:33
categories: kernel
tags: kernel
---
## 内核层

### 处理函数注册

```c
	struct netlink_kernel_cfg cfg = {
		.input = nl_data_ready, /* set recv callback */
	};

	nl_sk = netlink_kernel_create(&init_net, NETLINK_TEST, &cfg);
```
<!--more-->

netlink_kernel_create 函数的使用具体跟内核有关系，我这里是3.10的内核。
```c
	//2.6版本的 
	netlink_kernel_create(&init_net, NETLINK_TEST, 0, NULL, kernel_receive, THIS_MODULE); 

	//3.8后版本
	netlink_kernel_create(&init_net, NETLINK_TEST, &cfg);
```

参数说明:   
1. 采用的固定的init_net，具体不知道为什么  
2. NETLINK_TEST 这个是netlink协议类型与用户层的要相同    
    int skfd = socket(AF_NETLINK, SOCK_RAW, NETLINK_TEST);应用层的代码    					      
    这个值取1~31            			  						
3. cfg存放的是netlink内核配置参数  

### 接收数据

```c
	//处理消息的函数，这个根据内核版本也有变动，老版本的好像是struct sock *skb 类型
	static void nl_data_ready(struct sk_buff *skb)

	//获取netlink数据包中netlink header的起始地址。
	nlh = nlmsg_hdr(skb);

	//获取struct nlmsghdr结构的数据部分
	umsg = NLMSG_DATA(nlh);
```

### 发送数据
```c
	struct sk_buff *skb;
	struct nlmsghdr *nlh;

	// 为新的 sk_buffer申请空间
	skb = nlmsg_new(slen, GFP_ATOMIC);

	//用nlmsg_put()来设置netlink消息头部
	nlh = nlmsg_put(skb, 0, 0, NETLINK_TEST, slen, 0);

	//拷贝数据
	memcpy(nlmsg_data(nlh), message, slen);

	//通过netlink_unicast()将消息发送用户空间由pid所指定了进程号的进程
	netlink_unicast(nl_sk, skb, pid, MSG_DONTWAIT);
```

### 源码
```c
/**
 *	@file:	ktest.c
 *	@brief: kernel example
 *	@author: lflish
 *	@date: 2018-8-1
 *	@email:	hxy.gold@gmail.com
 *	kernel version:	3.10.0-862	
 **/

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/skbuff.h>
#include <linux/init.h>
#include <linux/ip.h>
#include <linux/types.h>
#include <linux/sched.h>
#include <net/sock.h>
#include <linux/netlink.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("lflish");

#define MAX_MSGSIZE 125

#define NETLINK_TEST 30

struct sock *nl_sk = NULL;
//向用户空间发送消息的接口
int sendnlmsg(char *message,int pid)
{
    struct sk_buff *skb;
    struct nlmsghdr *nlh;

    int slen = 0;

    if(!message || !nl_sk){
        return -1;
    }

    slen = strlen(message);

    // 为新的 sk_buffer申请空间
    skb = nlmsg_new(slen, GFP_ATOMIC);
    if(!skb){
        printk(KERN_ERR "my_net_link: alloc_skb Error./n");
        return -2;
    }

    //用nlmsg_put()来设置netlink消息头部
    nlh = nlmsg_put(skb, 0, 0, NETLINK_TEST, slen, 0);
	if(nlh == NULL){
		printk("nlmsg_put failauer \n");
		nlmsg_free(skb);
		return -1;
	}

    memcpy(nlmsg_data(nlh), message, slen);

    //通过netlink_unicast()将消息发送用户空间由pid所指定了进程号的进程
    netlink_unicast(nl_sk, skb, pid, MSG_DONTWAIT);
    printk("send OK!\n");

    return 0;
}

static void nl_data_ready(struct sk_buff *skb)
{
    struct nlmsghdr *nlh = NULL;
    char *umsg = NULL;
    char kmsg[] = "hello users!!!";

    if(skb->len >= nlmsg_total_size(0))
    {   
        nlh = nlmsg_hdr(skb);
        umsg = NLMSG_DATA(nlh);
        if(umsg)
        {   
            printk("kernel recv from user: %s\n", umsg);
            sendnlmsg (kmsg, nlh->nlmsg_pid);
        }   
    }   
}

struct netlink_kernel_cfg cfg = {
	.input = nl_data_ready, /* set recv callback */
};

int myinit_module(void)
{
    printk("my netlink in\n");
    nl_sk = netlink_kernel_create(&init_net, NETLINK_TEST, &cfg);
	if(nl_sk == NULL)
		printk("kernel_create error\n");
    return 0;
}

void mycleanup_module(void)
{
    printk("my netlink out!\n");
    sock_release(nl_sk->sk_socket);
	netlink_kernel_release(nl_sk);
}

module_init(myinit_module);
module_exit(mycleanup_module);
```

```Makefile
MODULE_NAME :=ktest
obj-m :=$(MODULE_NAME).o

KERNELDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all: user kernel

kernel:
    $(MAKE) -C $(KERNELDIR) M=$(PWD)

user: utest.c
    gcc utest.c -o utest

clean:
    $(MAKE) -C $(KERNELDIR) M=$(PWD) clean
    rm -rf utest
```

以上是内核的通信模型  

[git实例源码](https://gist.github.com/lflish/15e85da8bb9200794255439d0563b195)

## 参考文档   
结构、宏等说明实例 https://www.cnblogs.com/wenqiang/p/6306727.html   
rfc3549 https://tools.ietf.org/html/rfc3549   
这哥们的不错，但是是低版本内核 http://blog.chinaunix.net/uid-23069658-id-3405954.html
https://wenku.baidu.com/view/4d6af81da417866fb84a8eb5.html
