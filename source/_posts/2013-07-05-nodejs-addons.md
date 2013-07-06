title: Nodejs Addons
date: 2013-07-05 22:02:07
tags: nodejs
---

有时候仅仅用 javascript 并不能够实现我们想要的功能，比如说我最近买了一块 nokia 5110 的显示屏，想连在我的树莓派上显示一些有用的信息。而这块显示屏是 spi 接口的，树莓派上也是有 SPI 接口。但是我要对 SPI 接口写入信息传到显示屏上，就必须要用 c++ 来写，不是很方便。所以我就想写一个 nodejs 的 addon，最后可以实现 javascript 来与 SPI 总线进行通信。

所以，就要学习如何写一个 nodejs 的 addon，这篇文章完全参考 [http://nodejs.org/api/addons.html](http://nodejs.org/api/addons.html)

下面所有例子的代码可以从 [https://github.com/rvagg/node-addon-examples](https://github.com/rvagg/node-addon-examples) 下载到。

## Hello world

我们要写一个简单的模块，这个模块的 javascript 代码实现如下，目标是把他转换为 c++ 实现的 Addon。

```
exports.hello = function () { return 'world'; };
```

首先创建 `hello.cc`，内容如下：

```
#include <node.h>
#include <v8.h>

using namespace v8;

/**
 * "Method" 的名字可以任取，可以换成 "Hello"
 * 来对应 exports 的名称
 */
Handle<Value> Method(const Arguments& args) {
  HandleScope scope;
  return scope.Close(String::New("world"));
}

void Init(Handle<Object> exports) {
  exports->Set(String::NewSymbol("hello"),
    FunctionTemplate::New(Method)->GetFunction());
}

NODE_MODULE(hello, Init)
```

所有的 Node addons 必须输出一个初始化函数：

```
void Initialize(Handle<Object> exports);
NODE_MODULE(module_name, Initialize)
```
<!-- more -->

注意 `NODE_MODULE` 后面是没有分号的，因为他是一个宏 (see [node.h](https://github.com/joyent/node/blob/master/src/node.h))

`module_name` 需要和最终生成的二进制文件相同（不包括 .node 后缀）

为了把上面的 `hello.cc` 编译成 `hello.node` 二进制文件，我们要创建一个 `binding.gyp` 文件，它是用来描述你编译模块用到的配置，格式是 JSON 风格的。

```
{
  "targets": [
    {
      "target_name": "hello",
      "sources": [ "hello.cc" ]
    }
  ]
}
```

真正编译成二进制文件我们需要 [node-gyp](https://github.com/TooTallNate/node-gyp) 工具。

```
npm install -g node-gyp
```

安装好 node-gyp 后，先要生成与当前平台相关的项目生成文件。运行下面命令

```
node-gyp configure
```

然后你会发现在我的的项目文件夹中多出了一个 `build/` 文件夹，里面包含了 `Makefile` (linux 平台) 或 `vcxproj` (windows 平台) 文件。

然后运行

```
node-gyp build
```

编译完成后，可以在 `build/Release/` 下看到 `hello.node` 文件。

然后测试一下这个模块，创建 `hello.js` 文件，内容如下。执行 `node hello.js` 后看看是否会输出正确的结果。

```
var addon = require('./build/Release/hello');
console.log(addon.hello()); // 'world'
```

## Addon patterns

下面是一些 addon patterns 的例子。可以通过查阅 [v8 reference](http://izs.me/v8-docs/main.html) 和 [Embedder's Guide](http://code.google.com/apis/v8/embed.html) 获得更多帮助。

### Function arguments

javascript 实现：

```
exports.add = function (a, b) {
  if (arguments.length < 2) {
    throw new Error('Wrong number of arguments');
    return;
  }

  function isNum(s) {
    if (s!=null && s!='') {
      return !isNaN(s);
    }
    reutrn false;
  }

  if (!isNum(a) || !isNum(b)) {
    throw new Error('Wrong arguments');
    return;
  }

  return a + b;
};
```

c++ 实现：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>

using namespace v8;

Handle<Value> Add(const Arguments& args) {
  HandleScope scope;

  if (args.Length() < 2) {
    ThrowException(Exception::TypeError(String::New("Wrong number of arguments")));
    return scope.Close(Undefined());
  }

  if (!args[0]->IsNumber() || !args[1]->IsNumber()) {
    Throwexception(Exception::TypeError(String::New("Wrong arguments")));
    return scope.Close(Undefined());
  }

  Local<Number> num = Number::New(args[0]->NumberValue() +
      args[1]->NumberValue());
  return scope.Close(num);
}

void Init(Handle<Object> exports) {
  exports->Set(String::NewSymbol("add"),
      FunctionTemplate::New(Add)->GetFunction());
}

NODE_MODULE(addon, Init)
```

测试：

```
var addon = require('./build/Release/addon');
console.log('This should be eight: ', addon.add(3, 8));
```

### Callbacks

javascript 实现：

```
module.exports = function (cb) {
  cb('hello world');
};
```

c++ 实现：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>

using namespace v8;

Handle<Value> RunCallback(const Arguments& args) {
  HandleScope scope;

  Local<Function> cb = Local<Function>::Cast(args[0]);
  const unsigned argc = 1;
  Local<Value> argv[argc] = { Local<Value>::New(String::New("hello world")) };
  cb->Call(Context::GetCurrent()->Global(), argc, argv);

  return scope.Close(Undefined());
}

Void Init(Handle<Object> exports, Handle<Object> module) {
  module->Set(String::NewSymbol("exports"),
    FunctionTemplate::New(RunCallback)->GetFunction());
}

NODE_MODULE(addon, Init)
```

注意这个例子中 `Init()` 接收了两个参数，因为模块要直接暴露函数，和 javascript 一样。

```
function hello () {}

moudle.exports.hello = hello; // 通过模块的一个属性来暴露函数

module.exports = hello; // 暴露一个函数
```

测试：

```
var addon = require('./build/Release/addon');

addon(function (msg) {
  console.log(msg); // 'hello world'
});
```

### Object factory

javascript 实现：

```
module.exports = function (msg) {
  var obj = {};
  obj.msg = msg;
  return obj;
};
```

c++ 实现：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>

using namespace v8;

Handle<Value> CreateObject(const Arguments& args) {
  HandleScope scope;

  Local<Object> obj = Object::New();
  obj->Set(String::NewSymbol("msg"), args[0]->ToString());

  return scope.Close(obj);
}

void Init(Handle<Object> exports, Handle<Object> module) {
  module->Set(String::NewSymbol("exports"),
      FunctionTemplate::New(CreateObject)->GetFunction());
}

NODE_MODULE(addon, Init)
```

测试：

```
var addon = require('./build/Release/addon');

var obj1 = addon('hello');
var obj2 = addon('world');
console.log(obj1.msg + ' ' + obj2.msg); // 'hello world'
```

### Function factory

javascript 实现：

```
module.exports = function () {
  return function () {
    return 'hello world';
  };
};
```

c++ 实现：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>

using namespace v8;

Handle<Value> MyFunction(const Arguments& args) {
  HandleScope scope;
  return scope.Close(String::New("hello world"));
}

Handle<Value> CreateFunction(const Arguments& args) {
  HandleScope scope;

  Local<FunctionTemplate> tpl = FunctionTemplate::New(MyFunction); // 把 MyFunction 转换为对象实例
  Local<Function> fn = tpl->GetFunction();
  fn->SetName(String::NewSymbol("theFunction")); // 省略这句，变成匿名函数

  return scope.Close(fn);
}

void Init(Handle<Object> exports, Handle<Object> moduel) {
  module->Set(String::NewSymbol("exports"),
      FunctionTemplate::New(Createobject)->GetFunction());
}

NODE_MODULE(addon, Init)
```

测试：

```
var addon = require('./build/Release/addon');

var fn = addon();
console.log(fn()); // 'hello world'
```

### Wrapping C++ objects

javascript 实现：

```
function MyObject(count) {
  this.counter_ = count;
}

MyObject.prototype.plusOne = function () {
  this.counter_ += 1;
  return this.counter_;
};
```

c++ 实现：

`addon.cc` 文件：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>
#include "myobject.h"

using namespace v8;

void InitAll(Handle<Object> exports) {
  MyObject::Init(exports);
}

NODE_MODULE(addon, InitAll)
```

`myobject.h` 文件

```
#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <node.h>

class MyObject : public node::ObjectWrap {
  public:
    static void Init(v8::Handle<v8::Object> exports);

  private:
    MyObject();
    ~MyObject();

    static v8::Handle<v8::Value> New(const v8::Arguments& args);
    static v8::Handle<v8::Value> PlusOne(const v8::Arguments& args);

    double counter_;
};

#endif
```

`myobject.cc` 文件：

```
#define BUILDING_NODE_EXTENSION
#include <node.h>
#include "myobject.h"

using namespace v8;

MyObject::MYObject() {}
MyObject::~MYObject() {}

void MyObject::Init(Handle<Object> exports) {
  Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
  tpl->SetClassName(String::NewSymbol("MyObject"));
  tpl->InstanceTemplate()->SetInternalField(1);

  tpl->PrototypeTemplate()->Set(String::NewSymbol("plusOne"),
      FunctionTemplate::New(PlusOne)->GetFunction());

  Persistent<Function> constructor = Persistent<Function>::New(tpl->GetFunction());
  exports->Set(String::NewSymbol("MyObject"), constructor);
}

Handle<Value> MyObject::New(const Arguments& args) {
  HandleScope scope;

  MyObject* obj = new MyObject();
  obj->counter_ = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
  obj->Wrap(args.This());

  return args.This();
}

Handle<Value> MyObject::PlusOne(const Arguments& args) {
  HandleScope scope;

  MyObject* obj = ObjectWrap::Unwrap<MyObject>(args.This());
  obj->counter_ += 1;

  return scope.Close(Number::New(obj->counter_));
}
```

测试：

```
var addon = require('./build/Release/addon');

var obj = new addon.MyObject(10);
console.log(obj.plusOne()); // 11
console.log(obj.plusOne()); // 12
console.log(obj.plusOne()); // 13
```

