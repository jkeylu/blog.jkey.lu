title: tornado util 模块中的 Configurable 类
date: 2013-03-31 09:34:47
tags: tornado
---

简单的说 Configurable 就是让继承自它的子类的构造函数具有工厂函数一样的行为。意思是，只要一个类继承自 Configurable, 那么在这个类在实例化时，构造函数就像工厂一样来选择一个这个类的子类来实例化。

通常如果要继承 Configurable 接口，那么首先要实现 `configurable_base(cls)` 和 `configurable_default(cls)` 这两个静态方法。

在 tornado 中有三个类是继承自 Configurable 的，分别是 AsyncHttpClient, IOLoop 和 Resolver。

<!-- more -->

下面是 Configurable 类的主要代码：

``` python
class Configurable(object):
    __impl_class = None
    __impl_kwargs = None

    def __new__(cls, **kwargs):
        base = cls.configurable_base()
        args = {}
        if cls is base:
            impl = cls.configured_class()
            if base.__impl_kwargs:
                args.update(base.__impl_kwargs)
        else:
            impl = cls
        args.update(kwargs)
        instance = super(Configurable, cls).__new__(impl)

        # initialize vs __init__ 的选择是为了兼容 AsyncHTTPClient 单例模式的 magic。
        # 如果能摆脱它，那么这里我们也能切换到 __init__
        instance.initialize(**args)
        return instance

    @classmethod
    def configurable_base(cls):
        """返回继承于 Configurable 的基类

        一般这里直接返回这个类（但是不必须是和 cls 相同的类）
        """
        raise NotImplementedError()

    @classmethod
    def configurable_default(cls):
        """返回真正实现的类

        其实真正的工厂是在这里实现的
        """
        raise NotImplementedError()

    def initialize(self):
        """初始化一个 `Configurable` 子类的实例。

        Configurable 类应该用 `initialize` 来代替 ``__init__``
        """

    @classmethod
    def configured_class(cls):
        """返回当前配置完成的类。"""
        base = cls.configurable_base()
        if cls.__impl_class is None:
            base.__impl_class = cls.configurable_default()
        return base.__impl_class
```

这才明白为什么 tornado 应用在 main 最后调用 `tornado.ioloop.IOLoop.instance().start()` 就可以了选择和平台相关的 IOLoop 实现了。

下面就是 IOLoop 中的 `configurable_default(cls)` 定义
```
class IOLoop(Configurable):

    @classmethod
    def configurable_default(cls):
        if hasattr(select, "epoll"):
            from tornado.platform.epoll import EPollIOLoop
            return EPollIOLoop
        if hasattr(select, "kqueue"):
            # Python 2.6+ on BSD or Mac
            from tornado.platform.kqueue import KQueueIOLoop
            return KQueueIOLoop
        from tornado.platform.select import SelectIOLoop
        return SelectIOLoop
```
