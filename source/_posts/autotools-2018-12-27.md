---
layout: post
title: autoconf学习
date: 2018-12-27 15:04:35
tags: 自动化
categories: linux
---
# autoconf工具的初步学习

## autoconf产生的历史原因
原先写过一篇文章，叫《学习从历史开始》,这里先说下autotools产生的历史原因。  
autoconf历史：
https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.69/html_node/History.html#History  
### 一、__Genesis__  
1991年6月，作者维护了许多GNU的开源软件，而且这些开源软件被应用到了很多的平台。每个平台可能都需要依赖不同的-D参数来编译，_(-D是gcc编译器处理宏定义的一个选项)_。所以作者写了个shell脚本来检测系统已安装的工具包。由此configure脚本就诞生了。    
    后续做了一些改进，使用Makefile.in作为模板。   
<!--more-->
### 二、__Exodus__  
起初，许多用户给作者发送了很多建议，作者都是通过emacs中的搜索替换功能来更新自己的configure。  
    有天，有位大佬说作者工具很棒，问作者是否有自动生成的工具，作者意识到，是时候让它自己来生成脚本了。(小度啊，是时候自己写代码了)，于是，作者选用了M4语言来生成脚本。  
### __三、Leviticus__  
添加新的特性。比如，通过创建c的头文件来代替-D选项，这个应该就是指的config.h 这类文件。
### __四、Numbers__
终于，在1992年发布了autoconf的1.0，越来越多的人使用，包括哪些非GNU人员。这中间有许多开发者加入进来添加了许多新的特性，支持了更多的语言。

### __五、Leviticus__
1994，经过许多人的共同开发，这工具也大概就进入到了稳定期，这时候多少会留下来一些问题，不如编码风格，宏命名规范，等等。作者做了一些修正，统一，部分特性的添加。  
由此，2.0也就来临了。  
(作者说，我又开始 闲的一批了)

# autoconf使用案例

### 一、__普通版本__
两个文件，一个makefile文件，一个program.cc文件

Makefile文件
```Makefile
CXX=g++
LD=g++
CXXFLAGS=-Wall -Wextra

program: program.o
	$(LD) -o $@ $^
```
program.cc文件
```c++
#include <iostream>

using namespace std;

int main()
{
	cout << "Hello, I am a program\n";
}
```
编译
```
make && ./program
```

### 二、__autoconf版本__
一共三个文件，分别是makefile.in, configure.ac,program.cc  
makefile.in是生成makefile的模板，会替换其中的部分变量  
configure.ac 通过autoconf生成configure  
Makefile.in 文件
```Makefile
CXX=@CXX@
LD=@CXX@
CXXFLAGS=@CXXFLAGS@

program: program.o
	$(LD) -o $@ $^

.PHONY: clean
clean:
	rm -f program *.o
```

configure.ac 文件
```MAKEFILE
AC_INIT(program, 1.0)

#dnl Switch to a C++ compiler, and check if it works.
AC_LANG(C++)
AC_PROG_CXX

#dnl Process Makefile.in to create Makefile
AC_OUTPUT(Makefile)
```

_AC_PROG_CXX:会初始化当前语言的一些默认参数，比如CXX=G++,CXXFLAGS= -g -O2等_  
_AC_LANG(C++):标识当前语言_  
_AC_OUTPUT创建输出文件_  
_dnl是注释_ 

运行
```shell
./configure &&  make
```

这里默认CXX就是g++了 因为语言是c++，但是也可以通过在configure.ac中指定，或者在运行configure时指定
```shell
./configure CXX="gcc-c++"
```

### 三、__选择文件编译__
这里有五个文件，分别是Makefile.in, configure.ac, hello_libz.cc, hello_no_libz.cc, program.cc  

Makefile.in文件
```Makefile
CXX=@CXX@
LD=@CXX@
CXXFLAGS=@CXXFLAGS@
LDFLAGS=@LDFLAGS@
LIBS=@LIBS@

objs=@objs@

program: program.o $(objs)
	$(LD) -o $@ $^ $(LDFLAGS) $(LIBS)

.PHONY: clean
clean:
	rm -f program *.o
```
configure.ac 
```Makefile
AC_INIT(program, 1.0)

dnl Switch to a C++ compiler, and check if it works.
AC_LANG(C++)
AC_PROG_CXX

#dnl List of object files as determined by autoconf
object_files=""

a=0
AC_CHECK_HEADERS(zlib.h, [], [a=1])
AC_SEARCH_LIBS(deflate, z, [], [a=1])

if test $a == 0
then
	object_files="$object_files hello_libz.o"
else
	object_files="$object_files hello_no_libz.o"
fi

dnl Make AC_OUTPUT substitute the contents of $object_files for @objs@
AC_SUBST(objs, ["$object_files"])

dnl Process Makefile.in to create Makefile
AC_OUTPUT(Makefile)
```
hello_libz.cc

