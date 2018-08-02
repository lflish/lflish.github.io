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
```bash
	#生成文件
	hexo new test

	#markdown 格式编写
	echo "# hello world" >> ./source/_opst/title.md

	#生成静态文件
	hexo generate
```

## 开启服务
```bash
	#开启服务
	hexo server -p 80
```

## push到github page

```bash
	#清理重新编译
	hexo clean
	hexo generate 
	#push
	hexo deploy
```
## 插入图片
编辑_config.yml 修改post_asset_folder:false 为true

```bash
	#安装图片上传插件
	npm install https://github.com/CodeFalling/hexo-asset-image --save
	#创建一篇新闻章,此时创建的文章同时生产一个目录
	hexo new test
	#当然我这里是已有的项目,只需要创建个同名目录把图片放进去引用就行了
```
拷贝图片到目录
markdown 引用本地图片的格式来引用图片就行了
eg:![naruto](naruto.png)

![naruto](naruto.jpg)

	
## 参考文档

[hexo官方文档](https://hexo.io/zh-cn/docs/)
[next官方文档](http://theme-next.iissnan.com/)
[零基础搭建hexo博客](https://www.cnblogs.com/visugar/p/6821777.html)
[hexo博客添加功能](https://www.cnblogs.com/mrwuzs/p/7943337.html)

