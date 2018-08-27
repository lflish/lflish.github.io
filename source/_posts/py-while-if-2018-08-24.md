---
layout: post
title: python判断与循环
date: 2018-08-24 04:39:40
tags: python
---
## 条件判断

#### 一般格式
```python
if <test1>:           # if test    
   <statements1>      # Associated block
elif <test2>:         # Optional elifs    
    <statements2>
else:                 # Optional else    
    <statements3>
```

<!--more-->

#### if/else三元表达式

```
    A = Y if X else Z
```

#### 例子
```python
#一般格式
>>> if choice == 'spam':
...     print(1.25)
... elif choice == 'ham':
...     print(1.99)
... elif choice == 'eggs':
...     print(0.99)
... elif choice == 'bacon':
...     print(1.10)
... else:
...     print('Bad choice')

#三元表达式
>>> A = 't' if '' else 'f'
>>> A
'f'

```


## 循环

#### while 一般格式

```python
while <test>:           # Loop test    
    <statements1>       # Loop body
else:                   # Optional else   
    <statements2>       # Run if didn't exit loop with break
```

- break跳出最近所在的循环（跳过整个循环语句）。

- continue跳到最近所在循环的开头处（来到循环的首行）。

- pass什么事也不做，只是空占位语句。  
  *版本差异提示：Python 3.0（而不是Python 2.6）允许在可以使用表达式的任何地方使用...（三个连续的点号）来省略代码。*

- 循环else块只有当循环正常离开时才会执行（也就是没有碰到break语句）。

#### while 一般格式
```python
while <test1>:   
    <statements1>   
    if <test2>: break     # Exit loop now, skip else   
    if <test3>: continue  # Go to top of loop now, to test1
else:   
    <statements2>         # Run if we didn't hit a 'break'
```

#### while 例子
```python
while x:                   # Exit when x empty    
    if match(x[0]):        
        print('Ni')        
        break              # Exit, go around else    
    x = x[1:]
else:    
    print('Not found')     # Only here if exhausted x
```

#### for 一般格式

```python
for <target> in <object>:      # Assign object items to target    
    <statements>    
    if <test>: break           # Exit loop now, skip else    
    if <test>: continue        # Go to top of loop now
else:    
    <statements>               # If we didn't hit a 'break'
```

#### for 例子
```python
#列表
>>> for x in ["spam", "eggs", "ham"]:
...     print(x, end=' ')
...spam eggs ham

#字符串
S = "lumberjack"
>>> for x in S: print(x, end=' ')   # Iterate over a string...l u m b e r j a c k

#元组
>>> T = [(1, 2), (3, 4), (5, 6)]
>>> for (a, b) in T:                   # Tuple assignment at work
...     print(a, b)
...1 2
   3 4
   5 6

#字典
>>> D = {'a': 1, 'b': 2, 'c': 3}
>>> for key in D:
...    print(key, '=>', D[key])          # Use dict keys iterator and index
...a => 1
   c => 3
   b => 2

#items返回可遍历的(键, 值) 元组数组，所以字典也可以这样遍历。
>>> for (key, value) in D.items():
...    print(key, '=>', value)            # Iterate over both keys and values
...a => 1
   c => 3
   b => 2
   
#分片循环   
>>> S = 'abcdefghijk'
>>> for c in S[::2]: 
    print(c, end=' ')
...a c e g i k

# python3 扩展
>>> for (a, *b, c) in [(1, 2, 3, 4), (5, 6, 7, 8)]:
...    print(a, b, c)
...1 [2, 3] 4
   5 [6, 7] 8
```

#### range 迭代器
range是一个迭代器，会根据需要产生元素

```python
>>> list(range(-5, 5))
[-5, -4, -3, -2, -1, 0, 1, 2, 3, 4]

>>> list(range(0, len(S), 2))
[0, 2, 4, 6, 8, 10]

>>> for i in range(3):
...     print(i, 'Pythons')
...0 Pythons
   1 Pythons
   2 Pythons
 
# 修改列表
>>> L = [1, 2, 3, 4, 5]
>>> for i in range(len(L)):     # Add one to each item in L
...     L[i] += 1               # Or L[i] = L[i] + 1
...
>>> L
[2, 3, 4, 5, 6]
   
```

#### zip 并行迭代器
```python
>>> L1 = [1,2,3,4]
>>> L2 = [5,6,7,8]

>>> zip(L1, L2)
<zip object at 0x026523C8>

>>> list(zip(L1, L2))             # list() required in 3.0, not 2.6
[(1, 5), (2, 6), (3, 7), (4, 8)]

>>> for (x, y) in zip(L1, L2):
...     print(x, y, '--', x+y)
...1 5 -- 6
   2 6 -- 8
   3 7 -- 10
   4 8 -- 12
```

#### 通过zip构建字典
```python
# python2.2 before
>>> keys = ['spam', 'eggs', 'toast']
>>> vals = [1, 3, 5]
>>> list(zip(keys, vals))[('spam', 1), ('eggs', 3), ('toast', 5)]
>>> D2 = {}
>>> for (k, v) in zip(keys, vals): D2[k] = v
...

>>> D2
{'toast': 5, 'eggs': 3, 'spam': 1}

#python 2.2 later
>>> keys = ['spam', 'eggs', 'toast']
>>> vals = [1, 3, 5]
>>> D3 = dict(zip(keys, vals))

>>> D3
{'toast': 5, 'eggs': 3, 'spam': 1}
```

#### enumerate函数
*enumerate函数返回一个生成器，对象简而言之，这个对象有一个__next__方法，由下一个内置函数调用它，并且循环中每次迭代的时候它会返回一个(index,value)的元组。*
```python
>>> S = 'spam'
>>> for (offset, item) in enumerate(S):
...     print(item, 'appears at offset', offset)
...s appears at offset 0
   p appears at offset 1
   a appears at offset 2
   m appears at offset 3
```

