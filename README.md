### Day1:请写出下面代码执行的的结果
```js
console.log(1);
setTimeout(() => {
  console.log(2);
  process.nextTick(() => {
    console.log(3);
  });
  new Promise((resolve) => {
    console.log(4);
    resolve();
  }).then(() => {
    console.log(5);
  });
});
new Promise((resolve) => {
  console.log(7);
  resolve();
}).then(() => {
  console.log(8);
});
process.nextTick(() => {
  console.log(6);
});
setTimeout(() => {
  console.log(9);
  process.nextTick(() => {
    console.log(10);
  });
  new Promise((resolve) => {
    console.log(11);
    resolve();
  }).then(() => {
    console.log(12);
  });
});
```

**答案**
node <11:1 7 6 8 2 4 9 11 3 10 5 12
node>=11:1 7 6 8 2 4 3 5 9 11 10 12

**解析**
- 宏任务和微任务
  - 宏任务：macrotask,包括setTimeout、setInerVal、setImmediate(node独有)、requestAnimationFrame(浏览器独有)、I/O、UI rendering(浏览器独有)
  - 微任务：microtask,包括process.nextTick(Node独有)、Promise.then()、Object.observe、MutationObserver
- Promise构造函数中的代码是同步执行的，new Promise()构造函数中的代码是同步代码，并不是微任务
- Node.js中的EventLoop执行宏队列的回调任务有**6个阶段**
  - 1.timers阶段：这个阶段执行setTimeout和setInterval预定的callback
  - 2.I/O callback阶段：执行除了close事件的callbacks、被timers设定的callbacks、setImmediate()设定的callbacks这些之外的callbacks
  - 3.idle, prepare阶段：仅node内部使用
  - 4.poll阶段：获取新的I/O事件，适当的条件下node将阻塞在这里
  - 5.check阶段：执行setImmediate()设定的callbacks
  - 6.close callbacks阶段：执行socket.on('close', ....)这些callbacks
- NodeJs中宏队列主要有4个
  - 1.Timers Queue
  - 2.IO Callbacks Queue
  - 3.Check Queue
  - 4.Close Callbacks Queue
  - 这4个都属于宏队列，但是在浏览器中，可以认为只有一个宏队列，所有的macrotask都会被加到这一个宏队列中，但是在NodeJS中，不同的macrotask会被放置在不同的宏队列中。
- NodeJS中微队列主要有2个
  - 1.Next Tick Queue：是放置process.nextTick(callback)的回调任务的
  - 2.Other Micro Queue：放置其他microtask，比如Promise等
  - 在浏览器中，也可以认为只有一个微队列，所有的microtask都会被加到这一个微队列中，但是在NodeJS中，不同的microtask会被放置在不同的微队列中。
- Node.js中的EventLoop过程
  - 1.执行全局Script的同步代码
  - 2.执行microtask微任务，先执行所有Next Tick Queue中的所有任务，再执行Other Microtask Queue中的所有任务
  - 3.开始执行macrotask宏任务，共6个阶段，从第1个阶段开始执行相应每一个阶段macrotask中的所有任务，注意，这里是所有每个阶段宏任务队列的所有任务，在浏览器的Event Loop中是只取宏队列的第一个任务出来执行，每一个阶段的macrotask任务执行完毕后，开始执行微任务，也就是步骤2
  - 4.Timers Queue -> 步骤2 -> I/O Queue -> 步骤2 -> Check Queue -> 步骤2 -> Close Callback Queue -> 步骤2 -> Timers Queue ......
  - 5.这就是Node的Event Loop
- Node 11.x新变化
  - 现在node11在timer阶段的setTimeout,setInterval...和在check阶段的immediate都在node11里面都修改为一旦执行一个阶段里的一个任务就立刻执行微任务队列。为了和浏览器更加趋同.



### Day2:写出执行结果
```js
function side(arr) {
  arr[0] = arr[2];
}
function a(a, b, c = 3) {
  c = 10;
  side(arguments);
  return a + b + c;
}
a(1, 1, 1);
```

**答案**
12

**解析**
arguments 中 c 的值还是 1 不会变成 10，  
因为 a 函数加了默认值，就按 ES 的方式解析，ES6 是有块级作用域的，所以 c 的值是不会改变的

### Day3:写出执行结果
```js
var min = Math.min();
max = Math.max();
console.log(min < max);
```

**答案**
false

**解析**

- 按常规的思路，这段代码应该输出 true，毕竟最小值小于最大值。但是却输出 false  
- MDN 相关文档是这样解释的  
  - Math.min 的参数是 0 个或者多个，如果多个参数很容易理解，返回参数中最小的。如果没有参数，则返回 Infinity，无穷大。  
  - 而 Math.max 没有传递参数时返回的是-Infinity.所以输出 false  

### Day4:写出执行结果,并解释原因
```js
var a = 1;
(function a () {
    a = 2;
    console.log(a);
})();

```

**答案**
```js
ƒ  a () {
      a = 2;
      console.log(a);
 }
```

**解析**
立即调用的函数表达式（IIFE） 有一个 自己独立的 作用域，如果函数名称与内部变量名称冲突，就会永远执行函数本身；所以上面的结果输出是函数本身；

### Day5:写出执行结果,并解释原因
```js
var a = [0];
if (a) {
  console.log(a == true);
} else {
  console.log(a);
}
```

**答案**
false

**解析**
1）当 a 出现在 if 的条件中时，被转成布尔值，而 Boolean([0])为 true,所以就进行下一步判断 a == true,在进行比较时，[0]被转换成了 0，所以 0==true 为 false
数组从非 primitive 转为 primitive 的时候会先隐式调用 join 变成“0”，string 和 boolean 比较的时候，两个都先转为 number 类型再比较，最后就是 0==1 的比较了
```js
var a = [1];
if (a) {
  console.log(a == true);
} else {
  console.log(a);
}
// true
```
```js
!![] //true 空数组转换为布尔值是 true,  
!![0]//true 数组转换为布尔值是 true  
[0] == true;//false 数组与布尔值比较时却变成了 false  
Number([])//0  
Number(false)//0  
Number(['1'])//1
```

2）所以当 a 出现在 if 的条件中时，被转成布尔值，而 Boolean([0])为 true,所以就进行下一步判断 a == true,在进行比较时，js 的规则是：
①如果比较的是原始类型的值，原始类型的值会转成数值再进行比较
```js
1 == true  //true   1 === Number(true)
'true' == true //false Number('true')->NaN  Number(true)->1
'' = 0//true
'1' == true//true  Number('1')->1
```
②对象与原始类型值比较，对象会转换成原始类型的值再进行比较。
③undefined和null与其它类型进行比较时，结果都为false，他们相互比较时结果为true。

### Day6:写出执行结果,并解释原因
```js
(function () {
  var a = (b = 5);
})();

console.log(b);
console.log(a);
```

**答案**
5 Error, a is not defined

