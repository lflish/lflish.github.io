---
title: hexo博客搭建
date: 2018-07-26 02:38:15
categories:
	linux
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

<!--more -->

## hexo初始化

```bash
	#创建目录
	mkdir hexo 

	#初始化
	hexo init

	#清理缓存
	hexo clean
```
## 文档编写
```
	#生成文件
	hexo new test

	#markdown 格式编写
	echo "# hello world" >> ./source/_opst/title.md

	#生成静态文件
	hexo generate
```

## 开启服务
```
	#开启服务
	hexo server -p 80
```
## 参考文档

[hexo官方文档](https://hexo.io/zh-cn/docs/)
[next官方文档](http://theme-next.iissnan.com/)
[零基础搭建hexo博客](https://www.cnblogs.com/visugar/p/6821777.html)
[hexo博客添加功能](https://www.cnblogs.com/mrwuzs/p/7943337.html)

