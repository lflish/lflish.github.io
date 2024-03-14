---
title: 网络代理 4-简单代理(iptables)
date: 2024-03-13 22:40:24
categories: 
	计算机网络
tags: 代理
---

上次通过NC进行了代理测速，这次通过iptables直接内核层进行转发:

**目标服务器: 4.ipw.cn**
**代理机器: lflish.cloud(云机器)**


下边代码尚未进行测试，后续会更新(因为这次使用了80端口测试，排查是因为运营商拦截了请求，目前正在备案中)
```
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -F
iptables -F

#本机IP地址
LOCAL=10.0.24.7

#基于端口进行转发
function add_dnat_dip()
{
    PORT=$1
    DIP=$2

    iptables -t nat -I PREROUTING  --dst ${LOCAL} -p tcp --dport ${PORT} -j DNAT --to-destination ${DIP}
    iptables -t nat -I POSTROUTING -p tcp --dport ${PORT} -j SNAT --to-source ${LOCAL}
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport ${PORT} -j ACCEPT
}

#基于Ip+port进行转发
function add_dnat_dst()
{
    PORT=$1
    DIP=$2
    DPORT=$3

    iptables -t nat -I PREROUTING  --dst ${LOCAL} -p tcp --dport ${PORT} -j DNAT --to-destination ${DIP}:${DPORT}
    iptables -t nat -I POSTROUTING -p tcp --dport ${DPORT} -j SNAT --to-source ${LOCAL}
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport ${PORT} -j ACCEPT
}

 
#add_port_2_dip 80 114.132.191.12
add_dnat_dst 7000 114.132.191.12 80
```

chatGPT:
    当涉及到端口转发时，iptables 和 nc（netcat）是两种不同的实现方式，各自有其特点和用途。

iptables 端口转发：
    - iptables 是一个在 Linux 上用于配置防火墙规则的工具，它可以进行网络地址转换（NAT）以及端口转发等功能。
    - 通过 iptables 进行端口转发是在系统级别进行的，可以影响整个系统的网络流量控制。
    - iptables 可以实现四层（传输层）的端口转发，可以基于源地址、目标地址、源端口、目标端口等信息进行转发规则的配置。

nc 端口转发：
    - nc（netcat）是一个网络工具，用于在网络上读写数据，包括建立连接、传输数据等功能。
    - 通过 nc 进行端口转发是在应用层进行的，通常用于临时性的、针对特定应用的端口转发需求。
    - nc 端口转发是在命令行中执行的，只会影响 nc 所启动的端口转发过程，不会影响系统的其他网络流量。

总结：
    - iptables 适用于系统级别的网络流量控制，而 nc 更适用于临时性的、应用层的端口转发需求。
    - iptables 实现的端口转发作用于整个系统的网络流量，而 nc 只会影响 nc 命令所启动的端口转发过程。
    - iptables 可以实现四层的端口转发，而 nc 更多地是应用层的端口转发工具。