**解析**
       在这个立即执行函数表达式（IIFE）中包括两个赋值操作，其中`a`使用`var`关键字进行声明，因此其属于函数内部的局部变量（仅存在于函数中），相反，`b`被分配到全局命名空间。
       另一个需要注意的是，这里没有在函数内部使用[严格模式](http://cjihrig.com/blog/javascripts-strict-mode-and-why-you-should-use-it/)(`use strict`;)。如果启用了严格模式，代码会在输出 b 时报错`Uncaught ReferenceError: b is not defined`,需要记住的是，严格模式要求你显式的引用全局作用域。因此，你需要写成：
```js
(function () {
  "use strict";
  var a = (window.b = 5);
})();
console.log(b);
```
再看一个
```js
(function() {
   'use strict';
   var a = b = 5;
})();
 
console.log(b);  //Uncaught ReferenceError: b is not defined

/*---------------------------*/

(function() {
   'use strict';
   var a = window.b = 5;
})();
 
console.log(b);  // 5
```

### Day7:写出执行结果,并解释原因
```js
var fullname = 'a';
var obj = {
   fullname: 'b',
   prop: {
      fullname: 'c',
      getFullname: function() {
         return this.fullname;
      }
   }
};
 
console.log(obj.prop.getFullname()); // c
var test = obj.prop.getFullname;
console.log(test());  // a
```

**答案**
c a

**解析**
- 原因在于`this`指向的是函数的执行环境，`this`取决于其被谁调用了，而不是被谁定义了。
- 对第一个`console.log()`语句而言，`getFullName()` 是作为`obj.prop`对象的一个方法被调用的，因此此时的执行环境应该是这个对象。另一方面，但`getFullName()`被分配给`test`变量时，此时的执行环境变成全局对象（`window`），原因是`test`是在全局作用域中定义的。因此，此时的`this`指向的是全局作用域的`fullname`变量，即a。

### Day8:写出执行结果,并解释原因
```js
var company = {
    address: 'beijing'
}
var yideng = Object.create(company);
delete yideng.address
console.log(yideng.address);
```

**答案**

beijing

**解析**

这里的 yideng 通过 prototype 继承了 company的 address。yideng自己并没有address属性。所以delete操作符的作用是无效的。

**知识点**

1. delete使用原则：delete 操作符用来删除一个对象的属性。
2. delete在删除一个不可配置的属性时在严格模式和非严格模式下的区别:
 * （1）在严格模式中，如果属性是一个不可配置（non-configurable）属性，删除时会抛出异常;
 * （2）非严格模式下返回 false。
3. delete能删除隐式声明的全局变量：这个全局变量其实是global对象(window)的属性
4. delete能删除的：
 * （1）可配置对象的属性
 * （2）隐式声明的全局变量 
 * （3）用户定义的属性 
 * （4）在ECMAScript 6中，通过 const 或 let 声明指定的 "temporal dead zone" (TDZ) 对 delete 操作符也会起作用

  delete不能删除的：
 * （1）显式声明的全局变量 
 * （2）内置对象的内置属性 
 * （3）一个对象从原型继承而来的属性
5. delete删除数组元素：
 * （1）当你删除一个数组元素时，数组的 length 属性并不会变小，数组元素变成undefined
 * （2）当用 delete 操作符删除一个数组元素时，被删除的元素已经完全不属于该数组。
 * （3）如果你想让一个数组元素的值变为 undefined 而不是删除它，可以使用 undefined 给其赋值而不是使用 delete 操作符。此时数组元素是在数组中的
6. delete 操作符与直接释放内存（只能通过解除引用来间接释放）没有关系。
7. 其它例子
（1）下面代码输出什么？
```js
var output = (function(x){
    delete x;
    return x;
})(0);
console.log(output);
```
答案：0，`delete` 操作符是将object的属性删去的操作。但是这里的 `x` 是并不是对象的属性， `delete` 操作符并不能作用。

（2）下面代码输出什么？
```js
var x = 1;
var output = (function(){
    delete x;
    return x;
})();
console.log(output);
```
答案：输出是 1。delete 操作符是将object的属性删去的操作。但是这里的 x 是并不是对象的属性， delete 操作符并不能作用。

（3）下面代码输出什么?
```js
x = 1;
var output = (function(){
    delete x;
    return x;
})();
console.log(output);
```
答案：报错 VM548:1 Uncaught ReferenceError: x is not defined,

（4）下面代码输出什么？
```js
var x = { foo : 1};
var output = (function(){
    delete x.foo;
    return x.foo;
})();
console.log(output);
```
答案：输出是 undefined。x虽然是全局变量，但是它是一个object。delete作用在x.foo上，成功的将x.foo删去。所以返回undefined

### Day9:写出执行结果,并解释原因
```js
var foo = function bar(){ return 12; };
console.log(typeof bar());  
```

**答案**
输出是抛出异常，bar is not defined。

**解析**
这种命名函数表达式函数只能在函数体内有效
```js
var foo = function bar(){ 
    // foo is visible here 
    // bar is visible here
    console.log(typeof bar()); // Work here :)
};
// foo is visible here
// bar is undefined here
```

### Day10:写出执行结果,并解释原因
```js
var x=1;
if(function f(){}){
    x += typeof f;
}
console.log(x)
```

**答案**
1 undefined

**解析**
条件判断为假的情况有：0，false，''，null，undefined，未定义对象。函数声明写在运算符中，其为true，但放在运算符中的函数声明在执行阶段是找不到的。另外，对未声明的变量执行typeOf不会报错，会返回undefined

### Day11:写出执行结果,并解释原因
```js
function f(){
      return f;
 }
 console.log(new f() instanceof f);
```

**答案**
false

**解析**
a instanceof b 用于检测a是不是b的实例。如果题目f中没有return f,则答案明显为true;而在本题中new f()其返回的结果为f的函数对象，其并不是f的一个实例。
```js
function f(){}
 console.log(new f() instanceof f);
// 答案：true
```

### Day12:写出执行结果,并解释原因
```js
var foo = {
        bar: function(){
            return this.baz;
        },
         baz:1
    }
console.log(typeof (f=foo.bar)());
```

**答案**
undefined

**解析**
将foo.bar赋值给f,相当于f(),故其this指向window

### Day13:关于AMD、CMD规范区别说法正确的是？（多选）
```js
关于AMD、CMD规范区别说法正确的是？（多选）

A.AMD规范：是 RequireJS在推广过程中对模块定义的规范化产出的
B.CMD规范：是SeaJS 在推广过程中对模块定义的规范化产出的
C.CMD 推崇依赖前置;AMD 推崇依赖就近
D.CMD 是提前执行;AMD 是延迟执行
E.AMD性能好,因为只有用户需要的时候才执行;CMD用户体验好,因为没有延迟,依赖模块提前执行了
```

**答案**
A B 

**解析**
C.CMD 推崇依赖就近;AMD 推崇依赖前置
D.CMD 是延迟执行;AMD 是提前执行
E.CMD性能好,因为只有用户需要的时候才执行;AMD用户体验好,因为没有延迟,依赖模块提前执行了

### Day14:关于SPA单页页面的理解正确的是?
```js
关于SPA单页页面的理解正确的是?

A.用户体验好、快，但是内容的改变需要重新加载整个页面，会造成不必要的跳转和重复渲染；
B.前后端职责分离，架构清晰，前端进行交互逻辑，后端负责数据处理；
C.初次加载耗时多：为实现单页 Web 应用功能及显示效果，需要在加载页面的时候将 JavaScript、CSS 统一加载，部分页面按需加载；
D.前进后退路由管理需要使用浏览器的前进后退功能
E.SEO 难度较大：由于所有的内容都在一个页面中动态替换显示，所以在 SEO 上其有着天然的弱势。
```

**答案**
B C  E

**解析**
SPA（ single-page application ）仅在 Web 页面初始化时加载相应的 HTML、JavaScript 和 CSS。一旦页面加载完成，SPA 不会因为用户的操作而进行页面的重新加载或跳转；取而代之的是利用路由机制实现 HTML 内容的变换，UI 与用户的交互，避免页面的重新加载。

- SPA优点
  - 用户体验好、快，内容的改变不需要重新加载整个页面，避免了不必要的跳转和重复渲染；
  - 基于上面一点，SPA 相对对服务器压力小；
  - 前后端职责分离，架构清晰，前端进行交互逻辑，后端负责数据处理；

- SPA缺点
  - 初次加载耗时多：为实现单页 Web 应用功能及显示效果，需要在加载页面的时候将 JavaScript、CSS 统一加载，部分页面按需加载；
  - 前进后退路由管理：由于单页应用在一个页面中显示所有的内容，所以不能使用浏览器的前进后退功能，所有的页面切换需要自己建立堆栈管理；
  - SEO 难度较大：由于所有的内容都在一个页面中动态替换显示，所以在 SEO 上其有着天然的弱势。

### Day15:下面对Vue.js中keep-alive的理解正确的是？（多选）
```js
下面对Vue.js中keep-alive的理解正确的是？（多选）

A.一般结合路由和动态组件一起使用，用于缓存组件；
B.提供 include 和 exclude 属性，两者都支持字符串或正则表达式， include 表示只有名称匹配的组件会被缓存，exclude 表示任何名称匹配的组件都不会被缓存 ，其中 include  的优先级比 exclude 高；
C.对应两个钩子函数 activated 和 deactivated ，当组件被激活时，触发钩子函数 activated，当组件被移除时，触发钩子函数 deactivated。
D.keep-alive 是 Vue 内置的一个组件，可以使被包含的组件保留状态，但是不能避免重新渲染

```

**答案**
A C

**解析**
B: include的优先级比 exclude 低；
D：能避免重新渲染

### Day16:关于Vue.js虚拟DOM的优缺点说法正确的是？（多选）
```js
关于Vue.js虚拟DOM的优缺点说法正确的是？（多选）

A.可以保证性能下限，比起粗暴的 DOM 操作性能要好很多，因此框架的虚拟 DOM 至少可以保证在你不需要手动优化的情况下，依然可以提供还不错的性能，即保证性能的下限；
B.无需手动操作DOM，不再需要手动去操作 DOM，只需要写好 View-Model 的代码逻辑，框架会根据虚拟 DOM 和 数据双向绑定，帮我们以可预期的方式更新视图，极大提高我们的开发效率；
C.可以进行极致优化： 虚拟 DOM + 合理的优化，可以使性能达到极致
D.可以跨平台，虚拟 DOM 本质上是 JavaScript 对象,而 DOM 与平台强相关，相比之下虚拟 DOM 可以进行更方便地跨平台操作，例如服务器渲染、weex 开发等等。
```

**答案**
A B D

**解析**
1）优点
- **保证性能下限：** 框架的虚拟 DOM 需要适配任何上层 API 可能产生的操作，它的一些 DOM 操作的实现必须是普适的，所以它的性能并不是最优的；但是比起粗暴的 DOM 操作性能要好很多，因此框架的虚拟 DOM 至少可以保证在你不需要手动优化的情况下，依然可以提供还不错的性能，即保证性能的下限；
- **无需手动操作 DOM：** 我们不再需要手动去操作 DOM，只需要写好 View-Model 的代码逻辑，框架会根据虚拟 DOM 和 数据双向绑定，帮我们以可预期的方式更新视图，极大提高我们的开发效率；
- **跨平台：** 虚拟 DOM 本质上是 JavaScript 对象,而 DOM 与平台强相关，相比之下虚拟 DOM 可以进行更方便地跨平台操作，例如服务器渲染、weex 开发等等。

2）缺点
**无法进行极致优化：** 虽然虚拟 DOM + 合理的优化，足以应对绝大部分应用的性能需求，但在一些性能要求极高的应用中虚拟 DOM 无法进行针对性的极致优化。比如VScode采用直接手动操作DOM的方式进行极端的性能优化

### Day17:下面代码输出什么？
```js
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 1);
}
```

**答案**
0 1 2

**解析**
使用`let`关键字声明变量`i`：使用`let`（和`const`）关键字声明的变量是具有块作用域的（块是`{}`之间的任何东西）。 在每次迭代期间，`i`将被创建为一个新值，并且每个值都会存在于循环内的块级作用域。
```js
// 下面代码输出什么
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 1);
}
```

> 答案：3 3 3，由于JavaScript中的事件执行机制，setTimeout函数真正被执行时，循环已经走完。 由于第一个循环中的变量i是使用var关键字声明的，因此该值是全局的。 在循环期间，我们每次使用一元运算符++都会将i的值增加1。 因此在第一个例子中，当调用setTimeout函数时，i已经被赋值为3。

### Day18:写出执行结果,并解释原因
```js
const num = {
  a: 10,
  add() {
    return this.a + 2;
  },
  reduce: () => this.a -2;
};
console.log(num.add());
console.log(num.reduce());
```

**答案**
12 NaN

**解析**
注意，add是普通函数，而reduce是箭头函数。对于箭头函数，`this`关键字指向是它所在上下文（定义时的位置）的环境，与普通函数不同！ 这意味着当我们调用reduce时，它不是指向num对象，而是指其定义时的环境（window）。没有值a属性，返回`undefined`。

### Day19:写出执行结果,并解释原因
```js
const person = { name: "yideng" };

function sayHi(age) {
  return `${this.name} is ${age}`;
}
console.log(sayHi.call(person, 5));
console.log(sayHi.bind(person, 5));
```

**答案**
yideng is 21     ƒ sayHi(age) {return `${this.name} is ${age}`;}

**解析**
使用两者，我们可以传递我们想要`this`关键字引用的对象。 但是，`.call`方法会立即执行！
`.bind`方法会返回函数的拷贝值，但带有绑定的上下文！ 它不会立即执行。

### Day20:写出执行结果,并解释原因
```js
["1", "2", "3"].map(parseInt);
```

**答案**
[1,NaN,NaN]

**解析**
1）Array.prototype.map()
array.map(callback[, thisArg])
callback函数的执行规则
参数：自动传入三个参数
currentValue（当前被传递的元素）；
index（当前被传递的元素的索引）；
array（调用map方法的数组）

2）parseInt方法接收两个参数
第三个参数["1", "2", "3"]将被忽略。parseInt方法将会通过以下方式被调用
parseInt("1", 0)
parseInt("2", 1)
parseInt("3", 2)

3）parseInt的第二个参数radix为0时，ECMAScript5将string作为十进制数字的字符串解析；
parseInt的第二个参数radix为1时，解析结果为NaN；
parseInt的第二个参数radix在2—36之间时，如果string参数的第一个字符（除空白以外），不属于radix指定进制下的字符，解析结果为NaN。
parseInt("3", 2)执行时，由于"3"不属于二进制字符，解析结果为NaN。

### Day21:写出执行结果,并解释原因
```js
[typeof null, null instanceof Object]
```

**答案**
 [object, false]
 
**解析**

1） typeof 返回一个表示类型的字符串.

- typeof 的结果列表
  - Undefined   "undefined" 
  - Null        "object" 
  - Boolean     "boolean" 
  - Number      "number" 
  - String      "string"
  - Symbol      "symbol" 
  - Function   "function" 
  - Object      "object"

2）instanceof 运算符用来检测 constructor.prototype 是否存在于参数 object 的原型链上.

### Day22:写出执行结果,并解释原因
```js
function f() {}
const a = f.prototype,b = Object.getPrototypeOf(f)
console.log(a === b);
```

**答案**
false

**解析**

- f.prototype 是使用使用 new 创建的 f 实例的原型. 而 Object.getPrototypeOf 是 f 函数的原型.
- a === Object.getPrototypeOf(new f()) // true 
- b === Function.prototype // true

### Day22:写出执行结果,并解释原因
```js
function f() {}
const a = f.prototype,b = Object.getPrototypeOf(f)
console.log(a === b);
```

**答案**
false

**解析**

- f.prototype 是使用使用 new 创建的 f 实例的原型. 而 Object.getPrototypeOf 是 f 函数的原型.
- a === Object.getPrototypeOf(new f()) // true 
- b === Function.prototype // true

### Day24:选择正确的答案
```js
console.log([2,1,0].reduce(Math.pow));
console.log([].reduce(Math.pow));

/ *
A. 2 报错
B. 2 NaN
C. 1 报错
D. 1 NaN
*/
```

**答案**
C

**解析**
- arr.reduce(callback[, initialValue])
  - reduce接受两个参数, 一个回调, 一个初始值
  - 回调函数接受四个参数 previousValue, currentValue, currentIndex, array
  - 需要注意的是 If the array is empty and no initialValue was provided, TypeError would be thrown.
所以第二个会报异常. 第一个表达式等价于 Math.pow(2, 1) => 2; Math.pow(2, 0) =>1

### Day25:请问变量a会被GC吗
```js
function test(){
    var a = 1;
    return function(){
        eval("");
    }
}
test();
```

**答案**
不会

**解析**
因为eval会欺骗词法作用域，例如function test(){eval("var a = 1"},创建了一个a变量，不确定eval是否对a进行了引用，所以为了保险，不对其进行优化。相对，try catch,with也不会被回收，with会创建新的作用域。

### Day26:写出执行结果,并解释原因
```js
const value  = 'Value is' + !!Number(['0']) ? 'yideng' : 'undefined';
console.log(value);
```

**答案**
yideng

**解析**

- +优先级大于？
- 所以原题等价于 'Value is false' ? 'yideng' : undefined'' 而不是 'Value is' + (false ? 'yideng' : 'undefined')

### Day27:写出执行结果,并解释原因
```js
var arr = [0,1];
arr[5] = 5;
newArr = arr.filter(function(x) { return x === undefined;});
console.log(newArr.length);
```

### 答案

0

### 解析

- `filter` 为数组中的每个元素调用一次 `callback` 函数，并利用所有使得 `callback` 返回 true 或[等价于 true 的值](https://developer.mozilla.org/zh-CN/docs/Glossary/Truthy)的元素创建一个新数组。`callback` 只会在已经赋值的索引上被调用，对于那些已经被删除或者从未被赋值的索引不会被调用。那些没有通过 `callback` 测试的元素会被跳过，不会被包含在新数组中。
- 也就是说 从 2-4 都是没有初始化的'坑'!, 这些索引并不存在与数组中. 在 array 的函数调用的时候是会跳过这些'坑'的.

### Day28:写出执行结果,并解释原因(以最新谷歌浏览器为准)
```js
async function async1() {
    console.log('async1 start');
    await async2();
    console.log('async1 end');
}
async function async2() {
	console.log('async2');
}
console.log('script start');
setTimeout(function() {
    console.log('setTimeout');
}, 0)
async1();
new Promise(function(resolve) {
    console.log('promise1');
    resolve();
}).then(function() {
    console.log('promise2');
});
console.log('script end');
```

### 答案：

```
script start
async1 start
async2
promise1
script end
async1 end
promise2
setTimeout
```

### 解析：

#### 知识点：

考察的是js中的事件循环和回调队列。注意以下几点

1. `Promise`优先于`setTimeout`宏任务。所以，`setTimeout`回调会在最后执行。
2. `Promise`一旦被定义，就会立即执行
3. `Promise`的`reject`和`resolve`是异步执行的回调。所以，`resolve()`会被放到回调队列中，在主函数执行完和`setTimeout`前调用。
4. `await`执行完后，会让出线程。`async`标记的函数会返回一个`Promise`对象

#### 迷惑点

```js
async function async1() {
    console.log('async1 start');
    await async2();
    console.log('async1 end');
}
async function async2() {
    console.log('async2');
}
// 相当于
function async1() {
    return new Promise((resolve,reject)=>{
        console.log('async1 start');
        async1().then((result)=>{
            console.log('async1 end');
        })
       resolve()
    })
}
function async2() {
    return new Promise((resolve)=>{
        console.log('async2');
        resolve()
    })
}
```

#### 执行流程分析

1. 首先，事件循环从宏任务(macrotask)队列开始，这个时候，宏任务队列中，只有一个script(整体代码)任务；从宏任务队列中取一个任务出来执行。
  * a. 首先执行console.log('script start') ，输出 'script start' 。
  * b. 遇到setTimeout 把 console.log('setTimeout') 放到macroTask队列中。
  * c. 执行async1()， 输出 'async1 start' 和 'async2' ，把 console.log('async1 end') 放到micro 队列中。
  * d. 执行到promise ， 输出 'promise1' ， 把 console.log('promise2') 放到micro 队列中。
  * e. 执行 console.log('script end') 。输出 'script end'
2. macrotask 执行完会执行microtask ，把 microtask quene 里面的 microtask 全部拿出来一次性执行完，所以会输出 ‘async1 end’ 和 ‘promise2’
3. 开始新一轮事件循环，去除一个macrotask执行，所以会输出 “setTimeout”。

<br><br>

### Day29:下面代码中 a 在什么情况下会打印 1
```js
var a = ?;
if(a == 1 && a== 2 && a== 3){
 	console.log(1);
}
```


### 答案&解析

比较操作涉及多不同类型的值时候，会涉及到很多隐式转换，其中规则繁多即便是经验老道的程序员也没办法完全记住，特别是用到 `==` 和 `!=` 运算时候。所以一些团队规定禁用 `==` 运算符换用`===` 严格相等。


#### 答案一

```js
var aﾠ = 1;
var a = 2;
var ﾠa = 3;
if(aﾠ==1 && a== 2 &&ﾠa==3) {
    console.log("1")
}
```

> 考察你的找茬能力，注意if里面的空格，它是一个Unicode空格字符，不被ECMA脚本解释为空格字符(这意味着它是标识符的有效字符)。所以它可以解释为

```js
  var a_ = 1;
  var a = 2;
  var _a = 3;
  if(a_==1 && a== 2 &&_a==3) {
      console.log("1")
  }
```

#### 答案二

```js
var a = {
  i: 1,
  toString: function () {
    return a.i++;
  }
}
if(a == 1 && a == 2 && a == 3) {
  console.log('1');
}
```

> 如果原始类型的值和对象比较，对象会转为原始类型的值，再进行比较。
> 对象转换成原始类型的值，算法是先调用valueOf方法；如果返回的还是对象，再接着调用toString方法。

#### 答案三

```js
var a = [1,2,3];
a.join = a.shift;
console.log(a == 1 && a == 2 && a == 3);
```
> 比较巧妙的方式，array也属于对象，
> 对于数组对象，toString 方法返回一个字符串，该字符串由数组中的每个元素的 toString() 返回值经调用 join() 方法连接（由逗号隔开）组成。
> 数组 toString 会调用本身的 join 方法，这里把自己的join方法该写为shift,每次返回第一个元素，而且原数组删除第一个值，正好可以使判断成立


#### 答案四

```js
var i = 0;
with({
  get a() {
    return ++i;
  }
}) {
  if (a == 1 && a == 2 && a == 3)
    console.log("1");
}
```

> with 也是被严重建议不使用的对象，这里也是利用它的特性在代码块里面利用对象的 get 方法动态返回 i.


#### 答案五
```js
var val = 0;
Object.defineProperty(window, 'a', {
  get: function() {
    return ++val;
  }
});
if (a == 1 && a == 2 && a == 3) {
  console.log('1');
}
```
> 全局变量也相当于 window 对象上的一个属性，这里用defineProperty 定义了 a的 get 也使得其动态返回值。和with 有一些类似。

#### 答案六

```js
let a = {[Symbol.toPrimitive]: ((i) => () => ++i) (0)};
if (a == 1 && a == 2 && a == 3) {
  console.log('1');
}
```

> ES6 引入了一种新的原始数据类型Symbol，表示独一无二的值。我们之前在定义类的内部私有属性时候习惯用 __xxx ,这种命名方式避免别人定义相同的属性名覆盖原来的属性，有了 Symbol  之后我们完全可以用 Symbol值来代替这种方法，而且完全不用担心被覆盖。

> 除了定义自己使用的 Symbol 值以外，ES6 还提供了 11 个内置的 Symbol 值，指向语言内部使用的方法。Symbol.toPrimitive就是其中一个，它指向一个方法，表示该对象被转为原始类型的值时，会调用这个方法，返回该对象对应的原始类型值。这里就是改变这个属性，把它的值改为一个 闭包 返回的函数。

> 业务中一般不会写出这种代码,重点还是知识点的考察

### Day30:写出执行结果,并解释原因
```js
const obj = {
    '2': 3,
    '3': 4,
    'length': 2,
    'splice': Array.prototype.splice,
    'push': Array.prototype.push
}
obj.push(1)
obj.push(2)
console.log(obj)
```

**答案**

Object(4) [empty × 2, 1, 2, splice: ƒ, push: ƒ]

**涉及知识点：**

- 1.类数组（ArrayLike）：一组数据，由数组来存，但是如果要对这组数据进行扩展，会影响到数组原型，ArrayLike的出现则提供了一个中间数据桥梁，ArrayLike有数组的特性， 但是对ArrayLike的扩展并不会影响到原生的数组。
- 2.push方法：push 方法有意具有通用性。该方法和 call() 或 apply() 一起使用时，可应用在类似数组的对象上。push 方法根据 length 属性来决定从哪里开始插入给定的值。如果 length 不能被转成一个数值，则插入的元素索引为 0，包括 length 不存在时。当 length 不存在时，将会创建它。
- 唯一的原生类数组（array-like）对象是 Strings，尽管如此，它们并不适用该方法，因为字符串是不可改变的。
- 3.对象转数组的方式：Array.from()、splice()、concat()等

**解析**

这个obj中定义了两个key值，分别为splice和push分别对应数组原型中的splice和push方法，因此这个obj可以调用数组中的push和splice方法，调用对象的push方法：push(1)，因为此时obj中定义length为2，所以从数组中的第二项开始插入，也就是数组的第三项（下表为2的那一项），因为数组是从第0项开始的，这时已经定义了下标为2和3这两项，所以它会替换第三项也就是下标为2的值，第一次执行push完，此时key为2的属性值为1，同理：第二次执行push方法，key为3的属性值为2。此时的输出结果就是：Object(4) [empty × 2, 1, 2, splice: ƒ, push: ƒ]，因为只是定义了2和3两项，没有定义0和1这两项，所以前面会是empty。

### Day31:写出执行结果,并解释原因
```js
let a = {n: 1};
let b = a;
a.x = a = {n: 2};
console.log(a.x) 	
console.log(b.x)
```

```js
// 答案
undefined {n:2}

// 注意点
1: 点的优先级大于等号的优先级
2: 对象以指针的形式进行存储，每个新对象都是一份新的存储地址

// 解析
- `var b = a;` b 和 a 都指向同一个地址。
- `.`的优先级高于`=`。所以先执行`a.x`，于是现在的`a`和`b`都是`{n: 1, x: undefined}`。
- `=`是从右向左执行。所以是执行 `a = {n: 2}`，于是`a`指向了`{n: 2}`
- 再执行 `a.x = a`。 这里注意，`a.x` 是最开始执行的，已经是`{n: 1, x: undefined}`这个地址了，而不是一开的的那个`a`，所以也就不是`{n: 2}`了。而且`b`和旧的`a`是指向一个地址的，所以`b`也改变了。
- 但是，`=`右面的a，是已经指向了新地址的新`a`。
- 所以，`a.x = a` 可以看成是`{n: 1, x: undefined}.x = {n: 2}`
- 最终得出
  a = { n: 2 }，
  b = {
    n: 1,
    x: { n: 2 }
  }
```


### Day32:写出执行结果,并解释原因
```js
var a1={}, b1='123', c1=123;  
a1[b1]='b';
a1[c1]='c';  
console.log(a1[b1]);
var a2={}, b2=Symbol('123'), c2=Symbol('123');  
a2[b2]='b';
a2[c2]='c';  
console.log(a2[b2]);
var a3={}, b3={key:'123'}, c3={key:'456'};  
a3[b3]='b';
a3[c3]='c';  
console.log(a3[b3]);
```

```js
// 答案
c b c

// 考察知识点
- 对象的键名只能是字符串和 Symbol 类型。
- 其他类型的键名会被转换成字符串类型。
- 对象转字符串默认会调用 toString 方法。

// 解析
var a1={}, b1='123', c1=123;  
a1[b1]='b';
// c1 的键名会被转换成字符串'123'，这里会把 b1 覆盖掉。
a1[c1]='c';  
// 输出 c
console.log(a1[b1]);  


var a2={}, b2=Symbol('123'), c2=Symbol('123');  
// b2 是 Symbol 类型，不需要转换。
a2[b2]='b'; 
// c2 是 Symbol 类型，不需要转换。任何一个 Symbol 类型的值都是不相等的，所以不会覆盖掉 b2。
a2[c2]='c'; 
// 输出b
console.log(a2[b2]);


var a3={}, b3={key:'123'}, c3={key:'456'};  
// b3 不是字符串也不是 Symbol 类型，需要转换成字符串。对象类型会调用 toString 方法转换成字符串 [object Object]
a3[b3]='b'; 
// c3 不是字符串也不是 Symbol 类型，需要转换成字符串。对象类型会调用 toString 方法转换成字符串 [object Object]。这里会把 b3 覆盖掉。
a3[c3]='c';  
// 输出c
console.log(a3[b3]); 

// 扩展
除了前边的Symbol，如果想要不被覆盖 可以使用ES6提供的Map
var a=new Map(), b='123', c=123;
a.set(b,'b');
a.set(c,'c');
a.get(b);  // 'b'
a.get(c);  // 'c'
/*
	Objects 和 Maps 类似的是，它们都允许你按键存取一个值、删除键、检测一个键是否绑定了值。因此（并且也没有其他内建的替代方式了）过去我们一直都把对象当成 Maps 使用。不过 Maps 和 Objects 有一些重要的区别，在下列情况里使用 Map 会是更好的选择：
	1.一个Object的键只能是字符串或者 Symbols，但一个 Map 的键可以是任意值，包括函数、对象、基本类型。
	2.Map 中的键值是有序的，而添加到对象中的键则不是。因此，当对它进行遍历时，Map 对象是按插入的顺序返回键值。
*/
```


### Day33:写出执行结果,并解释原因
```js
function Foo() {
    Foo.a = function() {
        console.log(1)
    }
    this.a = function() {
        console.log(2)
    }
}
Foo.prototype.a = function() {
    console.log(3)
}
Foo.a = function() {
    console.log(4)
}
Foo.a();
let obj = new Foo();
obj.a();
Foo.a();
```

```js
// 答案
421

// 解析
1. `Foo.a()` 这个是调用 Foo 函数的静态方法 a，虽然 Foo 中有优先级更高的属性方法 a，但 Foo 此时没有被调用，所以此时输出 Foo 的静态方法 a 的结果：**4**
2. `let obj = new Foo();` 使用了 new 方法调用了函数，返回了函数实例对象，此时 Foo 函数内部的属性方法初始化，原型方法建立。
3. `obj.a();` 调用 obj 实例上的方法 a，该实例上目前有两个 a 方法：一个是内部属性方法，另一个是原型方法。当这两者重名时，前者的优先级更高，会覆盖后者，所以输出：**2**
4. `Foo.a();` 根据第2步可知 Foo 函数内部的属性方法已初始化，覆盖了同名的静态方法，所以输出：**1**
```


### Day34:写出执行结果,并解释原因
```js
function user(obj) {
  obj.name = "京程一灯"
  obj = new Object()
  obj.name = "精英班"
} 
let person = new Object();
user(person);
console.log(person.name);
```

```js
// 答案：
京程一灯

// 解析：
对象作为参数，传递进去的是这个对象的地址，obj.name是给person这个对象赋值;obj = new Object(),把obj指向另一个对象，obj.name现在是给这个新对象赋值，不影响person这个变量指向的对象；两个obj指向的对象的引用地址不同。

ECMAScript中所有函数的参数都是按值传递的。也就是说，把函数外部的值复制给函数内部的参数，就和把值从一个变量复制到另一个变量一样。不过需要注意的是，基本类型的传递如同基本类型变量的复制一样，传递方式是按值传递，这意味着在函数体内修改参数的值，不会影响到函数外部。而引用类型的值传递，如同引用类型变量的复制一样，传递方式是按引用传递，也就是传入函数的是原始值的地址，因此在函数内部修改参数，将会影响到原始值。
```


### Day35:写出执行结果,并解释原因
```js
let x, y;
try {
  throw new Error();
} catch (x) {
  x =1;
  y=2;
  console.log(x);
}
console.log(x);
console.log(y);
```

```js
// 答案
1 undefined 2

// 解析
`catch`块接收参数`x`。当我们传递参数时，这与变量的`x`不同。这个变量`x`是属于`catch`作用域的。需要注意的是catch的作用域，其实并不是常见的块作用域，并不能绑定自己的内部声明的变量。catch创建的块作用域，只对catch的参数有效。对于在内部声明的变量，catch并没有创建一个新的作用域，只是一个普通的代码块。
```


### Day36:写出执行结果,并解释原因
```js
function fn() {
    getValue = function () { console.log(1); };
    return this;
}
fn.getValue = function () { console.log(2);};
fn.prototype.getValue = function () {console.log(3);};
var getValue = function () {console.log(4);};
function getValue() {console.log(5);}
 
//请写出以下输出结果：
getValue();
fn().getValue();
getValue();
new fn.getValue();
new fn().getValue();
```

```js
// 答案
4 1 1 2 3 3

// 考察知识点
考察了面试者的JavaScript的综合能力，变量定义提升、this指针指向、运算符优先级、原型、继承、全局变量污染、对象属性及原型属性优先级等知识

// 解析
// 第一问 getValue();
/*
	1.直接调用getValue函数，就是访问当前上文作用域内的叫getName的函数，所以关注点就是在4，5上；
	2.两个坑：
		一是变量声明提升，JavaScript 解释器中存在一种变量声明被提升的机制，也就是说函数声明会被提升到作用域的最前面，即使写代码的时候是写在最后面，也还是会被提升至最前面。
		二是函数表达式和函数声明的区别，函数声明在JS解析时进行函数提升，因此在同一个作用域内，不管函数声明在哪里定义，该函数都可以进行调用。而函数表达式的值是在JS运行时确定，并且在表达式赋值完成后，该函数才能调用。
	3.所以第二问的答案就是4，5的函数声明被4的函数表达式覆盖了
*/

// 第二问 fn().getValue();
/*
	1.fn().getValue()，先执行了fn函数，然后调用fn函数的返回值对象的getValue属性函数；
	2.注意，fn函数中的第一句，getValue = function () { console.log(1); };没有用var进行声明，执行到这时，实际上，将外层作用域的getValue函数修改了；
	3.之后，fn函数返回this,this的指向在函数定义的时候是确定不了的，只有函数执行的时候才能确定this到底指向谁，而此处的直接调用方式，this指向window对象，所以此处相当于执行window.getValue(),现在getValue已经被修改成console.log(1),所以输出1
*/

// 第三问 getValue();
/*
	第二问中，执行完fn函数，getValue函数已经被修改了，现在已经是console.log(1),所以这里输出1
*/


// 第四问 new fn.getValue();
/*
 1.这里是考察JS的运算符优先级问题，可以参考MDN的运算符优先级，
 2.点的优先级是18，new 无参数列表优先级是17，点的优先级高，所以这里相当于new (fn.getValue())
 3.当点运算完后又因为有个括号()，此时就是变成new有参数列表，new有参数列列表的优先级是18，所以直接执行new。这是为什么遇到()不先函数调用再new,因为函数调用的优先级是17，优先级低于new 有参数列表的优先级
 4.最终就是相当于将 getValue函数function () { console.log(2);};作为构造函数来执行，所以输出2
*/

// 第五问 new fn().getValue();
/*
	1.与第四问的区别就是有括号无括号，这里带括号是new 有参数列表，new 有参数列表的优先级是18，点的优先级也是18，优先级相同按从左到右的顺序执行。
	2.所以这里是先执行有参数列表，再执行点的优先级，最后再函数调用
	3.这里涉及到一个知识点，fn作为构造函数有返回值，在JS中构造函数可以有返回值也可以没有
		a.没有返回值，返回实例化的对象
		b.有返回值，检查其返回值是否为引用类型。
			非引用类型，如基本类型（String,Number,Boolean,Null,Undefined）则与无返回值相同，实际返回其实例化对象。
			引用类型，实际返回值为这个引用类型
	4.这里fn函数返回的是this,this在构造函数中本来就代表当前实例化对象，最终fn函数返回实例化对象。最终调用，实例化对象的getValue函数，因为在Foo构造函数中没有为实例化对象添加任何属性，当前对象的原型对象(prototype)中寻找getValue函数。所以输出3。	
*/
```


### Day37:写出执行结果,并解释原因
```js
let length = 10;
function fn() {
	console.log(this.length);
}
var obj = {
  length: 5,
  method: function(fn) {
    fn();
    arguments[0]();
  }
};
obj.method(fn,1);
```

```js
// 答案
0  2

// 解析
1）fn()知识点
  ①fn()知识点，任意函数里如果嵌套了 非箭头函数，那这个时候 嵌套函数里的 this 在未指定的情况下，应该指向的是 window 对象，所以这里执行fn会打印window.length,但是let声明的变量会形成块级作用域，且不存在声明提升，而var存在声明提升。所以当使用let声明变量时，不存在声明提升，length属性实际上并没有添加到window对象中。
  // 例如在浏览器控制台
  let a = 1;
  window.a   // undefined
  var b = 1;
  window.b  // 1
  但是这里为什么输出0呢，因为window对象原先上有length属性，所以输出的是原先的值0
  ②arguments[0]()知识点
  在方法调用（如果某个对象的属性是函数，这个属性就叫方法，调用这个属性，就叫方法调用）中，执行函数体的时候，作为属性访问主体的对象和数组便是其调用方法内 this 的指向。（通俗的说，调用谁的方法 this 就指向谁；
  `arguments[0]`指向 `fn`,所以 `arguments[0]()` 是作为 `arguments`对象的属性`[0]`来调用 `fn`的，所以 `fn` 中的 `this` 指向属性访问主体的对象 `arguments`；这里this指向arguments。
  因为fn作为一个参数存储在arg对象里，argumengts的长度为2，所以输出2
  // 例如
  [function fn(){console.log(this.length)}][0]();  // 1
  // 数组也是对象，只不过数组对象的整型属性会计入 length 属性中，并被区别对待，这里就是调用数组对象的0属性，函数作为数组对象的属性调用，函数中的this 当然指向这个数组，所以返回数组的length 
```


### Day38:写出执行结果,并解释原因
```js
var a=10;
var foo={
  a:20,
  bar:function(){
      var a=30;
      return this.a;
    }
}
console.log(foo.bar());
console.log((foo.bar)());
console.log((foo.bar=foo.bar)());
console.log((foo.bar,foo.bar)());
```

```js
// 答案
20 20 10 10

// 解析
1）第一问  foo.bar()
/*
	foo调用，this指向foo , 此时的 this 指的是foo，输出20
*/

2）第二问  (foo.bar)()
/*
	给表达式加了括号，而括号的作用是改变表达式的运算顺序，而在这里加与不加括号并无影响；相当于foo.bar(),输出20
*/

3）第三问  (foo.bar=foo.bar)()
/*
	等号运算，
	相当于重新给foo.bar定义，即
	foo.bar = function () {
    var a = 10;
    return this.a;
	}
	就是普通的复制,一个匿名函数赋值给一个全局变量
	所以这个时候foo.bar是在window作用域下而不是foo = {}这一块级作用域，所以这里的this指代的是window,输出10
*/

4）第四问  (foo.bar,foo.bar)()
/*
	1.逗号运算符，
	2.逗号表达式，求解过程是：先计算表达式1的值，再计算表达式2的值，……一直计算到表达式n的值。最后整个逗号表达式的值是表达式n的值。逗号运算符的返回值是最后一个表达式的值。
  3.其实这里主要还是经过逗号运算符后，就是纯粹的函数了，不是对象方法的引用，所以这里this指向的是window，输出10
  4.第三问，第四问，一个是等号运算，一个是逗号运算，可以这么理解，经过赋值，运算符运算后，都是纯粹的函数，不是对象方法的引用。所以函数指向的this都是windows的。
*/

// 知识点
1）默认绑定
  ①独立函数调用时，this 指向全局对象（window），如果使用严格模式，那么全局对象无法使用默认绑定， this绑定至 undefined。
  
2）隐式绑定
 ①函数this 是指向调用者 （隐式指向）
 function foo() {
    console.log( this.a);
  }
  var obj = {
    a: 2,
    foo: foo
  };
  obj.foo();  // 2
  obj1.obj2.foo(); // foo 中的 this 与 obj2 绑定
  ②问题：隐式丢失
  描述：隐式丢失指的是函数中的 this 丢失绑定对象，即它会应用第 1 条的默认绑定规则，从而将 this 绑定到全局对象或者 undefined 上，取决于是否在严格模式下运行。
  以下情况会发生隐式丢失
    - 绑定至上下文对象的函数被赋值给一个新的函数，然后调用这个新的函数时
    - 传入回调函数时
3）显示绑定
显式绑定的核心是 JavaScript 内置的 call(..) 和 apply(..) 方法，call 和 apply bind的this第一个参数 （显示指向）

4）new 绑定
构造函数的this 是new 之后的新对象 （构造器）
```


### Day39:写出执行结果,并解释原因
```js
function getName(){
  for(let i = 0;i<5;i++){
    setTimeout(function(){
      console.log(i)
    },i*1000);
  }
  return
  {
    name:'京程一灯'
  }
}
console.log(getName());
```

```js
// 答案：
undefined 0 1 2 3 4

// 解析：
1.第一个点：undefined，这是因为return后换行了,JavaScirpt会在return语句后自动插入了分号。
分号自动添加的情况：
（1）如果下一行的开始与本行的结尾连在一起解释，JavaScript就不会自动添加分号；  
（2）只有下一行的开始于本行的结尾无法放在一起解释，JavaScript引擎才会自动添加分号；  
（3）如果一行的起首是++或--运算符，则他们后面自动添加分号；  
（4）如果continue、break、return、throw这四个语句后面，直接跟换行符，则会自动添加分号。 

2.第二个点：let的变量除了作用域是在for区块中，而且会为每次循环执行建立新的词法环境(LexicalEnvironment)，拷贝所有的变量名称与值到下个循环执行。  因为用let声明的，所以每个i一个作用域。这里如果是用var声明，则最后输出的都是5。
```


### Day40:写出执行结果,并解释原因
```js
const num = parseInt("2*4",10);
console.log(num);
```

```js
// 答案
2

// 解析
只返回了字符串中第一个字母. 设定了 进制 后 (也就是第二个参数，指定需要解析的数字是什么进制: 十进制、十六机制、八进制、二进制等等……), `parseInt` 检查字符串中的字符是否合法. 一旦遇到一个在指定进制中不合法的字符后，立即停止解析并且忽略后面所有的字符。
`*`就是不合法的数字字符。所以只解析到 2，并将其解析为十进制的2. `num`的值即为 2
```


### Day41:选择正确答案，并解释为什么
```js
const company = { name: "京程一灯" };
Object.defineProperty(company, "address", { value: "北京" });
console.log(company);
console.log(Object.keys(company));
/*
A. {name:"京程一灯",address:"北京"},["name","age"]
B. {name:"京程一灯",address:"北京"},["name"]
C. {name:"京程一灯"},["name","age"]
D. {name:"京程一灯"},["name","age"]
*/
```

```js
// 答案
B

// 解析
通过 `defineProperty`方法，我们可以给对象添加一个新属性，或者修改已经存在的属性。而我们使用 `defineProperty`方法给对象添加了一个属性之后，属性默认为 不可枚举(not enumerable). `Object.keys`方法仅返回对象中 可枚举(enumerable) 的属性，因此只剩下了 name
用 `defineProperty`方法添加的属性默认不可变。你可以通过 `writable`, `configurable` 和 `enumerable`属性来改变这一行为。这样的话， 相比于自己添加的属性， `defineProperty`方法添加的属性有了更多的控制权。
```


### Day42:写出执行结果,并解释原因
```js
let num = 10;
const increaseNumber = () => num++;
const increasePassedNumber = number => number++;
const num1 = increaseNumber();
const num2 = increasePassedNumber(num1);
console.log(num1);
console.log(num2);
```

```js
// 答案
 10 10
 
// 解析
一元操作符 `++` 先返回 操作值, 再累加 操作值。`num1`的值是 `10`, 因为 `increaseNumber`函数首先返回 `num`的值，也就是 `10`，随后再进行 `num`的累加。
`num2`是 `10`因为我们将 `num1`传入 `increasePassedNumber`. `number`等于 `10`（ `num1`的值。同样道理， `++` 先返回 操作值, 再累加 操作值。） `number`是 `10`，所以 `num2`也是 `10`.
```


### Day43:写出执行结果,并解释原因
```js
const value = { number: 10 };
const multiply = (x = { ...value }) => {
  console.log(x.number *= 2);
};
multiply();
multiply();
multiply(value);
multiply(value);
```

```js
// 答案
20 20 20 40

// 解析
在ES6中，我们可以使用默认值初始化参数。如果没有给函数传参，或者传的参值为 `"undefined"` ，那么参数的值将是默认值。上述例子中，我们将 `value` 对象进行了解构并传到一个新对象中，因此 `x` 的默认值为 `{number：10}` 。
默认参数在调用时才会进行计算，每次调用函数时，都会创建一个新的对象。我们前两次调用 `multiply` 函数且不传递值，那么每一次 `x` 的默认值都为 `{number：10}` ，因此打印出该数字的乘积值为 `20`。
第三次调用 `multiply` 时，我们传递了一个参数，即对象 `value`。`*=`运算符实际上是 `x.number=x.number*2`的简写，我们修改了 `x.number`的值，并打印出值 `20`。
第四次，我们再次传递 `value`对象。`x.number`之前被修改为 `20`，所以 `x.number*=2`打印为 `40`。
```


### Day44:写出执行结果,并解释原因
```js
[1, 2, 3, 4].reduce((x, y) => console.log(x, y));
```

```js
// 答案
1 2 undefined 3 undefined 4

// 解析
`reducer` 函数接收4个参数:

1. Accumulator (acc) (累计器)
2. Current Value (cur) (当前值)
3. Current Index (idx) (当前索引)
4. Source Array (src) (源数组)

`reducer` 函数的返回值将会分配给累计器，该返回值在数组的每个迭代中被记住，并最后成为最终的单个结果值。
`reducer` 函数还有一个可选参数 `initialValue`, 该参数将作为第一次调用回调函数时的第一个参数的值。如果没有提供 `initialValue`，则将使用数组中的第一个元素。
在上述例子， `reduce`方法接收的第一个参数(Accumulator)是 `x`, 第二个参数(Current Value)是 `y`。
在第一次调用时，累加器 `x`为 `1`，当前值 `“y”`为 `2`，打印出累加器和当前值：`1`和 `2`。
例子中我们的回调函数没有返回任何值，只是打印累加器的值和当前值。如果函数没有返回值，则默认返回 `undefined`。在下一次调用时，累加器为 `undefined`，当前值为“3”, 因此 `undefined`和 `3`被打印出。
在第四次调用时，回调函数依然没有返回值。累加器再次为 `undefined` ，当前值为“4”。`undefined`和 `4`被打印出。
```


### Day45:写出执行结果,并解释原因
```js
// index.js
console.log('running index.js');
import { sum } from './sum.js';
console.log(sum(1, 2));

// sum.js
console.log('running sum.js');
export const sum = (a, b) => a + b;
```

```js
// 答案
running sum.js running index.js  3

// 解析
import命令是编译阶段执行的，在代码运行之前。因此这意味着被导入的模块会先运行，而导入模块的文件会后执行。
这是CommonJS中require（）和 import之间的区别。使用 require()，可以在运行代码时根据需要加载依赖项。如果我们使用 require而不是import，则running index.js、running sum.js、 3会被依次打印。
```


### Day46:写出执行结果,并解释原因
```js
function addToList(item, list) {
 return list.push(item);
}
const result = addToList("company", ["yideng"]);
console.log(result);
```

```js
// 答案
2

// 解析
`push()`方法返回新数组的长度。一开始，数组包含一个元素（字符串 `"yideng"`），长度为1。 在数组中添加字符串 `"company"`后，长度变为2，并将从 `addToList`函数返回。
`push`方法修改原始数组，如果你想从函数返回数组而不是数组长度，那么应该在push `item`之后返回 `list`。
开发中一不小心会导致错误的地方
```


### Day47:写出执行结果,并解释原因
```js
var a = 0;
if(true){
  a = 10;
  console.log(a,window.a);
  function a(){};
  console.log(a,window.a);
  a = 20;
  console.log(a,window.a);
}
console.log(a);
```

```js
// 答案
10 0
10 10
20 10
10

// 知识点

// 解析
1）变量提升
  变量的提升是以变量作用域来决定的，即全局作用域中声明的变量会提升至全局最顶层，函数内声明的变量只会提升至该函数作用域最顶层。
  console.log(a);
  var a = 10;
  // 等价于
  var a;
  console.log(a);
  a = 10;
  
2）函数提升
  ①函数提升，类似变量提升，但是确有些许不同。
  ②函数表达式
    console.log(a);// undefined
    var a = function(){};
    // 函数表达式不会声明提升，这里输出undefined,是var a变量声明的提升
  ③函数声明
    函数声明覆盖变量声明
    //因为其是一等公民,与其他值地位相同，所以 函数声明会覆盖变量声明
    // 如果存在函数声明和变量声明（注意：仅仅是声明，还没有被赋值），而且变量名跟函数名是相同的，那么，它们都会被提示到外部作用域的开头，但是，函数的优先级更高，所以变量的值会被函数覆盖掉。

    /*************未赋值的情况***************/
    // 变量名与函数名相同
    var company;
    function company () {
    console.log ("yideng");
    }
    console.log(typeof company); // function,函数声明将变量声明覆盖了

    /*************赋值的情况***************/
    // 如果这个变量或者函数其中是赋值了的，那么另外一个将无法覆盖它：
    var company = "yideng"; // 变量声明并赋值
    function company () {
      console.log ("yideng");
    }
    console.log(typeof company); // string
    // 这个其实再次赋值了
    var company;
    function company(){};
    company = 'yideng'; // 被重新赋值
    console.log(typeof company); 
    
3）块级作用域的函数声明
  // 在块级作用域中的函数声明和变量是不同的
  /*********块级作用域中变量声明***************/
  console.log(a); //ReferenceError: a is not defined
  if(true){
    a = 10;
    console.log(a);
  }
  console.log(a);
  // 会报错，

  /****************块级作用域函数声明******************/
  console.log(a); // 这里不报错，是undefined
  if(true){
    console.log(a); // function a
    function a(){};
  }
  // 上边的代码等价于
  var a; // 函数a的声明
  console.log(a); // undefined
  if(true){
    function a(){} // 函数a的定义
    console.log(a); // function a
  }
  /*
    这里其实就是函数function a(){}经过预解析之后:
    将函数声明提到函数级作用域最前面，var a;// 函数a的声明
    然后将函数定义提升到块级作用域最前面， function a(){} 函数a的定义
  */
  
  如果改变了作用域内声明的函数的处理规则，显然会对老代码产生很大影响。为了减轻因此产生的不兼容问题，es6在附录B里面规定，浏览器的实现可以不遵守上面规定，有自己的行为方式
    ①允许在块级作用域内声明函数
    ②函数声明类似于var,即会提升到全局作用域或函数作用域的头部
    ③同时，函数声明还会提升到所在的块级作用域的头部。
  注意，上面三条规则只对ES6的浏览器实现有效，其它环境的实现不用遵守，还是将块级作用域的函数声明当做let处理
  块级作用域函数，就像预先在全局作用域中使用`var`声明了一个变量，且默认值为`undefined`。
  console.log(a,window.a); // undefined undefined
  {
    console.log(a,window.a); // function a(){} undefined
    function a(){}
    console.log(a,window.a); // function a(){} function a(){}
  }
  console.log(a,window.a);	// function a(){} function a(){}
  
  总结：
    ①块级作用域函数在编译阶段将函数声明提升到全局作用域，并且会在全局声明一个变量，值为undefined。同时，也会被提升到对应的块级作用域顶层。
    ②块级作用域函数只有定义声明函数的那行代码执行过后，才会被映射到全局作用域。
    
4）块级作用域中有同名的变量和函数声明
  console.log(window.a,a);//undefined undefined
  {
      console.log(window.a,a);//undefined function a(){}
      function a() {};
      a = 10;
      console.log(window.a,a); //function a(){}  10
  };
  console.log(window.a,a); //function a(){}  function a(){}

  /*
    1.第一个log,块级作用域函数a的声明会被提升到全局作用域，所以不报错，是undefined undefined
    2.第二个log,在块级作用域中，由于声明函数a提升到块级作用域顶端,所以打印a = function a(){}，而window.a由于并没有执行函数定义的那一行代码，所以仍然为undefined。
    3.第三个log,这时已经执行了声明函数定义，所以会把函数a映射到全局作用域中。所以输出function a(){},
    4.第四个log,就是function a(){}  function a(){}，因为在块级作用域中window.a的值已经被改变了，变成了function a(){}
  */
  块级作用域函数只有执行函数声明语句的时候，才会重写对应的全局作用域上的同名变量。
  
  // 解析
  看过上边的知识点，这道题现在已经可以轻松答对了
  var a;// 函数a声明提前，块级作用域函数a的声明会被提升到全局作用域
  var a = 0; // 已经声明了a,这里会忽略变量声明，直接赋值为0
  if(true){ // 块级作用域
    function a(){} // 函数a的定义，提升到块级作用域最前面
    a = 10; // 执行a = 10，此时，在块级作用域中函数声明已经被提升到顶层，那么此时执行a，就是相当于赋值，将函数声明a赋值为数字a，这里就是赋值为10了，
    console.log(a,window.a); // a是块级作用域的function a,所以输出 10,window.a还是0，因为块级作用域函数只有执行函数声明语句的时候，才会重写对应的全局作用域上的同名变量
    function a(){} // 执行到函数声明语句，虽然这一行代码是函数声明语句，但是a，已经为数字10了，所以，执行function a(){}之后，a的值10就会被赋值给全局作用域上的a，所以下面打印的window.a,a都为10
    console.log(a,window.a); // a 还是块级作用域中的function a,前边已经被赋值为10，所以window.a前边已经变为了10
    a = 20; // 仍然是函数定义块级作用域的a,重置为21
    console.log(a,window.a); // 输出为函数提升的块级作用域的a,和window.a,所以这里输出20 10
  }
  console.log(a); // 因为在块级作用域中window.a被改变成了10，所以这里现在是10
  
  
  // 写出打印结果
  var foo = 1;
  function bar() {
      // foo会声明提前 var foo;
    // !foo 等价于!undefined true
      if (!foo) {
          var foo = 10;
      }
    console.log(foo); // 10
  }
  bar();

  // 写出打印结果
  var a = 1;
  function b() {
      // 函数声明提前
      // var a = function a(){};
      a = 10; // 赋值相当于是给函数a进行重新赋值，并且这是函数作用域，不是块级作用域
      return;
      function a() {}
  }
  b();
  console.log(a); // 1
```


### Day48:能否以某种方式为下面的语句使用展开运算而不导致类型错误
```js
var obj = { x: 1, y: 2, z: 3 };
[...obj]; // TypeError
// 能否以某种方式为上面的语句使用展开运算而不导致类型错误
// 如果可以，写出解决方式
```

```js
// 答案
可以

// 解析
展开语法和for-of 语句遍历iterabl对象定义要遍历的数据。Arrary和Map 是具有默认迭代行为的内置迭代器。对象不是可迭代的，但是可以通过使用iterable和iterator协议使它们可迭代。

在Mozilla文档中，如果一个对象实现了@iterator方法，那么它就是可迭代的，这意味着这个对象(或者它原型链上的一个对象)必须有一个带有@iterator键的属性，这个键可以通过常量Symbol.iterator获得。

// 解决方式一
var obj = { x: 1, y: 2, z: 3 };
obj[Symbol.iterator] = function(){
  // iterator 是一个具有 next 方法的对象，
  // 它的返回至少有一个对象
  // 两个属性：value＆done。
   return {
     // 返回一个 iterator 对象
      next: function () {
        if (this._countDown === 3) {
          const lastValue = this._countDown;
          return { value: this._countDown, done: true };
        }
        this._countDown = this._countDown + 1;
        return { value: this._countDown, done: false };
      },
      _countDown: 0,
    };
};
[...obj];

// 解决方式二
// 还可以使用 generator 函数来定制对象的迭代行为：
var obj = { x: 1, y: 2, z: 3 };
obj[Symbol.iterator] = function*() {
    yield 1;
    yield 2;
    yield 3;
};
[...obj]; // 打印 [1, 2, 3]

```


### Day49:请你完成一个safeGet函数，可以安全的获取无限多层次的数据
```js
// 请你完成一个safeGet函数，可以安全的获取无限多层次的数据，一旦数据不存在不会报错，会返回 undefined，例如
var data = { a: { b: { c: 'yideng' } } }
safeGet(data, 'a.b.c') // => yideng
safeGet(data, 'a.b.c.d') // => undefined
safeGet(data, 'a.b.c.d.e.f.g') // => undefined
```

```js
// 参考答案
const safeGet = (o, path) => {
  try {
    return path.split('.').reduce((o, k) => o[k], o)
  } catch (e) {
    return undefined;
  }
}
```


### Day50:写一个isPrime()函数
```js
写一个isPrime()函数，当其为质数时返回true，否则返回false。
提示：质数是指在大于1的自然数中，除了1和它本身以外不再有其他因数的自然数。
```

```js
// 答案
这是面试中最常见的问题之一。然而，尽管这个问题经常出现并且也很简单，但是从被面试人提供的答案中能很好地看出被面试人的数学和算法水平。

首先， 因为JavaScript不同于C或者Java，因此你不能信任传递来的数据类型。如果面试官没有明确地告诉你`，你应该询问他是否需要做输入检查，还是不进行检查直接写函数。严格上说，应该对函数的输入进行检查。`

第二点要记住：负数不是质数。同样的，1和0也不是，因此，首先测试这些数字。此外，2是质数中唯一的偶数。没有必要用一个循环来验证4,6,8。再则，如果一个数字不能被2整除，那么它不能被4，6，8等整除。因此，你的循环必须跳过这些数字。如果你测试输入偶数，你的算法将慢2倍（你测试双倍数字）。可以采取其他一些更明智的优化手段，我这里采用的是适用于大多数情况的。例如，如果一个数字不能被5整除，它也不会被5的倍数整除。所以，没有必要检测10,15,20等等。如果你深入了解这个问题的解决方案，建议去看相关的Wikipedia介绍。

最后一点，你不需要检查比输入数字的开方还要大的数字。一般会遗漏掉这一点，并且也不会因为此而获得消极的反馈。但是，展示出这一方面的知识会给你额外加分。

现在你具备了这个问题的背景知识，下面是总结以上所有考虑的解决方案：
function isPrime(number) {
   // If your browser doesn't support the method Number.isInteger of ECMAScript 6,
   // you can implement your own pretty easily
   if (typeof number !== 'number' || !Number.isInteger(number)) {
      // Alternatively you can throw an error.
      return false;
   }
   if (number < 2) {
      return false;
   }
   if (number === 2) {
      return true;
   } else if (number % 2 === 0) {
      return false;
   }
   var squareRoot = Math.sqrt(number);
   for(var i = 3; i <= squareRoot; i += 2) {
      if (number % i === 0) {
         return false;
      }
   }
   return true;
}
```


### Day51:写出打印结果
```js
var x = 20;
var temp = {
    x: 40,
    foo: function() {
        var x = 10;
      	console.log(this.x);
    }
};
(temp.foo, temp.foo)();
```

```js
// 答案：
20

// 解析：
逗号操作符，逗号操作符会从左到右计算它的操作数，返回最后一个操作数的值。所以(temp.foo, temp.foo)();等价于var fun = temp.foo; fun();，fun调用时this指向window，所以返回20。
```


### Day52:请实现一个flattenDeep函数，把嵌套的数组扁平化~~
```js
flattenDeep([1, [2, [3, [4]], 5]]); //[1, 2, 3, 4, 5]
// 请实现一个flattenDeep函数，把嵌套的数组扁平化
```

```js
// 答案&解析

1.参考答案一：利用Array.prototype.flat

ES6 为数组实例新增了 flat方法，用于将嵌套的数组“拉平”，变成一维的数组。该方法返回一个新数组，对原数组没有影响。

flat默认只会 “拉平” 一层，如果想要 “拉平” 多层的嵌套数组，需要给 `flat` 传递一个整数，表示想要拉平的层数。

function flattenDeep(arr, deepLength) {
    return arr.flat(deepLength);
}
console.log(flattenDeep([1, [2, [3, [4]], 5]], 3));

当传递的整数大于数组嵌套的层数时，会将数组拉平为一维数组，JS能表示的最大数字为 Math.pow(2, 53) - 1，因此我们可以这样定义 flattenDeep 函数

function flattenDeep(arr) {
    //当然，大多时候我们并不会有这么多层级的嵌套
    return arr.flat(Math.pow(2,53) - 1); 
}
console.log(flattenDeep([1, [2, [3, [4]], 5]]));

2.参考答案二：利用 reduce 和 concat

function flattenDeep(arr){
    return arr.reduce((acc, val) => Array.isArray(val) ? 
                  acc.concat(flattenDeep(val)) : acc.concat(val), []);
}
console.log(flattenDeep([1, [2, [3, [4]], 5]]));

3.参考答案三：使用 stack 无限反嵌套多层嵌套数组

function flattenDeep(input) {
    const stack = [...input];
    const res = [];
    while (stack.length) {
        // 使用 pop 从 stack 中取出并移除值
        const next = stack.pop();
        if (Array.isArray(next)) {
            // 使用 push 送回内层数组中的元素，不会改动原始输入 original input
            stack.push(...next);
        } else {
            res.push(next);
        }
    }
    // 使用 reverse 恢复原数组的顺序
    return res.reverse();
}
console.log(flattenDeep([1, [2, [3, [4]], 5]]));
```


### Day53:请实现一个 uniq 函数，实现数组去重~~
```js
uniq([1, 2, 3, 5, 3, 2]);//[1, 2, 3, 5]
// 请实现一个 uniq 函数，实现数组去重
```

```js
// 答案&解析

1.参考答案一：利用ES6新增数据类型 Set

Set类似于数组，但是成员的值都是唯一的，没有重复的值。

function uniq(arry) {
    return [...new Set(arry)];
}

2.参考答案二：利用 indexOf

function uniq(arry) {
    var result = [];
    for (var i = 0; i < arry.length; i++) {
        if (result.indexOf(arry[i]) === -1) {
            //如 result 中没有 arry[i],则添加到数组中
            result.push(arry[i])
        }
    }
    return result;
}

3.参考答案三：利用 includes

function uniq(arry) {
    var result = [];
    for (var i = 0; i < arry.length; i++) {
        if (!result.includes(arry[i])) {
            //如 result 中没有 arry[i],则添加到数组中
            result.push(arry[i])
        }
    }
    return result;
}

4.参考答案四：利用 reduce

function uniq(arry) {
    return arry.reduce((prev, cur) => prev.includes(cur) ? prev : [...prev, cur], []);
}

5.参考答案五：利用 Map

function uniq(arry) {
    let map = new Map();
    let result = new Array();
    for (let i = 0; i < arry.length; i++) {
        if (map.has(arry[i])) {
            map.set(arry[i], true);
        } else {
            map.set(arry[i], false);
            result.push(arry[i]);
        }
    }
    return result;
}
```


### Day54:new操作符都做了什么，并手动实现一下

```js
// 答案&解析
1）new操作符做了什么
new 运算符创建一个用户定义的对象类型的实例或具有构造函数的内置对象的实例。new 关键字会进行如下的操作：
创建一个空的简单JavaScript对象（即{}）；
链接该对象（即设置该对象的构造函数）到另一个对象 ；
将步骤1新创建的对象作为this的上下文 ；
如果该函数没有返回对象，则返回this。

2）代码实现
// 参考答案：1.简单实现
function newOperator(ctor) {
    if (typeof ctor !== 'function'){
        throw 'newOperator function the first param must be a function';
    }
    var args = Array.prototype.slice.call(arguments, 1);
    // 1.创建一个空的简单JavaScript对象（即{}）
    var obj = {};
    // 2.链接该新创建的对象（即设置该对象的__proto__）到该函数的原型对象prototype上
    obj.__proto__ = ctor.prototype;
    // 3.将步骤1新创建的对象作为this的上下文
    var result = ctor.apply(obj, args);
    // 4.如果该函数没有返回对象，则返回新创建的对象

    var isObject = typeof result === 'object' && result !== null;
    var isFunction = typeof result === 'function';
    return isObject || isFunction ? result : obj;
}

// 测试
function company(name, address) {
    this.name = name;
    this.address = address;
  }
  
var company1 = newOperator(company, 'yideng', 'beijing');
console.log('company1: ', company1);

// 参考答案：2.更完整的实现
/**
 * 模拟实现 new 操作符
 * @param  {Function} ctor [构造函数]
 * @return {Object|Function|Regex|Date|Error}      [返回结果]
 */
function newOperator(ctor){
    if(typeof ctor !== 'function'){
      throw 'newOperator function the first param must be a function';
    }
    // ES6 new.target 是指向构造函数
    newOperator.target = ctor;
    // 1.创建一个全新的对象，
    // 2.并且执行[[Prototype]]链接
    // 4.通过`new`创建的每个对象将最终被`[[Prototype]]`链接到这个函数的`prototype`对象上。
    var newObj = Object.create(ctor.prototype);
    // ES5 arguments转成数组 当然也可以用ES6 [...arguments], Aarry.from(arguments);
    // 除去ctor构造函数的其余参数
    var argsArr = [].slice.call(arguments, 1);
    // 3.生成的新对象会绑定到函数调用的`this`。
    // 获取到ctor函数返回结果
    var ctorReturnResult = ctor.apply(newObj, argsArr);
    // 小结4 这些类型中合并起来只有Object和Function两种类型 typeof null 也是'object'所以要不等于null，排除null
    var isObject = typeof ctorReturnResult === 'object' && ctorReturnResult !== null;
    var isFunction = typeof ctorReturnResult === 'function';
    if(isObject || isFunction){
        return ctorReturnResult;
    }
    // 5.如果函数没有返回对象类型`Object`(包含`Functoin`, `Array`, `Date`, `RegExg`, `Error`)，那么`new`表达式中的函数调用会自动返回这个新的对象。
    return newObj;
}

```


### Day55:实现 (5).add(3).minus(2) 功能
```js
// 实现 (5).add(3).minus(2) 功能
console.log((5).add(3).minus(2)); // 6
```

```js
// 答案与解析
Number.prototype.add = function (number) {
    if (typeof number !== 'number') {
        throw new Error('请输入数字～');
    }
    return this + number;
};
Number.prototype.minus = function (number) {
    if (typeof number !== 'number') {
        throw new Error('请输入数字～');
    }
    return this - number;
};
console.log((5).add(3).minus(2));

// 扩展点有意思的，JS的经典的浮点数陷阱
// 如果是这样呢？
console.log((5).add(3).minus(6.234345));  // 1.7656549999999998
/*
	参考方案：
		大数加减：直接通过 Number 原生的安全极值来进行判断，超出则直接取安全极值
  	超级多位数的小数加减：取JS安全极值位数-2作为最高兼容小数位数
  	JavaScript 浮点数陷阱及解法:https://github.com/camsong/blog/issues/9
*/
Number.MAX_SAFE_DIGITS = Number.MAX_SAFE_INTEGER.toString().length-2
Number.prototype.digits = function(){
	let result = (this.valueOf().toString().split('.')[1] || '').length
	return result > Number.MAX_SAFE_DIGITS ? Number.MAX_SAFE_DIGITS : result
}
Number.prototype.add = function(i=0){
	if (typeof i !== 'number') {
        	throw new Error('请输入正确的数字');
    	}
	const v = this.valueOf();
	const thisDigits = this.digits();
	const iDigits = i.digits();
	const baseNum = Math.pow(10, Math.max(thisDigits, iDigits));
	const result = (v * baseNum + i * baseNum) / baseNum;
	if(result>0){ return result > Number.MAX_SAFE_INTEGER ? Number.MAX_SAFE_INTEGER : result }
	else{ return result < Number.MIN_SAFE_INTEGER ? Number.MIN_SAFE_INTEGER : result }
}
Number.prototype.minus = function(i=0){
	if (typeof i !== 'number') {
        	throw new Error('请输入正确的数字');
    	}
	const v = this.valueOf();
	const thisDigits = this.digits();
	const iDigits = i.digits();
	const baseNum = Math.pow(10, Math.max(thisDigits, iDigits));
	const result = (v * baseNum - i * baseNum) / baseNum;
	if(result>0){ return result > Number.MAX_SAFE_INTEGER ? Number.MAX_SAFE_INTEGER : result }
	else{ return result < Number.MIN_SAFE_INTEGER ? Number.MIN_SAFE_INTEGER : result 	}
}
console.log((5).add(3).minus(6.234345));  // 1.765655
```


### Day56:介绍下Set、Map、WeakSet和WeakMap的区别

```js
// 答案与解析
1)Set
成员唯一、无序且不重复；
[value, value]，键值与键名是一致的（或者说只有键值，没有键名）；
可以遍历，方法有：add、delete、has。

2)WeakSet
成员都是对象；
成员都是弱引用，可以被垃圾回收机制回收，可以用来保存DOM节点，不容易造成内存泄漏；
不能遍历，方法有 add、delete、has。

3)Map
本质上是键值对的集合，类似集合；
可以遍历，方法很多，可以跟各种数据格式转换。

4)WeakMap
只接受对象作为键名（null 除外），不接受其他类型的值作为键名；
键名是弱引用，键值可以是任意的，键名所指向的对象可以被垃圾回收，此时键名是无效的；
不能遍历，方法有 get、set、has、delete。
```


### Day57:如何在不使用%摸运算符的情况下检查一个数字是否是偶数

```js
// 答案
1）可以对这个问题使用按位&运算符，&对其操作数进行运算，并将其视为二进制值，然后执行与运算
function isEven(num){
  // 位运算不支持浮点数，所以可以利用这一点对小数取整
  const isInteger = (num|0) === num;
  if(num&1 || !isInteger){
    return false;
  }else{
    return true;
  }
}

0 二进制数是 000
1 二进制数是 001
2 二进制数是 010
3 二进制数是 011
4 二进制数是 100
5 二进制数是 101
6 二进制数是 110
7 二进制数是 111

以此类推...
例子： console.log(5&1); // 1
①首先，&运算符将两个数字都转换为二进制，因此5变为101，1变为001。即 101&001
②然后，它使用按位与运算符比较每个位（0和1）
	首先比较最左边的1&0，结果是0。
	然后比较中间的0&0，结果是0。
	然后比较最后1&1，结果是1。
	最后，得到一个二进制数001，对应的十进制数，即1。
  所以可以判断5为奇数
2）还可以递归的方式
function isEven(num){
  // 取绝对值
  const number = Math.abs(num);
  if(number === 1){
    return false;
  }
  if(number == 0 ) {
    return true;
  }
  return isEven(number -2);
}
3）通过Math.round，利用奇数除以2肯定会有小数特点
function isEven(num){
  const isInteger = (num|0) === num;
  if(!isInteger){
    return false;
  }
  const number = num/2;
  return parseInt(number) === Math.round(number);
}
```


### Day58:Object.seal和Object.freeze方法之间有什么区别

```js
// 答案
这两种方法之间的区别在于，当我们对一个对象使用Object.freeze方法时，该对象的属性是不可变的，这意味着我们不能更改或编辑这些属性的值。而在Obj.seal方法中，我们可以改变现有的属性。

1）Object.freeze()
Object.freeze() 方法可以冻结一个对象。一个被冻结的对象再也不能被修改；冻结了一个对象则不能向这个对象添加新的属性，不能删除已有属性，不能修改该对象已有属性的可枚举性、可配置性、可写性，以及不能修改已有属性的值。此外，冻结一个对象后该对象的原型也不能被修改。freeze() 返回和传入的参数相同的对象。

2）Object.seal()
Object.seal()方法封闭一个对象，阻止添加新属性并将所有现有属性标记为不可配置。当前属性的值只要可写就可以改变。

3）相同点：
①ES5新增
②对象不可能扩展，也就是不能再添加新的属性或者方法。
③对象已有属性不允许被删除。
④对象属性特性不可以重新配置。

4）不同点：
①Object.seal方法生成的密封对象，如果属性是可写的，那么可以修改属性值。
②Object.freeze方法生成的冻结对象，属性都是不可写的，也就是属性值无法更改。
```


### Day59:完成plus函数，通过全部的测试用例
```js
'use strict';
function plus(n){
  
}
module.exports = plus
// 测试用例如下
'use strict';
var assert = require('assert');
var plus = require('../lib/assign-4');
describe('测试用例',function(){
  it('plus(0) === 0',function(){
    assert.equal(0,plus(0).toString())
  })
  it('plus(1)(1)(2)(3)(5) === 12',function(){
    assert.equal(12,plus(1)(1)(2)(3)(5).toString())
  })
  it('plus(1)(4)(2)(3) === 10',function(){
    assert.equal(10,plus(1)(4)(2)(3).toString())
  })
  it('plus(1,1)(2,2)(3)(4) === 13',function(){
   	assert.equal(13,plus(1,1)(2,2)(3)(4).toString())
  })
})
```

```js
// 答案&解析
参考答案：答案不唯一
"use strict";
function plus(n) {
  // 第一次执行时，定义一个数组专门用来存储所有的参数
  var _args = [].slice.call(arguments);
  // 在内部声明一个函数，利用闭包的特性保存_args并收集所有的参数值
  var _adder = function () {
    _args.push(...arguments);
    return _adder;
  };
  // 利用toString隐式转换的特性，当最后执行时隐式转换，并计算最终的值返回
  _adder.toString = function () {
    return _args.reduce(function (a, b) {
      return a + b;
    });
  };
  return _adder;
}
module.exports = plus;
```


### Day60:解释下这段代码的意思以及用到的技术点
```js
[].forEach.call($$("*"),function(a){  
  a.style.outline="1px solid #"+(~~(Math.random()*(1<<24))).toString(16)  
})  
```

```js
// 答案与解析
直观操作：获取页面所有的元素，然后给这些元素加上1px的外边框，并且使用了随机颜色

几个关键点：
1）选择页面中所有的元素
$$函数是现代浏览器提供的一个命令行API，它相当于document.querySelectorAll，可以将当前页面中的CSS选择器作为参数传给该方法，然后它会返回匹配的所有元素。

2）遍历元素
[].forEach.call( $$('*'), function( a ) { /* 具体的操作 */ });  
通过使用函数的call和apply方法，可以实现在类似NodeLists这样的类数组对象上调用数组方法。

3）为元素添加颜色
a.style.outline="1px solid #" + color  
代码中使用outline的CSS属性给元素添加一个边框。由于渲染的outline是不在CSS盒模型中的，所以为元素添加outline并不会影响元素的大小和页面的布局。

4）生成随机颜色
~~(Math.random()*(1<<24))).toString(16)  
①Math.random()*(1<<24) 可以得到 0~2^24 - 1 之间的随机数，使用了位操作
②因为得到的是一个浮点数，但我们只需要整数部分，使用取反操作符 ~ 连续两次取反获得整数部分，使用两个波浪号等价于使用parseInt，
const a =12.34;
~~a == parseInt(a, 10); // true  
③然后再用 toString(16) 的方式，转换为一个十六进制的字符串。toString()方法将数值转换成字符串时，接收一个参数用以指明数值的进制。如果省略了该参数，则默认采用十进制，但你可以指定为其他的进制，
```


### Day61:写出执行结果,并解释原因
```js
var yideng_a = Function.length;
var yideng_b = new Function().length;
console.log(yideng_a === yideng_b);
```

```js
// 答案&解析
①每个 JavaScript 函数实际上都是一个 Function 对象。运行 (function(){}).constructor === Function,true 便可以得到这个结论。
②全局的 Function 对象没有自己的属性和方法，但是，因为它本身也是一个函数，所以它也会通过原型链从自己的原型链 Function.prototype 上继承一些属性和方法。
③length是函数对象的一个属性值，指该函数有多少个必须要传入的参数，即形参的个数。与之对比的是，  arguments.length 是函数被调用时实际传参的个数。
④length 是函数对象的一个属性值，指该函数有多少个必须要传入的参数，即形参的个数。
形参的数量不包括剩余参数个数，仅包括第一个具有默认值之前的参数个数。
Function 构造器本身也是个Function。他的 length 属性值为 1 。该属性 Writable: false, Enumerable: false, Configurable: true.Function  原型对象的 length 属性值为 0 。
```


### Day62:不借助中间变量交换两个变量的值
```js
不借助中间变量交换两个变量的值
比如 let a = 1,b = 2;交换a,b的值
```

```js
// 答案&解析
1）利用加法
let a = 1,b = 2;
b = a + b;
a = b - a;
b = b - a;
缺点：利用加法 a+b;有溢出风险

2）利用减法
let a = 1,b = 2;
b = a - b;
a = a - b;
b = a + b;
这样就解决了加法溢出的风险，理论上已经很完美了,继续往下看

3）es6解构赋值
let a = 1,b = 2;
[a,b]=[b,a]

4）按位异或^
这里用到了异或这个位运算的性质，即相同则为 0，不同则为 1
对于两个数字，a 和 b。则有 a ^ a ^ b 就等于 b 。我们可以利用这个性质来完成交换。
let a = 1,b = 2;
b = a ^ b; 
a = a ^ b; // a = a ^ a ^ b
b = a ^ b; // b = a ^ b ^ b

过程解释：
a = 1 -> 01
b = 2 -> 10
a ^ a -> 01 ^ 01 -> 肯定是00，因为相同为0
a ^ a ^ b -> 00 ^ 10 -> 还是 10 -> b
a ^ b ^ b->
	①过程：01 ^ 10 ^ 10 -> 11 ^ 10 -> 01 -> a
	②其实这里涉及到离散数学的异或运算性质：交换律：a ^ b ^ c  <=> a ^ c ^ b
  还有其它性质：任何数于0异或为任何数 0 ^ n => n，相同的数异或为0: n ^ n => 0

5）逗号表达式
逗号表达式是将两个及其以上的式子联接起来，从左往右逐个计算表达式，整个表达式的值为最后一个表达式的值。
利用这个性质，先完成一次赋值操作，然后将赋值操作的返回值变为0. 就可以完成赋值操作
let a = 1,b = 2;
a = b + ((b=a),0);
```


### Day63:实现一个isNegtiveZero函数，只检查+0和-0，-0则返回true,+0返回false
```js
// 实现一个isNegtiveZero函数，只检查+0和-0，-0则返回true,+0返回false
function isNegtiveZero(num){
  // 代码实现
}
```

```js
// 答案与解析
在 JavaScript 中, Number 是一种 定义为 64位双精度浮点型（double-precision 64-bit floating point format） (IEEE 754)的数字数据类型，首位是符号位，然后是52位的整数位和11位的小数位。如果符号位为1，其他各位均为0，那么这个数值会被表示成“-0”。
所以JavaScript的“0”值有两个，+0和-0。
1）解题思路
①看到+0和-0，大概想尝试把该数字通过toString()转化成字符串，在使用indexOf('-')判断是否等于0，或者charAt(0)判断是否等于-。很不幸，数值在进行toString()的时候就自动将其转为0了，所以此方法行不通。
②可以尝试另外一个思路，计算机在进行四则及与或模等数值运算时，符号本身也参与运算，JavaScript亦是如此。而使用0对一个数做加减操作对本身是无影响的，乘法虽然得到±0的结果，但是又回到了问题本身对±0的判断了，因此我们可以考虑到除法，加上数值本身有Infinity和-Infinity的区分，分别表示正无穷和负无穷。我们很容易想到使用一个数值来除以±0得到±Infinity。我们使用-1/0或1/-0都得到-Infinity的结果。
③同样的，JavaScript提供很多函数供你使用，但结果不外乎都是借助一个数值进行判断。如：Math.pow(-0, -1) === -Infinity，Math.atan2(-0, -1) === -Math.PI
2）参考答案
①实现方式一
function isNegtiveZero(num) {
  if (num !== 0) {
    throw new RangeError("The argument must be +0 or -0");
  }
  return 1 / num === -Infinity;
}
console.log(isNegtiveZero(+0));
console.log(isNegtiveZero(-0));
②实现方式2
ECMAScript2015添加了一个方法Object.is用于对两数值进行比较，可以用于比较±0
Object.is(+0, 0) === true;
Object.is(-0, 0) === false;

function isNegtiveZero(num) {
  if (num !== 0) {
    throw new RangeError("The argument must be +0 or -0");
  }
  return !Object.is(num, 0);
}
console.log(isNegtiveZero(+0));
console.log(isNegtiveZero(-0));
```


### Day64:补全代码
```js
/*
	说明：该文件名未知，位于当前项目内的dist/scripts文件夹内
	要求：一句话补全代码，获取它的完整位置:http://xx.com/dis/scripts/xx.js
	注：非node环境，node可以使用__dirname
*/
const url = ✍️代码书写处；
export default url;
```

```js
// 答案与解析
const url = import.meta.url
es2020新特性
```


### Day65:选择正确的选项
```js
class YiDeng {
  static str = '京程一灯';
	sayStr = ()=>{
    throw new Error('Need to implement');
  }
}
class Student extends YiDeng(){
  constructor(){
    super();
  }
  sayStr(){
    console.log(Student.str);
  }
}
const laoyuan = new Student();
console.log(Student.str);
laoyuan.sayStr();

//A.undefiend， 报错Need to implement
// B. undefiend, 京程一灯
// C. undefined, undefined
// D.京程一灯， 报错Need to implement
// E. 京程一灯，京程一灯
// F.京程一灯，undefined
// G. str is not defined, 京程一灯
```

```js
// 答案与解析
答案：选D
①在ES中类的继承是可以继承静态属性的，不晓得同学可以使用babel编译之后就可以很清晰的看到了
②在 class 里用 = 号声明的变量属于 Field declarations 的语法，下面是TC39规范，也就证明了实际Yideng的sayStr被挂载到了实例属性上，读取优于原型链
https://github.com/tc39/proposal-class-fields#field-declarations
```


### Day66:一个简单的算法题目
```js
给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那两个整数，这两个整数可能有多种组合，找出其中一组组合即可，并返回他们的数组下标。

示例:
给定 nums = [2, 7, 11, 15], target = 9
因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]
```

```js
// 答案与解析

// 最容易想到的就是暴力枚举，我们可以利用两层 for 循环来遍历每个元素，并查找满足条件的目标元素。不过这样时间复杂度为 O(N^2)，空间复杂度为 O(1)，时间复杂度较高，我们要想办法进行优化。我们可以增加一个 Map 记录已经遍历过的数字及其对应的索引值。这样当遍历一个新数字的时候去 Map 里查询，target 与该数的差值是否已经在前面的数字中出现过。如果出现过，那么已经得出答案，就不必再往下执行了。

/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
const twoSum = function (nums, target) {
    const map = new Map();
    for (let i = 0; i < nums.length; i++) {
        const diff = target - nums[i];
        if (map.has(diff)) {
            return [map.get(diff), i];
        }
        map.set(nums[i], i);
    }
}

```


### Day67:写出执行结果,并解释原因
```js
3.toString()
3..toString()
3...toString()
```

```js
// 答案与解析
报错  "3" 报错
运算符优先级问题
点运算符会被优先识别为数字常量的一部分，然后才是对象属性访问符
在JavaScript中，3.1，3.，.1都是合法的数字
3.toString() 会被JS引擎解析成 (3.)toString() 报错
3..toString() 会被JS引擎解析成 (3.).toString() "3"
3...toString() 会被JS引擎解析成 (3.)..toString() 报错
```


### Day68:写出执行结果,并解释原因
```js
function yideng(){}
const a = {}, b = Object.prototype;
console.log(a.prototype === b);
console.log(Object.getPrototypeOf(a) === b);
console.log(yideng.prototype === Object.getPrototypeOf(yideng));
```

```js
// 答案
false true false

//知识点
__proto__（隐式原型）与prototype（显式原型）
1）是什么？
①显式原型 explicit prototype property：
每一个函数在创建之后都会拥有一个名为prototype的属性，这个属性指向函数的原型对象。(需要注意的是，通过Function.prototype.bind方法构造出来的函数是个例外，它没有prototype属性)
②隐式原型 implicit prototype link：
JavaScript中任意对象都有一个内置属性[[prototype]]，在ES5之前没有标准的方法访问这个内置属性，但是大多数浏览器都支持通过__proto__来访问。ES5中有了对于这个内置属性标准的Get方法Object.getPrototypeOf()。(注意：Object.prototype 这个对象是个例外，它的__proto__值为null)
③二者的关系：
隐式原型指向创建这个对象的函数(constructor)的prototype

2）作用是什么？
①显式原型的作用：用来实现基于原型的继承与属性的共享。
②隐式原型的作用：构成原型链，同样用于实现基于原型的继承。举个例子，当我们访问obj这个对象中的x属性时，如果在obj中找不到，那么就会沿着__proto__依次查找。

3）__proto__的指向：
__proto__的指向到底如何判断呢？根据ECMA定义 'to the value of its constructor’s "prototype" ' ----指向创建这个对象的函数的显式原型。
所以关键的点在于找到创建这个对象的构造函数，接下来就来看一下JS中对象被创建的方式，一眼看过去似乎有三种方式：（1）对象字面量的方式 （2）new 的方式 （3）ES5中的Object.create()。
但是本质上只有一种方式，也就是通过new来创建。为什么这么说呢，首先字面量的方式是一种为了开发人员更方便创建对象的一个语法糖，本质就是 var o = new Object(); o.xx = xx;o.yy=yy; 

//解析：

1）a.prototype === b  =>false
prototype属性是只有函数才特有的属性，当你创建一个函数时，js会自动为这个函数加上prototype属性，值是一个空对象。而实例对象是没有prototype属性的。所以a.prototype是undefined,第一个结果为false。

2）Object.getPrototypeOf(a) === b =>true
首先要明确对象和构造函数的关系，对象在创建的时候，其__proto__会指向其构造函数的prototype属性
Object实际上是一个构造函数（typeof Object的结果为"function"）,使用字面量创建对象和new Object创建对象是一样的，所以a.__proto__也就是Object.prototype，所以Object.getPrototypeOf(a)与a.__proto__是一样的，第二个结果为true

3）yideng.prototype === Object.getPrototypeOf(yideng) =>false
关键点：f.prototype和Object.getPrototypeOf(f)说的不是一回事

①f.prototype 是使用使用 new 创建的 f 实例的原型:
f.prototype === Object.getPrototypeOf(new f()); // true

②Object.getPrototypeOf(f)是 f 函数的原型:
Object.getPrototypeOf(f) === Function.prototype; //true

所以答案是 false
```


### Day69:写出执行结果,并解释原因
```js
const lowerCaseOnly =  /^[a-z]+$/;
console.log(lowerCaseOnly.test('yideng'));
console.log(lowerCaseOnly.test(null));
console.log(lowerCaseOnly.test());
```

```js
// 答案
true true true
// 解析
test方法的参数会被调用toString强制转换成字符串
此题转换的字符串是null、undefined
```


### Day70:写出执行结果,并解释原因
```js
function captureOne(re, str) {
  var match = re.exec(str);
  return match && match[1];
}
var numRe  = /num=(\d+)/ig,
    wordRe = /yideng=(\w+)/i,
    a1 = captureOne(numRe,  "num=1"),
    a2 = captureOne(wordRe, "yideng=1"),
    a3 = captureOne(numRe,  "NUM=2"),
    a4 = captureOne(wordRe,  "YIDENG=2"),
		a5 = captureOne(numRe,  "Num=3"),
    a6 = captureOne(wordRe,  "YiDeng=3");
console.log(a1 === a2);
console.log(a3 === a4);
console.log(a5 === a6);
```

```js
// 答案
 true false true
// 解析
1）exec() 方法在一个指定字符串中执行一个搜索匹配。返回一个结果数组或 null。
2）但是在Javascript中使用exec进行正则表达式全局匹配时要注意：
	①在全局模式下，当 exec() 找到了与表达式相匹配的文本时，在匹配后，它将把正则表达式对象的   			②lastIndex 属性设置为匹配文本的最后一个字符的下一个位置。
	③这就是说，您可以通过反复调用 exec() 方法来遍历字符串中的所有匹配文本。
	④当 exec() 再也找不到匹配的文本时，它将返回 null，并把 lastIndex 属性重置为 0。
3）所以在全局模式下，如果在一个字符串中完成了一次模式匹配之后要开始检索新的字符串，就必须手动地把 lastIndex 属性重置为 0。
```


### Day71:[手写代码]实现Promise.all方法

```js
// 核心思路
①接收一个 Promise 实例的数组或具有 Iterator 接口的对象作为参数
②这个方法返回一个新的 promise 对象，
③遍历传入的参数，用Promise.resolve()将参数"包一层"，使其变成一个promise对象
④参数所有回调成功才是成功，返回值数组与参数顺序一致
⑤参数数组其中一个失败，则触发失败状态，第一个触发失败的 Promise 错误信息作为 Promise.all 的错误信息。

// 实现代码
一般来说，Promise.all 用来处理多个并发请求，也是为了页面数据构造的方便，将一个页面所用到的在不同接口的数据一起请求过来，不过，如果其中一个接口失败了，多个请求也就失败了，页面可能啥也出不来，这就看当前页面的耦合程度了～

//代码实现
function promiseAll(promises) {
  return new Promise(function(resolve, reject) {
    if(!Array.isArray(promises)){
        throw new TypeError(`argument must be a array`)
    }
    var resolvedCounter = 0;
    var promiseNum = promises.length;
    var resolvedResult = [];
    for (let i = 0; i < promiseNum; i++) {
      Promise.resolve(promises[i]).then(value=>{
        resolvedCounter++;
        resolvedResult[i] = value;
        if (resolvedCounter == promiseNum) {
            return resolve(resolvedResult)
          }
      },error=>{
        return reject(error)
      })
    }
  })
}

// test
let p1 = new Promise(function (resolve, reject) {
    setTimeout(function () {
        resolve(1)
    }, 1000)
})
let p2 = new Promise(function (resolve, reject) {
    setTimeout(function () {
        resolve(2)
    }, 2000)
})
let p3 = new Promise(function (resolve, reject) {
    setTimeout(function () {
        resolve(3)
    }, 3000)
})
promiseAll([p3, p1, p2]).then(res => {
    console.log(res) // [3, 1, 2]
})
```


### Day72:有效括号算法题
```js
/*
	给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串，判断字符串是否有效
  有效字符串需满⾜：
 	 	1. 左括号必须⽤相同类型的右括号闭合。
  	2. 左括号必须以正确的顺序闭合。
  注意空字符串可被认为是有效字符串。
  示例1：
  	输⼊: "()"
  	输出: true
  示例2：
  	输⼊: "()[]{}"
  	输出: true
  示例 3:
  	输⼊: "(]"
  	输出: false
  示例 4:
  	输⼊: "([)]"
  	输出: false
  示例 5:
  	输⼊: "{[]}"
  	输出: true
*/
```

```js
// 思路
1）首先，我们通过上边的例子可以分析出什么样子括号匹配是复合物条件的，两种情况。
	①第一种（非嵌套情况）：{} [] ；
	②第二种（嵌套情况）：{ [ ( ) ] } 。
除去这两种情况都不是符合条件的。
2）然后，我们将这些括号自右向左看做栈结构，右侧是栈顶，左侧是栈尾。
3）如果编译器中的括号是左括号，我们就入栈（左括号不用检查匹配）；如果是右括号，就取出栈顶元素检查是否匹配。
4）如果匹配，就出栈。否则，就返回 false；

// 代码实现
var isValid = function(s){
  let stack = [];
  var obj = {
     "[": "]",
     "{": "}",
     "(": ")",
  };
  // 取出字符串中的括号
  for (var i = 0; i < s.length;i++){
    if(s[i] === "[" || s[i] === "{" || s[i] === "("){
      // 如果是左括号，就进栈
      stack.push(s[i]);
    }else{
   		var key = stack.pop();
      // 如果栈顶元素不相同，就返回false
      if(obj[key] !== s[i]){
        return false;
      }
    }
  }
  return stack.length ===  0
}
```


### Day73:写出执行结果,并解释原因
```js
function yideng(n,o){
    console.log(o); // ？
    return {
        yideng:function(m){
            return yideng(m,n);
        }
    }
}
const a=yideng(0);a.yideng(1);a.yideng(2);a.yideng(3);
const b=yideng(0).yideng(1).yideng(2).yideng(3);
const c = yideng(0).yideng(1);c.yideng(2);c.yideng(3);
```

```js
// 答案
undefined 0 0 0 
undefined 0 1 2
undefined 0 1 1

// 解析
闭包知识考查
	return返回的对象的fun属性对应一个新建的函数对象，这个函数对象将形成一个闭包作用域，使其	能够访问外层函数的变量n及外层函数fun,
关键点：
	理清执行的是哪个yideng函数，为了不将yideng函数与yideng属性混淆，等价转换下代码
  function _yideng_(n,o){
      console.log(o);
      return {
          yideng:function(m){
              return _yideng_(m,n);
          }
      }
  }
  const a=_yideng_(0);a.yideng(1);a.yideng(2);a.yideng(3);
  const b=_yideng_(0).yideng(1).yideng(2).yideng(3);
  const c = _yideng_(0).yideng(1).yideng(2);c.yideng(3);

1）第一行a代码执行过程解析，
①const a=_yideng_(0);调用最外层的函数，只传入了n,所以打印o是undefined
②a.yideng(1);调用yideng(1)时m为1，此时yideng闭包了外层函数的n，也就是第一次调用的n=0，即m=1，n=0，并在内部调用第一层_yideng_函数_yideng_(1,0);所以o为0；
③a.yideng(2);调用yideng(2)时m为2，但依然是调用a.yideng，所以还是闭包了第一次调用时的n，所以内部调用第一层的_yideng_(2,0);所以o为0
④a.yideng(3);同③
所以是undefined 0 0 0

2）第二行b代码执行过程解析
①第一次调用第一层_yideng_(0)时，o为undefined；
②第二次调用 .yideng(1)时m为1，此时yideng闭包了外层函数的n，也就是第一次调用的n=0，即m=1，n=0，并在内部调用第一层_yideng_函数_yideng_(1,0);所以o为0；
③第三次调用 .yideng(2)时m为2，此时当前的yideng函数不是第一次执行的返回对象，而是第二次执行的返回对象。而在第二次执行第一层_yideng_(1,0)时,n=1,o=0,返回时闭包了第二次的n，遂在第三次调用第三层fun函数时m=2,n=1，即调用第一层_yideng_函数_yideng_(2,1)，所以o为1；
④第四次调用 .yideng(3)时m为3，闭包了第三次调用的n，同理，最终调用第一层_yideng_函数为_yideng_(3,2)；所以o为2；
所以是undefined 0 1 2

3）第三行c代码执行过程解析
①在第一次调用第一层_yideng_(0)时，o为undefined；
②第二次调用 .yideng(1)时m为1，此时yideng闭包了外层函数的n，也就是第一次调用的n=0，即m=1，n=0，并在内部调用第一层_yideng_函数fun(1,0);所以o为0；
③第三次调用 .yideng(2)时m为2，此时yideng闭包的是第二次调用的n=1，即m=2，n=1，并在内部调用第一层_yideng_函数_yideng_(2,1);所以o为1；
④第四次.yideng(3)时同理，但依然是调用的第二次的返回值，遂最终调用第一层fun函数_yideng_(3,1)，所以o还为1
所以是undefined 0 1 1
```


### Day74:写出执行结果,并解释原因
```js
var arr1 = "ab".split('');
var arr2 = arr1.reverse(); 
var arr3 = "abc".split('');
arr2.push(arr3);
console.log(arr1.length);
console.log(arr1.slice(-1));
console.log(arr2.length);
console.log(arr2.slice(-1));
```

```js
// 答案
3 ["a","b","c"] 3 ["a","b","c"]

//解析
这个题其实主要就是考察的reverse会返回该数组的引用，但是容易被迷惑，导致答错，如果知道这个点，就不会掉坑里了。

1）reverse
MDN 上对于 reverse() 的描述是酱紫的：
The reverse method transposes the elements of the calling array object in place, mutating the array, and returning a reference to the array.
reverse 方法颠倒数组中元素的位置，改变了数组，并返回该数组的引用。

2）slice
slice() 方法返回一个新的数组对象，这一对象是一个由 begin 和 end 决定的原数组的浅拷贝（包括 begin，不包括end）。原始数组不会被改变。
如果该参数为负数， 则它表示在原数组中的倒数第几个元素结束抽取。 slice(-2,-1) 表示抽取了原数组中的倒数第二个元素到最后一个元素（不包含最后一个元素，也就是只有倒数第二个元素）。
```


### Day75:写出执行结果,并解释原因
```js
var F = function(){}
Object.prototype.a = function(){
console.log('yideng')
}
Function.prototype.b = function(){
console.log('xuetang')
}
var f = new F()
F.a();
F.b();
f.a();
f.b();
```

```js
// 答案
yideng xuetang yideng 报错
//解析
1）F.a();F.b();
F是个构造函数，而f是构造函数F的一个实例。
因为F instanceof Object == true、F instanceof Function == true
由此我们可以得出结论：F是Object 和 Function两个的实例，即F既能访问到a，也能访问到b。
所以F.a() 输出 yideng F.b() 输出 xuetang

2）f.a();f.b();
对于f，我们先来看下下面的结果：
f并不是Function的实例，因为它本来就不是构造函数，调用的是Function原型链上的相关属性和方法了，只能访问Object原型链。
所以f.a() 输出 yideng 而f.b()就报错了。

3）具体分析下它们是如何按路径查找的：
①f.a的查找路径: f自身: 没有 ---> f.__proto__(Function.prototype),没有--->f.__proto__.__proto__(Object.prototype): 输出yideng
②f.b的查找路径: f自身: 没有 ---> f.__proto__(Function.prototype): 没有 ---> f.__proto__.__proto__ (Object.prototype): 因为找不到，所以报错
③F.a的查找路径: F自身: 没有 ---> F.__proto__(Function.prototype): 没有 ---> F.__proto__.__proto__(Object.prototype): 输出 yideng
④F.b的查找路径: F自身: 没有 ---> F.__proto__(Function.prototype): xuetang
```


### Day76:写出执行结果,并解释原因
```js
const a = [1,2,3],
    b = [1,2,3],
    c = [1,2,4],
		d = "2",
		e = "11";
console.log([a == b, a === b, a > c, a < c, d > e]);
```

```js
// 答案
[false,false,false,true,true] 

// 解析
1）JavaScript 有两种比较方式：严格比较运算符和转换类型比较运算符。
	对于严格比较运算符（===）来说，仅当两个操作数的类型相同且值相等为 true，而对于被广泛使用的比较运算符（==）来说，会在进行比较之前，将两个操作数转换成相同的类型。对于关系运算符（比如 <=）来说，会先将操作数转为原始值，使它们类型相同，再进行比较运算。
	当两个操作数都是对象时，JavaScript会比较其内部引用，当且仅当他们的引用指向内存中的相同对象（区域）时才相等，即他们在栈内存中的引用地址相同。
	javascript中Array也是对象，所以这里a,b,c显然引用是不相同的，所以这里a==b,a===b都为false。

2）两个数组进行大小比较，也就是两个对象进行比较
	当两个对象进行比较时，会转为原始类型的值，再进行比较。对象转换成原始类型的值，算法是先调用valueOf方法；如果返回的还是对象，再接着调用toString方法。
①valueOf() 方法返回指定对象的原始值。
  JavaScript调用valueOf方法将对象转换为原始值。你很少需要自己调用valueOf方法；当遇到要预期的原始值的对象时，JavaScript会自动调用它。默认情况下，valueOf方法由Object后面的每个对象继承。 每个内置的核心对象都会覆盖此方法以返回适当的值。如果对象没有原始值，则valueOf将返回对象本身。
②toString() 方法返回一个表示该对象的字符串。
  每个对象都有一个 toString() 方法，当该对象被表示为一个文本值时，或者一个对象以预期的字符串方式引用时自动调用。默认情况下，toString() 方法被每个 Object 对象继承。如果此方法在自定义对象中未被覆盖，toString() 返回 "[object type]"，其中 type 是对象的类型。
③经过valueOf,toString的处理，所以这里a,c最终会被转换为"1,2,3"与"1,2,4";

3）两个字符串进行比较大小
	上边的数组经转换为字符串之后，接着进行大小比较。
	MDN中的描述是这样的：字符串比较则是使用基于标准字典的 Unicode 值来进行比较的。
	字符串按照字典顺序进行比较。JavaScript 引擎内部首先比较首字符的 Unicode 码点。如果相等，再比较第二个字符的 Unicode 码点，以此类推。
	所以这里 "1,2,3" < "1,2,4",输出true,因为前边的字符的unicode码点都相等，所以最后是比较3和4的unicode码点。而3的Unicode码点是51,4的uniCode码点是52，所以a<c。
"2" > "11"也是同理，这个也是开发中有时会遇到的问题，所以在进行运算比较时需要注意一下。

4）关于valueOf，toString的调用顺序
①javascript中对象到字符串的转换经历的过程如下：
	如果对象具有toString()方法，javaScript会优先调用此方法。如果返回的是一个原始值（原始值包括null、undefined、布尔值、字符串、数字），javaScript会将这个原始值转换为字符串，并返回字符串作为结果。
	如果对象不具有toString()方法，或者调用toString()方法返回的不是原始值，则javaScript会判断是否存在valueOf()方法，如若存在则调用此方法，如果返回的是原始值，javaScript会将原始值转换为字符串作为结果。
  如果javaScript无法调用toString()和valueOf()返回原始值的时候，则会报一个类型错误异常的警告。
	比如：String([1,2,3]);将一个对象转换为字符串
	
②javaScript中对象转换为数字的转换过程：
	javaScript优先判断对象是否具有valueOf()方法，如具有则调用，若返回一个原始值，javaScript会将原始值转换为数字并作为结果。
	如果对象不具有valueOf()方法，javaScript则会调用toString()的方法，若返回的是原始值，javaScript会将原始值转换为数字并作为结果。
	如果javaScript无法调用toString()和valueOf()返回原始值的时候，则会报一个类型错误异常的警告。
	比如：Number([1,2,3]);将一个对象转换为字符串
```


### Day77:补充代码，使代码可以正确执行
```js
const str = '1234567890';
function formatNumber(str){
  // your code
}
console.log(formatNumber(str)); //1,234,567,890
// 补充代码，使代码可以正确执行
```

```js
//代码实现
/*
	1.普通版
	优点：比for循环，if-else判断的逻辑清晰直白一些
	缺点：太普通
*/
function formatNumber(str){
  let arr = [],
      count = str.length;
  while(count >= 3){
    // 将字符串3个一组存入数组
    arr.unshift(str.slice(count-3,count));
    count -= 3;
  }
  // 如果不是3的倍数就另外追加到数组
  str.length % 3 && arr.unshift(str.slice(0,str.length % 3));
  return arr.toString();
}
console.log(formatNumber('1234567890'));

/*
	2.进阶版
	优点：JS的API玩的了如之掌
	缺点：可能没那么好懂，但是读懂之后就会发出怎么没想到的感觉
*/
function formatNumber(str){
  //str.split('').reverse() => ["0", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
  return str.split('').reverse().reduce((prev,next,index) => {
    return ((index % 3) ? next : (next + ',')) + prev
  })
}
console.log(formatNumber("1234567890"));

/*
	3.正则版
	优点：代码少，浓缩的都是精华
	缺点：需要对正则表达式的位置匹配有一个较深的认识，门槛大一点
*/
function formatNumber(str) {
  /*
  	①/\B(?=(\d{3})+(?!\d))/g：正则匹配非单词边界\B，即除了1之前的位置，其他字符之间的边界，后面必须跟着3N个数字直到字符串末尾
		②(\d{3})+：必须是1个或多个的3个连续数字;
		③(?!\d)：第2步中的3个数字不允许后面跟着数字;
  */
  return str.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}
console.log(formatNumber("1234567890")) // 1,234,567,890

/*
	4.Api版
	优点：简单粗暴，直接调用 API
	缺点：Intl兼容性不太好，不过 toLocaleString的话 IE6 都支持
*/
 // ①toLocaleString：方法返回这个数字在特定语言环境下的表示字符串，具体可看MDN描述
function formatNumber(str){
  return Number(str).toLocaleString('en-US');
}
console.log(formatNumber("1234567890"));

 // ②还可以使用IntL对象
// Intl 对象是 ECMAScript 国际化 API 的一个命名空间，它提供了精确的字符串对比，数字格式化，日期和时间格式化。Collator，NumberFormat 和 DateTimeFormat 对象的构造函数是 Intl 对象的属性。
function formatNumber(str){
  return new Intl.NumberFormat().format(str);
}
console.log(formatNumber("1234567890"));
```


### Day79:写出下面代码null和0进行比较的代码执行结果，并解释原因
```js
console.log(null == 0);
console.log(null <= 0);
console.log(null < 0);
```

### 答案

```js
false true false
```

### 解析

1. 在JavaScript中，null不等于零，也不是零。
2. null只等于undefined 剩下它俩和谁都不等
3. 关系运算符，在设计上总是需要运算元尝试转为一个number，而相等运算符在设计上，则没有这方面的考虑。所以 计算null<=0 或者>=0的时候回触发Number(null)，它将被视为0（Number(null) == 0为true）


### Day80:关于数组sort，下面代码的正确打印结果是什么，并解释原因
```js
const arr1 = ['a', 'b', 'c'];
const arr2 = ['b', 'c', 'a'];
console.log(
  arr1.sort() === arr1,
  arr2.sort() == arr2,
  arr1.sort() === arr2.sort()
);
```

### 答案

```js
true, true, false
```

### 解析

1. array 的 sort 方法对原始数组进行排序，并返回对该数组的引用。调用 arr2.sort() 时，arr2 数组内的对象将会被排序。
2. 当你比较对象时，数组的排序顺序并不重要。由于 arr1.sort() 和 arr1 指向内存中的同一对象，因此第一个相等测试返回 true。第二个比较也是如此：arr2.sort() 和 arr2 指向内存中的同一对象。
3. 在第三个测试中，arr1.sort() 和 arr2.sort() 的排序顺序相同；但是，它们指向内存中的不同对象。因此，第三个测试的评估结果为 false。


### Day81:介绍防抖与节流的原理，并动手实现
```js
const debounce = (fn,delay) => {
  // 介绍防抖函数原理，并实现
  // your code
}
const throttle = (fn,delay = 500) => {
  // 介绍节流函数原理，并实现
   // your code
}
```

### 答案与解析

##### 1）防抖函数

**防抖函数原理：**

在事件被触发n秒后再执行回调，如果在这n秒内又被触发，则重新计时。

**适用场景：**

1. 按钮提交场景：防止多次提交按钮，只执行最后提交的一次
2. 服务端验证场景：表单验证需要服务端配合，只执行一段连续的输入事件的最后一次，还有搜索联想词功能类似

```js
// 手写简化版实现
const debounce = (fn,delay) => {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      fn.apply(this,args);
    },delay)
  }
}
```

##### 2）节流函数

**节流函数原理：**

规定在一个单位时间内，只能触发一次函数。如果这个单位时间内触发多次函数，只有一次生效。防抖是延迟执行，而节流是间隔执行，函数节流即每隔一段时间就执行一次

**适用场景：**

1. 拖拽场景：固定时间内只执行一次，防止超高频次触发位置变动
2. 缩放场景：监控浏览器resize
3. 动画场景：避免短时间内多次触发动画引起性能问题

```js
// 手写简化版实现
// ①定时器实现
const throttle = (fn,delay = 500) =>{
  let flag = true;
  return (...args) => {
    if(!flag) return;
    flag = false;
    setTimeout(() => {
      fn.apply(this,args);
      flag = true;
    },delay);
  };
}
// ②时间戳实现
const throttle = (fn,delay = 500) => {
  let preTime = Date.now();
  return (...args) => {
    const nowTime = Date.now();
    if(nowTime - preTime >= delay){
      	preTime = Date.now();
      	fn.apply(this,args);
    }
  }
}
```


### Day82:关于隐式转换，下面代码的执行结果是什么？并解释原因

```js
let a = [];
let b = "0";
console.log(a == 0);
console.log(a == !a);
console.log(b == 0);
console.log(a == b);
```

### 答案

```js
true true true false
```

### 解析

**1）[] == 0 => true**

对象与原始类型值相等比较，对象类型会依照ToPrimitive规则转换成原始类型的值再进行比较。

①[] == 0 =>[].valueOf().toSting() == 0 =>  '' == 0

数组[]是对象类型，所以会进行ToPrimitive操作，即调用valueOf再调用toString,数组被转换为空字符串'',

②'' == 0 => Number('') == 0 => 0 == 0 => true

空字符串再和数字0比较时，比较的是原始类型的值,原始类型的值会转成数值再进行比较,所以最后得到true

**2）[] == ![] => true**

!的优先级高于==，所以先执行!，将[]转为boolean值，null、undefined、NaN以及空字符串('')取反都为true，其余都为false，所以![]为false

[] == false => 如果有一个操作数是布尔值，则在比较相等性之前先将其转换为数值 => [] == 0 => 同第一问 => true

**3）"0" == 0 => true**

如果比较的是原始类型的值，原始类型的值会转成数值再进行比较

Number('0') => 0 => 0 == 0 => true

**4）[] == "0" => false**

根据1）可以知道[] 被转换为了 '' , 所以'' == '0'，为false

### 知识点

#### 1.ToString、ToNumber、ToBoolean、ToPrimitive转换规则：

**1）ToString**

这里所说的ToString可不是对象的toString方法，而是指其他类型的值转换为字符串类型的操作。

看下null、undefined、布尔型、数字、数组、普通对象转换为字符串的规则：

1. null：转为"null"
2. undefined：转为"undefined"
3. 布尔类型：true和false分别被转为"true"和"false"
4. 数字类型：转为数字的字符串形式，如10转为"10"， 1e21转为"1e+21"
5. 数组：转为字符串是将所有元素按照","连接起来，相当于调用数组的Array.prototype.join()方法，如[1, 2, 3]转为"1,2,3"，空数组[]转为空字符串，数组中的null或undefined，会被当做空字符串处理
6. 普通对象：转为字符串相当于直接使用Object.prototype.toString()，返回"[object Object]"

**2）ToNumber**

ToNumber指其他类型转换为数字类型的操作。

1. null： 转为0
2. undefined：转为NaN
3. 字符串：如果是纯数字形式，则转为对应的数字，空字符转为0, 否则一律按转换失败处理，转为NaN
4. 布尔型：true和false被转为1和0
5. 数组：数组首先会被转为原始类型，也就是ToPrimitive，然后在根据转换后的原始类型按照上面的规则处理，
6. 对象：同数组的处理

**3）ToBoolean**

ToBoolean指其他类型转换为布尔类型的操作

js中的假值只有false、null、undefined、空字符、0和NaN，其它值转为布尔型都为true。

**4）ToPrimitive**

ToPrimitive指对象类型类型（如：对象、数组）转换为原始类型的操作。

1. 当对象类型需要被转为原始类型时，它会先查找对象的valueOf方法，如果valueOf方法返回原始类型的值，则ToPrimitive的结果就是这个值
2. 如果valueOf不存在或者valueOf方法返回的不是原始类型的值，就会尝试调用对象的toString方法，也就是会遵循对象的ToString规则，然后使用toString的返回值作为ToPrimitive的结果。如果valueOf和toString都没有返回原始类型的值，则会抛出异常。
3. 注意：对于不同类型的对象来说，ToPrimitive的规则有所不同，比如Date对象会先调用toString，

ECMA规则：https://www.ecma-international.org/ecma-262/6.0/#sec-toprimitive
1. Number([])， 空数组会先调用valueOf，但返回的是数组本身，不是原始类型，所以会继续调用toString，得到空字符串，相当于Number('')，所以转换后的结果为"0"
2. 同理，Number(['10'])相当于Number('10')，得到结果10

#### 2.宽松相等(==)比较时的隐士转换规则

宽松相等（==）和严格相等（===）的区别在于宽松相等会在比较中进行隐式转换。

1. 布尔类型和其他类型的相等比较，只要布尔类型参与比较，该布尔类型的值首先会被转换为数字类型
2. 数字类型和字符串类型的相等比较，当数字类型和字符串类型做相等比较时，字符串类型会被转换为数字类型
3. 当对象类型和原始类型做相等比较时，对象类型会依照ToPrimitive规则转换为原始类型
4. 当两个操作数都是对象时，JavaScript会比较其内部引用，当且仅当他们的引用指向内存中的相同对象（区域）时才相等，即他们在栈内存中的引用地址相同。
5. ECMAScript规范中规定null和undefined之间互相宽松相等（==），并且也与其自身相等，但和其他所有的值都不宽松相等（==）


### Day83:请写出如下代码的打印结果，并解释为什么
```js
var obj = {};
var x = +obj.yideng?.name ?? '京程一灯';
console.log(x);
```

### 答案

NaN

### 解析

1. ?省去过去判断key的麻烦。所以 obj.yideng?.name 遇到不存在的值返回undefined
2. +undefined 强制转化number NaN
3. NaN ?? 京程一灯 返回NaN。原因：??为空值合并操作符（是一个逻辑操作符，当左侧的表达式结果为 null 或者 undefined 时，其返回右侧表达式的结果，否则返回左侧表达式的结果。
4. 参考链接：https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing_operator



### Day84:对于length下面代码的输出结果是什么？并解释原因
```js
 function foo(){
   console.log(length);
 }
function bar(){
  var length = "京程一灯";
  foo();
}
bar();
```

### 答案

```js
0 (页面iframe数量)
```

### 解析

1. 首次运行执行foo，foo内寻找length并没有定义
2. 然后很多同学可能会觉得在bar内定义了length。foo内应该寻找到了length
3. 其实函数作用域是在执行函数时创建的，当函数执行结束之后，函数作用域就随之被销毁掉了。所以向上寻找到该是全局的length
4. 那你会觉得length应该是undefined。其实length是你页面iframe的数量



### Day85:对于扩展运算符，下面代码的执行结果是什么？并解释原因
```js
let ydObject = { ...null, ...undefined };
console.log(ydObject);
let ydArray = [...null, ...undefined];
console.log(ydArray);
```


### 答案

```js
{}  抛出异常
```

### 解析

对象会忽略 null 和 undefined，数组会抛异常。这是ECMA的规范定义，所以大家在使用扩展运算符的时候还是要多加注意。这里补充一个其他小知识点，null 只能等于undefined,其余谁也不等。



### Day86:写出类数组转换结果，并解释原因
```js
const arrLike = {
  length:4,
  0:0,
  1:1,
  '-1':2,
  3:3,
  4:4,
}
console.log(Array.from(arrLike));
console.log(Array.prototype.slice.call(arrLike));
```

### 答案

```js
[0,1,undefined,3]
[0,1,empty,3]
```

### 解析

1）类数组是一个拥有length属性，并且他属性为非负整数的普通对象，类数组不能直接调用数组方法。

2）类数组转换为数组的方式

1. 使用 Array.from()
2. 使用 Array.prototype.slice.call()
3. 使用 Array.prototype.forEach() 进行属性遍历并组成新的数组

3）转换须知

  1. 转换后的数组长度由 length 属性决定。索引不连续时转换结果是连续的，会自动补位。
  2. 仅考虑 0或正整数 的索引
  3. 使用slice转换产生稀疏数组

4）扩展

稀疏数组是指索引不连续，数组长度大于元素个数的数组，通俗地说就是 有空隙的数组。

**empty vs undefined**

①稀疏数组在控制台中的表示：

```js
var a = new Array(5);
console.log(a);    // [empty × 5]
```

这里表示数组 a 有5个空隙。 empty 并非 JS 的基础数据类型

访问数组元素：`a[0];    // undefined`

②empty 和 undefined 不是一个含义

```js
var b = [undefined, undefined, undefined];
console.log(b);    // [undefined, undefined, undefined]
b[0];              // undefined

a.forEach(i => { console.log(i) });    // 无 log 输出
b.forEach(i => { console.log(i) });    // undefined undefined undefined
```

数组 a 和 数组 b 只有访问具体元素的时候输出一致，其他情况都是存在差异的。遍历数组 a 时，由于数组中没有任何元素，所以回调函数不执行不会有 log 输出；而遍历数组 b 时，数组其实填充着元素 undefined，所以会打印 log。

这里的数组 b 其实是一个 密集数组。

为什么访问稀疏数组的缺失元素时会返回 undefined，是因为 JS 引擎在发现元素缺失时会临时赋值 undefined，类似于 JS 变量的声明提升：

```js
console.log(a); // undefined
var a = 0;
```

3）稀疏数组跟密集数组相比具有以下特性：

1. 访问速度慢
2. 内存利用率高

4）稀疏数组跟密集数组相比访问速度慢的原因

1. 该特性与 V8 引擎构建 JS 对象的方式有关。V8 访问对象有两种模式：字典模式 和 快速模式。
2. 稀疏数组使用的是字典模式，也称为 散列表模式，该模式下 V8 使用散列表来存储对象属性。由于每次访问时都需要计算哈希值（实际上只需要计算一次，哈希值会被缓存）和寻址，所以访问速度非常慢。另一方面，对比起使用一段连续的内存空间来存储稀疏数组，散列表的方式会大幅度地节省内存空间。
3. 而密集数组在内存空间中是被存储在一个连续的类数组里，引擎可以直接通过数组索引访问到数组元素，所以速度会非常快。


### Day87:写出下面代码1，2，3的大小判断结果
```js
console.log(1 < 2 < 3);
console.log(3 > 2 > 1);
```

### 答案

```js
true false
```

### 解析

1. 对于运算符>、<,一般的计算从左向右
2. 第一个题：1 < 2 等于 true, 然后true < 3，true == 1 ，因此结果是true
3. 第二个题：3 > 2 等于 true, 然后true > 1, true == 1 ，因此结果是false


### Day88:以下两段代码会抛出异常吗？解释原因？
```js
let yd = { x: 1, y: 2 };
// 以下两段代码会抛出异常吗？
let ydWithXGetter1 = {
  ...yd,
  get x() {
    throw new Error();
  },
};

let ydWithXGetter2 = {
  ...yd,
  ...{
    get x() {
      throw new Error();
    },
  },
};
```
### 答案

```js
ydWithXGetter1不会报错 ydWithXGetter2会
```

### 解析

```
// 第一段代码实际等价于如下代码，所以不会报错
let ydWithXGetter1  = {};
Object.assign(ydWithXGetter1, yd);
Object.defineProperty(ydWithXGetter1, "x", {
  get(){ throw new Error() },
  enumerable : true,
  configurable : true
});
// 第二段代码会报错实际解构如下代码时.x被调了
// 原因是读取一个属性的时候会去对象的[[get]]中查找是否有该属性名
...{ get x() { throw new Error() } }
```


### Day89:请问React调用机制一共对任务设置了几种优先级别？每种优先级都代表的具体含义是什么？在你开发过程中如果遇到影响主UI渲染卡顿的任务，你又是如何利用这些优先级的？
null
### 答案

```js
//React 一共有这么6种任务的优先级。
//初始化和重置root和占位用的
export const NoPriority = 0;
//立即执行的优先级 一般用来执行过期的任务
export const ImmediatePriority = 1;
//会阻塞渲染的优先级别，用户和页面交互用的
export const UserBlockingPriority = 2;
//默认优先级 普通的优先级别
export const NormalPriority = 3;
//低优先级别（用户可使用）
export const LowPriority = 4;
//空闲优先级 用户不在意的任务（用户可使用）
export const IdlePriority = 5;

/*
* 开发中怎么使用这些优先级呢？
* Concurrent在目前的React版本中还是实验性的，
* 也请大家及时关注我们的公开课和对新版本的开箱测评
*/
//理想化
React.unstable_scheduleCallback(priorityLevel, callback, { timeout: <number> })
//现实
ReactDOM.createRoot( document.getElementById('container') ).render( <ConcurrentSchedulingExample /> )
```

### Day90:Vue父组件可以监听到子组件的生命周期吗？如果能请写出你的实现方法。
null
### 答案

可以

**1）实现方式一**

比如有父组件 Parent 和子组件 Child，如果父组件监听到子组件挂载 mounted 就做一些逻辑处理，可以通过以下写法实现：

```js
// Parent.vue
<Child @mounted="doSomething"/>
    
// Child.vue
mounted() {
  this.$emit("mounted");
}

```

**2）实现方式二**

以上需要手动通过 $emit 触发父组件的事件，更简单的方式可以在父组件引用子组件时通过 @hook 来监听即可，如下所示：

```js
//  Parent.vue
<Child @hook:mounted="doSomething" ></Child>

doSomething() {
   console.log('父组件监听到 mounted 钩子函数 ...');
},
    
//  Child.vue
mounted(){
   console.log('子组件触发 mounted 钩子函数 ...');
},  

// 以上输出顺序为：
// 子组件触发 mounted 钩子函数 ...
// 父组件监听到 mounted 钩子函数 ...     
```

当然 @hook 方法不仅仅是可以监听 mounted，其它的生命周期事件，例如：created，updated 等都可以监听。


### Day91:Vue 为什么要用 vm.$set() 解决对象新增属性不能响应的问题 ？你能说说如下代码的实现原理么？
```js
Vue.set (object, propertyName, value) 
vm.$set (object, propertyName, value)
```

### 答案

**1）Vue为什么要用vm.$set() 解决对象新增属性不能响应的问题**

1. Vue使用了Object.defineProperty实现双向数据绑定
2. 在初始化实例时对属性执行 getter/setter 转化
3. 属性必须在data对象上存在才能让Vue将它转换为响应式的（这也就造成了Vue无法检测到对象属性的添加或删除）

所以Vue提供了Vue.set (object, propertyName, value) / vm.$set (object, propertyName, value)


**2）接下来我们看看框架本身是如何实现的呢?**

> Vue 源码位置：vue/src/core/instance/index.js

```js
export function set (target: Array<any> | Object, key: any, val: any): any {
  // target 为数组  
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    // 修改数组的长度, 避免索引>数组长度导致splcie()执行有误
    target.length = Math.max(target.length, key)
    // 利用数组的splice变异方法触发响应式  
    target.splice(key, 1, val)
    return val
  }
  // key 已经存在，直接修改属性值  
  if (key in target && !(key in Object.prototype)) {
    target[key] = val
    return val
  }
  const ob = (target: any).__ob__
  // target 本身就不是响应式数据, 直接赋值
  if (!ob) {
    target[key] = val
    return val
  }
  // 对属性进行响应式处理
  defineReactive(ob.value, key, val)
  ob.dep.notify()
  return val
}
```

我们阅读以上源码可知，vm.$set 的实现原理是：

1. 如果目标是数组，直接使用数组的 splice 方法触发相应式；
2. 如果目标是对象，会先判读属性是否存在、对象是否是响应式，
3. 最终如果要对属性进行响应式处理，则是通过调用 defineReactive 方法进行响应式处理

> defineReactive 方法就是  Vue 在初始化对象时，给对象属性采用 Object.defineProperty 动态添加 getter 和 setter 的功能所调用的方法



### Day92:既然 Vue 通过数据劫持可以精准探测数据在具体dom上的变化,为什么还需要虚拟 DOM diff 呢?
null
### 答案

**前置知识:** 依赖收集、虚拟 DOM、响应式系统

现代前端框架有两种方式侦测变化，一种是 **pull** ，一种是 **push**

**pull:** 其代表为React，我们可以回忆一下React是如何侦测到变化的,我们通常会用setStateAPI显式更新，然后React会进行一层层的Virtual Dom Diff操作找出差异，然后Patch到DOM上，React从一开始就不知道到底是哪发生了变化，只是知道「有变化了」，然后再进行比较暴力的Diff操作查找「哪发生变化了」，另外一个代表就是Angular的脏检查操作。

**push:** Vue的响应式系统则是push的代表，当Vue程序初始化的时候就会对数据data进行依赖的收集，一但数据发生变化,响应式系统就会立刻得知。因此Vue是一开始就知道是「在哪发生变化了」，但是这又会产生一个问题，如果你熟悉Vue的响应式系统就知道，通常一个绑定一个数据就需要一个Watcher（具体如何创建的Watcher可以先了解下Vue双向数据绑定的原理如下图）

![vue 双向数据绑定原理](http://img-static.yidengxuetang.com/wxapp/issue-img/day92-vuemodel.png)

一但我们的绑定细粒度过高就会产生大量的Watcher，这会带来内存以及依赖追踪的开销，而细粒度过低会无法精准侦测变化,因此Vue的设计是选择中等细粒度的方案,在组件级别进行push侦测的方式,也就是那套响应式系统,通常我们会第一时间侦测到发生变化的组件,然后在组件内部进行Virtual Dom Diff获取更加具体的差异，而Virtual Dom Diff则是pull操作，Vue是push+pull结合的方式进行变化侦测的。



### Day93:Vue组件中写name选项有除了搭配keep-alive还有其他作用么？你能谈谈你对keep-alive了解么？（平时使用和源码实现方面）
null
### 答案

#### 一、组件中写 name 选项有什么作用？

1. 项目使用 keep-alive 时，可搭配组件 name 进行缓存过滤
2. DOM 做递归组件时需要调用自身 name
3. vue-devtools 调试工具里显示的组见名称是由vue中组件name决定的

#### 二、keep-alive使用

1. keep-alive 是 Vue 内置的一个组件，可以使被包含的组件保留状态，避免重新渲染
2. 一般结合路由和动态组件一起使用，用于缓存组件；
3. 提供 include 和 exclude 属性，两者都支持字符串或正则表达式， include 表示只有名称匹配的组件会被缓存，exclude 表示任何名称匹配的组件都不会被缓存 ，其中 exclude 的优先级比 include 高；
4. 对应两个钩子函数 activated 和 deactivated ，当组件被激活时，触发钩子函数 activated，当组件被移除时，触发钩子函数 deactivated。


#### 三、keep-alive实现原理

**1）首先看下源码**

```js
// 源码位置：src/core/components/keep-alive.js
export default {
  name: 'keep-alive',
  abstract: true, // 判断当前组件虚拟dom是否渲染成真是dom的关键

  props: {
    include: patternTypes, // 缓存白名单
    exclude: patternTypes, // 缓存黑名单
    max: [String, Number] // 缓存的组件实例数量上限
  },

  created () {
    this.cache = Object.create(null) // 缓存虚拟dom
    this.keys = [] // 缓存的虚拟dom的健集合
  },

  destroyed () {
    for (const key in this.cache) { // 删除所有的缓存
      pruneCacheEntry(this.cache, key, this.keys)
    }
  },

  mounted () {
    // 实时监听黑白名单的变动
    this.$watch('include', val => {
      pruneCache(this, name => matches(val, name))
    })
    this.$watch('exclude', val => {
      pruneCache(this, name => !matches(val, name))
    })
  },

  render () {
    // .....
  }
}
```

大概的分析源码，我们发现与我们定义组件的过程一样，先是设置组件名为keep-alive，其次定义了一个abstract属性，值为true。这个属性在vue的官方教程并未提及，其实是一个虚组件，后面渲染过程会利用这个属性。props属性定义了keep-alive组件支持的全部参数。

**2）接下来重点就是keep-alive在它生命周期内定义了三个钩子函数了**

**created**

初始化两个对象分别缓存VNode（虚拟DOM）和VNode对应的键集合

**destroyed**

删除缓存VNode还要对应执行组件实例的destory钩子函数。

删除this.cache中缓存的VNode实例。不是简单地将this.cache置为null，而是遍历调用pruneCacheEntry函数删除。

```js
// src/core/components/keep-alive.js
function pruneCacheEntry (
  cache: VNodeCache,
  key: string,
  keys: Array<string>,
  current?: VNode
) {
  const cached = cache[key]
  if (cached && (!current || cached.tag !== current.tag)) {
    cached.componentInstance.$destroy() // 执行组件的destory钩子函数
  }
  cache[key] = null
  remove(keys, key)
}
```

**mounted**

在mounted这个钩子中对include和exclude参数进行监听，然后实时地更新（删除）this.cache对象数据。pruneCache函数的核心也是去调用pruneCacheEntry。


**3）render**

```js
// src/core/components/keep-alive.js
render () {
const slot = this.$slots.default
const vnode: VNode = getFirstComponentChild(slot) // 找到第一个子组件对象
const componentOptions: ?VNodeComponentOptions = vnode && vnode.componentOptions
if (componentOptions) { // 存在组件参数
    // check pattern
    const name: ?string = getComponentName(componentOptions) // 组件名
    const { include, exclude } = this
    if ( // 条件匹配
    // not included
    (include && (!name || !matches(include, name))) ||
    // excluded
    (exclude && name && matches(exclude, name))
    ) {
    return vnode
    }

    const { cache, keys } = this
    const key: ?string = vnode.key == null // 定义组件的缓存key
    // same constructor may get registered as different local components
    // so cid alone is not enough (#3269)
    ? componentOptions.Ctor.cid + (componentOptions.tag ? `::${componentOptions.tag}` : '')
    : vnode.key
    if (cache[key]) { // 已经缓存过该组件
    vnode.componentInstance = cache[key].componentInstance
    // make current key freshest
    remove(keys, key)
    keys.push(key) // 调整key排序
    } else {
    cache[key] = vnode // 缓存组件对象
    keys.push(key)
    // prune oldest entry
    if (this.max && keys.length > parseInt(this.max)) { 
        // 超过缓存数限制，将第一个删除（LRU缓存算法）
        pruneCacheEntry(cache, keys[0], keys, this._vnode)
    }
    }

    vnode.data.keepAlive = true // 渲染和执行被包裹组件的钩子函数需要用到
}
return vnode || (slot && slot[0])
}
```

- 第一步：获取keep-alive包裹着的第一个子组件对象及其组件名；
- 第二步：根据设定的黑白名单（如果有）进行条件匹配，决定是否缓存。不匹配，直接返回组件实例（VNode），否则执行第三步；
- 第三步：根据组件ID和tag生成缓存Key，并在缓存对象中查找是否已缓存过该组件实例。如果存在，直接取出缓存值并更新该key在this.keys中的位置（更新key的位置是实现LRU置换策略的关键），否则执行第四步；
- 第四步：在this.cache对象中存储该组件实例并保存key值，之后检查缓存的实例数量是否超过max的设置值，超过则根据LRU置换策略删除最近最久未使用的实例（即是下标为0的那个key）。
- 第五步：最后并且很重要，将该组件实例的keepAlive属性值设置为true。

最后就是再次渲染执行缓存和对应钩子函数了








### Day94:说一下React Hooks在平时开发中需要注意的问题和原因？
null
**1）不要在循环，条件或嵌套函数中调用Hook，必须始终在React函数的顶层使用Hook**

这是因为React需要利用调用顺序来正确更新相应的状态，以及调用相应的钩子函数。一旦在循环或条件分支语句中调用Hook，就容易导致调用顺序的不一致性，从而产生难以预料到的后果。

**2）使用useState时候，使用push，pop，splice等直接更改数组对象的坑**

使用push直接更改数组无法获取到新值，应该采用析构方式，但是在class里面不会有这个问题

代码示例

```js
function Indicatorfilter() {
  let [num,setNums] = useState([0,1,2,3])
  const test = () => {
    // 这里坑是直接采用push去更新num
    // setNums(num)是无法更新num的
    // 必须使用num = [...num ,1]
    num.push(1)
    // num = [...num ,1]
    setNums(num)
  }
return (
    <div className='filter'>
      <div onClick={test}>测试</div>
        <div>
          {num.map((item,index) => (
              <div key={index}>{item}</div>
          ))}
      </div>
    </div>
  )
}

class Indicatorfilter extends React.Component<any,any>{
  constructor(props:any){
      super(props)
      this.state = {
          nums:[1,2,3]
      }
      this.test = this.test.bind(this)
  }

  test(){
      // class采用同样的方式是没有问题的
      this.state.nums.push(1)
      this.setState({
          nums: this.state.nums
      })
  }

  render(){
      let {nums} = this.state
      return(
          <div>
              <div onClick={this.test}>测试</div>
                  <div>
                      {nums.map((item:any,index:number) => (
                          <div key={index}>{item}</div>
                      ))}
                  </div>
          </div>
                      
      )
  }
}
```

**3）useState设置状态的时候，只有第一次生效，后期需要更新状态，必须通过useEffect**

看下面的例子

TableDeail是一个公共组件，在调用它的父组件里面，我们通过set改变columns的值，以为传递给TableDeail的columns是最新的值，所以tabColumn每次也是最新的值，但是实际tabColumn是最开始的值，不会随着columns的更新而更新

```js
const TableDeail = ({
    columns,
}:TableData) => {
    const [tabColumn, setTabColumn] = useState(columns) 
}

// 正确的做法是通过useEffect改变这个值
const TableDeail = ({
    columns,
}:TableData) => {
    const [tabColumn, setTabColumn] = useState(columns) 
    useEffect(() =>{setTabColumn(columns)},[columns])
}

```

**4）善用useCallback**

父组件传递给子组件事件句柄时，如果我们没有任何参数变动可能会选用useMemo。但是每一次父组件渲染子组件即使没变化也会跟着渲染一次。

**5）不要滥用useContent**

可以使用基于useContent封装的状态管理工具。


### Day95:Promise.all中任何一个Promise出现错误的时候都会执行reject，导致其它正常返回的数据也无法使用。你有什么解决办法么？
null
**1）在单个的catch中对失败的promise请求做处理**

**2）把reject操作换成 resolve(new Error("自定义的error"))**

**3）引入Promise.allSettled**

```js
const promises = [
    fetch('/api1'),
    fetch('/api2'),
    fetch('/api3'),
  ];
  
  Promise.allSettled(promises).
    then((results) => results.forEach((result) => console.log(result.status)));
  // "fulfilled"
  // "fulfilled"
  // "rejected"

```

**4）安装第三方库 promise-transaction**

```js
// 它是promise事物实现 不仅仅能处理错误还能回滚
  import Transaction from 'promise-transaction';
const t = new Transaction([
  {
    name: 'seed',
    perform: () => Promise.resolve(3),
    rollback: () => false,
    retries: 1, // optionally you can define how many retries you like to run if initial attemp fails for this step
  },
  {
    name: 'square',
    perform: (context) => {
      return Promise.resolve(context.data.seed * context.data.seed);
    },
    rollback: () => false,
  },
]);
 
return t.process().then((result) => {
  console.log(result); // should be value of 9 = 3 x 3
});
```








### Day96:请能尽可能多的说出 Vue 组件间通信方式？在组件的通信中EventBus非常经典，你能手写实现下EventBus么？
null
### 一、Vue组件通信方式

Vue 组件间通信是面试常考的知识点之一，这题有点类似于开放题，你回答出越多方法当然越加分，表明你对 Vue 掌握的越熟练

Vue 组件间通信主要指以下 3 类通信：**父子组件通信、隔代组件通信、兄弟组件通信**

下面我们分别介绍每种通信方式且会说明此种方法可适用于哪类组件间通信。

#### 1.`props` / `$emit`  

**适用于父子组件通信**

这种方法是 Vue 组件的基础，相信大部分同学耳闻能详，所以此处就不举例展开介绍。

#### 2.`ref` 与 `$parent` / `$children` 

**适用于父子组件通信**

- `ref`：如果在普通的 DOM 元素上使用，引用指向的就是 DOM 元素；如果用在子组件上，引用就指向组件实例
- `$parent / $children`：访问父 / 子实例

#### 3.`EventBus （$emit / $on）`

**适用于父子、隔代、兄弟组件通信**

这种方法通过一个空的 Vue 实例作为中央事件总线（事件中心），用它来触发事件和监听事件，从而实现任何组件间的通信，包括父子、隔代、兄弟组件。

#### 4.`$attrs/$listeners`

**适用于隔代组件通信**

- `$attrs`：包含了父作用域中不被 prop 所识别 (且获取) 的特性绑定 ( class 和 style 除外 )。当一个组件没有声明任何 prop 时，这里会包含所有父作用域的绑定 ( class 和 style 除外 )，并且可以通过 v-bind="$attrs" 传入内部组件。通常配合 inheritAttrs 选项一起使用。
- `$listeners`：包含了父作用域中的 (不含 .native 修饰器的)  v-on 事件监听器。它可以通过 v-on="$listeners" 传入内部组件

#### 5.`provide / inject`

**适用于隔代组件通信**

祖先组件中通过 provider 来提供变量，然后在子孙组件中通过 inject 来注入变量。 

`provide / inject` API 主要解决了跨级组件间的通信问题，不过它的使用场景，主要是子组件获取上级组件的状态，跨级组件间建立了一种主动提供与依赖注入的关系。

#### 6.`Vuex`

**适用于父子、隔代、兄弟组件通信**

Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。每一个 Vuex 应用的核心就是 store（仓库）。“store” 基本上就是一个容器，它包含着你的应用中大部分的状态 ( state )。

Vuex 的状态存储是响应式的。当 Vue 组件从 store 中读取状态的时候，若 store 中的状态发生变化，那么相应的组件也会相应地得到高效更新。

改变 store 中的状态的唯一途径就是显式地提交  (commit) mutation。这样使得我们可以方便地跟踪每一个状态的变化。

### 二、手写实现简版EventBus

```js
// 组件通信，一个触发与监听的过程
class EventEmitter {
    constructor () {
      // 存储事件
      this.events = this.events || new Map()
    }
    // 监听事件
    addListener (type, fn) {
      if (!this.events.get(type)) {
        this.events.set(type, fn)
      }
    }
    // 触发事件
    emit (type) {
      let handle = this.events.get(type)
      handle.apply(this, [...arguments].slice(1))
    }
  }
  // 测试
  let emitter = new EventEmitter()
  // 监听事件
  emitter.addListener('ages', age => {
    console.log(age)
  })
  // 触发事件
  emitter.emit('ages', 18)  // 18
  ```

### Day97:请讲一下react-redux的实现原理?
null
### 实现原理

![redux](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-828-redux.png)

#### 1.Provider

Provider的作用是从最外部封装了整个应用，并向connect模块传递store

#### 2.connect

负责连接React和Redux

**1）获取state**

connect通过context获取Provider中的store，通过store.getState()获取整个store tree 上所有state

**2）包装原组件**

将state和action通过props的方式传入到原组件内部wrapWithConnect返回一个ReactComponent对象Connect，Connect重新render外部传入的原组件WrappedComponent，并把connect中传入的mapStateToProps, mapDispatchToProps与组件上原有的props合并后，通过属性的方式传给WrappedComponent

**3）监听store tree变化**

connect缓存了store tree中state的状态,通过当前state状态和变更前state状态进行比较,从而确定是否调用this.setState()方法触发Connect及其子组件的重新渲染


### Day98:写出下面代码的执行结果，并解释原因
```js
Object.prototype.yideng = "京程一灯";
var a = 123;
a.b = 456;
console.log(a.yideng);
console.log(a.b)
```
### 答案

```js
京程一灯  undefined
```

### 解析

#### 1.“JS中一切皆对象”说法也对也不对

因为实际上JS中包括两种类型的值：

- 基本类型：包括数值类型、字符串类型、布尔类型等等
- 对象类型

说它对，是因为在某些情况下，基本类型会表现的很像对象类型，使得用户可以像使用对象去使用基本类型数据。这里的某些情况主要是指 **对对象的赋值和读取**

以数值为例

```js
var a = 123.1;
console.log(a.toFixed(3)); // 123.100

a.name = 'yideng';
console.log(a.name); //undefined
```

上边例子，说明基本类型可以像对象类型一样使用，包括访问其属性、对象属性赋值(尽管实际上不起作用，但是形式上可以)。

像题目中的这种赋值

```js
a.b = 456;
```

结果取决于a的类型：

1. 如果值a的类型为Undefined或Null，则会抛出错误，  
2. 如果 `a` 的值是Object类型，那么 `b` 将在该对象上定义一个命名属性  `a`（如果需要），并且其值将被设置为 `456`
3. 如果值 `a` 的类型是数字，字符串或布尔值，那么变量 `a` 将不会以任何方式改变。在这种情况下，上述分配操作将成为noop。

[noop](https://en.wikipedia.org/wiki/NOP)

所以，正如你所看到的，如果这些变量是对象，那么将属性赋值给变量才有意义。如果情况并非如此，那么这项任务根本就什么也不做，甚至会出错。

#### 2.为什么会出现这样的情况

之所以可以这样去使用基本类型，是因为JavaScript引擎内部在处理对某个基本类型 `a` 进行形如 `a.xxx` 的操作时，会在内部临时创建一个对应的包装类型(对数字类型来说就是Number类型)的临时对象，并把对基本类型的操作代理到对这个临时对象身上，使得对基本类型的属性访问看起来像对象一样。但是在操作完成后，临时对象就扔掉了，下次再访问时，会重新建立临时对象，当然对之前的临时对象的修改都不会有效了。

专业点的解释就是：由于自动装箱（更具体地说，是ECMA-262第5版第8.7.2节中描述的算法），将属性分配给基本类型是完全有效的。但是，属性将被添加到纯临时包装器对象而不是基本类型，因此无法获取属性（包装器对象不替换基本类型）;

除非赋值有副作用（例如，如果属性是通过访问函数实现的）

```js
var a= 123;
Object.defineProperty( Number.prototype, 'yideng', {
    get: () => {
       return  '京程一灯';
    }
}); 
console.log(a.yideng);  //京程一灯
// 或者
Object.prototype.yideng = "京程一灯";
console.log(a.yideng);  //京程一灯
```

关于prototype如果还有不明白的，回顾下这张图

![prototype](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-828-prototype.jpg)



### Day99:React 中 setState 后发生了什么？setState 为什么默认是异步？setState 什么时候是同步？
null
### 一、React中setState后发生了什么

在代码中调用setState函数之后，React 会将传入的参数对象与组件当前的状态合并，然后触发所谓的调和过程（Reconciliation）。

经过调和过程，React 会以相对高效的方式根据新的状态构建 React 元素树并且着手重新渲染整个UI界面。

在 React 得到元素树之后，React 会自动计算出新的树与老树的节点差异，然后根据差异对界面进行最小化重渲染。

在差异计算算法中，React 能够相对精确地知道哪些位置发生了改变以及应该如何改变，这就保证了按需更新，而不是全部重新渲染。

### 二、setState 为什么默认是异步

假如所有setState是同步的，意味着每执行一次setState时（有可能一个同步代码中，多次setState），都重新vnode diff + dom修改，这对性能来说是极为不好的。如果是异步，则可以把一个同步代码中的多个setState合并成一次组件更新。

### 三、setState 什么时候是同步

在setTimeout或者原生事件中，setState是同步的。






















### Day100:哪些方法会触发 react 重新渲染？重新渲染 render 会做些什么？
null
### 一、哪些方法会触发 react 重新渲染？

#### 1.`setState()` 方法被调用

setState 是 React 中最常用的命令，通常情况下，执行 setState 会触发 render。但是这里有个点值得关注，执行 setState 的时候一定会重新渲染吗？

答案是不一定。当 setState 传入 null 的时候，并不会触发 render。

```js
class App extends React.Component {
  state = {
    a: 1
  };

  render() {
    console.log("render");
    return (
      <React.Fragement>
        <p>{this.state.a}</p>
        <button
          onClick={() => {
            this.setState({ a: 1 }); // 这里并没有改变 a 的值
          }}
        >
          Click me
        </button>
        <button onClick={() => this.setState(null)}>setState null</button>
        <Child />
      </React.Fragement>
    );
  }
}
```

#### 2.父组件重新渲染

只要父组件重新渲染了，即使传入子组件的 props 未发生变化，那么子组件也会重新渲染，进而触发 render。

#### 3.`forceUpdate()`

默认情况下，当组件的state或props改变时，组件将重新渲染。如果你的render()方法依赖于一些其他的数据，你可以告诉React组件需要通过调用forceUpdate()重新渲染。

调用forceUpdate()会导致组件跳过shouldComponentUpdate(),直接调用render()。这将触发组件的正常生命周期方法,包括每个子组件的shouldComponentUpdate()方法。

forceUpdate就是重新render。有些变量不在state上，当时你又想达到这个变量更新的时候，刷新render；或者state里的某个变量层次太深，更新的时候没有自动触发render。这些时候都可以手动调用forceUpdate自动触发render


### 二、重新渲染 render 会做些什么？

1. 会对新旧 VNode 进行对比，也就是我们所说的DoM diff。
2. 对新旧两棵树进行一个深度优先遍历，这样每一个节点都会一个标记，在到深度遍历的时候，每遍历到一和个节点，就把该节点和新的节点树进行对比，如果有差异就放到一个对象里面
3. 遍历差异对象，根据差异的类型，根据对应对规则更新VNode

React 的处理 render 的基本思维模式是每次一有变动就会去重新渲染整个应用。在 Virtual DOM 没有出现之前，最简单的方法就是直接调用 innerHTML。Virtual DOM 厉害的地方并不是说它比直接操作 DOM 快，而是说不管数据怎么变，都会尽量以最小的代价去更新 DOM。React 将 render 函数返回的虚拟 DOM 树与老的进行比较，从而确定 DOM 要不要更新、怎么更新。当 DOM 树很大时，遍历两棵树进行各种比对还是相当耗性能的，特别是在顶层 setState 一个微小的修改，默认会去遍历整棵树。尽管 React 使用高度优化的 Diff 算法 ，但是这个过程仍然会损耗性能。

### 三、总结

React 基于虚拟 DOM 和高效 Diff 算法的完美配合，实现了对 DOM 最小粒度的更新。大多数情况下，React 对 DOM 的渲染效率足以我们的业务日常。但在个别复杂业务场景下，性能问题依然会困扰我们。此时需要采取一些措施来提升运行性能，其很重要的一个方向，就是避免不必要的渲染（Render）。

这里提下优化的点

#### 1.shouldComponentUpdate 和 PureComponent

在 React 类组件中，可以利用 shouldComponentUpdate 或者 PureComponent 来减少因父组件更新而触发子组件的 render，从而达到目的。shouldComponentUpdate 来决定是否组件是否重新渲染，如果不希望组件重新渲染，返回 false 即可。

#### 2.利用高阶组件

在函数组件中，并没有 shouldComponentUpdate 这个生命周期，可以利用高阶组件，封装一个类似 PureComponet 的功能

#### 3.使用 React.memo

React.memo 是 React 16.6 新的一个 API，用来缓存组件的渲染，避免不必要的更新，其实也是一个高阶组件，与 PureComponent 十分类似，但不同的是， React.memo 只能用于函数组件 。

#### 4.合理拆分组件

微服务的核心思想是：以更轻、更小的粒度来纵向拆分应用，各个小应用能够独立选择技术、发展、部署。我们在开发组件的过程中也能用到类似的思想。试想当一个整个页面只有一个组件时，无论哪处改动都会触发整个页面的重新渲染。在对组件进行拆分之后，render 的粒度更加精细，性能也能得到一定的提升。


### Day101:Vue v-model 是如何实现的，语法糖实际是什么
null

### 一、语法糖

指计算机语言中添加的某种语法，这种语法对语言的功能并没有影响，但是更方便程序员使用。通常来说使用语法糖能够增加程序的可读性，从而减少程序代码出错的机会。糖在不改变其所在位置的语法结构的前提下，实现了运行时的等价。可以简单理解为，加糖后的代码编译后跟加糖前一样,代码更简洁流畅，代码更语义自然.

### 二、实现原理

#### 1.作用在普通表单元素上

动态绑定了 `input` 的 `value` 指向了 `messgae` 变量，并且在触发 `input` 事件的时候去动态把 `message` 设置为目标值

```js
<input v-model="sth" />
//  等同于
<input 
    v-bind:value="message" 
    v-on:input="message=$event.target.value"
>
//$event 指代当前触发的事件对象;
//$event.target 指代当前触发的事件对象的dom;
//$event.target.value 就是当前dom的value值;
//在@input方法中，value => sth;
//在:value中,sth => value;
```

#### 2.作用在组件上

在自定义组件中，v-model 默认会利用名为 value 的 prop 和名为 input 的事件

**本质是一个父子组件通信的语法糖，通过prop和$.emit实现**

因此父组件`v-model`语法糖本质上可以修改为 `'<child :value="message" @input="function(e){message = e}"></child>'`

在组件的实现中，我们是可以通过 **v-model属性** 来配置子组件接收的prop名称，以及派发的事件名称。


例子

```js
// 父组件
<aa-input v-model="aa"></aa-input>
// 等价于
<aa-input v-bind:value="aa" v-on:input="aa=$event.target.value"></aa-input>

// 子组件：
<input v-bind:value="aa" v-on:input="onmessage"></aa-input>

props:{value:aa,}
methods:{
    onmessage(e){
        $emit('input',e.target.value)
    }
}
```

默认情况下，一个组件上的 v-model 会把 value 用作 prop 且把 input 用作 event

但是一些输入类型比如单选框和复选框按钮可能想使用 value prop 来达到不同的目的。使用 model 选项可以回避这些情况产生的冲突。

js 监听input 输入框输入数据改变，用oninput ,数据改变以后就会立刻出发这个事件。

通过input事件把数据$emit 出去，在父组件接受。

父组件设置v-model的值为input$emit过来的值。

### Day102:说一下减少 dom 数量的办法？一次性给你大量的 dom 怎么优化？
null
### 一、减少DOM数量的方法

1. 可以使用伪元素，阴影实现的内容尽量不使用DOM实现，如清除浮动、样式实现等；
2. 按需加载，减少不必要的渲染；
3. 结构合理，语义化标签；

### 二、大量DOM时的优化

当对Dom元素进行一系列操作时，对Dom进行访问和修改Dom引起的重绘和重排都比较消耗性能，所以关于操作Dom,应该从以下几点出发：

#### 1.缓存Dom对象 

首先不管在什么场景下。操作Dom一般首先会去访问Dom，尤其是像循环遍历这种时间复杂度可能会比较高的操作。那么可以在循环之前就将主节点，不必循环的Dom节点先获取到，那么在循环里就可以直接引用，而不必去重新查询。

```js
let rootElem = document.querySelector('#app');
let childList = rootElem.child; // 假设全是dom节点
for(let i = 0;i<childList.len;j++){
    /**
    * 根据条件对应操作
    */
}
```

#### 2.文档片段

利用`document.createDocumentFragment()`方法创建文档碎片节点，创建的是一个虚拟的节点对象。向这个节点添加dom节点，修改dom节点并不会影响到真实的dom结构。

我们可以利用这一点先将我们需要修改的dom一并修改完，保存至文档碎片中，然后用文档碎片一次性的替换真是的dom节点。与虚拟dom类似，同样达到了不频繁修改dom而导致的重排跟重绘的过程。

```js
let fragment = document.createDocumentFragment();
const operationDomHandle = (fragment) =>{
    // 操作 
}
operationDomHandle(fragment);
// 然后最后再替换  
rootElem.replaceChild(fragment,oldDom);
```

这样就只会触发一次回流，效率会得到很大的提升。如果需要对元素进行复杂的操作（删减、添加子节点），那么我们应当先将元素从页面中移除，然后再对其进行操作，或者将其复制一个（cloneNode()），在内存中进行操作后再替换原来的节点。

```js
var clone=old.cloneNode(true);
operationDomHandle(clone);
rootElem.replaceChild(clone,oldDom)
```

#### 3.用innerHtml 代替高频的appendChild

#### 4.最优的layout方案

批量读，一次性写。先对一个不在render tree上的节点进行操作，再把这个节点添加回render tree。这样只会触发一次DOM操作。 使用`requestAnimationFrame()`，把任何导致重绘的操作放入`requestAnimationFrame`

#### 5.虚拟Dom 

js模拟DOM树并对DOM树操作的一种技术。virtual DOM是一个纯js对象（字符串对象），所以对他操作会高效。

利用virtual dom，将dom抽象为虚拟dom，在dom发生变化的时候先对虚拟dom进行操作，通过dom diff算法将虚拟dom和原虚拟dom的结构做对比，最终批量的去修改真实的dom结构，尽可能的避免了频繁修改dom而导致的频繁的重排和重绘。

### Day103:多个 tab 只对应一个内容框，点击每个 tab 都会请求接口并渲染到内容框，怎么确保频繁点击 tab 但能够确保数据正常显示？
null
### 一、分析

因为每个请求处理时长不一致，可能会导致先发送的请求后响应，即请求响应顺序和请求发送顺序不一致，从而导致数据显示不正确。

即可以理解为连续触发多个请求，如何保证请求响应顺序和请求发送顺序一致。对于问题所在场景，用户只关心最后数据是否显示正确，即可以简化为：连续触发多个请求，如何保证最后响应的结果是最后发送的请求（不关注之前的请求是否发送或者响应成功）

类似场景：input输入框即时搜索，表格快速切换页码

### 二、解决方案

防抖（过滤掉一些非必要的请求） + 取消上次未完成的请求（保证最后一次请求的响应顺序）

取消请求方法：

- `XMLHttpRequest` 使用 `abort` `api` 取消请求
- `axios` 使用 `cancel token` 取消请求

伪代码（以 setTimeout 模拟请求，clearTimeout 取消请求）

```js
/**
 * 函数防抖，一定时间内连续触发事件只执行一次
 * @param {*} func 需要防抖的函数
 * @param {*} delay 防抖延迟
 * @param {*} immediate 是否立即执行，为true表示连续触发时立即执行，即执行第一次，为false表示连续触发后delay ms后执行一次
 */
let debounce = function(func, delay = 100, immediate = false) {
  let timeoutId, last, context, args, result

  function later() {
    const interval = Date.now() - last
    if (interval < delay && interval >= 0) {
      timeoutId = setTimeout(later, delay - interval)
    } else {
      timeoutId = null
      if (!immediate) {
        result = func.apply(context, args)
        context = args = null
      }
    }
  }

  return function() {
    context = this
    args = arguments
    last = Date.now()

    if (immediate && !timeoutId) {
      result = func.apply(context, args)
      context = args = null // 解除引用
    }
    
    if (!timeoutId) {
      timeoutId = setTimeout(later, delay)
    }

    return result
  }
}


let flag = false   // 标志位，表示当前是否正在请求数据
let xhr = null

let request = (i) => {
    if (flag) {
        clearTimeout(xhr)
        console.log(`取消第${i - 1}次请求`)
    }
    flag = true
    console.log(`开始第${i}次请求`)
    xhr = setTimeout(() => {
        console.log(`请求${i}响应成功`)
        flag = false
    }, Math.random() * 200)
}

let fetchData = debounce(request, 50)  // 防抖

// 模拟连续触发的请求
let count = 1 
let getData = () => {
  setTimeout(() => {
    fetchData(count)
    count++
    if (count < 11) {
        getData()
    }
  }, Math.random() * 200)
}
getData()

/* 某次测试输出：
    开始第2次请求
    请求2响应成功
    开始第3次请求
    取消第3次请求
    开始第4次请求
    请求4响应成功
    开始第5次请求
    请求5响应成功
    开始第8次请求
    取消第8次请求
    开始第9次请求
    请求9响应成功
    开始第10次请求
    请求10响应成功
*/
```


### Day104:项目中如何进行异常捕获
null
### 一、代码执行的错误捕获

**1.try……catch**

- 能捕获到代码执行的错误
- 捕获不到语法的错误
- 无法处理异步中的错误
- 使用try... catch 包裹，影响代码可读性

**2.window.onerror**

- 无论是异步还是非异步错误，`onerror` 都能捕获到运行时错误
- `onerror` 主要是来捕获预料之外的错误，而 `try-catch` 则是用来在可预见情况下监控特定的错误，两者结合使用更加高效。
- `window.onerror` 函数只有在返回 true 的时候，异常才不会向上抛出，否则即使是知道异常的发生控制台还是会显示 `Uncaught Error: xxxxx`。
- 当我们遇到 `<img src="./404.png">` 报 404 网络请求异常的时候，onerror 是无法帮助我们捕获到异常的。

> **缺点:** 监听不到资源加载的报错onerror,事件处理函数只能声明一次，不会重复执行多个回调：

**3.window.addEventListener('error')**

可以监听到资源加载报错，也可以注册多个事件处理函数。

`window.addEventListener('error',(msg, url, row, col, error) => {}, true)`

但是这种方式虽然可以捕捉到网络请求的异常,却无法判断 HTTP 的状态是 404 还是其他比如 500 等等，所以还需要配合服务端日志才进行排查分析才可以。

**4.window.addEventListener('unhandledrejection')**

捕获Promise错误，当Promise 被 reject 且没有 reject 处理器的时候，会触发 `unhandledrejection` 事件；这可能发生在 window 下，但也可能发生在 Worker 中。 这对于调试回退错误处理非常有用。

### 二、资源加载的错误捕获

1. `imgObj.onerror()`
2. `performance.getEntries()`，获取到成功加载的资源，对比可以间接的捕获错误
3. `window.addEventListener('error', fn, true)`, 会捕获但是不冒泡，所以window.onerror 不会触发，捕获阶段可以触发

### 三、Vue、React中

Vue有 `errorHandler`，React有 `componentDidCatch` 进行错误捕获

### Day105:JavaScript 中如何模拟实现方法的重载,动手实现下
null
### 一、背景知识

JavaScript不支持重载的语法，它没有重载所需要的函数签名。
ECMAScript函数不能像传统意义上那样实现重载。而在其他语言（如 Java）中，可以为一个函数编写两个定义，只要这两个定义的签名（接受的参数的类型和数量）不同即可。如前所述，ECMAScirpt函数没有签名，因为其参数是由包含零或多个值的数组来表示的。而没有函数签名，真正的重载是不可能做到的。 — JavaScript高级程序设计（第3版）

### 二、什么是函数重载

重载函数是函数的一种特殊情况，为方便使用，允许在同一范围中声明几个功能类似的同名函数，但是这些同名函数的形式参数（指参数的个数、类型或者顺序）必须不同，也就是说用同一个函数完成不同的功能。这就是重载函数

### 三、模拟实现

####  利用闭包特性

addMethod函数接收3个参数：目标对象、目标方法名、函数体，当函数被调用时：

1. 先将目标object[name]的值存入变量old中，因此起初old中的值可能不是一个函数；
2. 接着向object[name]赋值一个代理函数，并且由于变量old、fnt在代理函数中被引用，所以old、fnt将常驻内存不被回收。

```js
function addMethod(object, name, fnt) {
  var old = object[name];  // 保存前一个值，以便后续调用
  object[name] = function(){  // 向object[name]赋值一个代理函数
    // 判断fnt期望接收的参数与传入参数个数是否一致
    if (fnt.length === arguments.length)
      // 若是，则调用fnt
      return fnt.apply(this, arguments)
    else if (typeof old === 'function')  // 若否，则判断old的值是否为函数
      // 若是，则调用old
      return old.apply(this, arguments);
  };
}
//模拟重载add
var methods = {};
//添加方法，顺序无关
addMethod(methods, 'add', function(){return 0});
addMethod(methods, 'add', function(a,b){return a + b});
addMethod(methods, 'add', function(a,b,c){return a + b + c});
//执行
console.log(methods.add()); //0
console.log(methods.add(10,20)); //30
console.log(methods.add(10,20,30)); //60
```



### Day106:Webpack 里面的插件是怎么实现的？
null
### 实现分析

* webpack本质是一种事件流机制, 核心模块: **tapable (Sync + Async)Hooks 构造出=> Compiler(编译) + Compilation(创建bundles)**
* compiler 对象代表了完整的 webpack 环境配置。这个对象在启动 webpack 时被一次性建立，并配置好所有可操作的设置，包括 options，loader 和 plugin。当在 webpack 环境中应用一个插件时，插件将收到此 compiler 对象的引用。可以使用它来访问 webpack 的主环境。
* compilation 对象代表了一次资源版本构建。当运行 webpack 开发环境中间件时，每当检测到一个文件变化，就会创建一个新的 compilation，从而生成一组新的编译资源。一个 compilation 对象表现了当前的模块资源、编译生成资源、变化的文件、以及被跟踪依赖的状态信息。compilation 对象也提供了很多关键时机的回调，以供插件做自定义处理时选择使用。
* 创建一个插件函数, 在其prototype上定义apply方法;  指定一个绑定到webpack自身的事件钩子;
* 函数内,处理webpack内部实例的特定数据
* 处理完成后, 调用webpack提供的回调

代码示例

```js
function MyExampleWebpackPlugin() {

};
// 在插件函数的 prototype 上定义一个 `apply` 方法。
MyExampleWebpackPlugin.prototype.apply = function(compiler) {
  // 指定一个挂载到 webpack 自身的事件钩子。
  compiler.plugin('webpacksEventHook', function(compilation /* 处理 webpack 内部实例的特定数据。*/, callback) {
    console.log("This is an example plugin!!!");
    // 功能完成后调用 webpack 提供的回调。
    callback();
  });
};
```



### Day107:对虚拟 DOM 的理解？虚拟 DOM 主要做了什么？虚拟 DOM 本身是什么？
null

### 一、什么是虚拟Dom

从本质上来说，Virtual Dom是一个JavaScript对象，通过对象的方式来表示DOM结构。将页面的状态抽象为JS对象的形式，配合不同的渲染工具，使跨平台渲染成为可能。通过事务处理机制，将多次DOM修改的结果一次性的更新到页面上，从而**有效的减少页面渲染的次数，减少修改DOM的重绘重排次数，提高渲染性能**。

虚拟dom是对DOM的抽象，这个对象是更加轻量级的对DOM的描述。它设计的最初目的，就是更好的跨平台，比如Node.js就没有DOM,如果想实现SSR,那么一个方式就是借助虚拟dom, 因为虚拟dom本身是js对象。

在代码渲染到页面之前，vue或者react会把代码转换成一个对象（虚拟DOM）。以对象的形式来描述真实dom结构，最终渲染到页面。在每次数据发生变化前，虚拟dom都会缓存一份，变化之时，现在的虚拟dom会与缓存的虚拟dom进行比较。

在vue或者react内部封装了diff算法，通过这个算法来进行比较，渲染时修改改变的变化，原先没有发生改变的通过原先的数据进行渲染。

另外现代前端框架的一个基本要求就是无须手动操作DOM,一方面是因为手动操作DOM无法保证程序性能，多人协作的项目中如果review不严格，可能会有开发者写出性能较低的代码，另一方面更重要的是省略手动DOM操作可以大大提高开发效率。

### 二、为什么要用 Virtual DOM

#### 1.保证性能下限，在不进行手动优化的情况下，提供过得去的性能

看一下页面渲染的一个流程：

- 解析HTNL ☞ 生成DOM? ☞ 生成 CSSOM ☞ Layout ☞ Paint ☞ Compiler

下面对比一下修改DOM时真实DOM操作和Virtual DOM的过程，来看一下它们重排重绘的性能消耗：

- 真实DOM： 生成HTML字符串 + 重建所有的DOM元素
- Virtual DOM： 生成vNode + DOMDiff + 必要的dom更新

Virtual DOM的更新DOM的准备工作耗费更多的时间，也就是JS层面，相比于更多的DOM操作它的消费是极其便宜的。尤雨溪在社区论坛中说道： **框架给你的保证是，你不需要手动优化的情况下，我依然可以给你提供过得去的性能。**

#### 2.跨平台

Virtual DOM本质上是JavaScript的对象，它可以很方便的跨平台操作，比如服务端渲染、uniapp等。

### 三、Virtual DOM真的比真实DOM性能好吗

1. 首次渲染大量DOM时，由于多了一层虚拟DOM的计算，会比innerHTML插入慢。
2. 正如它能保证性能下限，在真实DOM操作的时候进行针对性的优化时，还是更快的。




### Day108:Webpack 为什么慢，如何进行优化
null
### 一、webpack 为什么慢

webpack是所谓的模块捆绑器，内部有循环引用来分析模块间之间的依赖，把文件解析成AST，通过一系类不同loader的加工，最后全部打包到一个js文件里。

webpack4以前在打包速度上没有做过多的优化手段，编译慢的大部分时间是花费在不同loader编译过程，webpack4以后，吸收借鉴了很多优秀工具的思路，

如支持0配置，多线程等功能，速度也大幅提升，但依然有一些优化手段。如合理的代码拆分，公共代码的提取，css资源的抽离

### 二、优化 Webpack 的构建速度

- 使用高版本的 Webpack （使用webpack4）
- 多线程/多实例构建：HappyPack(不维护了)、thread-loader
- 缩小打包作用域：
  - `exclude/include` (确定 loader 规则范围)
  - `resolve.modules` 指明第三方模块的绝对路径 (减少不必要的查找)
  - `resolve.extensions` 尽可能减少后缀尝试的可能性
  - `noParse` 对完全不需要解析的库进行忽略 (不去解析但仍会打包到 bundle 中，注意被忽略掉的文件里不应该包含 import、require、define 等模块化语句)
  - IgnorePlugin (完全排除模块)
  - 合理使用alias
- 充分利用缓存提升二次构建速度：
  - babel-loader 开启缓存
  - terser-webpack-plugin 开启缓存
  - 使用 cache-loader 或者 hard-source-webpack-plugin
注意：thread-loader 和 cache-loader 兩個要一起使用的話，請先放 cache-loader 接著是 thread-loader 最後才是 heavy-loader
- DLL
  - 使用 DllPlugin 进行分包，使用 DllReferencePlugin(索引链接) 对 manifest.json 引用，让一些基本不会改动的代码先打包成静态资源，避免反复编译浪费时间。

### 三、使用Webpack4带来的优化

- V8带来的优化（for of替代forEach、Map和Set替代Object、includes替代indexOf）
- 默认使用更快的md4 hash算法
- webpack AST可以直接从loader传递给AST，减少解析时间
- 使用字符串方法替代正则表达式

来看下具体使用

#### 1.noParse

- 不去解析某个库内部的依赖关系
- 比如jquery 这个库是独立的， 则不去解析这个库内部依赖的其他的东西
- 在独立库的时候可以使用

```js
module.exports = {
  module: {
    noParse: /jquery/,
    rules:[]
  }
}
```

#### 2.IgnorePlugin

- 忽略掉某些内容 不去解析依赖库内部引用的某些内容
- 从moment中引用 `./local` 则忽略掉
- 如果要用local的话 则必须在项目中必须手动引入 `import 'moment/locale/zh-cn'`

```js
module.exports = {
  plugins: [
    new Webpack.IgnorePlugin(/\.\/local/, /moment/),
  ]
}
```

#### 3.dillPlugin

- 不会多次打包， 优化打包时间
- 先把依赖的不变的库打包
- 生成 manifest.json文件
- 然后在webpack.config中引入
- `webpack.DllPlugin`、`Webpack.DllReferencePlugin`

#### 4.happypack -> thread-loader

- 大项目的时候开启多线程打包
- 影响前端发布速度的有两个方面，一个是 **构建** ，一个就是 **压缩** ，把这两个东西优化起来，可以减少很多发布的时间。

#### 5.thread-loader

**thread-loader** 会将您的 loader 放置在一个 worker 池里面运行，以达到多线程构建。

把这个 loader 放置在其他 loader 之前,放置在这个 loader 之后的 loader 就会在一个单独的 worker 池(worker pool)中运行。

```js
// webpack.config.js
module.exports = {
  module: {
    rules: [
      {
        test: /\.js$/,
        include: path.resolve("src"),
        use: [
          "thread-loader",
          // 你的高开销的loader放置在此 (e.g babel-loader)
        ]
      }
    ]
  }
}
```

每个 worker 都是一个单独的有 600ms 限制的 node.js 进程。同时跨进程的数据交换也会被限制。请在高开销的loader中使用，否则效果不佳


#### 6.压缩加速——开启多线程压缩

不推荐使用 webpack-paralle-uglify-plugin，项目基本处于没人维护的阶段，issue 没人处理，pr没人合并。

Webpack 4.0以前：uglifyjs-webpack-plugin，parallel参数

```js
module.exports = {
  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        parallel: true,
      }),
    ],
  },};
```

推荐使用 terser-webpack-plugin

```js
module.exports = {
  optimization: {
    minimizer: [new TerserPlugin(
      parallel: true   // 多线程
    )],
  },
};
```






### Day109:动画性能如何检测
null
####  1.Chrome 提供给开发者的功能十分强大，在开发者工具中，我们进行如下选择调出 FPS meter 选项：
   
![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-680-dev1.png)

通过这个选项，可以开启页面实时 Frame Rate (帧率) 观测及页面 GPU 使用率。但是缺点太多了，这个只能一次观测一到几个页面，而且需要人工实时观测。数据只能是主观感受，并没有一个十分精确的数据不断上报或者被收集


####  2.借助 Frame Timing API

Frame Timing API 是 Web Performance Timing API 标准中的其中一位成员。是通过一个接口获取帧相关的性能数据，例如每秒帧数和TTF.

以 Navigation Timing, Performance Timeline, Resource Timing 为例子，对于兼容它的浏览器，它以只读属性的形式对外暴露挂载在 window.performance 上。

其中Timing中的属性对应时间点如下：

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-680-frame.png)

通过window.performance.timing，就可以统计出页面每个重要节点的耗时

借助 Web Performance Timing API 中的 Frame Timing API，可以轻松的拿到每一帧中，主线程以及合成线程的时间。或者更加容易，直接拿到每一帧的耗时。

获取 Render 主线程和合成线程的记录，每条记录包含的信息基本如下，代码示意，（参考至Developer feedback needed: Frame Timing API）：

```js
var rendererEvents = window.performance.getEntriesByType("renderer");
var compositeThreadEvents = window.performance.getEntriesByType("composite");

//或者
var observer = new PerformanceObserver(function(list) {
    var perfEntries = list.getEntries();
    for (var i = 0; i < perfEntries.length; i++) {
        console.log("frame: ", perfEntries[i]);
    }
});
    
// subscribe to Frame Timing
observer.observe({entryTypes: ['frame']});

// 结果
// {
//  sourceFrameNumber: 120,
//  startTime: 1342.549374253
//  cpuTime: 6.454313323
// }

//每个记录都包括唯一的 Frame Number、Frame 开始时间以及 cpuTime 时间。通过计算每一条记录的 startTime ，我们就可以算出每两帧间的间隔，从而得到动画的帧率是否能够达到 60 FPS。
```
  
**但是。(重点来了) 现在 Frame Timing API 的兼容性不太友好，还没有任何浏览器支持，属于宏观试验性阶段，抬走下一个**

####  3.requestAnimationFrame API

requestAnimationFrame 告诉浏览器您希望执行动画并请求浏览器调用指定的函数在下一次重绘之前更新动画。

当准备好更新屏幕画面时你就应用此方法。这会要求动画函数在浏览器下次重绘前执行。回调的次数常是每秒 60 次，大多数浏览器通常匹配 W3C 所建议的刷新率。

**使用 requestAnimationFrame 计算 FPS 原理**

原理是，正常而言 requestAnimationFrame 这个方法在一秒内会执行 60 次，也就是不掉帧的情况下。假设动画在时间 A 开始执行，在时间 B 结束，耗时 x ms。而中间 requestAnimationFrame 一共执行了 n 次，则此段动画的帧率大致为：`n / (B - A)`。

代码如下，能近似计算每秒页面帧率，以及我们额外记录一个 allFrameCount，用于记录 rAF 的执行次数，用于计算每次动画的帧率 ：

```js
var rAF = function () {
    return (
        window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        function (callback) {
            window.setTimeout(callback, 1000 / 60);
        }
    );
}();

var frame = 0;
var allFrameCount = 0;
var lastTime = Date.now();
var lastFameTime = Date.now();

var loop = function () {
    var now = Date.now();
    var fs = (now - lastFameTime);
    var fps = Math.round(1000 / fs);

    lastFameTime = now;
    // 不置 0，在动画的开头及结尾记录此值的差值算出 FPS
    allFrameCount++;
    frame++;

    if (now > 1000 + lastTime) {
        var fps = Math.round((frame * 1000) / (now - lastTime));
        console.log(`${new Date()} 1S内 FPS：`, fps);
        frame = 0;
        lastTime = now;
    };

    rAF(loop);
}

loop();
```

在大部分情况下，这种方法可以很好的得出 Web 动画的帧率。

如果需要统计某个特定动画过程的帧率，只需要在动画开始和结尾两处分别记录 allFrameCount 这个数值大小，再除以中间消耗的时间，也可以得出特定动画过程的 FPS 值。

这个方法计算的结果和真实的帧率是存在误差的，因为它是将每两次主线程执行 javascript 的时间间隔当成一帧，而非上面说的主线程加合成线程所消耗的时间为一帧。但是对于现阶段而言，算是一种可取的方法。



### Day110:客户端缓存有几种方式？浏览器出现 from disk、from memory 的策略是啥
null
### 一、客户端缓存

浏览器缓存策略:

浏览器每次发起请求时，先在本地缓存中查找结果以及缓存标识，根据缓存标识来判断是否使用本地缓存。如果缓存有效，则使用本地缓存；否则，则向服务器发起请求并携带缓存标识。根据是否需向服务器发起HTTP请求，将缓存过程划分为两个部分：***强制缓存和协商缓存，强缓优先于协商缓存***。

**HTTP缓存都是从第二次请求开始的**

- 第一次请求资源时，服务器返回资源，并在response header中回传资源的缓存策略；
- 第二次请求时，浏览器判断这些请求参数，击中强缓存就直接200，否则就把请求参数加到request header头中传给服务器，看是否击中协商缓存，击中则返回304，否则服务器会返回新的资源。这是缓存运作的一个整体流程图：

![img](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-326.png)

#### 1.强缓存

服务器通知浏览器一个缓存时间，在缓存时间内，下次请求，直接用缓存，不在时间内，执行比较缓存策略。

强缓存命中则直接读取浏览器本地的资源，在network中显示的是from memory或者from disk

控制强制缓存的字段有：Cache-Control（http1.1）和Expires（http1.0）

- Cache-control是一个相对时间，用以表达自上次请求正确的资源之后的多少秒的时间段内缓存有效。
- Expires是一个绝对时间。用以表达在这个时间点之前发起请求可以直接从浏览器中读取数据，而无需发起请求
- Cache-Control的优先级比Expires的优先级高。前者的出现是为了解决Expires在浏览器时间被手动更改导致缓存判断错误的问题。
- 如果同时存在则使用Cache-control。

**1）强缓存-expires**

该字段是服务器响应消息头字段，告诉浏览器在过期时间之前可以直接从浏览器缓存中存取数据。

Expires 是 HTTP 1.0 的字段，表示缓存到期时间，是一个绝对的时间 (当前时间+缓存时间)。在响应消息头中，设置这个字段之后，就可以告诉浏览器，在未过期之前不需要再次请求。

由于是绝对时间，用户可能会将客户端本地的时间进行修改，而导致浏览器判断缓存失效，重新请求该资源。此外，即使不考虑修改，时差或者误差等因素也可能造成客户端与服务端的时间不一致，致使缓存失效。

优势特点:

- HTTP 1.0 产物，可以在HTTP 1.0和1.1中使用，简单易用。
- 以时刻标识失效时间。

劣势问题:

- 时间是由服务器发送的(UTC)，如果服务器时间和客户端时间存在不一致，可能会出现问题。
- 存在版本问题，到期之前的修改客户端是不可知的。

**2）强缓存-cache-control**

已知Expires的缺点之后，在HTTP/1.1中，增加了一个字段Cache-control，该字段表示资源缓存的最大有效时间，在该时间内，客户端不需要向服务器发送请求。

这两者的区别就是前者是绝对时间，而后者是相对时间。下面列举一些 `Cache-control` 字段常用的值：(完整的列表可以查看MDN)

- `max-age`：即最大有效时间。
- `must-revalidate`：如果超过了 `max-age` 的时间，浏览器必须向服务器发送请求，验证资源是否还有效。
- `no-cache`：不使用强缓存，需要与服务器验证缓存是否新鲜。
- `no-store`: 真正意义上的“不要缓存”。所有内容都不走缓存，包括强制和对比。
- `public`：所有的内容都可以被缓存 (包括客户端和代理服务器， 如 CDN)
- `private`：所有的内容只有客户端才可以缓存，代理服务器不能缓存。默认值。

**Cache-control 的优先级高于 Expires**，为了兼容 HTTP/1.0 和 HTTP/1.1，实际项目中两个字段都可以设置。

该字段可以在请求头或者响应头设置，可组合使用多种指令：

- **可缓存性**：
    - public：default，浏览器和缓存服务器都可以缓存页面信息
    - private：代理服务器不可缓存，只能被单个用户缓存
    - no-cache：浏览器器和服务器都不应该缓存页面信息，但仍可缓存，只是在缓存前需要向服务器确认资源是否被更改。可配合private，
      过期时间设置为过去时间。
    - only-if-cache：客户端只接受已缓存的响应
- **到期**
    - `max-age=<seconds>`：缓存存储的最大周期，超过这个周期被认为过期。
    - `s-maxage=<seconds>`：设置共享缓存，比如can。会覆盖max-age和expires。
    - `max-stale[=<seconds>]`：客户端愿意接收一个已经过期的资源
    - `min-fresh=<seconds>`：客户端希望在指定的时间内获取最新的响应
    - `stale-while-revalidate=<seconds>`：客户端愿意接收陈旧的响应，并且在后台一部检查新的响应。时间代表客户端愿意接收陈旧响应
      的时间长度。
    - `stale-if-error=<seconds>`：如新的检测失败，客户端则愿意接收陈旧的响应，时间代表等待时间。
- **重新验证和重新加载**
    - must-revalidate：如页面过期，则去服务器进行获取。
    - proxy-revalidate：用于共享缓存。
    - immutable：响应正文不随时间改变。
- **其他**
    - no-store：绝对禁止缓存
    - no-transform：不得对资源进行转换和转变。例如，不得对图像格式进行转换。

优势特点:

- HTTP 1.1 产物，以时间间隔标识失效时间，解决了Expires服务器和客户端相对时间的问题。 
- 比Expires多了很多选项设置。

劣势问题:

- 存在版本问题，到期之前的修改客户端是不可知的。


#### 2.协商缓存

让客户端与服务器之间能实现缓存文件是否更新的验证、提升缓存的复用率，将缓存信息中的Etag和Last-Modified通过请求发送给服务器，由服务器校验，返回304状态码时，浏览器直接使用缓存。

- 协商缓存的状态码由服务器决策返回200或者304
- 当浏览器的强缓存失效的时候或者请求头中设置了不走强缓存，并且在请求头中设置了If-Modified-Since 或者 If-None-Match 的时候，会将这两个属性值到服务端去验证是否命中协商缓存，如果命中了协商缓存，会返回 304 状态，加载浏览器缓存，并且响应头会设置 Last-Modified 或者 ETag 属性。
- 对比缓存在请求数上和没有缓存是一致的，但如果是 304 的话，返回的仅仅是一个状态码而已，并没有实际的文件内容，因此 在响应体体积上的节省是它的优化点。
- 协商缓存有 2 组字段(不是两个)，控制协商缓存的字段有：Last-Modified/If-Modified-since（http1.0）和Etag/If-None-match（http1.1）
- Last-Modified/If-Modified-since表示的是服务器的资源最后一次修改的时间；Etag/If-None-match表示的是服务器资源的唯一标识，只要资源变化，Etag就会重新生成。
- Etag/If-None-match的优先级比Last-Modified/If-Modified-since高。

**1）协商缓存-协商缓存-Last-Modified/If-Modified-since**

1. 服务器通过 `Last-Modified` 字段告知客户端，资源最后一次被修改的时间，例如 `Last-Modified: Mon, 10 Nov 2018 09:10:11 GMT`
2. 浏览器将这个值和内容一起记录在缓存数据库中。
3. 下一次请求相同资源时时，浏览器从自己的缓存中找出“不确定是否过期的”缓存。因此在请求头中将上次的 `Last-Modified` 的值写入到请求头的 `If-Modified-Since` 字段
4. 服务器会将 `If-Modified-Since` 的值与 `Last-Modified` 字段进行对比。如果相等，则表示未修改，响应 304；反之，则表示修改了，响应 200 状态码，并返回数据。


优势特点:

- 不存在版本问题，每次请求都会去服务器进行校验。服务器对比最后修改时间如果相同则返回304，不同返回200以及资源内容。

劣势问题:

1. 只要资源修改，无论内容是否发生实质性的变化，都会将该资源返回客户端。例如周期性重写，这种情况下该资源包含的数据实际上一样的。 
2. 以时刻作为标识，无法识别一秒内进行多次修改的情况。 如果资源更新的速度是秒以下单位，那么该缓存是不能被使用的，因为它的时间单位最低是秒。
3. 某些服务器不能精确的得到文件的最后修改时间。
4. 如果文件是通过服务器动态生成的，那么该方法的更新时间永远是生成的时间，尽管文件可能没有变化，所以起不到缓存的作用。

**2）协商缓存-Etag/If-None-match**

- 为了解决上述问题，出现了一组新的字段 `Etag` 和 `If-None-Match`
- `Etag` 存储的是文件的特殊标识(一般都是 hash 生成的)，服务器存储着文件的 `Etag` 字段。之后的流程和 `Last-Modified` 一致，只是 `Last-Modified` 字段和它所表示的更新时间改变成了 `Etag` 字段和它所表示的文件 hash，把 `If-Modified-Since` 变成了 `If-None-Match`。服务器同样进行比较，命中返回 304, 不命中返回新资源和 200。
- 浏览器在发起请求时，服务器返回在Response header中返回请求资源的唯一标识。在下一次请求时，会将上一次返回的Etag值赋值给If-No-Matched并添加在Request Header中。服务器将浏览器传来的if-no-matched跟自己的本地的资源的ETag做对比，如果匹配，则返回304通知浏览器读取本地缓存，否则返回200和更新后的资源。
- **Etag 的优先级高于 Last-Modified**。

优势特点:

- 可以更加精确的判断资源是否被修改，可以识别一秒内多次修改的情况。 
- 不存在版本问题，每次请求都回去服务器进行校验。

劣势问题:

- 计算ETag值需要性能损耗。
- 分布式服务器存储的情况下，计算ETag的算法如果不一样，会导致浏览器从一台服务器上获得页面内容后到另外一台服务器上进行验证时现ETag不匹配的情况。


### 二、浏览器出现 from disk、from memory 的策略

强缓存：服务器通知浏览器一个缓存时间，在缓存时间内，下次请求，直接用缓存，不在时间内，执行其他缓存策略

1. 浏览器发现缓存无数据，于是发送请求，向服务器获取资源
2. 服务器响应请求，返回资源，同时标记资源的有效期`Cache-Contrl: max-age=3000`
3. 浏览器缓存资源，等待下次重用



### Day112:数组里面有 10 万个数据，取第一个元素和第 10 万个元素的时间相差多少
null
### 解析

数组可以直接根据索引取的对应的元素，所以不管取哪个位置的元素的时间复杂度都是 O(1)

JavaScript 没有真正意义上的数组，所有的数组其实是对象，其“索引”看起来是数字，其实会被转换成字符串，作为属性名（对象的 key）来使用。所以无论是取第 1 个还是取第 10 万个元素，都是用 key 精确查找哈希表的过程，其消耗时间大致相同。

看一下chrome控制台下的结果

```js
var arr = new Array(100000).fill(null)
console.time('arr1')
arr[0]
console.timeEnd('arr1')
// arr1: 0.003173828125ms
```
```js
var arr = new Array(100000).fill(null)
console.time('arr100000')
arr[99999]
console.timeEnd('arr100000')
// arr100000: 0.002685546875ms
```

### Day113:Import 和 CommonJS 在 webpack 打包过程中有什么不同
null


#### 1.es6模块调用commonjs模块

可以直接使用commonjs模块，commonjs模块将不会被webpack的模块系统编译而是会原样输出，并且commonjs模块没有default属性

#### 2.es6模块调用es6模块

被调用的es6模块不会添加`{__esModule:true}`，只有调用者才会添加`{__esModule:true}`，并且可以进行`tree-shaking`操作，如果被调用的es6模块只是import进来，但是并没有被用到，那么被调用的es6模块将会被标记为`/* unused harmony default export */`，在压缩时此模块将会被删除（例外：如果被调用的es6模块里有立即执行语句，那么这些语句将会被保留）


#### 3.commonjs模块引用es6模块

es6模块编译后会添加`{__esModule:true}`。如果被调用的es6模块中恰好有`export default`语句，那么编译后的es6模块将会添加default属性。

#### 4.commonjs模块调用commonjs模块

commonjs模块会原样输出

### Day114:说一下Webpack 热更新的原理
null
### 一、基础概念

1. **Webpack Compiler:** 将 JS 编译成 Bundle
2. **Bundle Server:** 提供文件在浏览器的访问，实际上就是一个服务器
3. **HMR Server:** 将热更新的文件输出给HMR Runtime
4. **HMR Runtime:** 会被注入到bundle.js中，与HRM Server通过WebSocket链接，接收文件变化，并更新对应文件
5. **bundle.js:** 构建输出的文件

### 二、原理

#### 1.启动阶段

1. Webpack Compiler 将对应文件打包成bundle.js(包含注入的HMR Server)，发送给Bundler Server
2. 浏览器即可以访问服务器的方式获取bundle.js

#### 2.更新阶段(即文件发生了变化)

1. Webpack Compiler 重新编译，发送给HMR Server
2. HMR Server 可以知道有哪些资源、哪些模块发生了变化，通知HRM Runtime
3. HRM Runtime更新代码

### 三、HMR原理详解

![hmr](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-685-hmr.png)

使用webpack-dev-server去启动本地服务，内部实现主要使用了webpack、express、websocket。

- 使用express启动本地服务，当浏览器访问资源时对此做响应。
- 服务端和客户端使用websocket实现长连接
- webpack监听源文件的变化，即当开发者保存文件时触发webpack的重新编译。
  - 每次编译都会生成hash值、已改动模块的json文件、已改动模块代码的js文件
  - 编译完成后通过socket向客户端推送当前编译的hash戳
- 客户端的websocket监听到有文件改动推送过来的hash戳，会和上一次对比
  - 一致则走缓存
  - 不一致则通过ajax和jsonp向服务端获取最新资源
- 使用内存文件系统去替换有修改的内容实现局部刷新

#### 1.server端

- 启动webpack-dev-server服务器
- 创建webpack实例
- 创建Server服务器
- 添加webpack的done事件回调
- 编译完成向客户端发送消息
- 创建express应用app
- 设置文件系统为内存文件系统
- 添加webpack-dev-middleware中间件
- 中间件负责返回生成的文件
- 启动webpack编译
- 创建http服务器并启动服务
- 使用sockjs在浏览器端和服务端之间建立一个 websocket 长连接
- 创建socket服务器

#### 2.client端

- webpack-dev-server/client端会监听到此hash消息
- 客户端收到ok的消息后会执行reloadApp方法进行更新
- 在reloadApp中会进行判断，是否支持热更新，如果支持的话发射webpackHotUpdate事件，如果不支持则直接刷新浏览器
- 在webpack/hot/dev-server.js会监听webpackHotUpdate事件
- 在check方法里会调用module.hot.check方法
- HotModuleReplacement.runtime请求Manifest
- 它通过调用 JsonpMainTemplate.runtime的hotDownloadManifest方法 
- 调用JsonpMainTemplate.runtime的hotDownloadUpdateChunk方法通过JSONP请求获取到最新的模块代码  
- 补丁JS取回来后会调用JsonpMainTemplate.runtime.js的webpackHotUpdate方法 
- 然后会调用HotModuleReplacement.runtime.js的hotAddUpdateChunk方法动态更新模块代码 
- 然后调用hotApply方法进行热更新

### Day115:说一下 vue-router 的原理
null
### 实现原理

vue-router的原理就是更新视图而不重新请求页面。

vue-router可以通过mode参数设置为三种模式：**hash模式、history模式**、**abstract模式** 。

#### 1.hash模式

默认是hash模式,基于浏览器history api，使用 `window.addEventListener("hashchange",callback,false)` 对浏览器地址进行监听。当调用push时，把新路由添加到浏览器访问历史的栈顶。使用replace时，把浏览器访问历史的栈顶路由替换成新路由。

hash值等于url中#及其以后的内容。浏览器是根据hash值的变化，将页面加载到相应的DOM位置。锚点变化只是浏览器的行为，每次锚点变化后依然会在浏览器中留下一条历史记录，可以通过浏览器的后退按钮回到上一个位置。

#### 2.History

history模式，基于浏览器history api，使用 `window.onpopstate` 对浏览器地址进行监听。对浏览器history api中`pushState()`、`replaceState()` 进行封装，
当方法调用，会对浏览器历史栈进行修改。从而实现URL的跳转而无需重新加载页面。

但是它的问题在于当刷新页面的时候会走后端路由，所以需要服务端的辅助来兜底，避免URL无法匹配到资源时能返回页面。

#### 3.abstract

不涉及和浏览器地址的相关记录。流程跟hash模式一样，通过数组维护模拟浏览器的历史记录栈。

服务端下使用。使用一个不依赖于浏览器的浏览历史虚拟管理后台。

#### 4.总结

hash模式和history模式都是通过 `window.addEventListenter()` 方法监听 `hashchange` 和 `popState` 进行相应路由的操作。可以通过back、foward、go等方法访问浏览器的历史记录栈，进行各种跳转。而abstract模式是自己维护一个模拟的浏览器历史记录栈的数组。

### Day116:商城的列表页跳转到商品的详情页，详情页数据接口很慢，前端可以怎么优化用户体验？
null
### 一、优化简要版

**1）懒加载:获取首屏数据,后边的数据进行滑动加载请求**

1. 首先，不要将图片地址放到src属性中，而是放到其它属性(data-original)中。
2. 页面加载完成后，根据scrollTop判断图片是否在用户的视野内，如果在，则将data-original属性中的值取出存放到src属性中。
3. 在滚动事件中重复判断图片是否进入视野，如果进入，则将data-original属性中的值取出存放到src属性中

**2）利用骨架屏提升用户体验**

**3）PreloadJS预加载**

使用PreloadJS库，PreloadJS提供了一种预加载内容的一致方式，以便在HTML应用程序中使用。预加载可以使用HTML标签以及XHR来完成。默认情况下，PreloadJS会尝试使用XHR加载内容，因为它提供了对进度和完成事件的更好支持，但是由于跨域问题，使用基于标记的加载可能更好。

**4）除了添加前端loading和超时404页面外，接口部分可以添加接口缓存和接口的预加载**

1. 使用workbox对数据进行缓存 缓存优先
2. 使用orm对本地离线数据进行缓存 优先请求本地。
3. 采用预加载 再进入到详情页阶段使用quicklink预加载详情页
4. 使用nodejs作为中间层将详情页数据缓存至redis等
上面的方法，可以根据业务需求选择组合使用。


### 二、优化详细版

#### 1.打开谷歌搜索为例

![load和DOMContentLoad.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-devetool.png)


- 蓝色的分界线左边代表浏览器的 DOMContentLoaded，当初始 HTML 文档已完全加载和解析而无需等待样式表，图像和子帧完成加载时的标识;
- 红色分界线代表 load, 当整个页面及所有依赖资源如样式表和图片都已完成加载时

所以我们可以大致分为在 

- **TTFB 之前的优化**
- **浏览器上面渲染的优化**

#### 2.当网络过慢时在获取数据前的处理

首先先上一张经典到不能再经典的图

![timing-overview.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-performance.png)

> 其中cnd在dns阶段, dom渲染在processing onload阶段

上图从 promot for unload 到 onload 的过程这么多步骤, 在用户体验来说, 一个页面从加载到展示超过 4 秒, 就会有一种非常直观的卡顿现象, 其中 load 对应的位置是 onLoad 事件结束后, 才开始构建 dom 树, 但是用户不一定是关心当前页面是否是完成了资源的下载;
往往是一个页面开始出现可见元素开始**FCP 首次内容绘制**或者是**FC 首次绘制** 此时用户视觉体验开始, 到**TTI(可交互时间)** , 可交互元素的出现, 意味着,用户交互体验开始, 这时候用户就可以愉快的浏览使用我们的页面啦;

所以这个问题的主要痛点是需要缩短到达 **TTI** 和 **FCP** 的时间

但是这里已知进入我们详情页面时, 接口数据返回速度是很慢的, **FCP** 和 **FC** , 以及加快到达 **TTI** , 就需要我们页面预处理了

#### 3.页面数据缓存处理(缓存大法好)

**第一次** 进入详情页面, 可以使用骨架图进行模拟 **FC** 展示, 并且骨架图, 可使用背景图且行内样式的方式对首次进入详情页面进行展示, 对于请求过慢的详情接口使用 **worker** 进程, 对详情的接口请求丢到另外一个工作线程进行请求, 页面渲染其他已返回数据的元素; 当很慢的数据回来后, 需要对页面根据商品 id 签名为 key 进行 webp 或者是缩略图商品图的 cnd 路径 localStorage 的缓存, 商品 id 的签名由放在 cookie 并设置成 httpOnly

**非第一次** 进入详情页时, 前端可通过特定的接口请求回来对应的商品 id 签名的 cookieid, 读取 localStorage 的商品图片的缓存数据, 这样对于第一次骨架图的展示时间就可以缩短, 快速到达 **TTI** 与用户交互的时间, 再通过 worker 数据, 进行高清图片的切换

#### 4.过期缓存数据的处理(后端控制为主, LRU 为辅)

对于缓存图片地址的处理, 虽说缓存图片是放在 localStorage 中, 不会用大小限制, 但是太多也是不好的, 这里使用 LRU 算法对图片以及其他 localStorage 进行清除处理, 对于超过 7 天的数据进行清理
localStorage 详情页的数据, 数据结构如下:

```js
"读取后端的cookieID": {
  "path": "对应cdn图片的地址",
  "time": "缓存时间戳",
  "size": "大小"
}
```

#### 5.数据缓存和过期缓存数据的处理主体流程

![进入商品详情页,接口数据很慢时,对页面的优化](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-handle.png)

#### 6.对于大请求量的请求(如详情页面中的猜你喜欢, 推荐商品等一些大数据量的静态资源)

1. 由于这些不属于用户进入详情想第一时间获取的信息, 即不属于当前页面的目标主体, 所以这些可以使用 **Intersection Observer API** 进行主体元素的观察, 当当前主体元素被加载出来后, 在进行非主体元素的网络资源分配, 即网络空闲时再请求猜你喜欢, 推荐商品等资源, 处理请求优先级的问题
2. 需要保证当前详情页的请求列表的请求数 不超过当前浏览器的请求一个 tcp 最大 http 请求数

#### 7.当 worker 数据回来后, 出现 **大量图片** 替换对应元素的的 webp 或者缩略图出现的问题(静态资源过多)

这里有两种情景

1. 移动端, 对于移动端, 一般不会出现大量图片, 一般一个商品详情页, 不会超过 100 张图片资源; 这时候, 选择懒加载方案; 根据 GitHub 现有的很多方案, 当前滑动到可被观察的元素后才加载当前可视区域的图片资源, 同样使用的是 **Intersection Observer API** ; 比如 vue 的一个库 **vue-lazy** , 这个库就是对 Intersection_Observer_API 进行封装, 对可视区域的 img 便签进行 data-src 和 src 属性替换

2. 第二个情况, pc 端, 可能会出现大量的 img 标签, 可能多达 300~400 张, 这时候, 使用懒加载, 用户体验就不太好了; 比如说: 当用户在查看商品说明介绍时, 这些商品说明和介绍有可能只是一张张图片, 当用户很快速的滑动时, 页面还没懒加载完, 用户就有可能看不到想看的信息; 鉴于会出现这种情况, 这里给出一个方案就是, img 出现一张 load 一张; 实现如下：

```js
// 这里针对非第一次进入详情页,
//当前localStorage已经有了当前详情页商品图片的缩略图
for(let i = 0; i < worker.img.length; i++) {
  // nodeList是对应img标签,
  // 注意, 这里对应的nodeList一定要使用内联style把位置大小设置好, 避免大量的重绘重排
  const img = nodeList[i]
  img.src = worker.img['path'];
  img.onerror = () => {
    // 将替换失败或者加载失败的图片降级到缩略图, 
    // 即缓存到localStorage的缩略图或者webp图
    // 兼容客户端处理webp失败的情况
  }
}
```

#### 8.页面重绘重排处理

![页面渲染流程](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-paint.png)

触发重排的操作主要是几何因素：

1. 页面首次进入的渲染。
2. 浏览器 resize
3. 元素位置和尺寸发生改变的时候
4. 可见元素的增删
5. 内容发生改变
6. 字体的 font 的改变。
7. css 伪类激活。
   .....
  </br>
  
尽量减少上面这些产生重绘重排的操作

比如说：

这里产生很大的重绘重排主要发生在 worker 回来的数据替换页面中的图片 src 这一步

```js
// 该节点为img标签的父节点
const imgParent = docucment.getElementById('imgParent'); 
// 克隆当前需要替换img标签的父元素下所有的标签
const newImgParent = imgParent.cloneNode(true); 
const imgParentParent = docucment.getElementById('imgParentParent');
for(let i = 0; i < newImgParent.children.length; i++) { 
// 批量获取完所有img标签后, 再进行重绘
  newImgParent.children[i].src = worker.img[i].path;
}
// 通过img父节点的父节点, 来替换整个img父节点
// 包括对应的所有子节点, 只进行一次重绘操作
imgParentParent.replaceChild(newImgParent, imgParent); 
```

#### 9.css代码处理

**注意被阻塞的css资源**

众所周知, css的加载会阻塞浏览器其他资源的加载, 直至CSSOM **CSS OBJECT MODEL** 构建完成, 然后再挂在DOM树上, 浏览器依次使用渲染树来布局和绘制网页。 

很多人都下意识的知道, 将css文件一律放到head标签中是比较好的, 但是为什么将css放在head标签是最后了呢?

我们用淘宝做例子

![没有加载css的淘宝页面](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-taobao.png)
比如这种没有css样式的页面称之为FOUC(内容样式短暂失效), 但是这种情况一般出现在ie系列以及前期的浏览器身上; 就是当cssom在domtree生成后, 依然还没完成加载出来, 先展示纯html代码的页面一会再出现正确的带css样式的页面;

**减少不同页面的css代码加载**

对于电商页面, 有些在头部的css代码有些是首页展示的有些是特定情况才展示的, 比如当我们需要减少一些css文件大小但是当前网站又需要多屏展示, 这时候, 很多人都会想到是媒体查询, 没错方向是对的, 但是怎样的媒体查询才对css文件保持足够的小呢, 可以使用link标签媒体查询,看下边的的例子：

```html
<link href="base.css" rel="stylesheet">
<link href="other.css" rel="stylesheet" media="(min-width: 750px)">
```

第一个css资源表示所有页面都会加载, 第二个css资源, 宽度在750px才会加载, 默认media="all"

在一些需求写css媒体查询的网站, 不要在css代码里面写, 最好写两套css代码, 通过link媒体查询去动态加载, 这样就能很好的减轻网站加载css文件的压力

#### 10.静态js代码处理

这种js代码, 是那些关于埋点, 本地日记, 以及动态修改css代码, 读取页面成型后的信息的一些js代码, 这种一律放在同域下的localStorage上面, 什么是同域下的localStorage

这里还是以天猫为例

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-693-tianmao.png)


#### 11.容错处理

1. 页面在获取到 worker 回来的数据后, 通过拷贝整个html片段, 再将worker的img路径在替换对应的 img 资源后再进行追加到对应的dom节点
2. 缓存 css 文件和 js 文件到 localStorage 中, 若当前没有对应的 css 文件或者 js 文件, 或者被恶意修改过的 css 文件或者 js 文件(可使用签名进行判断), 删除再获取对应文件的更新

#### 12.推荐方案理由

1. 使用了 worker 线程请求详情数据, 不占用浏览器主线程; 进而减少主进程消耗在网络的时间
2. 使用 localStorage 的缓存机制, 因为当 worker 回来的数据后, 读取 localStorage 是同步读取的, 基本不会有太大的等待时间, 并且读取 localStorage 时, 使用的是后端返回来的 cookieID 进行读取, 且本地的 cookID 是 httpOnly 避免了第三方获取到 cookieID 进行读取商品信息
3. 使用 LRU 清除过多的缓存数据
4. 首次进入页面时, 保证已知页面布局情况下的快速渲染以及配置骨架图, 加快到达 FCP 和 FP 的时间
5. 就算 img 静态资源过大, 在第二次进入该页面的时候, 也可以做到低次数重绘重排, 加快到底 TTI 的时间

#### 13.方案不足

1. 在网络依然很慢的情况下, 首次进入详情页面, 如果长时间的骨架图和已知布局下, 用户的体验依然是不好的, 这里可以考虑 PWA 方案, 对最近一次成功请求的内容进行劫持, 并在无网情况下, 做出相应的提示和展示处理
2. 需要 UI 那边提供三套静态 img 资源

### Day118:说一下单点登录实现原理
null
### 一、什么是单点登录

单点登录SSO(Single Sign On),是一个多系统共存的环境下，用户在一处登录后，就不用在其他系统中登录，也就是用户的一次登录得到其他所有系统的信任

比如现有业务系统A、B、C以及SSO系统，第一次访问A系统时，发现没有登录，引导用户到SSO系统登录，根据用户的登录信息，生成唯一的一个凭据token，返回给用户。后期用户访问B、C系统的时候，携带上对应的凭证到SSO系统去校验，校验通过后，就可以单点登录；

单点登录在大型网站中使用的非常频繁，例如，阿里旗下有淘宝、天猫、支付宝等网站，其背后的成百上千的子系统，用户操作一次或者交易可能涉及到很多子系统，每个子系统都需要验证，所以提出，用户登录一次就可以访问相互信任的应用系统

单点登录有一个独立的认证中心，只有认证中心才能接受用户的用户名和密码等信息进行认证，其他系统不提供登录入口，只接受认证中心的间接授权。间接授权通过令牌实现，当用户提供的用户名和密码通过认证中心认证后，认证中心会创建授权令牌，在接下来的跳转过程中，授权令牌作为参数发送给各个子系统，子系统拿到令牌即得到了授权，然后创建局部会话。

### 二、单点登录原理

单点登录有同域和跨域两种场景

#### 1）同域

适用场景：都是企业自己的系统，所有系统都使用同一个一级域名通过不同的二级域名来区分。

举个例子：公司有一个一级域名为 zlt.com ，我们有三个系统分别是：门户系统(sso.zlt.com)、应用1(app1.zlt.com)和应用2(app2.zlt.com)，需要实现系统之间的单点登录，实现架构如下

核心原理：

1. 门户系统设置的cookie的domain为一级域名也是zlt.com，这样就可以共享门户的cookie给所有的使用该域名xxx.alt.com的系统
2. 使用Spring Session等技术让所有系统共享Session
3. 这样只要门户系统登录之后无论跳转应用1或者应用2，都能通过门户Cookie中的sessionId读取到Session中的登录信息实现单点登录

#### 2）跨域

单点登录之间的系统域名不一样，例如第三方系统。由于域名不一样不能共享Cookie了，需要的一个独立的授权系统，即一个独立的认证中心(passport),子系统的登录均可以通过passport，子系统本身将不参与登录操作，当一个系统登录成功后，passprot将会颁发一个令牌给子系统，子系统可以拿着令牌去获取各自的保护资源，为了减少频繁认证，各个子系统在被passport授权以后，会建立一个局部会话，在一定时间内无需再次向passport发起认证

**基本原理**

1. 用户第一次访问应用系统的时候，因为没有登录，会被引导到**认证系统**中进行登录；
2. 根据用户提供的登录信息，认证系统进行身份校验，如果通过，返回给用户一个认证凭据-**令牌**；
3. 用户再次访问别的应用的时候，**带上令牌作为认证凭证**；
4. 应用系统接收到请求后会把令牌送到认证服务器进行**校验**，如果通过，用户就可以在不用登录的情况下访问其他信任的业务服务器。

**登录流程**

![登录流程](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-689-sso.png)

1. 用户访问系统1的受保护资源，系统1发现用户没有登录，跳转到sso认证中心，并将自己的地址作为参数
2. sso认证中心发现用户未登录，将用户引导到登录页面
3. 用户提交用户名、密码进行登录
4. sso认证中心校验用户信息，创建用户与sso认证中心之间的会话，称之为全局会话，同时创建授权令牌
5. sso 带着令牌跳转回最初的请求的地址(系统1)
6. 系统1拿着令牌，去sso认证中心校验令牌是否有效
7. sso认证中心校验令牌，返回有效，注册系统1(也就是返回一个cookie)
8. 系统一使用该令牌创建与用户的会话，成为局部会话，返回受保护的资源
9. 用户访问系统2受保护的资源
10. 系统2发现用户未登录，跳转至sso认证中心，并将自己的地址作为参数
11. sso认证中心发现用户已登录，跳转回系统2的地址，并且附上令牌
12. 系统2拿到令牌，去sso中心验证令牌是否有效，返回有效，注册系统2
13. 系统2使用该令牌创建与用户的局部会话，返回受保护资源
14. 用户登录成功之后，会与sso认证中心以及各个子系统建立会话，用户与sso认证中心建立的会话称之为全局会话，用户与各个子系统建立的会话称之为局部会话，局部会话建立之后，用户访问子系统受保护资源将不再通过sso认证中心

**注销流程**

![注销流程](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-689-out.png)

1. 用户向系统提交注销操作
2. 系统根据用户与系统1建立的会话，拿到令牌，向sso认证中心提交注销操作
3. sso认证中心校验令牌有效，销毁全局会话，同时取出所有用此令牌注册的系统地址
4. sso认证中心向所有注册系统发起注销请求，各注册系统销毁局部会话
5. sso认证中心引导用户到登录页面



### Day119:怎样判断一个对象是否是数组，如何处理类数组对象
null
#### 判断数组方式

- `[] instanceof Array`
- `Object.prototype.toString.call([]) === '[object Array]'`
- `Array.prototype.isPrototypeOf([])`
- `[].constructor === Array`
- `Array.isArray([])`

#### 如何处理类数组对象

**1）JavaScript 类数组对象的定义**

- 可以通过索引访问元素，并且拥有 length 属性；
- 没有数组的其他方法，例如 `push` ， `forEach` ， `indexOf` 等。

```js
var foo = {
    0: 'JS',
    1: 'Node',
    2: 'TS',
    length: 3
}
```

**2）转换方式**

```js
// 方式一
Array.prototype.slice.call(arguments);
Array.prototype.slice.apply(arguments)
[].slice.call(arguments)

// 方式二
Array.from(arguments);

// 方式三
// 这种方式要求 数据结构 必须有 遍历器接口
[...arguments] 

// 方式四
[].concat.apply([],arguments)

// 方式五：手动实现
function toArray(s){
  var arr = [];  
  for(var i = 0,len = s.length; i < len; i++){   
    arr[i] = s[i];   
  }  
  return arr;  
}
```

**3）转换后注意几点**

- 数组长度由类数组的length属性决定
- 索引不连续，会自动补位undefined
- 仅考虑0和正整数索引；
- slice会产生稀疏数组，内容是empty而不是undefined
- 类数组push注意，push操作的是索引值为length的位置








### Day120:说一下 CORS 的简单请求和复杂请求的区别
null
### CORS

CORS即Cross Origin Resource Sharing（跨来源资源共享），通俗说就是我们所熟知的跨域请求。众所周知，在以前，跨域可以采用代理、JSONP等方式，而在Modern浏览器面前，这些终将成为过去式，因为有了CORS。

CORS在最初接触的时候只大概了解到，通过服务器端设置`Access-Control-Allow-Origin`响应头，即可使指定来源像访问同源接口一样访问跨域接口，最近在使用CORS的时候，由于需要传输自定义Header信息，发现原来CORS的规范定义远不止这些。

CORS可以分成两种：

1、**简单请求**
2、**复杂请求**

#### 1.简单请求：

**HTTP方法是下列之一**

- HEAD
- GET
- POST

**HTTP头信息不超出以下几种字段**

- Accept
- Accept-Language
- Content-Language
- Last-Event-ID
- Content-Type，但仅能是下列之一
- application/x-www-form-urlencoded
- multipart/form-data
- text/plain

任何一个不满足上述要求的请求，即被认为是复杂请求。一个复杂请求不仅有包含通信内容的请求，同时也包含预请求（preflight request）。

简单请求的发送从代码上来看和普通的XHR没太大区别，但是HTTP头当中要求总是包含一个域（Origin）的信息。该域包含协议名、地址以及一个可选的端口。不过这一项实际上由浏览器代为发送，并不是开发者代码可以触及到的。

**简单请求的部分响应头及解释如下：**

- Access-Control-Allow-Origin（必含）- 不可省略，否则请求按失败处理。该项控制数据的可见范围，如果希望数据对任何人都可见，可以填写"*"。
- Access-Control-Allow-Credentials（可选） – 该项标志着请求当中是否包含cookies信息，只有一个可选值：true（必为小写）。如果不包含cookies，请略去该项，而不是填写false。这一项与XmlHttpRequest2对象当中的withCredentials属性应保持一致，即withCredentials为true时该项也为true；withCredentials为false时，省略该项不写。反之则导致请求失败。
- Access-Control-Expose-Headers（可选） – 该项确定XmlHttpRequest2对象当中getResponseHeader()方法所能获得的额外信息。通常情况下，getResponseHeader()方法只能获得如下的信息：
- Cache-Control
- Content-Language
- Content-Type
- Expires
- Last-Modified
- Pragma
- 当你需要访问额外的信息时，就需要在这一项当中填写并以逗号进行分隔

如果仅仅是简单请求，那么即便不用CORS也没有什么大不了，但CORS的复杂请求就令CORS显得更加有用了。简单来说，任何不满足上述简单请求要求的请求，都属于复杂请求。比如说你需要发送PUT、DELETE等HTTP动作，或者发送Content-Type: application/json的内容。

#### 2.复杂请求

复杂请求表面上看起来和简单请求使用上差不多，但实际上浏览器发送了不止一个请求。其中最先发送的是一种"预请求"，此时作为服务端，也需要返回"预回应"作为响应。预请求实际上是对服务端的一种权限请求，只有当预请求成功返回，实际请求才开始执行。

预请求以OPTIONS形式发送，当中同样包含域，并且还包含了两项CORS特有的内容：

- Access-Control-Request-Method – 该项内容是实际请求的种类，可以是GET、POST之类的简单请求，也可以是PUT、DELETE等等。
- Access-Control-Request-Headers – 该项是一个以逗号分隔的列表，当中是复杂请求所使用的头部。

显而易见，这个预请求实际上就是在为之后的实际请求发送一个权限请求，在预回应返回的内容当中，服务端应当对这两项进行回复，以让浏览器确定请求是否能够成功完成。

**复杂请求的部分响应头及解释如下：**

- Access-Control-Allow-Origin（必含） – 和简单请求一样的，必须包含一个域。
- Access-Control-Allow-Methods（必含） – 这是对预请求当中Access-Control-Request-Method的回复，这一回复将是一个以逗号分隔的列表。尽管客户端或许只请求某一方法，但服务端仍然可以返回所有允许的方法，以便客户端将其缓存。
- Access-Control-Allow-Headers（当预请求中包含Access-Control-Request-Headers时必须包含） – 这是对预请求当中Access-Control-Request-Headers的回复，和上面一样是以逗号分隔的列表，可以返回所有支持的头部。这里在实际使用中有遇到，所有支持的头部一时可能不能完全写出来，而又不想在这一层做过多的判断，没关系，事实上通过request的header可以直接取到Access-Control-Request-Headers，直接把对应的value设置到Access-Control-Allow-Headers即可。
- Access-Control-Allow-Credentials（可选） – 和简单请求当中作用相同。
- Access-Control-Max-Age（可选） – 以秒为单位的缓存时间。预请求的的发送并非免费午餐，允许时应当尽可能缓存。

一旦预回应如期而至，所请求的权限也都已满足，则实际请求开始发送。

通过caniuse.com得知，目前大部分Modern浏览器已经支持完整的CORS，但IE直到IE11才完美支持，所以对于PC网站，还是建议采用其他解决方案，如果仅仅是移动端网站，大可放心使用。





### Day121:说一下 在 map 中和 for 中调用异步函数的区别
null
### map & for

- map 会先把执行同步操作执行完，就返回，之后再一次一次的执行异步任务
- for 是等待异步返回结果后再进入下一次循环

#### map

```js
const arr = [1, 2, 3, 4, 5];
function getData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve("data");
    }, 1000);
  });
}

(async () => {
  const result = arr.map(async () => {
    console.log("start");
    const data = await getData();
    console.log(data);
    return data;
  });
  console.log(result);
})();

// 5 start -> 遍历每一项开始
// (5) [Promise, Promise, Promise, Promise, Promise] -> 返回的结果
// 5 data -> 遍历每一项异步执行返回的结果
```

#### 分析

map 函数的原理是：

1. 循环数组，把数组每一项的值，传给回调函数
2. 将回调函数处理后的结果 push 到一个新的数组
3. 返回新数组

map 函数函数是同步执行的，循环每一项时，到给新数组值都是同步操作。

代码执行结果：

map 不会等到回调函数的异步函数返回结果，就会进入下一次循环。

执行完同步操作之后，就会返回结果，所以 map 返回的值都是 Promise

#### 解决问题

- 使用 for、for..of 代替

简单实现一个

```js
// 获取数据接口
function getData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve("data");
    }, 1000);
  });
}
// 异步的map
async function selfMap(arr, fn) {
  let result = [];
  for (let i = 0, len = arr.length; i < len; i++) {
    const item = await fn(arr[i], i);
    result.push(item);
  }
  return result;
}
// 调用
(async () => {
  const res = await selfMap([1, 2, 3, 4, 5], async (item, i) => {
    const data = await getData();
    return `${item}_${data}`;
  });
  console.log(res, "res");
})();
// ["1_data", "2_data", "3_data", "4_data", "5_data"] "res"
```

#### for

```js
function getData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve("data");
    }, 1000);
  });
}

(async () => {
  for (let i = 0, len = arr.length; i < len; i++) {
    console.log(i);
    const data = await getData();
    console.log(data);
  }
})();

// 0
// data
// 1
// data
// 2
// data
// 3
// data
// 4
// data
```




### Day122:说一下 import 的原理，与 require 有什么不同?
null
#### import原理(实际上就是ES6 module的原理)

1. 简单来说就是闭包的运用
2. 为了创建Module的内部作用域，会调用一个包装函数
3. 包装函数的返回值也就是Module向外公开的API，也就是所有export出去的变量
4. import也就是拿到module导出变量的引用

#### 与require的不同

- CommonJS模块输出的是一个值的拷贝，ES6模块输出的是值的引用
- CommonJS模块是运行时加载，ES6模块是编译时输出接口

CommonJS是运行时加载对应模块，一旦输出一个值，即使模块内部对其做出改变，也不会影响输出值，如：

```js
// a.js
var a = 1;
function changeA(val) {
    a = val;
}
module.exports = {
    a: a,
    changeA: changeA,
}

// b.js
var modA = require('./a.js');
console.log('before', modA.a); // 输出1
modA.changeA(2);
console.log('after', modA.a); // 还是1
```

而ES6模块则不同，import导入是在JS引擎对脚步静态分析时确定，获取到的是一个只读引用。等脚本增长运行时，会根据这个引用去对应模块中取值。所以引用对应的值改变时，其导入的值也会变化




### Day123:说下 webpack 的 loader 和 plugin 的区别，都使用过哪些 loader 和 plugin
null
### 一、loader&plugin

#### 1.1 loader

loader是文件加载器，能够加载资源文件，并对这些文件进行一些处理，诸如编译、压缩等，最终一起打包到指定的文件中，处理一个文件可以使用多个loader，loader的执行顺序和配置中的顺序是相反的，即最后一个loader最先执行，第一个loader最后执行，第一个执行的loader接收源文件内容作为参数，其它loader接收前一个执行的loader的返回值作为参数，最后执行的loader会返回此模块的JavaScript源码

编写自己的loader时需要引用官方提供的loader-utils ，调用loaderUtils.getOptions(this)拿到webpack的配置参数，然后进行自己的处理。

Loader 本身仅仅只是一个函数，接收模块代码的内容，然后返回代码内容转化后的结果，并且一个文件还可以链式的经过多个loader转化(比如scss-loader => css-loader => style-loader)。

一个 Loader 的职责是单一的，只需要完成一种转化。 如果一个源文件需要经历多步转化才能正常使用，就通过多个 Loader 去转化。 在调用多个 Loader 去转化一个文件时，每个 Loader 会链式的顺序执行， 第一个 Loader 将会拿到需处理的原内容，上一个 Loader 处理后的结果会传给下一个接着处理，最后的 Loader 将处理后的最终结果返回给 Webpack。

一个最简单的loader例子:

```js
module.exports = function(source) {
  // source 为 compiler 传递给 Loader 的一个文件的原内容
  // 该函数需要返回处理后的内容，这里简单起见，直接把原内容返回了，相当于该 Loader 没有做任何转换
  return source;
};
```

#### 1.2 plugin

plugin功能更强大，Loader不能做的都是它做。它的功能要更加丰富。从打包优化和压缩，到重新定义环境变量，功能强大到可以用来处理各种各样的任务。

plugin让webpack的机制更加灵活，它在编译过程中留下的一系列生命周期的钩子，通过调用这些钩子来实现在不同编译结果时对源模块进行处理。它的编译是基于事件流来编译的，主要通过taptable来实现插件的绑定和执行的，taptable主要是基于发布订阅执行的插件架构，是用来创建声明周期钩子的库。调用complier.hooks.run.tap开始注册，创建compilation，基于配置创建chunks，在通过parser解析chunks，使用模块和依赖管理模块之间的依赖关系，最后使用template基于compilation数据生成结果代码 

plugin 的实现可以是一个类，使用时传入相关配置来创建一个实例，然后放到配置的 `plugins` 字段中，而 plugin 实例中最重要的方法是 `apply`，该方法在 webpack compiler 安装插件时会被调用一次，`apply` 接收 webpack compiler 对象实例的引用，你可以在 compiler 对象实例上注册各种事件钩子函数，来影响 webpack 的所有构建流程，以便完成更多其他的构建任务。

一个最简单的plugin例子：

```js
class BasicPlugin{
  // 在构造函数中获取用户给该插件传入的配置
  constructor(options){
  }

  // Webpack 会调用 BasicPlugin 实例的 apply 方法给插件实例传入 compiler 对象
  apply(compiler){
    compiler.plugin('compilation',function(compilation) {
    })
  }
}

// 导出 Plugin
module.exports = BasicPlugin;
```

Webpack 启动后，在读取配置的过程中会先执行 new BasicPlugi(options) 初始化一个 BasicPlugin 获得其实例。 在初始化 compiler 对象后，再调用 basicPlugin.apply(compiler) 给插件实例传入 compiler 对象。 插件实例在获取到 compiler 对象后，就可以通过 compiler.plugin(事件名称, 回调函数) 监听到 Webpack 广播出来的事件。 并且可以通过 compiler 对象去操作 Webpack。

开发 Plugin 最主要的就是理解 compiler 和 compilation，它们是Plugin 和 Webpack 之间的桥梁。这两者提供的各种 hooks 和 api，则是开发plugin 所必不可少的材料，通过 compiler 和 compilation 的生命周期 hooks，也可以更好地深入了解 webpack 的整个构建工作是如何进行的。

### 二、常见的plugin & loader

#### 2.1 常见loader

1. file-loader:文件加载
2. url-loader：文件加载，可以设置阈值，小于时把文件base64编码
3. image-loader：加载并压缩图片
4. json-loader：webpack默认包含了
5. babel-loader：ES6+ 转成ES5
6. ts-loader：将ts转成js
7. awesome-typescript-loader：比上面那个性能好
8. css-loader：处理@import和url这样的外部资源
9. style-loader：在head创建style标签把样式插入；
10. postcss-loader：扩展css语法，使用postcss各种插件autoprefixer，cssnext，cssnano
11. eslint-loader,tslint-loader:通过这两种检查代码，tslint不再维护，用的eslint
12. vue-loader：加载vue单文件组件
13. i18n-loader：国际化
14. cache-loader：性能开销大的loader前添加，将结果缓存到磁盘；
15. svg-inline-loader：压缩后的svg注入代码；
16. source-map-loader：加载source Map文件，方便调试；
17. expose-loader:暴露对象为全局变量
18. imports-loader、exports-loader等可以向模块注入变量或者提供导出模块功能
19. raw-loader可以将文件已字符串的形式返回
20. 校验测试：mocha-loader、jshint-loader 、eslint-loader等

2.2 常见plugin

- ignore-plugin：忽略文件
- uglifyjs-webpack-plugin：不支持 ES6 压缩 (Webpack4 以前使用)
- terser-webpack-plugin: 支持压缩 ES6 (Webpack4)
- webpack-parallel-uglify-plugin: 多进程执行代码压缩，提升构建速度
- mini-css-extract-plugin: 分离样式文件，CSS 提取为独立文件，支持按需加载
- serviceworker-webpack-plugin：为网页应用增加离线缓存功能
- clean-webpack-plugin: 目录清理
- speed-measure-webpack-plugin: 可以看到每个 Loader 和 Plugin 执行耗时
- webpack内置UglifyJsPlugin，压缩和混淆代码。
- webpack内置CommonsChunkPlugin，提高打包效率，将第三方库和业务代码分开打包。
- ProvidePlugin：自动加载模块，代替require和import
- html-webpack-plugin可以根据模板自动生成html代码，并自动引用css和js文件
- extract-text-webpack-plugin 将js文件中引用的样式单独抽离成css文件
- DefinePlugin 编译时配置全局变量，这对开发模式和发布模式的构建允许不同的行为非常有用。
- HotModuleReplacementPlugin 热更新
- DllPlugin和DllReferencePlugin相互配合，前者第三方包的构建，只构建业务代码，同时能解决Externals多次引用问题。DllReferencePlugin引用DllPlugin配置生成的manifest.json文件，manifest.json包含了依
赖模块和module id的映射关系
- optimize-css-assets-webpack-plugin 不同组件中重复的css可以快速去重
- webpack-bundle-analyzer 一个webpack的bundle文件分析工具，将bundle文件以可交互缩放的treemap的形式展示。
- compression-webpack-plugin 生产环境可采用gzip压缩JS和CSS
- happypack：通过多进程模型，来加速代码构建







