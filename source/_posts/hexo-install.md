---
title: hexo博客搭建
date: 2018-07-26 02:38:15
categories:
	-linux
tags: 环境搭建
---

## 环境搭建
-----
```bash
	#下载官方源  
	curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -

	#安装nodejs  
	sudo yum -y install nodejs

	#安装hexo  
	npm i -g hexo
```

## hexo配置使用

```bash
	#创建目录
	mkdir hexo 

	#初始化
	hexo init

	#清理缓存
	hexo clean

	#生成静态文件
	hexo generate

	#开启服务
	hexo server -p 80
```


