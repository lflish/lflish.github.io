---
layout: post
title: 内核链表
date: 2019-05-08 13:26:10
tags: hlist
categories: linux
---

### 内核hlist链表
原先研究过内核的链表，也写过测试用例，但是最近做主机防护，回过头来用竟然又忘记了。这里记录一下。

<!--more-->
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "hlist.h"

typedef struct wd_maps{
	int wd;
	char *dir_name;
	char *file_name;
	struct hlist_node h_node;
}wd_maps_s;

#define WD_MAPS_SIZE (sizeof(wd_maps_s))
//#define HASH_NUM 	0xFF
#define HASH_NUM 	0x0F
#define MALLOC malloc

static struct hlist_head wd_tables[HASH_NUM] = {{0}};

static unsigned int hash_fun(unsigned int wd)
{
	return wd & HASH_NUM;
}

int add_wd(int wd, const char *dir_name, const char *file_name)
{
	wd_maps_s *pos = MALLOC(WD_MAPS_SIZE);
	memset(pos, 0, WD_MAPS_SIZE);


	pos->wd = wd;

	if(dir_name != NULL){
		pos->dir_name = malloc(strlen(dir_name + 1));
		strcpy(pos->dir_name, dir_name);
	}

	if(file_name != NULL){

		pos->file_name = malloc(strlen(file_name + 1));
		strcpy(pos->file_name, file_name);
	}
	
	hlist_add_head(&pos->h_node, &wd_tables[hash_fun(wd)]);
}

int test()
{
	int n = 20;
	int i = 0;
	
	// add
	for(; i < n; i++){
		char buf[1024] = {0};
		sprintf(buf, "filename = %d_.txt", i);
		add_wd(i, buf, NULL);
	}


	printf("***********************************add**********************************************************\n");
	//list 
	for(i = 0; i < HASH_NUM; i++){
		struct hlist_node *pos = NULL;
		wd_maps_s *tpos = NULL;
		hlist_for_each_entry( tpos, pos, &wd_tables[i], h_node){
			printf("%d = %s\n", tpos->wd, tpos->dir_name);
		}
	}

	// del
	for(i = 0; i < HASH_NUM; i++){

		struct hlist_node *pos, *n = NULL;

		hlist_for_each_safe(pos, n, &wd_tables[i]){
				__hlist_del(pos);
				/*注意，这里没做释放，只是在链表中删除罢了*/
		}
	}

	printf("***********************************del**********************************************************\n");

	//list 
	for(i = 0; i < HASH_NUM; i++){
		struct hlist_node *pos = NULL;
		wd_maps_s *tpos = NULL;
		hlist_for_each_entry( tpos, pos, &wd_tables[i], h_node){
			printf("%d = %s\n", tpos->wd, tpos->dir_name);
		}
	}

	printf("***********************************end**********************************************************\n");
}

int main()
{
	test();

	return 0;

}
```

### 为什么pprev用二级指针
```c
struct hlist_head {
        struct hlist_node *first;
};

struct hlist_node {
        struct hlist_node *next;
	struct hlist_node *pprev;
};

static inline void __hlist_del(struct hlist_node *n)
{
        struct hlist_node *next = n->next;
        struct hlist_node *pprev = n->pprev;


	//问题来了 如果这里n是第一个节点，那么pprev就是NULL
	//第二个节点如何转变为第一个节点呢，无能为力,除非把头结点也传过来
        pprev->next = next;

        if (next)
                next->pprev = pprev;
}

static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
{
        struct hlist_node *first = h->first;
        n->next = first;
        if (first)
                first->pprev = n;
        h->first = n;

	//这里就要出问题了，ppre指向的是(struct hlist_node*)类型， 然而h的类型是 hlist_head
	//或者这里就不来设定第一个节点的pprev了
	//单单这里来说 已经可以有拒绝 *ppre的类型而改用 **ppre了，因为第一个节点的ppre是NULL的用
        n->pprev = &h->first;
}
```
源码点[**这里**](https://github.com/lflish/initserver/tree/master/work/linux/hlist)
