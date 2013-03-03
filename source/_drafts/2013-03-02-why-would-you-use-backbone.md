title: 为什么使用 Backbone.js ？
date: 2013-03-02 11:39:58
tags: backbone
---

虽然现在 [jQuery](http://jquery.com/) 或 [MooTools](http://mootools.net/) 这类的类库很大程度上方便了我们，但是当我们尝试去用这些类库工具来构建一个单页面的 web 程序或者一个有着比较复杂 UI 的网站，这就往往会变得非常复杂。问题是什么？问题是这些 JS 类库精于 what they do - 就是说最终你的 web 应用虽然很完整，但是可能会无意中忽略了结构化，维护起来就比较麻烦了。可能你很熟练的不费吹灰之力就能够用 jQuery 创建一个应用，但是这个应用可能会包含一堆嵌套的回调函数，并且与页面上的 DOM 节点有着相当紧密的联系。

我觉得我不需要解释为何不用任何良好的结构来创建网站一定不是一个好主意的原因。当然，你也可以创造你自己的方式来组织你的 web 应用，但你也将会错过开源社区带来的好处。

为什么未来将更流行单页面网站
----------------------------
Backbone.js 强制完全使用 RESTful API 来和服务器通信。现在 web 的趋势是所有的 data/content 都会通过一个 API 输出。
This is because the browser is no longer the only client, we now have mobile devices, tablet devices, Google Goggles and electronic fridges etc.


那么 Backbone.js 将如何帮助我们？
--------------------------------


其他框架
--------
如果你正想创建单页面的应用，并在寻找对比各个框架，那么你可以戳一下下面这些链接：

* [A feature comparison of different frontend frameworks](http://codebrief.com/2012/01/the-top-10-javascript-mvc-frameworks-reviewed/)
* [Todo MVC - Todo list implemented in the many different types of frontend frameworks](http://addyosmani.github.com/todomvc/)