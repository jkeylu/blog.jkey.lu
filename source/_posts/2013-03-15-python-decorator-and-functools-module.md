title: python 装饰器和 functools 模块
date: 2013-03-15 23:11:49
tags: python
---

什么是装饰器？
-------------

在 python 语言里第一次看到装饰器不免让人想到设计模式中的装饰模式——动态地给一个对象添加一些额外的职责，就增加功能来说，装饰模式比生成子类更为灵活。

好吧，python 中的装饰器显然和装饰模式毫无关系。那 python 中的装饰器到底是什么呢？

简而言之，装饰器提供了一种方法，在函数和类定义语句的末尾插入自动运行代码。python 中有两种装饰器：函数装饰器和类装饰器。

函数装饰器
----------

###简单的装饰器例子：

``` python
def decorator(F): # 装饰器函数定义
    print "I'm decorator"
    return F

@decorator
def foo():
    print 'Hello World!'
# 上面等价于 foo = decorator(foo)

foo()
"""
I'm decorator
Hello World!
"""

decorator(foo)() # 所以这里的输出与 foo() 相同
"""
I'm decorator
Hello World!
"""
```

从上面运行后结果看出，装饰器就是一个能够返回可调用对象（函数）的可调用对象（函数）。

<!-- more -->

###具有封闭作用域的装饰器

``` python
def decorator(func): # 装饰器函数
    print 'in decorator'
    def wrapper(*args):
        print 'in decorator wrapper'
        wrapper._calls += 1
        print "calls = %d" % (wrapper._calls)
        func(*args)
    wrapper._calls = 0
    return wrapper

@decorator
def foo(x, y):
    print "x = %d, y = %d" % (x, y)

foo(1, 2) # 第一次调用
"""
in decorator
in decorator wrapper
calls = 1
x = 1, y = 2
"""

foo(2, 3) # 第二次调用
"""
in decorator wrapper
calls = 2
x = 2, y = 3
"""
```

可以看出第一次调用 `foo(1, 2)` 时，相当于
```
foo = decorator(foo)
foo(1, 2)
```

第二次调用 `foo(2, 3)` 时 *foo* 已经为 *decorator(foo)* 的返回值了


再看看一个装饰器类来实现的：

``` python
class decorator: # 一个装饰器类
    def __init__(self, func):
        print 'in decorator __init__'
        self.func = func
        self.calls = 0
    def __call__(self, *args):
        print 'in decorator __call__'
        self.calls += 1
        print "calls = %d" % (self.calls)
        self.func(*args)

@decorator
def foo(x, y):
    print "x = %d, y = %d" % (x, y)

foo(1, 2) # 第一次调用
"""
in decorator __init__
in decorator __call__
calls = 1
x = 1, y = 2
"""

foo(2, 3) # 第二次调用
"""
in decorator __call__
calls = 2
x = 2, y = 3
"""
```

###装饰器参数

``` python
def decorator_wrapper(a, b):
    print 'in decorator_wrapper'
    print "a = %d, b = %d" % (a, b)
    def decorator(func):
        print 'in decorator'
        def wrapper(*args):
            print 'in wrapper'
            func(*args)
        return wrapper
    return decorator

@decorator_wrapper(1, 2) # 这里先回执行 decorator_wrapper(1, 2), 返回 decorator 相当于 @decorator
def foo(word):
    print word

foo('Hello World!')
"""
in decorator_wrapper
a = 1, b = 2
in decorator
in wrapper
Hello World!
"""
```

functools 模块
------------------

functools 模块中有三个主要的函数 partial(), update_wrapper() 和 wraps(), 下面我们分别来看一下吧。

### partial(func[,*args][, **keywords])

看源码时发现这个函数不是用 python 写的，而是用 C 写的，但是帮助文档中给出了用 python 实现的代码，如下：

``` python
def partial(func, *args, **keywords):
    def newfunc(*fargs, **fkeywords):
        newkeywords = keywords.copy()
        newkeywords.update(fkeywords)
        return func(*(args + fargs), **newkeywords)
    newfunc.func = func
    newfunc.args = args
    newfunc.keywords = keywords
    return newfunc
```

OK，可能一下子没看明白，那么继续往下看，看一下是怎么用的。我们知道 python 中有个 `int([x[,base]])` 函数，作用是把字符串转换为一个普通的整型。如果要把所有输入的二进制数转为整型，那么就要这样写 `int('11', base=2)`。这样写起来貌似不太方便，那么我们就能用 partial 来实现值传递一个参数就能转换二进制数转为整型的方法。

``` python
from functools import partial
int2 = partial(int, base=2)

print int2('11') # 3
print int2('101') # 5
```

### update_wrapper(wrapper, wrapped[, assigned][, updated])

看这个函数的源代码发现，它就是把被封装的函数的 __module__, __name__, __doc__ 和 __dict__ 复制到封装的函数中去，源码如下，很简单的几句：

```
WRAPPER_ASSIGNMENTS = ('__module__', '__name__', '__doc__')
WRAPPER_UPDATES = ('__dict__',)
def update_wrapper(wrapper,
                   wrapped,
                   assigned = WRAPPER_ASSIGNMENTS,
                   updated = WRAPPER_UPDATES):
    for attr in assigned:
        setattr(wrapper, attr, getattr(wrapped, attr))
    for attr in updated:
        getattr(wrapper, attr).update(getattr(wrapped, attr, {}))
    return wrapper
```

具体如何用我们可以往下看一下。

### wraps(wrapped[, assigned][, updated])

wraps() 函数把用 partial() 把 update_wrapper() 给封装了一下。

```
def wraps(wrapped,
          assigned = WRAPPER_ASSIGNMENTS,
          updated = WRAPPER_UPDATES):

    return partial(update_wrapper, wrapped=wrapped,
                   assigned=assigned, updated=updated)
```

好，接下来看一下是如何使用的，这才恍然大悟，一直在很多开源项目的代码中看到如下使用。

```
from functools import wraps
def my_decorator(f):
     @wraps(f)
     def wrapper(*args, **kwds):
         print 'Calling decorated function'
         return f(*args, **kwds)
     return wrapper

@my_decorator
def example():
    """这里是文档注释"""
    print 'Called example function'

example()

# 下面是输出
"""
Calling decorated function
Called example function
"""
print example.__name__ # 'example'
print example.__doc__ # '这里是文档注释'
```
