title: 制作一个 python egg
date: 2013-04-11 22:06:51
tags: python
---

最近用 Python 写了一个公共的库，然后我想让它能够像平常使用 pip 安装第三方库一样方便的安装。然后就去研究了一下 python 是如何打包的，更确切的说是适合用于 pip 安装的打包方式。

首先创建一个项目文件夹，这个项目文件夹的结构如下：

```
helloworld/
    helloworld/
        __init__.py
        foo.py
    setup.py
    README.md
```

<!-- more -->

在 foo.py 中顶一个简单的函数

```
def sayHello():
    print 'Hello World!'
```

然后就是 setup.py 文件，他是创建 egg 的配置文件

```
import distutils.core

version = '0.1'

distutils.core.setup(
    name='helloworld',
    version=version,
    packages=['helloworld'],
    author='jKey Lu',
    author_email='i@jkey.lu',
    url='https://blog.jkey.lu/2013/04/11/create-python-egg/',
    license='http://opensource.org/licenses/mit-license.php',
    description='Create Python Egg'
    )
```

更多关于 distutils.core.setup 中的参数可以看这里：[Additional meta-data](http://docs.python.org/2/distutils/setupscript.html#additional-meta-data)

接下来就是我们最终想要的，就是打包了，其实这是最简单的一条命令

```
python setup.py sdist
```

上面命令回车后，看看我们的项目文件夹有何变化

1. 多了一个 dist/ 文件夹，里面 helloworld-0.1.zip 就是我们生成的包
2. 多了个 MANIFEST 文件，这是打包这个命令自动生成的。你会发现文件里列出的文件名称和打包进 helloworld-0.1.zip 中的文件是一样的

```
helloworld/
    helloworld/
        __inti__.py
        foo.py
    dist/
        helloworld-0.1.zip
    MANIFEST
    setup.py
    README.md
```

接下来我们用 pip 安装刚刚打包完成的包

```
pip install dist/helloworld-0.1.zip
```

在 IDEL 中验证一下刚安装的包是否成功，很显然是成功了

```
from helloworld.foo import sayHello
sayHello() # Hello World!
```

写到这里差不多该结束，等等，发现 helloworld-0.1.zip 中没有 README.md 文件，想打包的时候一起包含进去咋办？

在项目文件夹中添加 MANIFEST.in 文件，是不是和打包命令自动生成的 MANIFEST 文件有点像，多了个文件扩展名，其实 MANIFEST.in 是 MANIFEST 的模板。关于这个文件的详细信息可以看着里 [The MANIFEST.in template](http://docs.python.org/2/distutils/sourcedist.html#the-manifest-in-template)

下面是 MANIFEST.in 中的内容

```
include README.md
```

重新打包一下，helloworld-0.1.zip 中就包含 README.md 文件了。

可能你会注意到我打包后生成的文件是 zip 压缩包，这是因为我在 windows 上大的包，如果在 linux 上打包，默认生成的是 tar.gz 的压缩包。问题：如果想在 windows 上也生成 tar.gz 的包该如何？

```
python setup.py sdist --formats=gztar
```

更多关于生成的格式看这里 [Create a Source Distribution](http://docs.python.org/2/distutils/sourcedist.html#creating-a-source-distribution)