```c++
#include <iostream>
#include <zlib.h>

using namespace std;

void hello()
{
	//Output a string, compressed in gzip format.
	unsigned char in[] = "Hello, I am a program\n";
	unsigned char out[1024] = {};

	z_stream strm = {};
	deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 8+16, 9, Z_DEFAULT_STRATEGY);
	strm.next_in = in;
	strm.avail_in = sizeof(in);
	strm.next_out = out;
	strm.avail_out = sizeof(out);
	deflate(&strm, Z_FINISH);
	deflateEnd(&strm);

	cout.write((const char*)out, strm.total_out);
}
```
hello_no_libz.cc    
```c++
#include <iostream>

using namespace std;

void hello()
{
	char data[]={0x1f,0x8b,0x08,0x00,0x00,0x00,0x00,0x00,0x00,
				0x03,0xf3,0x48,0xcd,0xc9,0xc9,0xd7,0x51,0xf0,
				0x54,0x48,0xcc,0x55,0x48,0x54,0x28,0x28,0xca,
				0x4f,0x2f,0x4a,0xcc,0xe5,0x62,0x00,0x00,0x45,
				0x29,0xde,0xb8,0x17,0x00,0x00,0x00};

	cout.write(data, sizeof(data));
}
```
program.cc  
```c++
using namespace std;

//The purpose here is to teach autoconf, not C++ best
//practices...
void hello();

int main()
{
	hello();
}
```

这里最主要的是这块
```Makefile
a=0
AC_CHECK_HEADERS(zlib.h, [], [a=1])
AC_SEARCH_LIBS(deflate, z, [], [a=1])

if test $a == 0
then
	object_files="$object_files hello_libz.o"
else
	object_files="$object_files hello_no_libz.o"
fi
```

__AC_SEARCH_LIBS__ 会检测libz库是否存在，测试原理是通过 __AC_CHECK_LIB(m,cos)__ 宏，这个宏会生成如下测试代码

```c
char cos (); 
int main ()
{   
    cos ();
	return 0;
}
```

参数一:测试的函数  
参数二:测试的库  
参数三:成功操作  
参数四:失败操作  

### 四、__条件编译__

makefile.in

```Makefile
CXX=@CXX@
LD=@CXX@
CXXFLAGS=@CXXFLAGS@
LDFLAGS=@LDFLAGS@
LIBS=@LIBS@

program: program.o
	$(LD) -o $@ $^ $(LDFLAGS) $(LIBS)

.PHONY: clean
clean:
	rm -f program *.o
```

config.in
```c++
#ifndef INCLUDE_CONFIG_H_df90858
#define INCLUDE_CONFIG_H_df90858

#undef HAVE_ZLIB

#endif
```
configure.ac
```
AC_INIT(program, 1.0)

dnl Switch to a C++ compiler, and check if it works.
AC_LANG(C++)
AC_PROG_CXX


a=0
AC_CHECK_HEADERS(zlib.h, [], [a=1])
AC_SEARCH_LIBS(deflate, z, [], [a=1])

if test $a == 0
then
	AC_DEFINE(HAVE_LIBZ)
fi


AC_CONFIG_HEADERS(config.h)
AC_OUTPUT(Makefile)
```

program.cc
```c
#include <iostream>
#include "config.h"
using namespace std;


#ifdef HAVE_ZLIB
	#include <zlib.h>
	void hello()
	{
		//Output a string, compressed in gzip format.
		unsigned char in[] = "Hello, I am a program\n";
		unsigned char out[1024] = {};

		z_stream strm = {};
		deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 8+16, 9, Z_DEFAULT_STRATEGY);
		strm.next_in = in;
		strm.avail_in = sizeof(in);
		strm.next_out = out;
		strm.avail_out = sizeof(out);
		deflate(&strm, Z_FINISH);
		deflateEnd(&strm);

		cout.write((const char*)out, strm.total_out);
	}
#else
	void hello()
	{
		char data[]={0x1f,0x8b,0x08,0x00,0x00,0x00,0x00,0x00,0x00,
					 0x03,0xf3,0x48,0xcd,0xc9,0xc9,0xd7,0x51,0xf0,
					 0x54,0x48,0xcc,0x55,0x48,0x54,0x28,0x28,0xca,
					 0x4f,0x2f,0x4a,0xcc,0xe5,0x62,0x00,0x00,0x45,
					 0x29,0xde,0xb8,0x17,0x00,0x00,0x00};

		cout.write(data, sizeof(data));
	}
#endif

int main()
{
	hello();
}
```

