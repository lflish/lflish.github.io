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
```
	eg:![naruto](naruto.png)
```

![naruto](naruto.jpg)

## 修改文件属性
在用hexo new创建一个新的md文件时，会在开头添加以下内容。
```
---
title: hexo博客搭建
date: 2018-07-26 02:38:15
tags:
---
```
以上内容格式应该是可以定制的，所以网上查了下，确实如此。

*之前介绍使用hexo new 的时候可以带一个参数layout，那么这个layout指的是什么呢？*
*它其实是在scaffolds文件夹下的.md，默认情况下有draft.md page.md post.md*
*如果没有指定的话它会默认使用post.md ，这个属性可以在根目录下的_config 文件中进行配置：*
*default_layout: post 配置默认的layout*
*同时我们也可以看到当你hexo new 的时候产生的md文件中会默认产生一些内容，这个内容就是上述介绍的draft.md page.md post.md 所指定的。*

也就是说他这个默认格式由post.md来定义,类似如下。
```
title: {{ title }}
date: {{ date }}
tags:
```
但我这里不一样，我这里没找到他说的文件夹以及他说的post.md，不过我这有scaffolds.json的文件，通过修改里边的格式一样可以达到定制的目的。

参考链接:http://tbfungeek.github.io/2016/02/27/Hexo-%E6%96%87%E7%AB%A0%E5%B1%9E%E6%80%A7/
	
## 参考文档

[hexo官方文档](https://hexo.io/zh-cn/docs/)
[next官方文档](http://theme-next.iissnan.com/)
[零基础搭建hexo博客](https://www.cnblogs.com/visugar/p/6821777.html)
[hexo博客添加功能](https://www.cnblogs.com/mrwuzs/p/7943337.html)

