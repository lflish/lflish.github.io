---
title: 源码记录
date: 2018-07-26 03:33:24
categories: 
	linux
tags: 源码分析
---

工作中分析了不少源码，这里列举下，方便以后使用。


### 安全相关
	ossec:		主机入侵检测工具 hids	
	scanlogd: 	端口防扫描工具
	snort: 		网络入侵检测工具 nids
	fail2ban:	入侵检测

<!--more -->

### 系统相关
	cronie 		定时任务	git://git.fedorahosted.org/git/cronie.git
	top     	资源管理
	sysstat 	资源管理	https://github.com/sysstat/sysstat.git
	chkconfig	自启动项目	https://github.com/fedora-sysv/chkconfig.git
	shadow		用户管理(passwd,useradd等) https://github.com/shadow/shadow.git

### 文件管理
	coreutils 文件管理(ls,rm,cp,move等)	https://github.com/coreutils/coreutils.git
	

### 网络方面
	net-tools	网络网卡等信息(netstat，ifconfig)