这种方式需要写一个config.in配置文件用来生成，config.h，比如如果libz存在会注释 #undef HAVE_ZLIB 并添加 #define HAVE_ZLIB。

Avoid config.h as much as possible. Disadvantages are:

1. Every file depending on config.h must be rebuilt if config.h changes even if the change is irrelevant.
2. Conditional compilation is ugly and can lead to tangled messes of dead code.
3. It's generally good practice to avoid the preprocessor where possible.
4. If you're building a library and you've got a config.h included from the public headers, then everything using the library has to be rebuilt if config.h changes.
6. More source files means better parallel builds.

以上是针对不存在库的两种使用方式，建议使用第一种，第二种有以上缺点。

以上其实就够用了，但是也有一些扩展使用，比如--with --enable等，这里举个例子

### 五、__扩展__
Makefile.in  
```Makefile
CXX=@CXX@
LD=@CXX@
CXXFLAGS=@CXXFLAGS@
LDFLAGS=@LDFLAGS@
LIBS=@LIBS@

objs=@objs@

program: program.o $(objs)
	$(LD) -o $@ $^ $(LDFLAGS) $(LIBS)

.PHONY: clean
clean:
	rm -f program *.o
```
configure.ac
```
AC_INIT(program, 1.0)

dnl Switch to a C++ compiler, and check if it works.
AC_LANG(C++)
AC_PROG_CXX

dnl List of object files as determined by autoconf
object_files=""

AC_ARG_WITH(zlib, [AS_HELP_STRING([--without-zlib], [do not use zlib])])

zlib_objs=hello_no_libz.o
if test "$with_zlib" != no
then
	a=0
	AC_CHECK_HEADERS(zlib.h, [], [a=1])
	AC_SEARCH_LIBS(deflate, z, [], [a=1])

	if test $a == 0
	then
		zlib_objs=hello_libz.o
	fi
fi

object_files="$object_files $zlib_objs"

dnl Make AC_OUTPUT substitute the contents of $object_files for @objs@
AC_SUBST(objs, ["$object_files"])

dnl Process Makefile.in to create Makefile
AC_OUTPUT(Makefile)
```

hello_libz.cc  
```c++
#include <iostream>
#include <zlib.h>

using namespace std;

void hello()
{
	//Output a string, compressed in gzip format.
    unsigned char in[] = "Hello, I am a program\n";
	unsigned char out[1024] = {};

    z_stream strm = {};
    deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 8+16, 9, Z_DEFAULT_STRATEGY);
	strm.next_in = in;
	strm.avail_in = sizeof(in);
	strm.next_out = out;
	strm.avail_out = sizeof(out);
	deflate(&strm, Z_FINISH);
	deflateEnd(&strm);

	cout.write((const char*)out, strm.total_out);
}
```

hello_no_libz.cc
```c++
#include <iostream>

using namespace std;

void hello()
{
	char data[]={0x1f,0x8b,0x08,0x00,0x00,0x00,0x00,0x00,0x00,
	             0x03,0xf3,0x48,0xcd,0xc9,0xc9,0xd7,0x51,0xf0,
				 0x54,0x48,0xcc,0x55,0x48,0x54,0x28,0x28,0xca,
				 0x4f,0x2f,0x4a,0xcc,0xe5,0x62,0x00,0x00,0x45,
				 0x29,0xde,0xb8,0x17,0x00,0x00,0x00};

	cout.write(data, sizeof(data));
}
```

progarm.cc这个同上 都一样。  

这里修改了以下内容
```
AC_ARG_WITH(zlib, [AS_HELP_STRING([--without-zlib], [do not use zlib])])

zlib_objs=hello_no_libz.o
if test "$with_zlib" != no
then
	a=0
	AC_CHECK_HEADERS(zlib.h, [], [a=1])
	AC_SEARCH_LIBS(deflate, z, [], [a=1])

	if test $a == 0
	then
		zlib_objs=hello_libz.o
	fi
fi
```
这里可以使用--with-zlib 或者--without-zlib 来选择是否使用zlib库。   
以上意思是，判断with-zlib是否为no, 默认是yes


这里记录比较好的学习网站  
例子:https://github.com/edrosten/autoconf_tutorial/blob/eb95160b15ca6133ffb5ffc5ee17fdab08fecfdc/README.md    
变量说明:http://darktea.github.io/notes/2012/06/24/autotools.html  
官网:https://www.gnu.org/software/autoconf/manual/autoconf.html  
https://blog.csdn.net/romandion/article/details/1688234#TOC9  
