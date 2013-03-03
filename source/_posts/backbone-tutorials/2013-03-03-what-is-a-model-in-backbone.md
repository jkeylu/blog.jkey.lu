title: Backbone.js 中的 model 是什么？
date: 2013-03-03 13:55:58
tags: backbone
---

根据维基百科上对 [MVC](http://zh.wikipedia.org/wiki/MVC) 的定义，我们很难搞懂 model 到底是个什么东西。Backbone.js 的作者对 model 在 backbone.js 中的定义如下。

> Models are the heart of any JavaScript application, containing the interactive data as well as a large part of the logic surrounding it: conversions, validations, computed properties, and access control.

所以接下来让我们创建一个 model 来搞懂到底什么是 model。

``` javascript
var Person = Backbone.Model.extend({
    initialize: function () {
        alert('Welcome to this world');
    }
});
```

所以 *initialize()* 会在初始化 model 为一个新的实例时被触发（models, collections 和 views 都是一样的）。当然你可以在写你的 model 时不写初始化函数，但是你会发现你会很平凡的使用它。

<!-- more -->

设置属性
--------

然后我们想在实例化一个 model 时传递一些参数给它。

``` javascript
var Person = Backbone.Model.extend({
    initialize: function () {
        alert('Welcome to this world');
    }
});

var person = new Person({name: 'Thomas', age: 67});
// 或者我们可以在实例化以后设置，这两个操作是相同的
var person = new Person();
person.set({name: 'Thomas', age: 67});
```

所以调用 *model.set()* 和给构造函数传递一个 JavaScript 对象的效果是相同的。当我们设置了 models 的属性后，我们接下来看看如何去获取它们。

获取属性
--------

使用 *model.get()* 方法来获取 model 实例的属性。

``` javascript
var Person = Backbone.Model.extend({
    initialize: function () {
        alert('Welcome to this world');
    }
});

var person = new Person({name: 'Thomas', age: 67, child: 'Ryan'});

var age = person.get('age'); // 67
var name = person.get('name'); // 'Thomas'
var child = person.get('child'); // 'Ryan'
```

设置 model 的默认值
-------------------

有时候你想实例化 model 后就有默认值。其实，这也很简单，只要在你定义 model 时设置名字为 'defaults' 的属性。

``` javascript
var Person = Backbone.Model.extend({
    defaults: {
        name: 'Fetus',
        age: 0,
        child: ''
    },
    initialize: function () {
        alert('Welcome to this world');
    }
});

var person = new Person({name: 'Thomas', age: 67, child: 'Ryan'});

var age = person.get('age'); // 67
var name = person.get('name'); // 'Thomas'
var child = person.get('child'); // 'Ryan'
```

操作 model 属性
---------------

在 models 中可以自定义方法来操作相关属性。默认所有方法都是公共可访问的。

``` javascript
var Person = Backbone.Model.extend({
    defaults: {
        name: 'Fetus',
        age: 0,
        child: ''
    },
    initialize: function (){
        alert("Welcome to this world");
    },
    adopt: function (newChildsName) {
        this.set({child: newChildsName});
    }
});

var person = new Person({ name: "Thomas", age: 67, child: 'Ryan'});
person.adopt('John Resig');
var child = person.get("child"); // 'John Resig'
```

显而易见，我们能用自定义方法来实现 get/set 操作，也可以执行一些其他会使用到 model 中属性的计算。

监听 model 中值改变的事件
-------------------------

``` javascript
var Person = Backbone.Model.extend({
    defaults: {
        name: 'Fetus',
        age: 0
    },
    initialize: function () {
        alert('Welcome to this world');
        this.on('change:name', function (model) {
            var name = model.get('name'); // 'Stewwie Griffin'
            alert('Change my name to ' + name);
        });
    }
});

var person = new Person({name: 'Thomas', age: 67});
person.set({name: 'Stewie Griffin'}); // 这会触发一个 change 事件
```

可以看到我们可以为个别属性单独绑定事件监听者，或者直接 `this.on('change', function (model) {});` 来监听所有属性改变的事件。

与服务器交互
------------

Models 是用来描述服务器端返回的数据和你对 RESTful URL 发送数据时的操作。

models 中属性 `id` 应该与数据库中映射的[代理键](http://zh.wikipedia.org/wiki/%E5%85%B3%E7%B3%BB%E9%94%AE#.E4.BB.A3.E7.90.86.E9.8D.B5)相对应，一般我们都直接用主键，可以快速索引到我们要的数据。

假设我们的 mysql 数据库上有一张 `Users` 表，这张表中有三个字段，分别为 `id`, `name`, `email`。

并且服务器端已经实现了能够为我们提供数据的 RESTful URL, 地址为 `/user` 的 。

我们的 model 定义应该如下：

Models are used to represent data from your server and actions you perform on them will be translated to RESTful operations.

``` javascript
var UserModel = Backbone.Model.extend({
    urlRoot: '/user',
    default: {
        name: '',
        email: ''
    }
});
```

### 创建一个新的 model

``` javascript
var UserModel = Backbone.Model.extend({
    urlRoot: '/user',
    defaults: {
        name: '',
        email: ''
    }
});
var user = new UserModel();
// 注意我们没有设置 'id'
var userDetails = {
    name: 'Thomas',
    email: 'thomasalwyndavis@gmail.com'
};
// 由于我们没有设置 'id'，所以 backbone 会通过 POST /user
// 发送 a payload of {name: 'Thomas', email: 'thomasalwyndavis@gmail.com'}
// 服务器保存数据并返回一个包含 'id' 的响应
user.save(userDetails, {
    success: function (user) {
        alert(user.toJSON());
    }
});
```

我们数据库表中就有了一行数据:

1, 'Thomas', 'thomasalwyndavis@gmail.com'

### 获取一个 model 实例

现在我们数据表中就有了一条 user 的数据，我们就能够从服务器上获取了。从上面的例子中我们知道我们数据库中有一条 `id` 为 1 的数据行。

如果用 `id` 来实例化一个 model, Backbone.js 会自动请求 `urlRoot + '/id'`（遵循 RESTful 约定）。

``` javascript
// 我们在这里设置 'id'
var user = new UserModel({id: 1});

// 调用 fetch 会执行 GET /user/1 的请求
// 服务器应该返回 id, name 和 email
user.fetch({
    success: function (user) {
        alert(user.toJSON());
    }
});
```

### 更新一个 model

现在我们有了一个 model，并且这个 model 中的数据也存在于数据库中，这时我们就可以用 PUT 请求来执行更新操作。我们依旧调用 `save` 函数保存更新数据，这时 Backbone.js 会很智能的用 PUT 请求来代替 POST 请求如果在 `id` 设置了的情况下（遵循 RESTful 约定）。

``` javascript
// 在这里我们设置了 'id'
var user = new UserModel({
    id: 1,
    name: 'Thomas',
    email: 'thomasalwyndavis@gmail.com'
});

// 让我们修改一下 name 属性的值并且更新它
// 由于设置了 'id', Backbone.js 会发送
// PUT /user/1 with a payload of {name: 'Davis', email: 'thomasalwyndavis@gmail.com'}
user.save({name: 'Davis'}, {
    success: function (model) {
        alert(user.toJSON());
    }
});
```

### 删除一个 model

当我们有一个设置了 `id` 的 model，并且知道服务器上有一条与这个 `id` 对应的数据，那么如果我们想把它从数据库中删除时就可以调用 `destroy` 函数。

`destroy` 会发送 DELETE /user/id 的请求（遵循 RESTful 约定）。

``` javascript
// 这里我们设置了 'id'
var user = new UserModel({
    id: 1,
    name: 'Thomas',
    email: 'thomasalwyndavis@gmail.com'
});

// 由于我们设置了 'id', 所以 Backbone.js 会发送
// DELETE /user/1
user.destroy({
    success: function () {
        alert('Destroyed');
    }
});
```

### 提示和小窍门

_获取所有当前属性_

``` javascript
var person = new Person({name: 'Thomas', age: 67});
var attributes = person.toJSON(); // {name: 'Thomas', age: 67}
/* 这是简单直接的返回所有属性的一份拷贝 */

var attributes = person.attributes;
/*
通过上面一行的写法，我们可以获得 model 中 attributes 属性的应用，这时我们应该小心的操作它。
最佳实践是我们建议使用 .set() 来修改 model 中属性的值，这样也可以触发 backbone 的事件。
*/
```

_在设置或保存数据前进行验证_

``` javascript
var Person = Backbone.Model.extend({
    // 如果你在验证函数中返回一个字符串
    // Backbone 将会抛出一个包含你返回的字符串的错误对象
    validate: function (attributes) {
        if (attributes < 0 && attributes.name != 'Dr Manhatten') {
            return 'You can not be negative years old';
        }
    },
    initialize: function () {
        alert('Welcome to this world');
        this.bind('error', function (model, error) {
            // 在这里我们可以接收错误，记录它。
            alert(error);
        });
    }
});

var person = new Person();
person.set({name: 'Mary Poppins', age: -1});
// 验证没有通过，会抛出错误

var person = new Person();
person.set({name: 'Dr Manhatten', age: -1});
```

我碰到的问题
------------

我用 `fetch` 来获取数据时，服务器端返回的数据不是完全一致的，这时候我就要重写 `parse` 函数。

``` javascript
/*
服务器端返回的数据格式：
{success: true, user: {id: 1, name: 'jKey', email: 'hello.world@gmail.com'}}
*/
var UserModel = Backbone.Model.extend({
    parse: function(resp, options) {
        return resp.user;
    }
});

var user = new UserModel({id: 1});

user.fetch({
    success: function (user) {
        alert(user.toJSON());
        // {id: 1, name: 'jKey', email: 'hello.world@gmail.com'}
    }
});
```

还有一个有用的，就是当你改变了一个属性的值后，又想获取之前那个值时，可以使用 `previous` 函数。

``` javascript
var bill = new Backbone.Model({name: 'Bill Smith'});

bill.on('change:name', function (model, name) {
    alert('Changed name from ' + bill.previous('name') + 'to' + name);
})

bill.set({name: 'Bill Jones'});
```

关于本文
--------

为了学习 Backbone.js，网上找到了 [http://backbonetutorials.com/](http://backbonetutorials.com/) 这个网站。所以，边翻译边学，记录下来也是为了加深记忆。

相关链接
--------

[What is a model?](http://backbonetutorials.com/what-is-a-model/)

[Backbone.Model](http://backbonejs.org/#Model)

基于版本：[9e4aba0af8](https://github.com/thomasdavis/backbonetutorials/tree/9e4aba0af8b56538e6cdda034770c4971a43c181)
