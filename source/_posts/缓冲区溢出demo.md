---
layout: post
title: first_shellcode
date: 2018-09-12 22:35:59
tags: 渗透
categories: 安全分析
---
# 缓冲区溢出攻击入门

*系统环境: ubuntu 16.04 32位*  

有如下C测试程序

```c
//vuln.c
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
        /* [1] */ char buf[256];
        /* [2] */ strcpy(buf,argv[1]);
        /* [3] */ printf("Input:%s\n",buf);
        return 0;
}
```

显然以上代码存在缓冲区漏洞，当argv[1]中数据过长，会造成buf数组溢出，覆盖EIP寄存器。
