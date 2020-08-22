### 1实现链式调用

链式调用的核心就在于调用完的方法将自身实例返回
1）示例一
```js
function Class1() {
    console.log('初始化')
}
Class1.prototype.method = function(param) {
    console.log(param)
    return this
}
let cl = new Class1()
//由于new 在实例化的时候this会指向创建的对象， 所以this.method这个方法会在原型链中找到。
cl.method('第一次调用').method('第二次链式调用').method('第三次链式调用')
```
2）示例二
```js
var obj = {
    a: function() {
        console.log("a");
        return this;
    },
    b: function() {
        console.log("b");
        return this;
    },
};
obj.a().b();
```
3）示例三
```js
// 类
class Math {
    constructor(value) {
        this.hasInit = true;
        this.value = value;
        if (!value) {
            this.value = 0;
            this.hasInit = false;
        }
    }
    add() {
        let args = [...arguments]
        let initValue = this.hasInit ? this.value : args.shift()
        const value = args.reduce((prev, curv) => prev + curv, initValue)
        return new Math(value)
    }
    minus() {
        let args = [...arguments]
        let initValue = this.hasInit ? this.value : args.shift()
        const value = args.reduce((prev, curv) => prev - curv, initValue)
        return new Math(value)
    }
    mul() {
        let args = [...arguments]
        let initValue = this.hasInit ? this.value : args.shift()
        const value = args.reduce((prev, curv) => prev * curv, initValue)
        return new Math(value)
    }
    divide() {
        let args = [...arguments]
        let initValue = this.hasInit ? this.value : args.shift()
        const value = args.reduce((prev, curv) => prev / (+curv ? curv : 1), initValue)
        return new Math(value)
    }
}

let test = new Math()
const res = test.add(222, 333, 444).minus(333, 222).mul(3, 3).divide(2, 3)
console.log(res.value)

// 原型链
Number.prototype.add = function() {
    let _that = this
    _that = [...arguments].reduce((prev, curv) => prev + curv, _that)
    return _that
}
Number.prototype.minus = function() {
    let _that = this
    _that = [...arguments].reduce((prev, curv) => prev - curv, _that)
    return _that
}
Number.prototype.mul = function() {
    let _that = this
    _that = [...arguments].reduce((prev, curv) => prev * curv, _that)
    return _that
}
Number.prototype.divide = function() {
    let _that = this
    _that = [...arguments].reduce((prev, curv) => prev / (+curv ? curv : 1), _that)
    return _that
}
let num = 0;
let newNum = num.add(222, 333, 444).minus(333, 222).mul(3, 3).divide(2, 3)
console.log(newNum)
```

### 2实现 add(1)(2)(3)

考点：函数柯里化

函数柯里化概念： 柯里化（Currying）是把接受多个参数的函数转变为接受一个单一参数的函数，并且返回接受余下的参数且返回结果的新函数的技术。

1）粗暴版

```js
function add (a) {
    return function (b) {
        return function (c) {
            return a + b + c;
        }
    }
}
console.log(add(1)(2)(3)); // 6
```

2）柯里化解决方案

- 参数长度固定

```js
const curry = (fn) =>
(judge = (...args) =>
    args.length === fn.length
    ? fn(...args)
    : (...arg) => judge(...args, ...arg));
const add = (a, b, c) => a + b + c;
const curryAdd = curry(add);
console.log(curryAdd(1)(2)(3)); // 6
console.log(curryAdd(1, 2)(3)); // 6
console.log(curryAdd(1)(2, 3)); // 6
```

- 参数长度不固定

```js
function add (...args) {
    //求和
    return args.reduce((a, b) => a + b)
}

function currying (fn) {
    let args = []
    return function temp (...newArgs) {
        if (newArgs.length) {
            args = [
                ...args,
                ...newArgs
            ]
            return temp
        } else {
            let val = fn.apply(this, args)
            args = [] //保证再次调用时清空
            return val
        }
    }
}

let addCurry = currying(add)
console.log(addCurry(1)(2)(3)(4, 5)())  //15
console.log(addCurry(1)(2)(3, 4, 5)())  //15
console.log(addCurry(1)(2, 3, 4, 5)())  //15
```


### 3实现 lodash 的\_.get

在 js 中经常会出现嵌套调用这种情况，如 a.b.c.d.e，但是这么写很容易抛出异常。你需要这么写 a && a.b && a.b.c && a.b.c.d && a.b.c.d.e，但是显得有些啰嗦与冗长了。特别是在 graphql 中，这种嵌套调用更是难以避免。
这时就需要一个 get 函数，使用 get(a, 'b.c.d.e') 简单清晰，并且容错性提高了很多。

1）代码实现
```js
function get(source, path, defaultValue = undefined) {
  // a[3].b -> a.3.b -> [a,3,b]
 // path 中也可能是数组的路径，全部转化成 . 运算符并组成数组
  const paths = path.replace(/\[(\d+)\]/g, ".$1").split(".");
  let result = source;
  for (const p of paths) {
    // 注意 null 与 undefined 取属性会报错，所以使用 Object 包装一下。
    result = Object(result)[p];
    if (result == undefined) {
      return defaultValue;
    }
  }
  return result;
}
// 测试用例
console.log(get({ a: null }, "a.b.c", 3)); // output: 3
console.log(get({ a: undefined }, "a", 3)); // output: 3
console.log(get({ a: null }, "a", 3)); // output: 3
console.log(get({ a: [{ b: 1 }] }, "a[0].b", 3)); // output: 1
```
2）代码实现 
不考虑数组的情况
```js
const _get = (object, keys, val) => {
 return keys.split(/\./).reduce(
  (o, j)=>( (o || {})[j] ), 
  object
 ) || val
}
console.log(get({ a: null }, "a.b.c", 3)); // output: 3
console.log(get({ a: undefined }, "a", 3)); // output: 3
console.log(get({ a: null }, "a", 3)); // output: 3
console.log(get({ a: { b: 1 } }, "a.b", 3)); // output: 1
```

### 4手写用 ES6proxy 如何实现 arr[-1] 的访问

```js
const negativeArray = els =>
    new Proxy(els, {
        get: (target, propKey, receiver) =>
            Reflect.get(
                target,
                +propKey < 0 ? String(target.length + +propKey) : propKey,
                receiver
            )
    });
const unicorn = negativeArray(["京", "程", "一", "灯"]);
unicorn[-1]; 
```

### 5手写发布订阅

```js
// 发布订阅中心, on-订阅, off取消订阅, emit发布, 内部需要一个单独事件中心caches进行存储;

interface CacheProps {
  [key: string]: Array<((data?: unknown) => void)>;
}

class Observer {

  private caches: CacheProps = {}; // 事件中心

  on (eventName: string, fn: (data?: unknown) => void){ // eventName事件名-独一无二, fn订阅后执行的自定义行为
    this.caches[eventName] = this.caches[eventName] || [];
    this.caches[eventName].push(fn);
  }

  emit (eventName: string, data?: unknown) { // 发布 => 将订阅的事件进行统一执行
    if (this.caches[eventName]) {
      this.caches[eventName].forEach((fn: (data?: unknown) => void) => fn(data));
    }
  }

  off (eventName: string, fn?: (data?: unknown) => void) { // 取消订阅 => 若fn不传, 直接取消该事件所有订阅信息
    if (this.caches[eventName]) {
      const newCaches = fn ? this.caches[eventName].filter(e => e !== fn) : [];
      this.caches[eventName] = newCaches;
    }
  }
  
}
```

### 6手写数组转树

```js
// 例如将 input 转成output的形式
let input = [
    {
        id: 1, val: '学校', parentId: null
    }, {
        id: 2, val: '班级1', parentId: 1
    }, {
        id: 3, val: '班级2', parentId: 1
    }, {
        id: 4, val: '学生1', parentId: 2
    }, {
        id: 5, val: '学生2', parentId: 3
    }, {
        id: 6, val: '学生3', parentId: 3
    },
]

let output = {
    id: 1,
    val: '学校',
    children: [{
        id: 2,
        val: '班级1',
        children: [
            {
                id: 4,
                val: '学生1',
                children: []
            },
            {
                id: 5,
                val: '学生2',
                children: []
            }
        ]
    }, {
        id: 3,
        val: '班级2',
        children: [{
            id: 6,
            val: '学生3',
            children: []
        }]
    }]
}
```

```js
// 代码实现
function arrayToTree(array) {
    let root = array[0]
    array.shift()
    let tree = {
        id: root.id,
        val: root.val,
        children: array.length > 0 ? toTree(root.id, array) : []
    }
    return tree;
}

function toTree(parenId, array) {
    let children = []
    let len = array.length
    for (let i = 0; i < len; i++) {
        let node = array[i]
        if (node.parentId === parenId) {
            children.push({
                id: node.id,
                val: node.val,
                children: toTree(node.id, array)
            })
        }
    }
    return children
}

console.log(arrayToTree(input))
```

### 7介绍防抖节流原理、区别以及应用，并用JavaScript进行实现

1）防抖
- 原理：在事件被触发n秒后再执行回调，如果在这n秒内又被触发，则重新计时。
- 适用场景：
  - 按钮提交场景：防止多次提交按钮，只执行最后提交的一次
  - 搜索框联想场景：防止联想发送请求，只发送最后一次输入
- 简易版实现

```js
function debounce(func, wait) {
    let timeout;
    return function () {
        const context = this;
        const args = arguments;
        clearTimeout(timeout)
        timeout = setTimeout(function(){
            func.apply(context, args)
        }, wait);
    }
}
```

- 立即执行版实现
  - 有时希望立刻执行函数，然后等到停止触发 n 秒后，才可以重新触发执行。

```js
// 有时希望立刻执行函数，然后等到停止触发 n 秒后，才可以重新触发执行。
function debounce(func, wait, immediate) {
  let timeout;
  return function () {
    const context = this;
    const args = arguments;
    if (timeout) clearTimeout(timeout);
    if (immediate) {
      const callNow = !timeout;
      timeout = setTimeout(function () {
        timeout = null;
      }, wait)
      if (callNow) func.apply(context, args)
    } else {
      timeout = setTimeout(function () {
        func.apply(context, args)
      }, wait);
    }
  }
}
```

- 返回值版实现
  - func函数可能会有返回值，所以需要返回函数结果，但是当 immediate 为 false 的时候，因为使用了 setTimeout ，我们将 func.apply(context, args) 的返回值赋给变量，最后再 return 的时候，值将会一直是 undefined，所以只在 immediate 为 true 的时候返回函数的执行结果。

```js
function debounce(func, wait, immediate) {
  let timeout, result;
  return function () {
    const context = this;
    const args = arguments;
    if (timeout) clearTimeout(timeout);
    if (immediate) {
      const callNow = !timeout;
      timeout = setTimeout(function () {
        timeout = null;
      }, wait)
      if (callNow) result = func.apply(context, args)
    }
    else {
      timeout = setTimeout(function () {
        func.apply(context, args)
      }, wait);
    }
    return result;
  }
}
```

2）节流
- 原理：规定在一个单位时间内，只能触发一次函数。如果这个单位时间内触发多次函数，只有一次生效。
- 适用场景
  - 拖拽场景：固定时间内只执行一次，防止超高频次触发位置变动
  - 缩放场景：监控浏览器resize
- 使用时间戳实现
  - 使用时间戳，当触发事件的时候，我们取出当前的时间戳，然后减去之前的时间戳(最一开始值设为 0 )，如果大于设置的时间周期，就执行函数，然后更新时间戳为当前的时间戳，如果小于，就不执行。

```js
function throttle(func, wait) {
  let context, args;
  let previous = 0;

  return function () {
    let now = +new Date();
    context = this;
    args = arguments;
    if (now - previous > wait) {
      func.apply(context, args);
      previous = now;
    }
  }
}
```

- 使用定时器实现
  - 当触发事件的时候，我们设置一个定时器，再触发事件的时候，如果定时器存在，就不执行，直到定时器执行，然后执行函数，清空定时器，这样就可以设置下个定时器。

```js
function throttle(func, wait) {
  let timeout;
  return function () {
    const context = this;
    const args = arguments;
    if (!timeout) {
      timeout = setTimeout(function () {
        timeout = null;
        func.apply(context, args)
      }, wait)
    }

  }
}
```


### 8类数组和数组的区别，dom 的类数组如何转换成数组

1）定义

- 数组是一个特殊对象,与常规对象的区别：
   1. 当由新元素添加到列表中时，自动更新length属性
   2. 设置length属性，可以截断数组
   3. 从Array.protoype中继承了方法
   4. 属性为'Array'
- 类数组是一个拥有length属性，并且他属性为非负整数的普通对象，类数组不能直接调用数组方法。

2）区别

本质：类数组是简单对象，它的原型关系与数组不同。

```js
// 原型关系和原始值转换
let arrayLike = {
    length: 10,
};
console.log(arrayLike instanceof Array); // false
console.log(arrayLike.__proto__.constructor === Array); // false
console.log(arrayLike.toString()); // [object Object]
console.log(arrayLike.valueOf()); // {length: 10}

let array = [];
console.log(array instanceof Array); // true
console.log(array.__proto__.constructor === Array); // true
console.log(array.toString()); // ''
console.log(array.valueOf()); // []
```

3）类数组转换为数组

- 转换方法
   1. 使用 `Array.from()`
   2. 使用 `Array.prototype.slice.call()` 
   3. 使用 `Array.prototype.forEach()` 进行属性遍历并组成新的数组 
- 转换须知
  - 转换后的数组长度由 `length` 属性决定。索引不连续时转换结果是连续的，会自动补位。
  - 代码示例

```js
let al1 = {
    length: 4,
    0: 0,
    1: 1,
    3: 3,
    4: 4,
    5: 5,
};
console.log(Array.from(al1)) // [0, 1, undefined, 3]
```

  - ②仅考虑 0或正整数 的索引

```js
// 代码示例
let al2 = {
    length: 4,
    '-1': -1,
    '0': 0,
    a: 'a',
    1: 1
};
console.log(Array.from(al2)); // [0, 1, undefined, undefined]
```

  - ③使用slice转换产生稀疏数组

```js
// 代码示例
let al2 = {
    length: 4,
    '-1': -1,
    '0': 0,
    a: 'a',
    1: 1
};
console.log(Array.prototype.slice.call(al2)); //[0, 1, empty × 2]
```

4）使用数组方法操作类数组注意地方

```js
  let arrayLike2 = {
    2: 3,
    3: 4,
    length: 2,
    push: Array.prototype.push
  }

  // push 操作的是索引值为 length 的位置
  arrayLike2.push(1);
  console.log(arrayLike2); // {2: 1, 3: 4, length: 3, push: ƒ}
  arrayLike2.push(2);
  console.log(arrayLike2); // {2: 1, 3: 2, length: 4, push: ƒ}
```

### 9介绍下 promise 的特性、优缺点，内部是如何实现的，动手实现 Promise

1）Promise基本特性
- 1、Promise有三种状态：pending(进行中)、fulfilled(已成功)、rejected(已失败)
- 2、Promise对象接受一个回调函数作为参数, 该回调函数接受两个参数，分别是成功时的回调resolve和失败时的回调reject；另外resolve的参数除了正常值以外， 还可能是一个Promise对象的实例；reject的参数通常是一个Error对象的实例。
- 3、then方法返回一个新的Promise实例，并接收两个参数onResolved(fulfilled状态的回调)；onRejected(rejected状态的回调，该参数可选)
- 4、catch方法返回一个新的Promise实例
- 5、finally方法不管Promise状态如何都会执行，该方法的回调函数不接受任何参数
- 6、Promise.all()方法将多个多个Promise实例，包装成一个新的Promise实例，该方法接受一个由Promise对象组成的数组作为参数(Promise.all()方法的参数可以不是数组，但必须具有Iterator接口，且返回的每个成员都是Promise实例)，注意参数中只要有一个实例触发catch方法，都会触发Promise.all()方法返回的新的实例的catch方法，如果参数中的某个实例本身调用了catch方法，将不会触发Promise.all()方法返回的新实例的catch方法
- 7、Promise.race()方法的参数与Promise.all方法一样，参数中的实例只要有一个率先改变状态就会将该实例的状态传给Promise.race()方法，并将返回值作为Promise.race()方法产生的Promise实例的返回值
- 8、Promise.resolve()将现有对象转为Promise对象，如果该方法的参数为一个Promise对象，Promise.resolve()将不做任何处理；如果参数thenable对象(即具有then方法)，Promise.resolve()将该对象转为Promise对象并立即执行then方法；如果参数是一个原始值，或者是一个不具有then方法的对象，则Promise.resolve方法返回一个新的Promise对象，状态为fulfilled，其参数将会作为then方法中onResolved回调函数的参数，如果Promise.resolve方法不带参数，会直接返回一个fulfilled状态的 Promise 对象。需要注意的是，立即resolve()的 Promise 对象，是在本轮“事件循环”（event loop）的结束时执行，而不是在下一轮“事件循环”的开始时。
- 9、Promise.reject()同样返回一个新的Promise对象，状态为rejected，无论传入任何参数都将作为reject()的参数


2）Promise优点

- ①统一异步 API
  - Promise 的一个重要优点是它将逐渐被用作浏览器的异步 API ，统一现在各种各样的 API ，以及不兼容的模式和手法。
- ②Promise 与事件对比
  - 和事件相比较， Promise 更适合处理一次性的结果。在结果计算出来之前或之后注册回调函数都是可以的，都可以拿到正确的值。 Promise 的这个优点很自然。但是，不能使用 Promise 处理多次触发的事件。链式处理是 Promise 的又一优点，但是事件却不能这样链式处理。
- ③Promise 与回调对比
  - 解决了回调地狱的问题，将异步操作以同步操作的流程表达出来。
- ④Promise 带来的额外好处是包含了更好的错误处理方式（包含了异常处理），并且写起来很轻松（因为可以重用一些同步的工具，比如 Array.prototype.map() ）。

3）Promise缺点

- 1、无法取消Promise，一旦新建它就会立即执行，无法中途取消。
- 2、如果不设置回调函数，Promise内部抛出的错误，不会反应到外部。
- 3、当处于Pending状态时，无法得知目前进展到哪一个阶段（刚刚开始还是即将完成）。
- 4、Promise 真正执行回调的时候，定义 Promise 那部分实际上已经走完了，所以 Promise 的报错堆栈上下文不太友好。


4）简单代码实现
最简单的Promise实现有7个主要属性, state(状态), value(成功返回值), reason(错误信息), resolve方法, reject方法, then方法.

```js
class Promise{
  constructor(executor) {
    this.state = 'pending';
    this.value = undefined;
    this.reason = undefined;
    let resolve = value => {
      if (this.state === 'pending') {
        this.state = 'fulfilled';
        this.value = value;
      }
    };
    let reject = reason => {
      if (this.state === 'pending') {
        this.state = 'rejected';
        this.reason = reason;
      }
    };
    try {
      // 立即执行函数
      executor(resolve, reject);
    } catch (err) {
      reject(err);
    }
  }
  then(onFulfilled, onRejected) {
    if (this.state === 'fulfilled') {
      let x = onFulfilled(this.value);
    };
    if (this.state === 'rejected') {
      let x = onRejected(this.reason);
    };
  }
}
```

5）面试够用版

```js
function myPromise(constructor){ let self=this;
  self.status="pending" //定义状态改变前的初始状态 
  self.value=undefined;//定义状态为resolved的时候的状态 
  self.reason=undefined;//定义状态为rejected的时候的状态 
  function resolve(value){
    //两个==="pending"，保证了了状态的改变是不不可逆的 
    if(self.status==="pending"){
      self.value=value;
      self.status="resolved"; 
    }
  }
  function reject(reason){
     //两个==="pending"，保证了了状态的改变是不不可逆的
     if(self.status==="pending"){
        self.reason=reason;
        self.status="rejected"; 
      }
  }
  //捕获构造异常 
  try{
      constructor(resolve,reject);
  }catch(e){
    reject(e);
    } 
}
myPromise.prototype.then=function(onFullfilled,onRejected){ 
  let self=this;
  switch(self.status){
    case "resolved": onFullfilled(self.value); break;
    case "rejected": onRejected(self.reason); break;
    default: 
  }
}

// 测试
var p=new myPromise(function(resolve,reject){resolve(1)}); 
p.then(function(x){console.log(x)})
//输出1
```

6）大厂专供版

```js
const PENDING = "pending"; 
const FULFILLED = "fulfilled"; 
const REJECTED = "rejected";
function Promise(excutor) {
  let that = this; // 缓存当前promise实例例对象
  that.status = PENDING; // 初始状态
  that.value = undefined; // fulfilled状态时 返回的信息
  that.reason = undefined; // rejected状态时 拒绝的原因 
  that.onFulfilledCallbacks = []; // 存储fulfilled状态对应的onFulfilled函数
  that.onRejectedCallbacks = []; // 存储rejected状态对应的onRejected函数
  function resolve(value) { // value成功态时接收的终值
    if(value instanceof Promise) {
      return value.then(resolve, reject);
    }
    // 实践中要确保 onFulfilled 和 onRejected ⽅方法异步执⾏行行，且应该在 then ⽅方法被调⽤用的那⼀一轮事件循环之后的新执⾏行行栈中执⾏行行。
    setTimeout(() => {
      // 调⽤用resolve 回调对应onFulfilled函数
      if (that.status === PENDING) {
        // 只能由pending状态 => fulfilled状态 (避免调⽤用多次resolve reject)
        that.status = FULFILLED;
        that.value = value;
        that.onFulfilledCallbacks.forEach(cb => cb(that.value));
      }
    });
  }
  function reject(reason) { // reason失败态时接收的拒因
    setTimeout(() => {
      // 调⽤用reject 回调对应onRejected函数
      if (that.status === PENDING) {
        // 只能由pending状态 => rejected状态 (避免调⽤用多次resolve reject)
        that.status = REJECTED;
        that.reason = reason;
        that.onRejectedCallbacks.forEach(cb => cb(that.reason));
      }
    });
  }

  // 捕获在excutor执⾏行行器器中抛出的异常
  // new Promise((resolve, reject) => {
  //     throw new Error('error in excutor')
  // })
  try {
    excutor(resolve, reject);
  } catch (e) {
    reject(e);
  }
}
Promise.prototype.then = function(onFulfilled, onRejected) {
  const that = this;
  let newPromise;
  // 处理理参数默认值 保证参数后续能够继续执⾏行行
  onFulfilled = typeof onFulfilled === "function" ? onFulfilled : value => value;
  onRejected = typeof onRejected === "function" ? onRejected : reason => {
    throw reason;
  };
  if (that.status === FULFILLED) { // 成功态
    return newPromise = new Promise((resolve, reject) => {
      setTimeout(() => {
        try{
          let x = onFulfilled(that.value);
          resolvePromise(newPromise, x, resolve, reject); //新的promise resolve 上⼀一个onFulfilled的返回值
        } catch(e) {
          reject(e); // 捕获前⾯面onFulfilled中抛出的异常then(onFulfilled, onRejected);
        }
      });
    })
  }
  if (that.status === REJECTED) { // 失败态
    return newPromise = new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          let x = onRejected(that.reason);
          resolvePromise(newPromise, x, resolve, reject);
        } catch(e) {
          reject(e);
        }
      });
    });
  }
  if (that.status === PENDING) { // 等待态
// 当异步调⽤用resolve/rejected时 将onFulfilled/onRejected收集暂存到集合中
    return newPromise = new Promise((resolve, reject) => {
      that.onFulfilledCallbacks.push((value) => {
        try {
          let x = onFulfilled(value);
          resolvePromise(newPromise, x, resolve, reject);
        } catch(e) {
          reject(e);
        }
      });
      that.onRejectedCallbacks.push((reason) => {
        try {
          let x = onRejected(reason);
          resolvePromise(newPromise, x, resolve, reject);
        } catch(e) {
          reject(e);
        }
      });
    });
  }
};
```

### 10实现 Promise.all
```js
Promise.all = function (arr) {
  // 实现代码
};
```

**1) 核心思路**

- ①接收一个 Promise 实例的数组或具有 Iterator 接口的对象作为参数
- ②这个方法返回一个新的 promise 对象，
- ③遍历传入的参数，用Promise.resolve()将参数"包一层"，使其变成一个promise对象
- ④参数所有回调成功才是成功，返回值数组与参数顺序一致
- ⑤参数数组其中一个失败，则触发失败状态，第一个触发失败的 Promise 错误信息作为 Promise.all 的错误信息。

**2）实现代码**
一般来说，Promise.all 用来处理多个并发请求，也是为了页面数据构造的方便，将一个页面所用到的在不同接口的数据一起请求过来，不过，如果其中一个接口失败了，多个请求也就失败了，页面可能啥也出不来，这就看当前页面的耦合程度了～

```js
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

### 11说一下事件循环机制(node、浏览器)

#### 1）为什么会有Event Loop

​    JavaScript的任务分为两种`同步`和`异步`，它们的处理方式也各自不同，**同步任务**是直接放在主线程上排队依次执行，**异步任务**会放在任务队列中，若有多个异步任务则需要在任务队列中排队等待，任务队列类似于缓冲区，任务下一步会被移到**调用栈**然后主线程执行调用栈的任务。

> **调用栈**：调用栈是一个栈结构，函数调用会形成一个栈帧，帧中包含了当前执行函数的参数和局部变量等上下文信息，函数执行完后，它的执行上下文会从栈中弹出。

​    JavaScript是`单线程`的，单线程是指 js引擎中解析和执行js代码的线程只有一个（主线程），每次只能做一件事情，然而`ajax`请求中，主线程在等待响应的过程中回去做其他事情，浏览器先在事件表注册ajax的回调函数，响应回来后回调函数被添加到任务队列中等待执行，不会造成线程阻塞，所以说js处理ajax请求的方式是异步的。

​    综上所述，检查调用栈是否为空以及讲某个任务添加到调用栈中的个过程就是event loop，这就是JavaScript实现异步的核心。



#### 2）浏览器中的 Event Loop

##### Micro-Task 与 Macro-Task

浏览器端事件循环中的异步队列有两种：macro（宏任务）队列和 micro（微任务）队列。

常见的 macro-task：`setTimeout`、`setInterval`、`script（整体代码）`、` I/O 操作`、`UI 渲染`等。

常见的 micro-task: `new Promise().then(回调)`、`MutationObserve `等。



##### requestAnimationFrame

requestAnimationFrame也属于异步执行的方法，但该方法既不属于宏任务，也不属于微任务。按照MDN中的定义：

> `window.requestAnimationFrame()` 告诉浏览器——你希望执行一个动画，并且要求浏览器在下次重绘之前调用指定的回调函数更新动画。该方法需要传入一个回调函数作为参数，该回调函数会在浏览器下一次重绘之前执行

requestAnimationFrame是GUI渲染之前执行，但在`Micro-Task`之后，不过requestAnimationFrame不一定会在当前帧必须执行，由浏览器根据当前的策略自行决定在哪一帧执行。



##### event loop过程

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-20-1.jpg)

1. 检查macrotask队列是否为空，非空则到2，为空则到3
2. 执行macrotask中的一个任务
3. 继续检查microtask队列是否为空，若有则到4，否则到5
4. 取出microtask中的任务执行，执行完成返回到步骤3
5. 执行视图更新

> 当某个宏任务执行完后,会查看是否有微任务队列。如果有，先执行微任务队列中的所有任务，如果没有，会读取宏任务队列中排在最前的任务，执行宏任务的过程中，遇到微任务，依次加入微任务队列。栈空后，再次读取微任务队列里的任务，依次类推。



#### 3）node中的 Event Loop

Node 中的 Event Loop 和浏览器中的是完全不相同的东西。Node.js采用V8作为js的解析引擎，而I/O处理方面使用了自己设计的libuv，libuv是一个基于事件驱动的跨平台抽象层，封装了不同操作系统一些底层特性，对外提供统一的API，事件循环机制也是它里面的实现

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-20-2.png)

根据上图node的运行机制如下

1. V8引擎解析JavaScript脚本。
2. 解析后的代码，调用Node API。
3. libuv库负责Node API的执行。它将不同的任务分配给不同的线程，形成一个Event Loop（事件循环），以异步的方式将任务的执行结果返回给V8引擎。
4. V8引擎再将结果返回给用户。



##### 六大阶段

其中libuv引擎中的事件循环分为 6 个阶段，它们会按照顺序反复运行。每当进入某一个阶段的时候，都会从对应的回调队列中取出函数去执行。当队列为空或者执行的回调函数数量到达系统设定的阈值，就会进入下一阶段。

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-20-3.png)

1. `timers` 阶段：这个阶段执行timer（setTimeout、setInterval）的回调，并且是由 poll 阶段控制的。
2. `I/O callbacks` 阶段：处理一些上一轮循环中的少数未执行的 I/O 回调
3. `idle, prepare` 阶段：仅node内部使用
4. `poll` 阶段：获取新的I/O事件, 适当的条件下node将阻塞在这里
5. `check` 阶段：执行 setImmediate() 的回调
6. `close callbacks` 阶段：执行 socket 的 close 事件回调



#####  poll阶段

poll 是一个至关重要的阶段，这一阶段中，系统会做两件事情

1.回到 timer 阶段执行回调

2.执行 I/O 回调

并且在进入该阶段时如果没有设定了 timer 的话，会发生以下两件事情

- 如果 poll 队列不为空，会遍历回调队列并同步执行，直到队列为空或者达到系统限制
- 如果 poll 队列为空时，会有两件事发生
  - 如果有 setImmediate 回调需要执行，poll 阶段会停止并且进入到 check 阶段执行回调
  - 如果没有 setImmediate 回调需要执行，会等待回调被加入到队列中并立即执行回调，这里同样会有个超时时间设置防止一直等待下去

当然设定了 timer 的话且 poll 队列为空，则会判断是否有 timer 超时，如果有的话会回到 timer 阶段执行回调。



##### Micro-Task 与 Macro-Task

Node端事件循环中的异步队列也是这两种：macro（宏任务）队列和 micro（微任务）队列。

- 常见的 macro-task 比如：`setTimeout`、`setInterval`、 `setImmediate`、`script（整体代码`）、` I/O 操作等`。
- 常见的 micro-task 比如: `process.nextTick`、`new Promise().then(回调)`等。



##### setTimeout 和 setImmediate

二者非常相似，区别主要在于调用时机不同。

- setImmediate 设计在poll阶段完成时执行，即check阶段；
- setTimeout 设计在poll阶段为空闲时，且设定时间到达后执行，但它在timer阶段执行

```javascript
setTimeout(function timeout () {
  console.log('timeout');
},0);
setImmediate(function immediate () {
  console.log('immediate');
});
```

1. 对于以上代码来说，setTimeout 可能执行在前，也可能执行在后。
2. 首先 setTimeout(fn, 0) === setTimeout(fn, 1)，这是由源码决定的 进入事件循环也是需要成本的，如果在准备时候花费了大于 1ms 的时间，那么在 timer 阶段就会直接执行 setTimeout 回调
3. 如果准备时间花费小于 1ms，那么就是 setImmediate 回调先执行了



#####  process.nextTick

这个函数其实是独立于 Event Loop 之外的，它有一个自己的队列，当每个阶段完成后，如果存在 nextTick 队列，就会清空队列中的所有回调函数，并且优先于其他 microtask 执行



#### 4）Node与浏览器的 Event Loop 差异

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-20-4.png)

- Node端，microtask 在事件循环的各个阶段之间执行
- 浏览器端，microtask 在事件循环的 macrotask 执行完之后执行


### 12对闭包的看法，为什么要用闭包？说一下闭包原理以及应用场景

### 答案

#### 1）什么是闭包

函数执行后返回结果是一个内部函数，并被外部变量所引用，如果内部函数持有被执行函数作用域的变量，即形成了闭包。

可以在内部函数访问到外部函数作用域。使用闭包，一可以读取函数中的变量，二可以将函数中的变量存储在内存中，保护变量不被污染。而正因闭包会把函数中的变量值存储在内存中，会对内存有消耗，所以不能滥用闭包，否则会影响网页性能，造成内存泄漏。当不需要使用闭包时，要及时释放内存，可将内层函数对象的变量赋值为null。


#### 2）闭包原理

函数执行分成两个阶段(预编译阶段和执行阶段)。

- 在预编译阶段，如果发现内部函数使用了外部函数的变量，则会在内存中创建一个“闭包”对象并保存对应变量值，如果已存在“闭包”，则只需要增加对应属性值即可。
- 执行完后，函数执行上下文会被销毁，函数对“闭包”对象的引用也会被销毁，但其内部函数还持用该“闭包”的引用，所以内部函数可以继续使用“外部函数”中的变量

利用了函数作用域链的特性，一个函数内部定义的函数会将包含外部函数的活动对象添加到它的作用域链中，函数执行完毕，其执行作用域链销毁，但因内部函数的作用域链仍然在引用这个活动对象，所以其活动对象不会被销毁，直到内部函数被烧毁后才被销毁。

#### 3）优点

1. 可以从内部函数访问外部函数的作用域中的变量，且访问到的变量长期驻扎在内存中，可供之后使用
2. 避免变量污染全局
3. 把变量存到独立的作用域，作为私有成员存在

#### 4）缺点

1. 对内存消耗有负面影响。因内部函数保存了对外部变量的引用，导致无法被垃圾回收，增大内存使用量，所以使用不当会导致内存泄漏
2. 对处理速度具有负面影响。闭包的层级决定了引用的外部变量在查找时经过的作用域链长度
3. 可能获取到意外的值(captured value)

#### 4）应用场景

**应用场景一：** 典型应用是模块封装，在各模块规范出现之前，都是用这样的方式防止变量污染全局。

```js
var Yideng = (function () {
    // 这样声明为模块私有变量，外界无法直接访问
    var foo = 0;

    function Yideng() {}
    Yideng.prototype.bar = function bar() {
        return foo;
    };
    return Yideng;
}());
```

**应用场景二：** 在循环中创建闭包，防止取到意外的值。

如下代码，无论哪个元素触发事件，都会弹出 3。因为函数执行后引用的 i 是同一个，而 i 在循环结束后就是 3

```js
for (var i = 0; i < 3; i++) {
    document.getElementById('id' + i).onfocus = function() {
      alert(i);
    };
}
//可用闭包解决
function makeCallback(num) {
  return function() {
    alert(num);
  };
}
for (var i = 0; i < 3; i++) {
    document.getElementById('id' + i).onfocus = makeCallback(i);
}
```


### 13写一个 mySetInterVal(fn, a, b),每次间隔 a,a+b,a+2b 的时间，然后写一个 myClear，停止上面的 mySetInterVal

```js
const mySetInterval = (fn, a, b) => {
    let _interval = [a, a + b, a + 2 * b]
    let _currentInterval = null
    let _idx = 0

    let _mySetInterval = _t => {
        if(_idx < _interval.length) {
            clearInterval(_currentInterval)
            _currentInterval =  setInterval(() => {
                fn()
                _idx++
                _mySetInterval(_interval[_idx])
            }, _t)
            return _currentInterval
        } else {
            _idx = 0
            _mySetInterval(_interval[_idx])
        }
    }
    _mySetInterval(_interval[_idx])
    return _currentInterval
}

const myClear = (_interval) => {
    clearInterval(_interval)
}
let interval = mySetInterval(() => {
    console.timeEnd('定时器')
    console.time('定时器')
}, 1000, 1000)
```

### 14请列出目前主流的 JavaScript 模块化实现的技术有哪些？说出它们的区别？

目前流行的js模块化规范有CommonJS、AMD、CMD以及ES6的模块系统。

### 一、CommonJS

**CommonJS的出发点:** JS没有完善的模块系统，标准库较少，缺少包管理工具。伴随着NodeJS的兴起，能让JS在任何地方运行，特别是服务端，也达到了具备开发大型项目的能力，所以CommonJS营运而生。

Node.js是commonJS规范的主要实践者，它有四个重要的环境变量为模块化的实现提供支持：`module`、`exports`、`require`、`global`。实际使用时，用`module.exports`定义当前模块对外输出的接口（不推荐直接用`exports`），用`require`加载模块。

commonJS用同步的方式加载模块。在服务端，模块文件都存在本地磁盘，读取非常快，所以这样做不会有问题。但是在浏览器端，限于网络原因，更合理的方案是使用异步加载。

- 暴露模块：`module.exports = value`或`exports.xxx = value`
- 引入模块：`require(xxx)`

#### 1.CommonJS规范

- 一个文件就是一个模块，拥有单独的作用域
- 普通方式定义的变量、函数、对象都属于该模块内
- 通过require来加载模块
- 通过exports和module.exports来暴露块中的内容

#### 2.注意

1. 当exports和module.exports同时存在时，module.exports会覆盖exports
2. 当模块内全是exports时，就等同于module.exports
3. exports就是module.exports的子集
4. 所有代码都运行在模块作用域，不会污染全局作用域
5. 模块可以多次加载，但只会在第一次加载时候运行，然后运行结果就被缓存了，以后再加载，就直接读取缓存结果
6. 模块加载顺讯，按照代码出现的顺序同步加载
7. __dirname代表当前磨具爱文件所在的文件夹路径
8. __filename代表当前模块文件所在的文件夹路径+文件名

### 二、ES6模块化

ES6 在语言标准的层面上，实现了模块功能，而且实现得相当简单，旨在成为浏览器和服务器通用的模块解决方案。其模块功能主要由两个命令构成：`export`和`import`。`export`命令用于规定模块的对外接口，`import`命令用于输入其他模块提供的功能。

其实ES6还提供了`export default`命令，为模块指定默认输出，对应的`import`语句不需要使用大括号。这也更趋近于AMD的引用写法。

ES6的模块不是对象，`import`命令会被 JavaScript 引擎静态分析，在编译时就引入模块代码，而不是在代码运行时加载，所以无法实现条件加载。也正因为这个，使得静态分析成为可能。

#### 1.export

export可以导出的是一个对象中包含的多个属性、方法。export default只能导出一个可以不具名的函数。我们可以通过import进行引用。同时，我们也可以直接使用require使用，原因是webpack起了server相关。

#### 2.import

1. import {fn} from './xxx/xxx' ( export 导出方式的 引用方式 )
2. import fn from './xxx/xxx1' ( export default 导出方式的 引用方式 )

### 三、AMD

Asynchronous Module Definition，异步加载模块。它是一个在浏览器端模块化开发的规范，不是原生js的规范，使用AMD规范进行页面开发需要用到对应的函数库，RequireJS。

AMD规范采用异步方式加载模块，模块的加载不影响它后面语句的运行。所有依赖这个模块的语句，都定义在一个回调函数中，等到加载完成之后，这个回调函数才会运行。

使用require.js实现AMD规范的模块化：用`require.config()`指定引用路径等，用`define()`定义模块，用`require()`加载模块。

```js
//定义模块
define('moduleName',['a','b'],function(ma,mb){
    return someExportValue;
})
//引入模块
require(['a','b'],function(ma,mb){
  /*code*/
})
```

#### 1.RequireJS主要解决的问题

- 文件可能有依赖关系，被依赖的文件需要早于依赖它的文件加载到浏览器
- js加载的时候浏览器会停止页面渲染，加载文件愈多，页面相应事件就越长
- 异步前置加载

#### 2.语法


`define(id,dependencies,factory)`

- id 可选参数，用来定义模块的标识，如果没有提供该参数，脚本文件名（去掉拓展名）
- dependencies 是一个当前模块用来的模块名称数组
- factory 工厂方法，模块初始化要执行的函数或对象，如果为函数，它应该只被执行一次，如果是对象，此对象应该为模块的输出值。


### 四、CMD

CMD是另一种js模块化方案，它与AMD很类似，不同点在于：AMD 推崇依赖前置、提前执行，CMD推崇依赖就近、延迟执行。此规范其实是在sea.js推广过程中产生的。

因为CMD推崇一个文件一个模块，所以经常就用文件名作为模块id； CMD推崇依赖就近，所以一般不在define的参数中写依赖，而是在factory中写。

`define(id, deps, factory)`

factory有三个参数： `function(require, exports, module){}`

1. require require 是 factory 函数的第一个参数，require 是一个方法，接受 模块标识 作为唯一参数，用来获取其他模块提供的接口；
2. exports exports 是一个对象，用来向外提供模块接口；
3. module module是一个对象，上面存储了与当前模块相关联的一些属性和方法。

```js
//定义没有依赖的模块
define(function(require,exports,module){
  exports.xxx = vaule;
  module.exports = value;
})
//定义有依赖的模块
define(function(require,exports,module){
  //同步引入模块
  var module1 = require("./module1.js");
  //异步引入模块
  require.async("./module2.js",function(m2){
    /***/
  })
  //暴露接口
  exports.xxx = value;
})

//引入模块
define(function(require){
  const m1 = require("./module1.js");
  m1.show();
})
```

### 五、UMD通用模块规范

一种整合了CommonJS和AMD规范的方法，希望能解决跨平台模块方案。

**运行原理**

- UMD先判断是否支持Node.js的模块（exports）是否存在，存在则使用Node.js模块模式。
- 再判断是否支持AMD（define是否存在），存在则使用AMD方式加载模块。

```js
(function (window, factory) {
    if (typeof exports === 'object') {  
        module.exports = factory();
    } else if (typeof define === 'function' && define.amd) {
        define(factory);
    } else {    
        window.eventUtil = factory();
    }
})(this, function () {
    //module ...
});
```

### 六、总结

commonjs是同步加载的。主要是在nodejs 也就是服务端应用的模块化机制，通过 `module.export` 导出声明，通过 `require('')` 加载。每个文件都是一个模块。他有自己的作用域，文件内的变量，属性函数等不能被外界访问。node会将模块缓存，第二次加载会直接在缓存中获取。

AMD是异步加载的。主要应用在浏览器环境下。requireJS是遵循AMD规范的模块化工具。他是通过 `define()` 定义声明，通过 `require('',function(){})` 加载。

ES6的模块化加载时通过 `export default` 导出,用import导入 可通过 `{}` 对导出的内容进行解构。

ES6的模块的运行机制与common不一样，js引擎对脚本静态分析的时候，遇到模块加载指令后会生成一个只读引用，等到脚本真正执行的时候才会通过引用去模块中获取值，在引用到执行的过程中 模块中的值发生了变化，导入的这里也会跟着变，ES6模块是动态引用，并不会缓存值，模块里总是绑定其所在的模块。

### 15请实现鼠标点击页面中的任意标签，alert 该标签的名称(注意兼容性)

#### 代码实现

```js
// 直接实现
document.onclick = function(e){
    let e = e || window.event;//处理兼容，获取事件的对象
    let o = e["target"] || e["srcElement"];//处理兼容，获取事件目标
    alert(o.tagName.toLowerCase()); 
}

// 优雅实现
function elementName(evt) {
  evt = evt || window.event;
  var selected = evt.target || evt.srcElement;
  var eleName =
      selected && selected.tagName
  ? selected.tagName.toLowerCase()
  : "no tagName";
  alert(eleName);
}

window.onload = function() {
  var el = document.getElementsByTagName("body");
  el[0].onclick = elementName;
};
```

### 16原生实现 ES5 的 Object.create()方法

#### Object.create()

- Object.create()方法使用指定的原型对象和其属性创建了一个新的对象。
- Object.create(proto,[propertiesObject])
- Object.create方法创建一个空对象，然后将空对象的__proto__ = proto，如果还有propertiesObject参数的话，就进行object.assign类似的操作，把属性赋上去。

#### 代码实现

**1）简单粗暴**

```js
// create 创建一个对象，使其 __proto__ 指向传入的原型
fuction creat(obj){
  // 创建一个空的构造函数
  function F(){}
  // 将构造函数的 prototype 指向传入的对象
  F.prototype = obj
  // 返回新构造函数的实例
  retrun new F()
}
```

**2）实现propertiesObject参数**

```js
Object.create = function (prototype, properties) {
    if (typeof prototype !== "object") { 
        throw TypeError(); }
    function Ctor() {}
    Ctor.prototype = prototype;
    var o = new Ctor();
    if (prototype) { 
        o.constructor = Ctor; 
    }
    if (properties !== undefined) {
      if (properties !== Object(properties)) { 
          throw TypeError(); 
       }
      Object.defineProperties(o, properties);
    }
    return o;
};
```

### 17原生实现addClass,用多种方法

#### 1.实现方式一

- classList

```js
document.getElementById("vipemail").classList.add("btn-active");
```

#### 2.实现方式二

- className

```js
function isHasClassName(target,arr){
    for(var i in arr){
        if(target === arr[i]){
            return true;
        }
    }
} 
function addClass(ele,addname){
    if(!ele.className){
        // class非空的时候,再判断要添加的类目是不是已经存在
        ele.className = addname;
        //class名为空的时候,直接赋值           
    }else{
        //非空
        if(!isHasClassName(addname,ele.className.split(" "))){
            //不存在要添加的class名
            ele.className += " " + addname;
        }

    }
}
```

#### 2.实现方式三

- className

```js
function hasClass(obj, cls) {
    return obj.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
}

function addClass(obj, cls) {
    if (!this.hasClass(obj, cls)) obj.className += " " + cls;
}
```



### 18回调函数和任务队列的区别

#### 1.回调函数

回调函数是作为参数传给另一个函数的函数，这个函数会在另一个函数执行完成后执行。

#### 2.任务队列

任务队列是一个事件的队列，IO设备完成一项任务后，就在队列中添加一个事件，表示相关的异步任务可以进入执行栈了。

**同步任务:** 主线程上排队执行的任务，前一个任务执行完成后才能执行下一个任务。

**异步任务:** 不进入主线程，进入任务队列的任务。只有当主线程上的同步任务执行完成后，主线程会读取任务队列中的任务，开始异步执行。

任务队列中的事件包括IO设备的事件、用户产生的事件。只要指定过回调函数，这些事件发生时就会进入任务队列，等待主线程读取。

异步任务必须指定回调函数，当主线程开始执行异步任务，就是执行对应的回调函数。

### 19按要求完成题目
```js
/* 
  a)在不使用vue、react的前提下写代码解决一下问题
    一个List页面上，含有1000个条目的待办列表，现其中100项在同一时间达到了过期时间，需要在对应项的text-node里添加“已过期”文字。需要尽可能减少dom重绘次数以提升性能。
  b)尝试使用vue或react解决上述问题
*/
```

#### 1.原生方式实现

- **html**

```html
<body>
    <button id="expire1">过期设置(暴力法)</button>
    <button id="expire2">过期设置(innerHTMl)</button>
    <ul id="wrap"></ul>
</body>
```

- **JavaScript**

```js
//生成大量dom 
let start = new Date().getTime()
let $ul = document.getElementById("wrap");

let el = document.createDocumentFragment()
let allKeys = []
for(var i = 0; i < 1000; i++){
    let li = document.createElement('li');
    li.dataset.key = i  //key
    li.innerHTML = i
    el.appendChild(li)
    allKeys.push(i)
}
$ul.appendChild(el)


// 生成过期项 模拟服务端生成的数据
function getExpireKeys(){
    let keys = []
    while(keys.length < 100){
    let randomKey = Math.floor(Math.random() * 1000)
    if(keys.indexOf(randomKey) === -1){
        keys.push(randomKey)
    }else{
        continue
    }
    }
    return keys
}

// 暴力项 逐项遍历
document.getElementById('expire1').onclick = function(){
    let expireKeys = getExpireKeys()
    let children = $ul.children;
    let start = Date.now()
    for (let i = 0; i < expireKeys.length; i++) {
    const element = document.querySelector(`[data-key="${expireKeys[i]}"]`);
    element.innerHTML = element.innerHTML + '已过期'
    }
}

//模板字符串 innerHtml替换
document.getElementById('expire2').onclick = function(){
    let expireKeys = getExpireKeys()
    const item = []
    for (let i = 0; i < allKeys.length; i++) {
    item.push( `<li>${allKeys[i]} ${expireKeys.indexOf(allKeys[i]) !== -1 ? '已过期' : ''}</li>`)
    }
    $ul.innerHTML = item.join('')
}
```

#### 2.Vue方式处理

```js
// template
<button @click=setExpire>过期</button>
<ul>
  <li v-for="item in allKeys" :key="item.value">
    {{item.value}}
    {{item.expire ? '已过期' : ''}}
  </li>
</ul>

// script
<script>
export default {
  data() {
    return {
      allKeys: [],  //所有项
      expireKeys: []  //过期项
    }
  },
  created(){
    for(var i = 0; i < 1000; i++){
      this.allKeys.push({
        value: i,
        expire: false
      })
    }
  },
  methods: {
    setExpire(){
      let keys = this.getExpireKeys()
      for (let i = 0; i < this.allKeys.length; i++) {
        if(keys.indexOf(this.allKeys[i].value) !== -1){
          this.allKeys[i].expire = true
        }
      }
    },
    // 生成过期项 模拟服务端生成的数据
    getExpireKeys(){
      let keys = []
      while(keys.length < 100){
        let randomKey = Math.floor(Math.random() * 1000)
        if(keys.indexOf(randomKey) === -1){
          keys.push(randomKey)
        }else{
          continue
        }
      }
      return keys
    }
  },
}
</script>
```


### 20实现一个倒计时,setInterval实现的话，如何消除时间误差

### 解决思路

可以使用setTimeout 递归自循环调用解决问题

实现代码

```js
countDown();
function addZero(i){
    return i < 10 ? "0" + i : i + "";
}
function countDown(){
    var nowtime = new Date()
    var endtime = new Date("2020/10/25,17:57:00");
    var lefttime = parseInt((endtime.getTime() - nowtime.getTime()) / 1000);
    var d = parseInt(lefttime / (24*60*60));
    var h = parseInt(lefttime / (60*60)%24);
    var m = parseInt(lefttime / 60%60);
    var s = parseInt(lefttime % 60);
    d = addZero(d);
    h = addZero(h);
    m = addZero(m);
    s = addZero(s);
    document.querySelector(".count").innerText = `活动倒计时 ${d} 天 ${h} 时 ${m} 分 ${s} 秒 `;
    if(lefttime <= 0){
        document.querySelector('.count').innerText = "活动结束";
    }
    setTimeout(countDown,1000);
}
```

### 21你是如何组织 JavaScript 代码的？（可以从模块、组件、模式、编程思想等方面回答）

### 组织JavaScript代码

精心设计的代码更易于维护，优化和扩展，能使开发者更高效。这意味着更多的注意力和精力可以花在构建伟大的事情上，每个人都很愉快——用户，开发者和利益相关者。

比较宽松的语言，特别是 JavaScript ，需要一些规矩才能写好

JavaScript 环境非常宽松，随处扔些代码片段，就可能起作用。早点确立系统架构（然后遵守它！）对你的代码库提供制约，确保自始至终的一致性。

有3个高级的，跟语言无关的点，对代码设计十分重要。

####   1.系统架构

代码库的基础设计。控制各种组件的规则，例如模块（models），视图（views）和控制器（controllers），以及之间的相互作用。

#### 2.可维护性

如何更好地改进和扩展代码？

#### 3.复用性

应用组件如何复用？每个组件的实例如何简便地个性定制？

### 二、模块模式

**模块模式** 是一个简单的结构基础，它可以让你的代码保持干净和条例清晰。一个“模块”就是个标准的包含方法和属性的对象字面量，简单是这个模式的最大亮点：甚至一些不熟悉传统的软件设计模式的人，一看就能立刻明白代码是如何工作的。

用此模式的应用，每个组件有它独立的模块。例如，创建自动完成功能，你要写个模块用于文本区域，一个模块用于结果列表。两个模块相互工作，但是文本区域代码不会触及结果列表代码，反之亦然。

**模块解耦** 是模块模式非常适于构建可靠的系统架构的原因。应用间的关系是明确定义的；任何关系到文本区域的事情被文本区域模块管理，并不是散落在代码库中——代码整洁。

模块化组织的另一个好处是固有的可维护性。模块可以独立地改进和优化，不会影响应用的任何其它部分。

看下下边的例子

#### 1.基础 - 函数版：

```js
function a(){};
function b(){};
```

#### 2.入门 - 字面量版：

```js
var obj = {
    init : function(){
        this.a();
        this.b();
    },
    a : function(){},
    b : function(){}
}
// 在页面中调用obj.init();
```

#### 3.进阶 - 命名空间版：

```js
var hogo = {
    ns : function(){};
}

hogo.ns('hogo.wx', {
    init : function(){
        this.a();
        this.b();
    },
    a : function(){},
    b : function(){}
});
hogo.wx.init();
```

#### 4.提高 - 模块化版：

```js
define();
require();
```

### 22请写出代码执⾏结果，并解释为什么
```js
function yideng() {
  console.log(1);
}
(function () {
  if (false) {
    function yideng() {
      console.log(2);
    }
  }
  console.log(typeof yideng);
  yideng();
})();
```

### 答案

```js
undefined 
Uncaught TypeError: yideng is not a function
```

### 解析

直接在函数体内定义的函数声明，整个都会提前, 但是在块中定义的函数声明，只会提升其声明部分，不分配实际的内存空间。

所以yideng被提升的只是声明的函数名称变量，并未实际赋值。

代码等价于

```js
function yideng() {
  console.log(1);
}
(function () {
  var yideng;
  if (false) {
    function yideng() {
      console.log(2);
    }
  }
  console.log(typeof yideng);//undefined
  yideng();//is not a function
})();
```

### 知识点


#### 1.变量提升

变量的提升是以变量作用域来决定的

- 全局作用域中声明的变量会提升至全局最顶层
- 函数内声明的变量只会提升至该函数作用域最顶层。

```js
console.log(a);
var a = 10;
// 等价于
var a;
console.log(a);
a = 10;
```

#### 2.函数提升

函数提升，类似变量提升，但是确有些许不同。

**1）函数表达式**

```js
console.log(a);// undefined
var a = function(){};
```

函数表达式不会声明提升，所以这里输出undefined,是var a变量声明的提升

**2）函数声明**

函数声明会覆盖变量声明，因为函数是一等公民,与其他值地位相同，所以函数声明会覆盖变量声明

如果存在函数声明和变量声明（注意：仅仅是声明，还没有被赋值），而且变量名跟函数名是相同的，那么，它们都会被提示到外部作用域的开头，但是，函数的优先级更高，所以变量的值会被函数覆盖掉。

- 未赋值的情况

```js
var company;
function company () {
console.log ("yideng");
}
console.log(typeof company);// function
// 函数声明将变量声明覆盖了
```

- 赋值情况

如果这个变量或者函数其中是赋值了的，那么另外一个将无法覆盖它：

```js
var company = "yideng"; // 变量声明并赋值
function company () {
    console.log ("yideng");
}
console.log(typeof company); // string

// 上边的代码等价于
var company;
function company(){};
company = 'yideng'; // 被重新赋值
console.log(typeof company);  // 所以是string
```

#### 3.块级作用域的函数声明

在块级作用域中的函数声明和变量是不同的

**1）级作用域中变量声明**

```js
console.log(a); //ReferenceError: a is not defined
if(true){
    a = 10;
    console.log(a);
}
console.log(a);
// 会报错，
```

**2）块级作用域函数声明**

```js
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
```

这里其实就是函数 `function a(){}` 经过预解析之后,将函数声明提到函数级作用域最前面，`var a;// 函数a的声明` ,然后将函数定义提升到块级作用域最前面， `function a(){}` 函数a的定义

**3）注意**

- 如果改变了作用域内声明的函数的处理规则，显然会对老代码产生很大影响。为了减轻因此产生的不兼容问题，es6在附录B里面规定，浏览器的实现可以不遵守上面规定，有自己的行为方式
  - 允许在块级作用域内声明函数
  - 函数声明类似于var,即会提升到全局作用域或函数作用域的头部
  - 同时，函数声明还会提升到所在的块级作用域的头部。
- 注意，上面三条规则只对ES6的浏览器实现有效，其它环境的实现不用遵守，还是将块级作用域的函数声明当做let处理
- 块级作用域函数，就像预先在全局作用域中使用`var`声明了一个变量，且默认值为`undefined`。

```js
console.log(a,window.a); // undefined undefined
{
    console.log(a,window.a); // function a(){} undefined
    function a(){}
    console.log(a,window.a); // function a(){} function a(){}
}
console.log(a,window.a);	// function a(){} function a(){}
```

**4）总结**

- 块级作用域函数在编译阶段将函数声明提升到全局作用域，并且会在全局声明一个变量，值为undefined。同时，也会被提升到对应的块级作用域顶层。
- 块级作用域函数只有定义声明函数的那行代码执行过后，才会被映射到全局作用域。

#### 5.块级作用域中有同名的变量和函数声明

```js
console.log(window.a,a);//undefined undefined
{
    console.log(window.a,a);//undefined function a(){}
    function a() {};
    a = 10;
    console.log(window.a,a); //function a(){}  10
};
console.log(window.a,a); //function a(){}  function a(){}
```

1. 第一个log,块级作用域函数a的声明会被提升到全局作用域，所以不报错，是 `undefined undefined`
2. 第二个log,在块级作用域中，由于声明函数a提升到块级作用域顶端,所以打印 `a = function a(){}`，而 `window.a`由于并没有执行函数定义的那一行代码，所以仍然为 `undefined`。
3. 第三个log,这时已经执行了声明函数定义，所以会把函数a映射到全局作用域中。所以输出 `function a(){}`,
4. 第四个log,就是 `function a(){}  function a(){}`，因为在块级作用域中window.a的值已经被改变了，变成了`function a(){}`

**块级作用域函数只有执行函数声明语句的时候，才会重写对应的全局作用域上的同名变量。**

### 23在浏览器执行以下代码，写出打印结果
```js
console.log("start");
setTimeout(() => {
  console.log("children2");
  Promise.resolve().then(() => {
    console.log("children3");
  });
}, 0);
new Promise(function (resolve, reject) {
  console.log("children4");
  setTimeout(function () {
    console.log("children5");
    resolve("children6");
  }, 0);
}).then((res) => {
  console.log("children7");
  setTimeout(() => {
    console.log(res);
  }, 0);
});
```

### 答案

```js
start
children4
children2
children3
children5
children7
children6
```

### 解析

1. 先执行宏任务script脚本
2. console.log("start")执行
3. 遇到定时器交由定时器线程，等待时间到了加入队列
4. 遇到Promise直接执行executor，打印console.log("children4");遇到第二定时器，又交由定时器线程管理，等待加入队列。Promise.then等resolve之后加入微对列。此时第一轮任务执行完毕
5. 第一定时器先进入队列，取出任务进行执行console.log("children2");此时遇到promise执行，并将promise.then放入当前宏任务队列中的微任务队列。当前任务还行完毕。执行then，打印 console.log("children3");
6. 取出第二定时器，打印console.log("children5");并将then放入微任务中，当前宏任务执行完毕，取出then执行children7。
7. 又遇到定时器，由定时器线程管理等待时间到了添加到宏任务中，
8. 取出定时器任务，打印children6


**原理**

1. js是单线程，最大特点就维持了一个事件循环
2. 事件循环的组成由主线程和任务队列
3. 执行方式就是主线程不停从任务队列一个一个取出任务进行执行
4. 任务分为宏任务和微任务
5. 每个宏任务内都维持了一个微任务队列，为了让高优先及任务及时执行。也即是每取出一个宏任务，执行完毕之后。检查当前宏任务是否有微任务可执行

### 24请写出弹出值，并解释为什么？
```js
alert(a);
a();
var a = 3;
function a() {
  alert(10);
}
alert(a);
a = 6;
a();
```

### 答案

```js
'function a(){ alert(10) }''
10
3
typeError: a is not a function
```

### 解析

**var、function 均有变量提升, 实际编译后为如下代码执行:**

```js
function a(){alert(10)}  // a: function...
var a;                   // a: undefined
alert(a);                // alert()弹出a代表function...
a();                     // function a执行： alert(10); 
a = 3;                   // a: 3
alert(a);       
a = 6;                   // a: 6
a();                     // typeError
```

所以输出结果如下：

- 第一步 alert输出的是function a的函数体
- 第二步 执行function a，弹出10
- 第三步 将a赋值为3，则弹出3
- 第四步 将a赋值为6，执行时则会报错，输出 `Uncaught TypeError: a is not a function`

> 注：
>
>如果存在函数声明和变量声明（注意：仅仅是声明，还没有被赋值），而且变量名跟函数名是相同的，那么，它们都会被提示到外部作用域的开头，但是，函数的优先级更高，所以变量的值会被函数覆盖掉。

在《你不知道的JavaScript》上册第一章讲到：

> 编译器会进行如下处理：
>
> 遇到`var a`，编译器会询问作用域是否已经有一个该名称的变量存在于同一个作用域的集合中。如果是，编译器会忽略该声明，继续进行编译；否则他会要求作用于在当前作用域的集合中声明一个新的变量，并命名为a。

### 25原生 JavaScript 实现图片懒加载的思路

### 实现方案

1. 在img元素时，自定义一个属性data-src，用于存放图片的地址；
2. 获取屏幕可视区域的尺寸；
3. 获取元素到窗口边缘的距离；
4. 判断元素时候在可视区域内，在则将data-src的值赋给src,否则，不执行其他操作；

**实质:** 当图片在可视区域内时，才加载，否则不加载；也可一个给个默认的图片占位

**用到的api:**

- `IntersectionObserver` 它提供了一种异步观察目标元素与顶级文档viewport的交集中的变化的方法
- `window.requestIdleCallback()` 方法将在浏览器的空闲时段内调用的函数排队。这使开发者能够在主事件循环上执行后台和低优先级工作，而不会影响延迟关键事件，如动画和输入响应。

**几个细节:**

- 提前加载，可以+100像素
- 滚动时只处理未加载的图片即可；
- 函数节流

**简单代码演示**

判断是否是在可视区域的三种方式

- 屏幕可视区域的高度 + 滚动条滚动距离 > 元素到文档顶部的距离，`document.documentElement.clientHeight + document.documentElement.scrollTop  >  element.offsetTop`
- 使用getBoundingClientRect()获取元素大小和位置；
- IntersectionObserver 自动观察元素是否在视口内

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="X-UA-Compatible" content="ie=edge" />
  <title>图片懒加载</title>
  <style>
    img {
      display: block;
      height: 450px;
      margin-bottom: 20px;
    }
  </style>
</head>

<body>
  <img data-src="./images/1.png" alt="" />
  <img data-src="./images/2.png" alt="" />
  <img data-src="./images/3.png" alt="" />
  <img data-src="./images/4.png" alt="" />
  <img data-src="./images/5.png" alt="" />
  <img data-src="./images/6.png" alt="" />
</body>
<script>
  var imgs = document.querySelectorAll("img");

  // 节流函数,定时器版本
  function throttle(func, wait) {
    let timer = null;
    return function (...args) {
      if (!timer) {
        func(...args);
        timer = setTimeout(() => {
          timer = null;
        }, wait);
      }
    };
  }

  //方法1： H + S > offsetTop
  function lazyLoad1(imgs) {
    //offsetTop是元素与offsetParent的距离，循环获取直到页面顶部
    function getTop(e) {
      var T = e.offsetTop;
      while ((e = e.offsetParent)) {
        T += e.offsetTop;
      }
      return T;
    }
    var H = document.documentElement.clientHeight; //获取可视区域高度
    var S = document.documentElement.scrollTop || document.body.scrollTop;
    Array.from(imgs).forEach(function (img) {
      // +100 提前100个像素就开始加载
      // 并且只处理没有src即没有加载过的图片
      if (H + S + 100 > getTop(img) && !img.src) {
        img.src = img.dataset.src;
      }
    });
  }
  const throttleLazyLoad1 = throttle(lazyLoad1, 200);

  // 方法2：el.getBoundingClientRect().top <= window.innerHeight
  function lazyLoad2(imgs) {
    function isIn(el) {
      var bound = el.getBoundingClientRect();
      var clientHeight = window.innerHeight;
      return bound.top <= clientHeight + 100;
    }
    Array.from(imgs).forEach(function (img) {
      if (isIn(img) && !img.src) {
        img.src = img.dataset.src;
      }
    });
  }
  const throttleLazyLoad2 = throttle(lazyLoad2, 200);

  // 滚轮事件监听
  // window.onload = window.onscroll = function () {
  //   throttleLazyLoad1(imgs);
  //   // throttleLazyLoad2(imgs);
  // };

  // 方法3：IntersectionObserver
  function lazyLoad3(imgs) {
    const io = new IntersectionObserver((ioes) => {
      ioes.forEach((ioe) => {
        const img = ioe.target;
        const intersectionRatio = ioe.intersectionRatio;
        if (intersectionRatio > 0 && intersectionRatio <= 1) {
          if (!img.src) {
            img.src = img.dataset.src;
          }
        }
        img.onload = img.onerror = () => io.unobserve(img);
      });
    });
    imgs.forEach((img) => io.observe(img));
  }
  lazyLoad3(imgs);
</script>

</html>
```

### 26实现Function 原型的bind方法，使得以下程序最后能输出“success”
```js
function Animal(name,color){
  this.name = name;
  this.color = color;
}
Animal.prototype.say = function(){
  return `I'm a ${this.color}${this.name}`;
}
const cat = Animal.bind(null,'cat');
const cat = new Cat('white');
if(cat.say() === "I'm white cat" && cat instanceof Cat && cat instanceof Animal){
  console.log('sunccess');
}
```

### 代码实现

```js
function Animal(name, color) {
  this.name = name
  this.color = color
}
Animal.prototype.say = function () {
  return `I'm a ${this.color}${this.name}`
}
Function.prototype.bind = function (_this, arg) {
  const name = arg
  const callFn = this

  function fn(color) {
    callFn.call(this, name, color)
  }
  fn.prototype = Object.create(callFn.prototype)
  // 寄生组合式继承
  fn.prototype.say = function () {
    return `I'm ${this.color} ${this.name}`
  }
  return fn
}
const Cat = Animal.bind(null, 'cat')
const cat = new Cat('white')
if (
  cat.say() === "I'm white cat" &&
  cat instanceof Cat &&
  cat instanceof Animal
) {
  console.log('sunccess')
}
```

### 27使用 JavaScript 实现 cookie 的设置、读取、删除

### 代码实现

```js
// 设置cookie
function setCookie(name,value){
    var Days = 30;
    var exp = new Date();
    exp.setTime(exp.getTime() + Days*24*60*60*1000);
    document.cookie = name + “=”+ escape (value) + “;expires=” + exp.toGMTString();
}

// 读取cookie
function getCookie(name){
    var arr,reg=new RegExp(“(^| )”+name+”=([^;]*)(;|$)”);
    if(arr=document.cookie.match(reg))
    return unescape(arr[2]);
    else
    return null;
}

// 删除cookie
function delCookie(name) {
    var exp = new Date();
    exp.setTime(exp.getTime() – 1);
    var cval=getCookie(name);
    if(cval!=null){
        document.cookie= name + “=”+cval+”;expires=”+exp.toGMTString();
    }
}
```

### 28填充代码实现 template 方法
```js
var str = "您好，<%=name%>。欢迎来到<%=location%>";
function template(str) {
  // your code
}
var compiled = template(srt);
// compiled的输出值为：“您好，张三。欢迎来到网易游戏”
compiled({ name: "张三", location: "网易游戏" });
```

### 代码实现

- 正则匹配然后进行替换

```js
var str = "您好，<%=name%>。欢迎来到<%=location%>";

function template(str) {
    return data => str.replace(/<%=(\w+)%>/g, (match, p) => data[p] || '')
}
var compiled = template(str);
// compiled的输出值为：“您好，张三。欢迎来到网易游戏” 
compiled({
    name: "张三",
    location: "网易游戏"
});
```


### 29给 JavaScript 的 String 原生对象添加一个名为 trim 的原型方法，用于截取字符串前后的空白字符

### 代码实现

- 正则

```js
String.prototype.trim = function(){
    return this.replace(/^\s*|\s*$/g,'');
} 
console.log('  yd  yd    '.trim())
```


### 30实现格式化输出，比如输入 999999999，输出 999,999,999

### 代码实现

#### 1.普通版

- 优点：比for循环，if-else判断的逻辑清晰直白一些
- 缺点：太普通

```js
function formatNumber(num){
  let arr = [],
      str = num + '';
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
console.log(formatNumber(1234567890));
```

#### 2.进阶版

- 优点：JS的API玩的了如之掌
- 缺点：可能没那么好懂，但是读懂之后就会发出怎么没想到的感觉

```js
function formatNumber(num){
  //str.split('').reverse() => ["0", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
  return num.toString().split('').reverse().reduce((prev,next,index) => {
    return ((index % 3) ? next : (next + ',')) + prev
  })
}
console.log(formatNumber(1234567890));
```

#### 3.正则版

- 优点：代码少，浓缩的都是精华
- 缺点：需要对正则表达式的位置匹配有一个较深的认识，门槛大一点


```js
function formatNumber(num) {
  /*
  	①/\B(?=(\d{3})+(?!\d))/g：正则匹配非单词边界\B，即除了1之前的位置，其他字符之间的边界，后面必须跟着3N个数字直到字符串末尾
	②(\d{3})+：必须是1个或多个的3个连续数字;
	③(?!\d)：第2步中的3个数字不允许后面跟着数字;
  */
  return (num+'').replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}
console.log(formatNumber(1234567890)) // 1,234,567,890
```

#### 4.Api版

- 优点：简单粗暴，直接调用 API
- 缺点：Intl兼容性不太好，不过 toLocaleString的话 IE6 都支持

**1）toLocaleString**

方法返回这个数字在特定语言环境下的表示字符串，具体可看MDN描述

```js
function formatNumber(num){
  return num.toLocaleString('en-US');
}
console.log(formatNumber(1234567890));
```

**2）IntL对象**

 Intl 对象是 ECMAScript 国际化 API 的一个命名空间，它提供了精确的字符串对比，数字格式化，日期和时间格式化。Collator，NumberFormat 和 DateTimeFormat 对象的构造函数是 Intl 对象的属性。

```js
function formatNumber(num){
  return new Intl.NumberFormat().format(num);
}
console.log(formatNumber(1234567890));
```


### 31完成一个表达式，验证用户输入是否是电子邮箱

### 代码实现

#### 1.常规方案

**1）规则定义**

- 以大写字母 `[A-Z]`、小写字母 `[a-z]` 、数字 `[0-9]`、下滑线 `[_]`、减号 `[-]`及点号 `[.]` 开头，并需要重复一次至多次`[+]`。
- 中间必须包括 `@` 符号。
- `@` 之后需要连接大写字母 `[A-Z]`、小写字母 `[a-z]`、数字`[0-9]`、下滑线`[_]`、减号`[-]`及点号`[.]`，并需要重复一次至多次`[+]`。
- 结尾必须是点号`[.]`连接2至4位的大小写字母`[A-Za-z]{2,4}`。

**2）代码**

```js
var pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;

pattern.test('cn42du@163.com')  //true;
pattern.test('ifat3@sina.com.cn') // true;
pattern.test('ifat3.it@163.com') // true;
pattern.test('ifat3_-.@42du.cn') // true;
pattern.test('ifat3@42du.online') // false;
pattern.test('邮箱@42du.cn') // false;

```

**3）说明**

这是最常用的邮件正则表达式验证方案，也适合大多数的应用场景。从以上测试可以看出，该表达式不支持.online及.store结尾的域名。如需兼容这类域名（大于4位），调整正则结尾｛2,4｝的限制部分即可（例：{2,8}）。另一个问题是邮件用户名不能包括中文。

**4）添加规则**

- 用户名可以包括中文[\u4e00-\u9fa5]
- 域名结尾最长可为8位{2,8}

```js
var pattern = /^([A-Za-z0-9_\-\.\u4e00-\u9fa5])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,8})$/;

pattern.test('cn42du@163.com')  //true;
pattern.test('ifat3@sina.com.cn') // true;
pattern.test('ifat3.it@163.com') // true;
pattern.test('ifat3_-.@42du.cn') // true;
pattern.test('ifat3@42du.online') // true;
pattern.test('邮箱@42du.cn') // true;
```

#### 2.安全方案

在手机验证码出现之前，差不多邮箱验证是保证用户唯一性的唯一条件。而临时邮箱（也称10分钟邮箱或一次性邮箱）的出现，则使得邮箱验证及帐户激活这种机制失去了意义。而临时邮箱的地址是不可枚举的，我们只能才采取白名单的方式，只允许有限的邮箱域名通过验证。

**1）继续添加规则**

- 邮箱域名只能是163.com，qq.com或者42du.cn。

```js
var pattern = /^([A-Za-z0-9_\-\.])+\@(163.com|qq.com|42du.cn)$/;
```

**2）说明**

这种方式虽然能保证安全性，但是如果白名单太长会造成模式字符串太长。这时可以将邮箱域名白名单写成数组，利用正则表达式做初步验证，用白名单做域名的二次验证。

**3）代码改善**

```js
var isEmail = function (val) {
    var pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    var domains= ["qq.com","163.com","vip.163.com","263.net","yeah.net","sohu.com","sina.cn","sina.com","eyou.com","gmail.com","hotmail.com","42du.cn"];
    if(pattern.test(val)) {
        var domain = val.substring(val.indexOf("@")+1);
        for(var i = 0; i< domains.length; i++) {
            if(domain == domains[i]) {
                return true;
            }
        }
    }
    return false;
}
// 输出 true
isEmail("cn42du@163.com");
```



### 32有这样一个函数 A,要求在不改变原有函数 A 功能以及调用方式的情况下，使得每次调用该函数都能在控制台打印出“HelloWorld”
```js
function A() {
  console.log("调用了函数A");
}
```

### 代码实现

#### 1.实现方式一

- 装饰器写法

```js
const myDecorator = (fn, execute, obj=window) => {
        let old = obj[fn]
         obj[fn] = function() {
            return execute(old.bind(obj))
        }
  }
 
  function A() {
         console.log('调用函数A')
  }
         
  myDecorator('A', (fn) => {
         fn()
         console.log('hello world')
  })
  A();
```

#### 2.实现方式二

- 添加原型方法

```js
Function.prototype.before = function (beforeFN) {
    var _self = this;
    return function () {
        beforeFN.apply(_self, arguments)
        return _self.apply(this, arguments)
    }
}

Function.prototype.after = function (afterFN) {
    var _self = this;
    return function () {
        var fn = _self.apply(this, arguments);
        afterFN.apply(_self, arguments)
        return fn
    }
}

var A = function () {
    console.warn("调用了函数A")
}

A = A.before(function () {
    console.warn("前置钩子 HelloWorld")
}).after(function () {
    console.warn("后置钩子 HelloWorld")
})

A()
```

#### 3.实现方式三

- 粗暴直接

```js
function A() {
    console.log('调用了函数A');
}
const nativeA = A;
A = function () {
    console.log('HelloWorld');
    nativeA();
}
A()
```



### 33尾递归实现

### 什么是尾递归

尾调用是函数式编程中一个很重要的概念，当一个函数执行时的最后一个步骤是返回另一个函数的调用，这就叫做尾调用。当一个函数尾调用自身，就叫做尾递归。

**尾调用优化**：函数在调用的时候会在调用栈（call stack）中存有记录，每一条记录叫做一个调用帧（call frame），每调用一个函数，就向栈中push一条记录，函数执行结束后依次向外弹出，直到清空调用栈。

> 尾调用优化只在严格模式下有效。

### 尾递归应用

尾递归的实现，往往需要改写递归函数，确保最后一步只调用自身。

#### 1.阶乘函数

```js
'use strict';
function factorial(n, total = 1) {
  if (n === 1) return total;
  return factorial(n - 1, n * total);
}

factorial(5, 1);                // 120
factorial(10, 1);               // 3628800
factorial(500000, 1);           // 分情况
```

> 注意，虽然说这里启用了严格模式，但是经测试，在Chrome和Firefox下，还是会报栈溢出错误，并没有进行尾调用优化
> 
> Safari浏览器进行了尾调用优化，factorial(500000, 1)结果为Infinity，因为结果超出了JS可表示的数字范围
> 
> 如果在node v6版本下执行，需要加--harmony_tailcalls参数，node --harmony_tailcalls test.js
> 
> node最新版本已经移除了--harmony_tailcalls功能

#### 2.斐波那契数列

```js
/**
 *  @params {n : 序列号, pre: 上次序列和, current:本次序列和}
 */
const Fibonacci = (n, pre = 1, current = 1) => {
    if (n <= 1) return current;
    return Fibonacci(n - 1, pre, pre + current);
}
```





### 34请用 JavaScript 代码实现事件代理

### 一、概念理解

#### 1.什么是事件代理

事件委托或事件代理：根据《js高级程序设计》一书（前端红宝书）来说就是利用事件冒泡，只指定一个事件处理程序，就可以管理某一类型的所有时间。举一个栗子：dom需要事件处理程序，我们都会直接给它设置事件处理程序。but，如果有在ul中全部100个li需要添加事件处理程序，其具有相同的点击事件，那么可以根据for来进行遍历，也可以根据上层的ul来进行添加。在性能的角度来看，把ul建立事件会减少dom的交互次数，提高性能。

#### 2.事件代理原理

事件委托是利用事件的冒泡原理来实现的，就是事件从最深的节点开始，然后逐步向上传播事件。

举个例子：页面上有这么一个节点树，div>ul>li>a;比如给最里面的a加一个click点击事件，那么这个事件就会一层一层的往外执行，执行顺序a>li>ul>div，有这样一个机制，那么我们给最外面的div加点击事件，那么里面的ul，li，a做点击事件的时候，都会冒泡到最外层的div上，所以都会触发，这就是事件委托，委托它们父级代为执行事件。


### 二、代码实现

#### 1.比如实现ul中li的事件代理

```js
window.onload = function () {
    var oBtn = document.getElementById("btn");
    var oUl = document.getElementById("ul1");
    var aLi = oUl.getElementsByTagName('li');
    var num = 4;
    //事件委托，添加的子元素也有事件 
    oUl.onmouseover = function (ev) {
      var ev = ev || window.event;
      var target = ev.target || ev.srcElement;
      if (target.nodeName.toLowerCase() == 'li') {
        target.style.background = "red";
      }
    };
    oUl.onmouseout = function (ev) {
      var ev = ev || window.event;
      var target = ev.target || ev.srcElement;
      if (target.nodeName.toLowerCase() == 'li') {
        target.style.background = "#fff";
      }
    };
    //添加新节点 
    oBtn.onclick = function () {
      num++;
      var oLi = document.createElement('li');
      oLi.innerHTML = 111 * num;
      oUl.appendChild(oLi);
    };
}
}
```


#### 2.简单封装一个事件代理通用代码

```js
!function (root, doc) {
  class Delegator {
    constructor (selector) {
      this.root = document.querySelector(selector);//父级dom
      this.delegatorEvents = {};//代理元素及事件
      //代理逻辑
      this.delegator = e => {        
        let currentNode = e.target;//目标节点
        const targetEventList = this.delegatorEvents[e.type];
        //如果当前目标节点等于事件当前所在的节点，不再向上冒泡
        while (currentNode !== e.currentTarget) {
          targetEventList.forEach(target => {
            if (currentNode.matches(target.matcher)) {
              //开始委托并把当前目标节点的event对象传过去
              target.callback.call(currentNode, e);
            }
          })
          currentNode = currentNode.parentNode;
        }
      }
    }
    /*
     *绑定事件
     *@param event 绑定事件类型
     *@param selector 需要被代理的选择器
     *@param fn 触发函数
     * */
    on (event, selector, fn) {
     //相同事件只添加一次，如果存在，则再对应的代理事件里添加
      if (!this.delegatorEvents[event]) {
        this.delegatorEvents[event] = [{
          matcher: selector,
          callback: fn
        }]
        this.root.addEventListener(event, this.delegator);
      }else{
        this.delegatorEvents[event].push({
          matcher: selector,
          callback: fn
        })
      }
      return this;
    }
    /*
     *移除事件
     */
    destroy () {
      Object.keys(this.delegatorEvents).forEach(eventName => {
        this.root.removeEventListener(eventName, this.delegator)
      });
    }
  }

  root.Delegator = Delegator
}(window, document)
```

### 35多个 tab 只对应一个内容框，点击每个 tab 都会请求接口并渲染到内容框，怎么确保频繁点击 tab 但能够确保数据正常显示？

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


let flag = false             // 标志位，表示当前是否正在请求数据
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


### 36商城的列表页跳转到商品的详情页，详情页数据接口很慢，前端可以怎么优化用户体验？

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


### 37如何记录前端再用户浏览器上发生的错误并汇报给服务器？

### 一、代码执行的错误捕获

**1.try……catch**

使用try... catch 包裹，影响代码可读性。无法处理异步中的错误无法处理语法错误

**2.window.onerrorwindow.onerror**

比`try catch`要强那么一丢丢。无论是异步还是非异步错误，onerror 都能捕获到运行时错误

**缺点:** 监听不到资源加载的报错onerror,事件处理函数只能声明一次，不会重复执行多个回调：

**3.window.addEventListener('error')**

可以监听到资源加载报错，也可以注册多个事件处理函数。

**4.window.addEventListener('unhandledrejection')**

捕获Promise错误

### 二、资源加载的错误捕获

1. `imgObj.onerror()`
2. `performance.getEntries()`，获取到成功加载的资源，对比可以间接的捕获错误
3. `window.addEventListener('error', fn, true)`, 会捕获但是不冒泡，所以window.onerror 不会触发，捕获阶段可以触发

### 三、错误上报

一般使用image来上报，大厂都是采用利用image对象的方式上报错误的；

使用图片发送get请求，上报信息，由于浏览器对图片有缓存，同样的请求，图片只会发送一次，避免重复上报。

### 四、借助第三方库

- sentry-javascript




### 38单点登录实现原理

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

单点登录之间的系统域名不一样，例如第三方系统。由于域名不一样不能共享Cookie了，需要的一个独立的授权系统，即一个独立的认证中心(passport),子系统的登录均可以通过passport，子系统本身将不参与登录操作，当一个系统登录成功后，passprot将会颁发一个令牌给子系统，子系统可以拿着令牌去获取格子的保护资源，为了减少频繁认证，各个子系统在被passport授权以后，会建立一个局部会话，在一定时间内无需再次向passport发起认证

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

### 39请描述下为什么页面需要做优化？并写出常用的页面优化实现方案？

### 一、为什么需要做优化

页面性能的问题对用户体验的影响非常大，加载时间每多 1 秒，你就会流失 7%的用户，在正常页面的情况下，若页面加载时间超过 8 秒时间，那么你可能会损失 85%以上的用户。

为了更好的用户体验更好的业务支持更好的代码质量我们需要对页面进行优化

### 二、实现方案

页面进行优化，其实有两种优化方式

#### 1.软件优化

- **html** 优化 布局优化，减少空格，不用 table 布局，尽量不用 iframe 标签
- **css 优化** 可以用 css 实现的尽量不用 js 实现；css 代码压缩；css 合并；用字体图标代替图片； 开启 css 硬件加速：transform 动画由 GPU 控制，支持硬件加速，并不需要软件方面的渲染，使用 top 和 left 实现动画时浏览器发生的 repaint
- **js 优化** 图片优化(预加载/懒加载/延时加载)；视频或音频不加载，当点击之后开始单独加载视频或音频； 在 js 中尽量减少闭包的使用（原因：闭包会产生不释放的栈内存） DOM 的操作 其实 css 压缩与 js 的压缩和混乱比 html 压缩收益要大得多，同时 css 代码和 js 代码比 html 代码多得多，通过 css 压缩和 js 压缩带来流量的减少，会非常明显。
- **http 优化** 尽量减少需要发送的 http 请求；
- **缓存方面** 使用浏览器的缓存机制，不需要每次登录或者怎么样都需要再去访问服务器；利用浏览器和服务器端的缓存技术（304 缓存），把一些不经常更新的静态资源文件做缓存处理

#### 2.硬件优化

- 设置负载均衡服务器 通过负载均衡服务器使得后台数据压力平衡；
- 增加带宽 但是硬件的成本远远高于软件优化。






### 40请描述下 JavaScript 中 Scope、Closure、Prototype 概念，并说明 JavaScript 封装、继承实现原理。

### 一、Scope

#### 1.Lexical scope 词法作用域

作用域是什么呢？它指的是你的变量和函数运行到某个地方的代码处能否被访问到。

为什么需要作用域呢？为什么要限制变量的访问性而非全部暴露到公共域下呢？

这是计算机科学中最基本的概念和理念：隔离性（The Principle of Least Access）。为了职责明确，你只能刚好访问到你需要的所有东西，不多也不少。附带地，它带来了模块化、命名空间等好处，让你写出更易阅读、更易维护的代码。可以说，作用域是许多现代编程语言都从语言层面支持的一个特性。

而词法作用域，指的是一个变量，你可以通过变量名引用之，而不发生引用错误。

它本质上是 静态作用域 static scopes 。

#### 2.有什么类型的作用域

**1）全局作用域**

不定义在任何函数以内的变量或函数都位于全局作用域下。当然，这个全局作用域其实也是有边界/上下文的，比如 NodeJS 中不同文件之间的全局变量不能互相访问，因为每个全局对象 global 的上下文仅限于一个文件；比如浏览器中 不同 tab 之间的全局变量也是不能互相访问的，因为每个标签的全局对象 window 的上下文也仅限于一个 tab 中

**2）函数作用域**

任何定义在函数内的变量或函数都处于函数作用域下，这些变量无法在函数以外被引用到

**3）块作用域**

ES6之前是没有这个东西的，也就是说，定义在 { } 大括号对 及 for (i = 0; i < 10; i++) { ... } 循环结构中的变量统统都会跑到全局作用域下去。这就很违反直觉了。ES6 通过 let 和 const 关键字修复了这个问题，并且赋予了一般的块 block 以块作用域

------

在函数或块作用域中声明的变量或函数若发生嵌套，则又有了嵌套下的词法作用域规则。相对地，位于一个函数/块内部的变量或函数称位于内层作用域 inner scope；前者相对地称其位于外层的作用域 outer scope。

内外之间的变量访问性规则为：

**3）外层作用域**

全局作用域是最外层的作用域。

外层作用域下的变量及函数可以在内层作用域中被访问获取

**4）内层作用域**

可以访问到外层作用域的变量，可以访问自身的变量，但不能被外层作用域引用

#### 3.作用域什么时候生成

**1）全局作用域**

没声明就使用的代码，默认全跑到全局作用域中。可以使用 use strict 模式禁止

**2）函数作用域**

函数声明开始时 function() { ... }，自动生成一个词法作用域

**3）块作用域**

ES6 前，{ } 大括号对 及 for (i = 0; i < 10; i++) { ... } 循环结构 均不生成词法作用域。也就是说，块里面声明的变量全部都会跑到当前的全局作用域里去。这是前 JS 时代的一个坑。ES6 以后 let 和 const 关键字都修复了这个问题，它们会生成一个块作用域，或可称为 condition/loop lexical scope

因此 ES6 时代后，可以这样理解：除了函数作用域和块作用域，其他的全是全局作用域。

作用域对于编程模型的重要意义之一，即是其体现的模块概念。你只需要关注模块内与自己相关的变量和代码，而不需考虑代码库中其他任何代码。这样你可以专注在当前代码片段上，减少编写时大脑的思考负担，也减少了维护阅读时的理解负担。这样的编程模型很符合单一职责原则（SRP），大大提高了工作效率 。

### 二、Closure

#### 1.什么是闭包

一个函数返回一个函数的引用，就形成了一个闭包。

**闭包:** 当函数能记住并访问所在词法作用域，即使函数在词法作用域范围之外，此时就产生了闭包。

从实现上讲，闭包是一条记录，它存储了一个函数与其环境的上下文信息。这个上下文主要记录了：函数的每个自由变量（在内层函数使用，但在外层函数处被定义的变量）与其被绑定的值或引用之间的关联,主要是用来实现信息封装。

#### 2.闭包的作用

闭包最实用的例子就是使局部作用域外能调用局部作用域内的变量。

```js
var closure = function () {
    var innerVar = 'inner'
    return function () {
        console.log(innerVar)
    }
}

var getInner = closure()
getInner() // 就去到了局部作用域内的变量声明 inner
```

当然这只是闭包的一种场景，并不是说一个函数返回一个函数才是闭包，换而言之，简单地使词法作用域的外层可以访问其中的变量，这便创建了一个闭包。

### 三、Prototype

原型:每一个函数内部都具有一个prototype属性。构造函数创造的实例对象实例内部有一个内部属性[[prototype]],作为一个指针，指向构造函数原型所指的对象.所有的实例共享原型对象上的属性和方法 

原型是js中非常重要的概念，换句话说， 原型是js语言的一个特征。js中任何对象都有原型，函数对象有原型（只不过函数不充当构造函数时，原型不起作用），普通的js`object`也有原型，原型是一个`object`，它也有原型，这就构成了一个**原型链**，直到`Object.prototype`。`Object.prototype`的原型是`null`。

读取对象的某个属性时，`JavaScript` 引擎先寻找对象本身的属性，如果找不到，就到它的原型去找，如果还是找不到，就到原型的原型去找。如果直到最顶层的`Object.prototype`还是找不到，则返回`undefined`。如果对象自身和它的原型，都定义了一个同名属性，那么优先读取对象自身的属性，这叫做“覆盖”。

### 四、封装

封装，也就是把客观事物封装成抽象的类，并且类可以把自己的数据和方法只让可信的类或者对象操作，对不可信的进行信息隐藏。封装是面向对象的特征之一，是对象和类概念的主要特性。 

通俗的讲就是，将用户不需要知道的数据和方法隐藏起来，外部无法直接访问。在Java中，可以用private， protected关键字进行修饰。在JS中可以用**闭包**实现。

```js
var person = {
  fullName : "coolb",
};
 
alert(person.fullName); // coolb
person.fullName = "jay";
alert(person.fullName); // jay
```

这里person对象的fullName属性是暴露给用户的，你无法保证用户总是赋合法的名字。为了解决这一问题，我们可以用闭包。

```js
var person = function () {
 
  var fullName = "coolb";
  var reg = new RegExp(/\d+/);
 
  return { 
    setFullName : function (newValue) {
      if(reg.test(newValue)) {
        console.log("Invalid Name");
      }
      else {
        fullName = newValue;
      }
    },
    getFullName : function () {
     return fullName; 
    }
  }
} 
 
var p = person();
console.log(p.getFullName());   // coolb
p.setFullName('jay');
console.log(p.getFullName());  // jay
p.setFullName(42); // Invalid Name
p.fullName = 42;     // 这种方式并不影响内部fullName的值
console.log(p.getFullName());  // jay
```


简单的说，一个类就是一个封装了数据以及操作这些数据的代码的逻辑实体。在一个对象内部，某些代码或某些数据可以是私有的，不能被外界访问。通过这种方式，对象对内部数据提供了不同级别的保护，以防止程序中无关的部分意外的改变或错误的使用了对象的私有部分。

**1）创建一个类**

在ES6之前创建一个类：首先声明一个函数保存在一个对象里，然后按照编程习惯这个代表类的变量名首字母大写，然后再这个函数的内部通过this（函数内部自带的一个变量，用于指向当前这个对象）变量，添加属性或者方法来实现对类属性或方法的添加给类添加属性的时候有两种方法，一种是直接用this指向进行属性的赋值，一种是通过prototype属性进行赋值，使用this进行属性添加的时候所有的实例化对象都会创建并且具有这个属性的实际内容但是使用prototype属性进行属性添加，其实所有的实例化对象本身是不包含该属性的，只是将该属性添加到该对象的原型属性上，但是由于js的原型链的原理，所有的原型对象也可以调用和使用该属性

**2）属性与方法的封装**

- 私有属性：对象的属性不能被访问者看到；只能在函数内部使用。好处就是安全，就类似闭包中的函数一样，减少污染
- 公有属性（共有属性）：当我们定义一个对象后，使用对象的人在实例化之后可以访问到对象内部的属性；
- 私有方法：对象的方法不能被访问者看到；只能在函数内部使用。好处就是安全，就类似闭包中的函数一样，减少污染
- 构造方法： 通过方法修改实例中属性或者私有属性的方法
- 实现方法： 由于Js中定义的变量都只会存在最近的函数作用域或者最近的全局作用域，所以可以通过函数包裹作用域，实现方法和属性的私有化

### 五、继承

#### 1.继承是什么

顾名思义，一个对象上想拥有被继承对象的方法属性，继承过来就好了

在`OOP`中，通过类的继承来实现代码的复用，通过实例化一个类可以创建许多对象，在JS中继承是通过原型实现的。

```js
let user = function(name) {
    this.name = name;
    this.getName = function () {
        console.log(this.name);
    }
};
 
//为了避免下面比较name时，对值进行比较，这里故意传入了String对象
let user1 = new user(new String('KK'));
let user2 = new user(new String('KK'));
 
console.log(user1.name === user2.name);    //输出false
console.log(user1.getName === user2.getName); //输出false
```

在上述代码中，我们通过构造函数user，创建了两个对象。实际上是通过复制 构造函数user的原型对象 来创建user1和user2。原型对象中有个constructor指向了user函数，实际上还是通过这个构造函数来创建的对象。

假如不用原型（更准确地说原型对象中没有用户定义的属性），那么这两个对象就无法共享任何属性，对于这个例子来说，getName的逻辑是一样的，不需要两份getName，所有的user对象其实可以共享这个getName方法。这个逻辑非常像java类中的静态函数，只不过静态函数只能够调用静态变量和静态方法。但是在JS的世界里，可以通过将getName定义在原型中，已达到所有对象共享这个函数。

```js
let user = function(name) {
    this.name = name;
};
 
user.prototype.getName = function () {
    console.log(this.name);
}
 
user.prototype.color = new String('White');
 
let user1 = new user(new String('KK'));
let user2 = new user(new String('KK'));
 
console.log(user1.name === user2.name);  //输出false
console.log(user1.getName === user2.getName); //输出true
console.log(user1.color === user2.color); //输出true
```

这里就一目了然了。在原型对象中定义的变量和方法能够被所有多个对象共享。原型的属性被对象共享，但是它不属于对象本身。

```js
user1.hasOwnProperty('name');  //true;
user1.hasOwnProperty('getName');  //false;
```

这里要注意：原型对象的属性不是实例对象自身的属性。只要修改原型对象，变动就立刻会体现在**所有**实例对象上。反之，如果对象的属性被修改，原型的对象中相同的属性并不会修改。

#### 2.继承的实现原理

从构造函数实例化说起，当你再调用`new`的时候，js实际上执行的是

```js
var o = new Object();
o.__proto__ = Foo.prototype;
Foo.call(o);
```

然后，当你执行

```js
o.someProp
```

它检查 o 是否具有 `someProp` 属性。如果没有，它会查找`Object.getPrototypeOf(o).someProp`，如果仍旧没有，它会继续查找 `Object.getPrototypeOf(Object.getPrototypeOf(o)).someProp`。

**实现一个继承：B继承自A**

```js
function A(a){
  this.varA = a;
}

// 以上函数 A 的定义中，既然 A.prototype.varA 总是会被 this.varA 遮蔽，
// 那么将 varA 加入到原型（prototype）中的目的是什么？
A.prototype = {
  varA : null,
/*
既然它没有任何作用，干嘛不将 varA 从原型（prototype）去掉 ? 
也许作为一种在隐藏类中优化分配空间的考虑 
如果varA并不是在每个实例中都被初始化，那这样做将是有效果的。
*/
  doSomething : function(){
    // ...
  }
}

function B(a, b){
  A.call(this, a);
  this.varB = b;
}
B.prototype = Object.create(A.prototype, {
  varB : {
    value: null, 
    enumerable: true, 
    configurable: true, 
    writable: true 
  },
  doSomething : { 
    value: function(){ // override
      A.prototype.doSomething.apply(this, arguments); 
      // call super
      // ...
    },
    enumerable: true,
    configurable: true, 
    writable: true
  }
});
B.prototype.constructor = B;

var b = new B();
b.doSomething();
```

**最重要的部分**

- 类型被定义在 `.prototype` 中
- 用 `Object.create()` 来继承


`Object.create()`的实现原理或者说是对`ES5`之前版本的polyfill

```js
if (typeof Object.create !== "function") {
    Object.create = function (proto, propertiesObject) {
        if (typeof proto !== 'object' && typeof proto !== 'function') {
            throw new TypeError('Object prototype may only be an Object: ' + proto);
        } else if (proto === null) {
            throw new Error("This browser's implementation of Object.create is a shim and doesn't support 'null' as the first argument.");
        }

        if (typeof propertiesObject != 'undefined') throw new Error("This browser's implementation of Object.create is a shim and doesn't support a second argument.");

        function F() {}
        F.prototype = proto;

        return new F();
    };
}
```

#### 3.继承的方式

**1）类继承**

```js
function SuperClass(){
    this.SuperObj = {}
}
SuperClass.prototype.SuperMethod = function(){}

function SubClass(){
    
}
SubClass.prototype.SubMethod = function(){
    
}
SubClass.prototype = new SuperClass()
//将子类的prototype属性设置为父类的实例

//实例化方法
var Sub = new SubClass()
```

**2）构造函数继承**

call方法可以改变函数的执行上下文，因此在子类中调用父类的构造函数，就相当于以子类的this调用了父类的构造函数，但是最后会返回到子类的创建的对象中，实现了子类调用父类构造函数的操作，叫做**构造函数继承**

```js
function SuperClass(){
    this.SuperObj = {}
}
SuperClass.prototype.SuperMethod = function(){}          

function SubClass(opt){
    SuperClass.call(this,opt)
    //继承父类
}          

//实例化方法
var Sub = new SubClass()
```

**3）组合继承**

既不会实例属性影响类属性的引用特性，同时在子类构造函数中执行父类的构造函数能都传递参数，看起来两全其美近乎完美

```js
function SuperClass(){
      this.SuperObj = {}
  }
  SuperClass.prototype.SuperMethod = function(){}
  
  function SubClass(opt){
    SuperClass.call(this,opt)
    //继承父类
  }
  
  SubClass.prototype = new SuperClass()
  //在构造函数继承中再次把原型属性赋值到子类的原型属性上
  
  //实例化方法
  var Sub = new SubClass()
```

**4）原型式继承**

```js
function inheritObject(o){
    function F(){}
    F.prototype = o
    return new F()
}

//测试用例

var book = {
    name:'js book',
    alikeBook:["css","htmlbook"]
}
var newBook = inheritObject(book)
//实现继承

newBook.name = 'new book'
//修改子类属性
```

**5）寄生组合式继承**

原理：直接将父类的原型复制到子类，但是同时将父类的原型中的构造函数改成子类的构造函数，变为一个子类的对象实现继承，一般和其他的构造函数式继承混合使用

```js
function inheritObject(o){
    function F(){}
    F.prototype = o
    return new F()
}
function inheritPrototype(subClass,superClass){
    var p = inheritObject(superClass.prototype)
    //复制一份原型副本保存在变量中
    p.constructor = subClass
    //修正因为重写子类原型导致子类的construtor属性被修改
    subClass.prototype = p;
}
```

### 六、总结

`Javascript`中的这些概念，`scope`、`closure`、`prototype`等对于语言的特征来说是基建，他们息息相关，没有哪个更重要，都是非常重要的概念，只有这些基础的东西搞明白了之后，才能去读懂一些框架的源码，甚至去开发一套框架开发一些牛x的开源库。

### 41以最小的改动解决以下代码的错误(可以使用ES6)
```js
const obj = {
  name:"jsCoder",
  skill:["es6","react","angular"],
  say:function(){
    for(var i = 0,len = this.skill.length;i<len;i++){
      setTimeout(function(){
        console.log('No.' + i + this.name);
        console.log(this.skill[i]);
        console.log('----------------');
      },0);
      console.log(i);
    }
  }
}
obj.say();

/* 
  期望得到下面的结果
  1
  2
  3
  No.1 jsCoder
  es6
  ----------------
  No.2 jsCoder
  react
  ----------------
  No.3 jsCoder
  angular
*/
```

 ### 代码实现

- 使用let、箭头函数、序号+1

```js
const obj = {
    name:"jsCoder",
    skill:["es6","react","angular"],
    say:function(){
    for(let i = 0,len = this.skill.length;i<len;i++){
        setTimeout(()=>{
            console.log('No.' + (i+1) + this.name);
            console.log(this.skill[i]);
            console.log('----------------');
        },0);
        console.log(i+1);
    }
  }
}
obj.say();
```

### 42有哪几种方式可以解决跨域问题？(描述对应的原理)



### 43如何实现 a,b 两个变量的交换



### 44写出下面代码的输出结果
```js
//counter.js
let counter = 10;
export default counter;

//index.js
import myCounter from "./counter";
myCounter += 1;
console.log(myCounter);
```



### 45写出输出值，并解释为什么
```js
function test(m) {
  m = { v: 5 };
}
var m = { k: 30 };
test(m);
alert(m.v);
```



### 46请写出代码执⾏结果，并解释为什么
```js
function fn() {
  console.log(this.length);
}
var person = {
  length: 5,
  method: function (fn) {
    fn();
  },
};
person.method(fn, 1);
```



### 47函数中的arguments是数组吗？若不是，如何将它转化为真正的数组？



### 48请写出以下代码的打印结果
```js
if([] == false){console.log(1)};
if({} == false) {console.log(2)};
if([]){console.log(3)};
if([1] == [1]){console.log(4)};
```



### 49列举 3 种强制类型转换和 2 种隐式类型转换



### 50微任务和宏任务的区别


### 微任务和宏任务的区别


微任务和宏任务是异步任务的两个种类。

**宏任务:** 当前调用栈中执行的代码成为宏任务。（主代码快，定时器等等）。 

**微任务:** 当前（此次事件循环中）宏任务执行完，在下一个宏任务开始之前需要执行的任务,可以理解为回调事件。（promise.then，proness.nextTick等等）。

宏任务中的事件放在callback queue中，由事件触发线程维护；微任务的事件放在微任务队列中，由js引擎线程维护。

在挂起任务时，JS引擎会将所有任务按照类别分到这两个队伍中，首先在macrotask的队列中取出第一个任务，执行完毕后取出microtask队列中的所有任务顺序执行；之后再取macrotask任务，周而复始，直至两个队列的任务都取完

### 51有 1000 个 dom，需要更新其中的 100 个，如何操作才能减少 dom 的操作？


### 实现方案

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



### 52请编写一个 JavaScript 函数 parseQueryString,它的用途是把 URL 参数解析为一个对象，url="http://iauto360.cn/index.php?key0=0&key1=1&key2=2"


### 代码实现

```js
function parseQueryString(url){
  if(typeof url !== 'string') throw new Error('invalid url')
  const search = decodeURIComponent(url).split('?')[1];
  if(!search) return {};
  return search.split('&').reduce((pre, cur) => {
    const [key, value] = cur.split('=');
    pre[key] = value;
    return pre;
  }, {});
}
parseQueryString("http://iauto360.cn/index.php?key0=0&key1=1&key2=2")
```

### 53请列出至少 5 个 JavaScript 常用的内置对象，说明用途



#### JavaScript标砖内置对象

全局的对象（ global objects ）或称标准内置对象，不要和 "全局对象（global object）" 混淆。这里说的全局的对象是说在全局作用域里的对象。


### 一、常用的五种内置对象

#### 1.encodeURI()

函数通过将特定字符的每个实例替换为一个、两个、三或四转义序列来对统一资源标识符 (URI) 进行编码 (该字符的 UTF-8 编码仅为四转义序列)由两个 "代理" 字符组成)。

#### 2.eval()

函数会将传入的字符串当做 JavaScript 代码进行执行。

#### 3.isFinite()

函数用来判断被传入的参数值是否为一个有限数值（finite number）。在必要情况下，参数会首先转为一个数值。   

#### 4.isNaN()

函数用来确定一个值是否为 `NaN`，另外也可以使用 ECMAScript 2015 中定义的 `Number.isNaN()` 来判断。

> 注：`isNaN`函数内包含一些非常有趣的规则,详细看查看MDN

#### 5.parseInt(string, radix) 

将一个字符串 string 转换为 radix 进制的整数， radix 为介于2-36之间的数。


### 二、JavaScript标准内置对象

全局的对象（ global objects ）或称标准内置对象，不要和 "全局对象（global object）" 混淆。这里说的全局的对象是说在全局作用域里的对象。

标准的内置对象分类：

#### 1.值属性

这些全局属性返回一个简单值，这些值没有自己的属性和方法。

- Infinity
- NaN
- undefined
- globalThis

#### 2.函数属性

全局函数可以直接调用，不需要在调用时指定所属对象，执行结束后会将结果直接返回给调用者。

- eval()
- uneval()
- isFinite()
- isNaN()
- parseFloat()
- parseInt()
- decodeURI()
- decodeURIComponent()
- encodeURI()
- encodeURIComponent()

#### 3.基本对象

顾名思义，基本对象是定义或使用其他对象的基础。基本对象包括一般对象、函数对象和错误对象。

- Object
- Function
- Boolean
- Symbol

**错误对象:**

错误对象是一种特殊的基本对象。它们拥有基本的 Error 类型，同时也有多种具体的错误类型。

- Error
- AggregateError
- EvalError
- InternalError
- RangeError
- ReferenceError
- SyntaxError
- TypeError
- URIError

#### 4.数字和日期对象

用来表示数字、日期和执行数学计算的对象。

- Number
- BigInt
- Math
- Date

#### 5.字符串

用来表示和操作字符串的对象。

- String
- RegExp

#### 6.可索引的集合对象

这些对象表示按照索引值来排序的数据集合，包括数组和类型数组，以及类数组结构的对象。

- Array
- Int8Array
- Uint8Array
- Uint8ClampedArray
- Int16Array
- Uint16Array
- Int32Array
- Uint32Array
- Float32Array
- Float64Array
- BigInt64Array
- BigUint64Array

#### 7.使用键的集合对象

这些集合对象在存储数据时会使用到键，包括可迭代的Map 和 Set，支持按照插入顺序来迭代元素。

- Map
- Set
- WeakMap
- WeakSet

#### 8.结构化数据

这些对象用来表示和操作结构化的缓冲区数据，或使用 JSON （JavaScript Object Notation）编码的数据。

- ArrayBuffer
- SharedArrayBuffer
- Atomics
- DataView
- JSON

#### 9.控制抽象对象

控件抽象可以帮助构造代码，尤其是异步代码（例如，不使用深度嵌套的回调）。

- Promise
- Generator
- GeneratorFunction
- AsyncFunction

#### 10.反射

- Reflect
- Proxy

#### 11.国际化

ECMAScript核心的附加功能，用于支持多语言处理。

- Intl
- Intl.Collator
- Intl.DateTimeFormat
- Intl.ListFormat
- Intl.NumberFormat
- Intl.PluralRules
- Intl.RelativeTimeFormat
- Intl.Locale

#### 12.WebAssembly

- WebAssembly
- WebAssembly.Module
- WebAssembly.Instance
- WebAssembly.Memory
- WebAssembly.Table
- WebAssembly.CompileError
- WebAssembly.LinkError
- WebAssembly.RuntimeError

#### 13.其它

- arguments

### 54Promise 有没有解决异步的问题

Promise 对象是 JavaScript 的异步操作解决方案，为异步操作提供统一接口。它起到代理作用（proxy），充当异步操作与回调函数之间的中介，使得异步操作具备同步操作的接口。Promise 可以让异步操作写起来，就像在写同步操作的流程，而不必一层层地嵌套回调函数。

Promise解决了callback回调地狱的问题，async、await 是异步的终极解决方案。

来看一下JavaScript中异步方案

#### 1）回调函数（callback）

```js
setTimeout(() => {
    // callback 函数体
}, 1000)
```

**缺点：** 回调地狱，不能用 try catch 捕获错误，不能 return

回调地狱的根本问题在于：

- 缺乏顺序性： 回调地狱导致的调试困难，和大脑的思维方式不符
- 嵌套函数存在耦合性，一旦有所改动，就会牵一发而动全身，即（控制反转）
- 嵌套函数过多的多话，很难处理错误

```js
ajax('XXX1', () => {
    // callback 函数体
    ajax('XXX2', () => {
        // callback 函数体
        ajax('XXX3', () => {
            // callback 函数体
        })
    })
})
```

**优点：** 解决了同步的问题（只要有一个任务耗时很长，后面的任务都必须排队等着，会拖延整个程序的执行。）

#### 2）Promise

Promise就是为了解决callback的问题而产生的。Promise 实现了链式调用，也就是说每次 then 后返回的都是一个全新 Promise，如果我们在 then 中 return ，return 的结果会被 Promise.resolve() 包装

**优点：** 解决了回调地狱的问题

```js
ajax('XXX1')
  .then(res => {
      // 操作逻辑
      return ajax('XXX2')
  }).then(res => {
      // 操作逻辑
      return ajax('XXX3')
  }).then(res => {
      // 操作逻辑
  })
```

**缺点：** 无法取消 Promise ，错误需要通过回调函数来捕获

#### 3）Generator

**特点：** 可以控制函数的执行，可以配合 co 函数库使用

```js
function *fetch() {
    yield ajax('XXX1', () => {})
    yield ajax('XXX2', () => {})
    yield ajax('XXX3', () => {})
}
let it = fetch()
let result1 = it.next()
let result2 = it.next()
let result3 = it.next()
```

#### 4）Async/await

async、await 是异步的终极解决方案

**优点：** 代码清晰，不用像 Promise 写一大堆 then 链，处理了回调地狱的问题

**缺点：** await 将异步代码改造成同步代码，如果多个异步操作没有依赖性而使用 await 会导致性能上的降低。

```js
async function test() {
  // 以下代码没有依赖性的话，完全可以使用 Promise.all 的方式
  // 如果有依赖性的话，其实就是解决回调地狱的例子了
  await fetch('XXX1')
  await fetch('XXX2')
  await fetch('XXX3')
}
```










### 55Promise 构造函数是同步还是异步执行，then 呢

#### promise构造函数是同步执行的，then方法是异步执行的

看个代码示例

```js
new Promise(resolve => {
    console.log(1);
    resolve(3);
}).then(num => {
    console.log(num)
});
console.log(2)

// 输出 123
```

#### 具体分析下

**语法**

```js
new Promise( function(resolve, reject) {...} /* executor */  ) 
```

- 构建 Promise 对象时，需要传入一个 executor 函数，主要业务流程都在 executor 函数中执行。
- Promise构造函数执行时立即调用executor 函数， resolve 和 reject 两个函数作为参数传递给executor，resolve 和 reject 函数被调用时，分别将promise的状态改为fulfilled(完成)或rejected(失败)。一旦状态改变，就不会再变，任何时候都可以得到这个结果。
- 在 executor 函数中调用 resolve 函数后，会触发 promise.then 设置的回调函数;而调用 reject 函数后，会触发 promise.catch 设置的回调函数。

> 值得注意的是，Promise 是用来管理异步编程的，它本身不是异步的，new Promise的时候会立即把executor函数执行，只不过我们一般会在executor函数中处理一个异步操作。比如下面代码中，一开始是会先打印出2。

```js
let p1 = new Promise(()=>{ 
    setTimeout(()=>{ 
      console.log(1) 
    },1000) 
    console.log(2) 
  }) 
console.log(3) // 2 3 1 
```

Promise 采用了回调函数延迟绑定技术，在执行 resolve 函数的时候，回调函数还没有绑定，那么只能推迟回调函数的执行。

再看个例子

```js
let p = new Promise((resolve,reject)=>{ 
  console.log(1); 
  resolve('yideng') 
  console.log(2) 
}) 
// then:设置成功或者失败后处理的方法 
p.then(result=>{ 
 //p延迟绑定回调函数 
  console.log('成功 '+result) 
},reason=>{ 
  console.log('失败 '+reason) 
}) 
console.log(3) 
// 1 
// 2 
// 3 
// 成功 yideng
```

new Promise的时候先执行executor函数，打印出 1、2，Promise在执行resolve时，触发微任务，还是继续往下执行同步任务， 执行p.then时，存储起来两个函数(此时这两个函数还没有执行),然后打印出3，此时同步任务执行完成，最后执行刚刚那个微任务，从而执行.then中成功的方法。





### 56请手写实现一个拖拽

#### 1.原生js实现

拖拽需要三大事件：

- mousedown  鼠标摁下触发
- mousemove  鼠标移动触发
- mouseup    鼠标抬起触发

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>手动实现拖拽</title>
</head>
<style>
  .move {
    position: absolute;
    width: 100px;
    height: 100px;
    background: gray
  }
</style>

<body>
  <div class="move-container">
    <div class="move">
    </div>
  </div>
  <script>
    let elem = document.querySelector('.move');
    let dragging; //拖拽状态
    let trans, portrait; //鼠标按下时相对于选中元素的位移

    document.addEventListener('mousedown', function (e) {
      if (e.target == elem) {
        dragging = true; //激活拖拽状态
        let elemRect = elem.getBoundingClientRect(); //返回元素的大小及其相对于视口的位置
        trans = e.clientX - elemRect.left; //鼠标按下时和选中元素的坐标偏移:x坐标
        portrait = e.clientY - elemRect.top; //鼠标按下时和选中元素的坐标偏移:y坐标
      }
    });
    document.addEventListener('mouseup', function (e) {
      dragging = false;
    });
    document.addEventListener('mousemove', function (e) {
      if (dragging) {
        var moveX = e.clientX - trans,
          moveY = e.clientY - portrait;

        elem.style.left = moveX + 'px';
        elem.style.top = moveY + 'px';

      }
    });
  </script>
</body>
</html>
```

#### 2.HTML5原⽣ 拖拽draggable属性以及DataTranfers对象

![流程图](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-582-process.png)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>手动实现拖拽</title>
</head>
<style>
  .main {
    display: flex;
    justify-content: space-around;
  }

  .left {
    width: 300px;
    height: 500px;
    margin-right: 10px;
    border: 1px solid red;
    text-align: center;
    box-sizing: border-box;
    padding: 1pxx
  }

  .right {
    width: 300px;
    height: 500px;
    border: 1px solid lightseagreen;
    text-align: center;
    box-sizing: border-box;
    padding: 1px;
  }

  .txt {
    border: 1px solid gray;
    margin: 1px;
    padding: 5px;
    cursor: move;
  }
</style>

<body>
  <main class="main">
    <div class="left" id="left">
      <div class="txt-show">左边区域</div>
      <div id='txt1' draggable="true" class="dragable txt txt1">可移动的文字一</div>
      <div id='txt2' draggable="true" class="dragable txt txt2">可移动的文字二</div>
      <div id='txt3' draggable="true" class="dragable txt txt3">可移动的文字三</div>
      <div id='txt4' draggable="true" class="dragable txt txt4">可移动的文字四</div>
      <div id='txt5' draggable="true" class="dragable txt txt5">可移动的文字五</div>
    </div>
    <div class="right" id='right'>
      <div class="txt-show">右边区域</div>
    </div>
  </main>

  <script>
    let txtObj = document.getElementsByClassName('txt')
    for (let i = 0; i < txtObj.length; i++) {
      txtObj[i].ondragstart = handle_start
      txtObj[i].ondrag = handle_drag
      txtObj[i].ondragend = handle_end
    }

    function handle_start(e) {
      e.dataTransfer.setData('Text', e.target.id)
      console.log('handle_start-拖动开始')
    }

    function handle_drag(e) {
      console.log('handle_drag-拖动中')
    }

    function handle_end(e) {
      console.log('handle_end-拖动结束')
    }
    let target = document.getElementById('right')
    target.ondragenter = handle_enter
    target.ondragover = handle_over
    target.ondragleave = handle_leave
    target.ondrop = handle_drop

    function handle_enter(e) {
      e.preventDefault()
      console.log('handle_enter-进入目的地')
    }

    function handle_over(e) {
      e.preventDefault()
      let returnObj = e.dataTransfer.getData('Text')
      console.log(returnObj + '-handle_over-在目的地范围内')
    }

    function handle_leave(e) {
      e.preventDefault()
      let returnObj = e.dataTransfer.getData('Text')
      console.log(returnObj)
      console.log('handle_leave-没有放下就离开目的地')
    }

    function handle_drop(e) {
      e.stopPropagation(); // 不再派发事件。解决Firefox浏览器，打开新窗口的问题。
      e.preventDefault()
      let returnObj = e.dataTransfer.getData('Text')
      if (returnObj) {
        e.target.appendChild(document.getElementById(returnObj))
      }
      console.log(returnObj + '-handle_drop-在目的地区释放')
    }
  </script>
</body>

</html>
```

### 57项目如何管理模块

### 项目如何管理模块

在一个项目内，当有多个开发者一起协作开发时，或者功能越来越多、项目越来越庞大时，保证项目井然有序的进行是相当重要的。一般会从下面几点来考证一个项目是否管理得很好：

1. **可扩展性**：能够很方便、清晰的扩展一个页面、组件、模块
2. **组件化**：多个页面之间共用的大块代码可以独立成组件，多个页面、组件之间共用的小块代码可以独立成公共模块
3. **可阅读性**：阅读性良好（包括目录文件结构、代码结构），能够很快捷的找到某个页面、组件的文件，也能快捷的看出项目有哪些页面、组件
4. **可移植性**：能够轻松的对项目架构进行升级，或移植某些页面、组件、模块到其他项目
5. **可重构性**：对某个页面、组件、模块进行重构时，能够保证在重构之后功能不会改变、不会产生新 bug
6. **开发友好**：开发者在开发某一个功能时，能够有比较好的体验（不好的体验比如：多个文件相隔很远）
7. **协作性**：多人协作时，很少产生代码冲突、文件覆盖等问题
8. **可交接性**：当有人要离开项目时，交接给其他人是很方便的

多个项目之间，如何管理好项目之间联系，比如共用组件、公共模块等，保证快捷高效开发、不重复造轮子，也是很重要的。一般会从下面几点来考证多个项目之间是否管理得很好：

1. **组件化**：多个项目共用的代码应当独立出来，成为一个单独的组件项目
2. **版本化**：组件项目与应用项目都应当版本化管理，特别是组件项目的版本应当符合 semver 语义化版本规范
3. **统一性**：多个项目之间应当使用相同的技术选型、UI 框架、脚手架、开发工具、构建工具、测试库、目录规范、代码规范等，相同功能应指定使用固定某一个库
4. **文档化**：组件项目一定需要相关的文档，应用项目在必要的时候也要形成相应的文档

### 58页面埋点怎么实现

### 页面埋点方案

#### 1）现有的埋点类型：

1. **手动代码埋点**：在需要采集数据的地方调用埋点的方法。在任意地点任意场景进行数据采集，
2. **可视化埋点**：元素都带有唯一标识。通过埋点配置后台，将元素与要采集事件关联起来，可以自动生成埋点代码嵌入到页面中。
3. **无埋点**：前端自动采集全部事件，上报埋点数据，由后端来过滤和计算出有用的数据，

#### 2）基本实现方案：


1. 约定通用的埋点采集接口规范: 如header(标识X-Device-Id, X-Source-Url, X-Current-Url, X-User-Id等信息), body(标识PageSessionID, Event, PageTitle, CurrentTime, ExtraInfo);
2. 指定调用采集脚本的方式: 单页面应用 => 对history路径的变化保持监听, 路径变化时触发埋点收集; 页面加载/离开绑定对应的onload, unload事件, 页面元素上绑定相关的交互事件(click, event等)



#### 3）示意伪代码： 

```js
var collect = {
    deviceUrl:'',
    eventUrl:'',
    isuploadUrl:'',
    parmas:{},
    device:{}
};

//获取埋点配置
collect.setParames = function(){}

//更新访问路径及页面信息
collect.updatePageInfo = function(){}

//获取事件参数
collect.getParames = function(){}

//获取设备信息
collect.getDevice = function(){}

//事件采集
collect.send = function(){}

//设备采集
collect.sendDevice = function(){}

//判断是否采集，埋点采集的开关
collect.isupload = function(){
/*
1. 判断是否采集，不采集就注销事件监听（项目中区分游客身份和用户身份的采集情况，这个方法会被判断两次）
2. 采集则判断是否已经采集过
    a.已经采集过不做任何操作
    b.没有采集过添加事件监听
3. 判断是 混合应用还是纯 web 应用
    a.如果是web 应用，调用 collect.setIframe 设置 iframe
    b.如果是混合应用 将开始加载和加载完成事件传输给 app
*/

}

//点击事件处理函数
collect.clickHandler = function(){}

//离开页面的事件处理函数
collect.beforeUnloadHandler = function(){}

//页面回退事件处理函数
collect.onPopStateHandler = function(){}

//系统事件初始化，注册离开事件，浏览器后退事件
collect.event = function(){}

//获取记录开始加载数据信息
collect.getBeforeload = function(){}

//存储加载完成，获取设备类型，记录加载完成信息
collect.onload = function(){
/*
    1. 判断cookie是否有存设备类型信息，有表示混合应用
    2. 采集加载完成时间等信息
    3. 调用 collect.isupload 判断是否进行采集
*/
}

//web 应用，通过嵌入 iframe 进行跨域 cookie 通讯，设置设备id
collect.setIframe = function(){}

//app 与 h5 混合应用，直接将数信息发给 app,判断设备类型做原生方法适配器
collect.saveEvent = function(){}

//采集自定义事件类型
collect.dispatch = function(){}

//将参数 userId 存入sessionStorage
collect.storeUserId = function(){}

//采集H5信息,如果是混合应用，将采集到的信息发送给 app 端
collect.saveEventInfo = function(){}

//页面初始化调用方法
collect.init = function(){
/*
    1. 获取开始加载的采集信息
    2. 获取 SDK 配置信息，设备信息
    3. 改写 history 两个方法，单页面应用页面跳转前调用我们自己的方法
    4. 页面加载完成，调用 collect.onload 方法
*/

}


collect.init(); // 初始化

//暴露给业务方调用的方法
return {
    dispatch:collect.dispatch,
    storeUserId:collect.storeUserId,
}
```

### 59数组里面有 10 万个数据，取第一个元素和第 10 万个元素的时间相差多少

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

### 60如何加快页面渲染速度，都有哪些方式

### 网站性能提升

#### 1、静态资源的优化
  
主要是减少静态资源的加载时间，主要包括html、js、css和图片。

- a、减少http请求数：合并js、css、制作雪碧图以及使用http缓存；
- b、减小资源的大小：压缩文件、压缩图片，小图使用base64编码等；
- c、异步组件和图片懒加载；
- d、CDN加速和缓存（bootCND）：客户端可通过最佳的网络链路加载静态资源，提高访问的速度和成功率。（CDN：通过在网络各处放置节点服务器构成的一层智能虚拟网络，可将用户的请求重新导向离用户最近的服务节点上）
     
      
     
#### 2、接口访问的优化
  
1. http持久链接（Conection:keep-alive）
2. 后端优化合并请求（比如在进入一个商品详情页的时候后端会提供一个接口获取商品的基本信息，然后当用户点击假如购物车时）
3. 冷数据接口缓存到localstorage，减少请求
     
    
     
#### 3、页面渲染速度的优化
  
1. 由于浏览器的js引擎线程和GUI渲染线程是互斥的，所以在执行js的时候会阻塞它的渲染，所以一般会将css放在顶部，优先渲染，js放在底部；
2. 减少dom的操作：
3. 使用虚拟DOM渲染方案，做到最小化操作真实的dom；
4. 事件代理：利用事件冒泡原理，把函数注册到父级元素上。
5. 减少页面的重绘和回流。

### 61定时器为什么是不精确的

### 简要回答

首先，我们要知道 setInterval 的运行机制，setInterval 属于宏任务，要等到一轮同步代码以及微任务执行完后才会走到宏任务队列，但是前面的任务到底需要多长时间，这个我们是不确定的

等到宏任务执行，代码会检查 setInterval 是否到了指定时间，如果到了，就会执行 setInterval，如果不到，那就要等到下次 EventLoop 重新判断

当然，还有一部分不确定的因素，比如 setInterval 的时间戳小于 10ms，那么会被调整至 10ms 执行，因为这是 setInterval 设计及规定，当然，由于其他任务的影响，这个 10ms 也会不精确

还有一些物理原因，如果用户使用的设备处于供电状态等，为了节电，浏览器会使用系统定时器，时间间隔将会被调整至 16.6ms

### 深入探究版

#### 1.超时限制为>=4ms

在现代浏览器中，由于回调嵌套（嵌套级别至少为特定深度）或者经过一定数量的连续间隔而触发连续调用时，`setTimeout`/`setInterval`调用至少每**4ms**被限制一次

```js
function f(){}
function cb(){
    f()
    setTimeout(cb,0)
}
setTimeout(cb,0)
```

- 在Chrome和Firefox 第五次连续的调用就会被限制
- Safari锁定了第六次通话
- Edge在第三次
- Gecko在`version56`已经这样开始尝试`setInterval`(对setTimeout也一样) 。`In Chrome and Firefox, the 5th successive callback call is clamped; Safari clamps on the 6th call; in Edge its the 3rd one. Gecko started to treat setInterval() like this in version 56 (it already did this with setTimeout(); see below). `

**从历史上来看，某些浏览器在执行此节流方式有所不同了，在`setInterval`从任何地方的调用上，或者在`setTimeout`嵌套级别至少达到一定深度的情况下调用嵌套时，要想在现代浏览器实现0毫秒延迟可以使用`postMessage`**

> 注意：最小延迟`DOM_MIN_TIMEOUT_VALUE`为4ms，同时`DOM_CLAMP_TIMEOUT_NESTING_LEVEL`是5（dom固定超时嵌套级别）

#### 2.在非活动tab卡，超时限制为>=1000ms

为了减少背景选项卡的负载（和相关的资源使用），在不活动的资源卡将超时限制为1000ms以下

firefox从版本5开始实施该行为（可通过`dom.min_background_timeout_value`首选项调整1000ms常量）。Chrome从版本11开始实现该行为，自Firefox 14中出现错误736602以来，Android版Firefox的背景标签使用的超时值为15分钟，并且背景标签也可以完全卸载

#### 3.限制跟踪超时脚本

自Firefox 55起，跟踪脚本（例如Google Analytics（分析），Firefox通过其TP列表将其识别为跟踪脚本的任何脚本URL ）都受到了进一步的限制。在前台运行时，节流最小延迟仍为4ms。但是，在后台选项卡中，限制最小延迟为10,000毫秒（即10秒），该延迟在首次加载文档后30秒生效。

控制此行为的首选项是：

- dom.min_tracking_timeout_value：4
- dom.min_tracking_background_timeout_value：10000
- dom.timeout.tracking_throttling_delay：30000

#### 4.逾期超时

除了固定值意外，当页面（或OS /浏览器本身）忙于其他任务时，超时还会在以后触发。要注意的一个重要情况是，直到调用的线程setTimeout()终止，函数或代码段才能执行。例如：

```js
function foo() {
  console.log('foo has been called');
}
setTimeout(foo, 0);
console.log('After setTimeout');
// After setTimeout    foo has been called
```

这是因为即使setTimeout以零的延迟被调用，它也被放置在队列中并计划在下一个机会运行。不是立即。当前执行的代码必须在执行队列中的功能之前完成，因此生成的执行顺序可能与预期的不同

### 62手写实现 apply

### 简单模拟实现

```js
Function.prototype.myapply = function (context, ...argus) {
    if (typeof this !== 'function') {
        throw new TypeError('not funciton')
    }
    const fn = this
    let result = null

    context = context || window
    argus = argus && argus[0] || []
    context.fn = fn
    result = context.fn(...argus)
    delete context.fn

    return result
}
```

### 63loadsh 深拷贝实现原理

### 源码分析

```js
// cloneDeep.js
function cloneDeep(value) {
  return baseClone(value, CLONE_DEEP_FLAG | CLONE_SYMBOLS_FLAG);
}
export default cloneDeep;
```

```
function cloneDeepWith(value, customizer) {
  customizer = typeof customizer == 'function' ? customizer : undefined;
  return baseClone(value, CLONE_DEEP_FLAG | CLONE_SYMBOLS_FLAG, customizer);
}

export default cloneDeepWith;
```

先看 lodash 深拷贝的两个主要方法，cloneDeep，参数只有一个 value，就是我们要拷贝的对象

cloneDeepWith，这个方法参数比 cloneDeep 多了一个 customizer，翻译过来就是定制的意思，那也就可以知道，customizer 是一个函数，在这个函数里可以自定义一些东西

从上面的深拷贝的方法里可以看到，都执行了 baseClone 方法，baseClone 就是实现深拷贝的主要方法

接下来看下 baseClone 这个方法做了什么

```js
function baseClone(value, bitmask, customizer, key, object, stack) {
    // 在这里，我们看到一进来就定义了三个常量，通过位运算，可以得到下面三个值 isDeep isFlat isFull
  var result,
      isDeep = bitmask & CLONE_DEEP_FLAG,  //深拷贝 1
      isFlat = bitmask & CLONE_FLAT_FLAG,  //拷贝原型链 0
      isFull = bitmask & CLONE_SYMBOLS_FLAG; //拷贝Symbol 4
    // 这里判断是否有customizer，如果存在，就会执行customizer，也就是自定义clone函数
  if (customizer) {
    result = object ? customizer(value, key, object, stack) : customizer(value);
  }
  // 判断函数返回值,如果使用者自己在customizer函数中返回了值，那么直接return 返回值
  if (result !== undefined) {
    return result;
  }
  // 非对象  直接返回  isObject中判断也很明确，非null以及typeof Object || typeof Function
  if (!isObject(value)) {
    return value;
  }
  // 这里的isArray方法，里面用了Array.isArray
  var isArr = isArray(value);
  // 如果是数组 执行initCloneArray方法  initCloneArray这个方法下面一起看
  if (isArr) {
    result = initCloneArray(value);
    // 如果是浅拷贝，则直接循环赋值到result上，但是并未创建新数组
    if (!isDeep) {
      return copyArray(value, result);
    }
  } else {
      // 这里获取类型，getTag方法里返回字符串，比如对象---"[Object object]"
    var tag = getTag(value),
        isFunc = tag == funcTag || tag == genTag;
    // 如果是buffer
    if (isBuffer(value)) {
      return cloneBuffer(value, isDeep);
    }
    // 如果是对象或者function
    if (tag == objectTag || tag == argsTag || (isFunc && !object)) {
      result = (isFlat || isFunc) ? {} : initCloneObject(value);
      if (!isDeep) {
          // 是否拷贝原型
        return isFlat
          ? copySymbolsIn(value, baseAssignIn(result, value))
          : copySymbols(value, baseAssign(result, value));
      }
    } else {
      if (!cloneableTags[tag]) {
        return object ? value : {};
      }
      result = initCloneByTag(value, tag, isDeep);
    }
  }
  // Check for circular references and return its corresponding clone.
  // 判断stacked中是否存在value  Stack使用函数原型链的来实现存储对象
  stack || (stack = new Stack);
  var stacked = stack.get(value);
  if (stacked) {
    return stacked;
  }
  stack.set(value, result);
    // 这里判断Set 以及Map 一会详细看
  if (isSet(value)) {
    value.forEach(function(subValue) {
      result.add(baseClone(subValue, bitmask, customizer, subValue, value, stack));
    });
  } else if (isMap(value)) {
    value.forEach(function(subValue, key) {
      result.set(key, baseClone(subValue, bitmask, customizer, key, value, stack));
    });
  }

  var keysFunc = isFull
    ? (isFlat ? getAllKeysIn : getAllKeys)
    : (isFlat ? keysIn : keys);
    // Symbolh和__proto__
  var props = isArr ? undefined : keysFunc(value);
  arrayEach(props || value, function(subValue, key) {
    if (props) {
      key = subValue;
      subValue = value[key];
    }
    // Recursively populate clone (susceptible to call stack limits).
    assignValue(result, key, baseClone(subValue, bitmask, customizer, key, value, stack));
  });
  // 返回result
  return result;
}

export default baseClone;
```

### 深拷贝的具体实现

分析上面具体是如何深拷贝的

#### 1.initCloneArray

```js
function initCloneArray(array) {
    // 得到数组的length，创建一个新数组，新数组的length与原数组保持一致
  var length = array.length,
      result = new array.constructor(length);

  // Add properties assigned by `RegExp#exec`.
  // 正则返回的数组 因为正则表达式 regexObj.exec(str) 返回的是一个数组，匹配失败返回null
  if (length && typeof array[0] == 'string' && hasOwnProperty.call(array, 'index')) {
    result.index = array.index;
    result.input = array.input;
  }
  return result;
}

export default initCloneArray;
```

这里对于数组，该方法只是创建数组，如果存在正则，只拷贝 index 和 input，数组里的值并没有拷贝，后面会看到

#### 2.copyObject && initCloneObject

```js
//initCloneObject
function initCloneObject(object) {
    // 构造函数是否在原型上 如果是，使用Object.create创建原型副本
    return (typeof object.constructor == 'function' && !isPrototype(object))
        ? Object.create(Object.getPrototypeOf(object))
     : {}
}
//isPrototype
function isPrototype(value) {
    const Ctor = value && value.constructor
    // 对应原型
    const proto = (typeof Ctor == 'function' && Ctor.prototype) || Object.prototype
    return value === proto
}
// copyObject 该方法就是上面的copySymbolsIn / copySymbols里调用的，copySymbolsIn / copySymbols主要区分是否拷贝Symbol
function copyObject(source, props, object, customizer) {
  var isNew = !object;
  object || (object = {});

  var index = -1,
      length = props.length;
    // 循环 对象的属性，如果有自定义函数，则传入执行
  while (++index < length) {
    var key = props[index];

    var newValue = customizer
      ? customizer(object[key], source[key], key, object, source)
      : undefined;
    // 等待自定义方法执行完毕，如果没有返回值，则认为该属性直接拷贝即可
    if (newValue === undefined) {
      newValue = source[key];
    }
    // 是否存在Symbol的数组
    if (isNew) {
      baseAssignValue(object, key, newValue);
    } else {
      assignValue(object, key, newValue);
    }
  }
  return object;
}

export default copyObject;
```

#### 3.baseAssignValue 和 assignValue

看下 baseAssignValue 和 assignValue 的区别以及它们是如何给对象属性赋值的

```js
// baseAssignValue
function baseAssignValue(object, key, value) {
    // 如果key是原型，那么使用defineProperty来改变属性的值
  if (key == '__proto__' && defineProperty) {
    defineProperty(object, key, {
      'configurable': true,
      'enumerable': true,
      'value': value,
      'writable': true
    });
  } else {
      // 直接改变属性值
    object[key] = value;
  }
}

export default baseAssignValue;

//assignValue
function assignValue(object, key, value) {
  var objValue = object[key];
  // 值是否不相等，如果不相等，及执行baseAssignValue，也就是真正赋值的方法
  if (!(hasOwnProperty.call(object, key) && eq(objValue, value)) ||
      (value === undefined && !(key in object))) {
    baseAssignValue(object, key, value);
  }
}

export default assignValue;
```

#### 4.对于 Set 和 Map 的处理

处理方式也很易懂，如果是 Set，则循环 add 上去，因为我们在上面看到了，如果是对象。则会拷贝出一份原型副本，所以此时的目标对象原型上，有源对象的原型及方法
如果是 Map，和上面一样，只是 set 方法而不是 add 方法

#### 5.数组的遍历

在核心方法 baseClone 里，方法的末尾又判断了是否是数组，上面的 initCloneArray 我们只是看到创建了与原数组长度一样的新数组，并未赋值

```js
// baseClone
// 是否有是数组，如果是数组，我们已经有新的数组等待赋值，否则的话，再次提取原数组的key
  var props = isArr ? undefined : keysFunc(value);
  arrayEach(props || value, function(subValue, key) {
      // 替换真正的key,value
    if (props) {
      key = subValue;
      subValue = value[key];
    }
    // Recursively populate clone (susceptible to call stack limits).
    // 赋值以及递归拷贝  实现多层深拷贝，而不是一层
    assignValue(result, key, baseClone(subValue, bitmask, customizer, key, value, stack));
  });
```

### 64添加原生事件不移除为什么会内存泄露，还有哪些地方会存在内存泄漏

### 添加原生事件的问题

```js
var button = document.getElementById('button');
function onClick(event) {
    button.innerHTML = 'text';
}
button.addEventListener('click', onClick);
```

给元素button添加了一个事件处理器onClick, 而处理器里面使用了button的引用。而老版本的 IE 是无法检测 DOM 节点与 JavaScript 代码之间的循环引用，因此会导致内存泄漏。

如今，现代的浏览器（包括 IE 和 Microsoft Edge）使用了更先进的垃圾回收算法，已经可以正确检测和处理循环引用了。换言之，回收节点内存时，不必非要调用 removeEventListener 了。

### 其它内存泄露


- 意外的全局变量 (如果必须使用全局变量存储大量数据时，确保用完以后把它设置为 null 或者重新定义。与全局变量相关的增加内存消耗的一个主因是缓存。缓存数据是为了重用，缓存必须有一个大小上限才有用。)
- 被遗忘的计时器,比如下面示例代码, 尽管这个定时器不再需要，里面的回调也不再需要，可是计时器回调函数并没有被回收，这样someResource,如果存储了大量的数据，也是无法被回收。 因此需要把定时器清除。
- 脱离DOM的引用(当你保存了一个dom的引用，然后将该dom从html中删除后，你应该将这个引用赋为null，否则GC不会回收，这个dom仍然在内存中。保存 DOM 元素引用的时候，要小心谨慎。
- 闭包，闭包包含这外面函数的活动对象，无法被GC回收。 

### 65尽可能多的写出判断数组的方法

### 数组判断方法

- arr instanceof Array，原型链判断；
- arr.constructor == Array，构造函数判断；
- Object.prototype.toString.call(obj)=='Array’，对象的toSting方法；
- Array.isArray，数组的原生方法；

### 66说下 offsetWith 和 clientWidth、offsetHeight 和 clientHeight 的区别，说说 offsetTop，offsetLeft，scrollWidth、scrollHeight 属性都是干啥的

### 扩展一下

- offset 相关：offsetWidth offsetHeight offsetTop offsetLeft
- client 相关：clientWidth clientHeight clientTop clientLeft
- scroll 相关：scrollWidth scrollHeight scrollTop scrollLeft

#### 1.offset

**offsetHeight**:是一个只读属性，它返回该元素的像素高度，高度包含该元素的垂直内边距和边框，且是一个整数，不包含:before 或:after 等伪类元素的高度，如果元素被隐藏（例如 元素或者元素的祖先之一的元素的 style.display 被设置为 none），则返回 0，

**offsetWidth**:同上，将理解高度为宽度即可

这个两个属性值会被四舍五入为整数值，如果你需要一个浮点数值，请用 element.getBoundingClientRect()

**offsetLeft**:为只读属性，它返回当前元素 左边框 外边缘 到 最近的已定位父级（offsetParent） 左边框 内边缘的距离。如果父级都没有定位，则是到 body 左边的距离

**offsetTop**：为只读属性，当前元素 上边框 外边缘 到 最近的已定位父级（offsetParent） 上边框 内边缘的 距离。如果父级都没有定位，则是到 body 顶部的距离

#### 2.client

-  **clientWidth**:包括元素内容的宽度、左右 padding
-  **clientHeight**:包括元素内容的高度、上下 padding
-  **clientTop**:为只读属性,上边框的宽度
-  **clientLeft**:表示一个元素的左边框的宽度，以像素表示。如果元素的文本方向是从右向左（RTL, right-to-left），并且由于内容溢出导致左边出现了一个垂直滚动条，则该属性包括滚动条的宽度。clientLeft 不包括左外边距和左内边距。clientLeft 是只读的。

#### 3.scroll

**scrollWidth**:宽度的测量方式与 clientWidth 相同：它包含元素的内边距，但不包括边框，外边距或垂直滚动条（如果存在）。 它还可以包括伪元素的宽度，例如::before 或::after。 如果元素的内容可以适合而不需要水平滚动条，则其 scrollWidth 等于 clientWidth

谷歌获取的 Element.scrollWidth 和 IE，火狐下获取的 Element.scrollWidth 并不相同

**scrollHeight**: 理解同上

**scrollTop**:读取或设置元素内容层顶部 到 可视区域顶部的距离

**scrollTop** 可以被设置为任何整数值，同时注意： 

1. 如果一个元素不能被滚动（例如，它没有溢出，或者这个元素有一个"non-scrollable"属性）， scrollTop 将被设置为 0。 
2. 设置 scrollTop 的值小于 0，scrollTop 被设为 0 
3. 如果设置了超出这个容器可滚动的值, scrollTop 会被设为最大值。

兼容性写法 `var scrollTop = document.documentElement.scrollTop || window.pageYOffset || document.body.scrollTop`

读取或设置元素内容层左端 到 可视区域左端的距离

注意如果这个元素的内容排列方向（direction） 是 rtl (right-to-left) ，那么滚动条会位于最右侧（内容开始处），并且 scrollLeft 值为 0。此时，当你从右到左拖动滚动条时，scrollLeft 会从 0 变为负数。

兼容性写法 `var scrollLeft = document.documentElement.scrollLeft || window.pageXOffset || document.body.scrollLeft`


### 67请修改代码能跳出死循环
```js
while (1) {
  switch ("yideng") {
    case "yideng":
    //禁止直接写一句break
  }
}
```

### 实现方案

#### 1.实现方式一

```js
//通过标签语句,跳出无限循环：
loop1:
while(1){
 switch ('yideng'){
  case 'yideng': break loop1;
 }
}
```

#### 2.实现方式二

```js
try{
    while (1) {
       switch("yideng"){
           case "yideng" :
           		console.log(true);
           		throw new Error("跳出循环");
        }  
    }
} catch(e){
    console.log(e);
}
```

#### 3.实现方式三

```js
//javascript goto实现 
out:
for(let i =0;i<1;i++){
	while (1) {
    switch ("yideng") {
      case "yideng":
        console.log("yideng");
        continue out
    }
	}
}
```

#### 4.实现方式四

```js
//return
function test(){
  while (1) {
    switch ("yideng") {
      case "yideng":
        console.log("yideng");
        return;
    }
  }
}
test();
```




### 68词法作用域和 this 的区别

### 区别

词法作用域包含了执行上下文中的变量声明，this 是执行上下文的一个可能为空值的属性，是对对象的引用。

JS 引擎执行一段和当前执行上下文（running execution context）无关的代码时，会创建一个对应的执行上下文用于追踪代码执行过程，并将当前执行上下文指向该上下文。执行上下文的创建过程中会根据语法块（块级作用域）创建对应的环境记录。

词法作用域会通过环境记录（Environment Record）来存储标识符与实际变量的映射关系，和一个外部环境（OuterEnv）来引用上级作用域。

环境记录包括词法环境（Lexical Environment）和变量环境（Variable Environment），块级声明如 let/function 等存于词法环境，其它声明如 var 等存于变量环境。

代码执行中，词法环境可能会建立环境记录与 this 的绑定。解析 this 时，从当前上下文中开始直到全局，返回最近可用的 this 绑定。

### 69for..in 和 object.keys 的区别

### 区别

for-in 是javaScript中最常见的迭代语句，常常用来枚举对象的属性。某些情况下，可能按照随机顺序遍历数组元素；

而Object构造器有一个实例属性keys，则可以返回以对象的属性为元素的数组。数组中属性名的顺序跟使用for-in遍历返回的顺序是一样的。

for-in循环会枚举对象原型链上的可枚举属性，而Object.keys不会

### 70JavaScript 写一个单例模式，可以具体到某一个场景

### 代码实现

保证一个类仅有一个实例，并提供一个访问它的全局访问点，一般购物车、登录等都是一个单例。

#### 1.代码示例

```js
// es6
class SingleManage {
    constructor({ name, level }) {
        if (!SingleManage.instance) {
            this.name = name;
            this.level = level
            SingleManage.instance = this;
        }
        return SingleManage.instance
    }
}

let boss = new SingleManage({name:"Jokul", level:"1"})
let boss2 = new SingleManage({name:"Jokul2", level:"2"})
console.log(boss === boss2)

// es5
function SingleManage(manage) {
    this.name = manage.name
    this.level = manage.level
    this.info = function () {
        console.warn("Boss's name is " + this.name + " and level is " + this.level)
    }
}
SingleManage.getInstance = function (manage) {
    if (!this.instance) {
        this.instance = new SingleManage(manage)
    }
    return this.instance
}
var boss = SingleManage.getInstance({ name: "Jokul", level: "1" })
var boss2 = SingleManage.getInstance({ name: "Jokul2", level: "2" })
boss.info()
boss2.info()
```

#### 2.应用实例

- 实现一个storage

```js
// 先实现一个基础的StorageBase类，把getItem和setItem方法放在它的原型链上
function StorageBase () {}
StorageBase.prototype.getItem = function (key){
    return localStorage.getItem(key)
}
StorageBase.prototype.setItem = function (key, value) {
    return localStorage.setItem(key, value)
}

// 以闭包的形式创建一个引用自由变量的构造函数
const Storage = (function(){
    let instance = null
    return function(){
        // 判断自由变量是否为null
        if(!instance) {
            // 如果为null则new出唯一实例
            instance = new StorageBase()
        }
        return instance
    }
})()

// 这里其实不用 new Storage 的形式调用，直接 Storage() 也会有一样的效果 
const storage1 = new Storage()
const storage2 = new Storage()

storage1.setItem('name', 'yd')
// yd
storage1.getItem('name')
// 也是yd
storage2.getItem('name')

// 返回true
storage1 === storage2
```

### 71手写实现 call

### 代码实现

```js
Function.prototype.mycall = function (context, ...argus) {
    if (typeof this !== 'function') {
        throw new TypeError('not funciton')
    }
    const fn = this
    let result = null

    context = context || window
    context.fn = fn
    result = context.fn(...argus)
    delete context.fn

    return result
}
```

### 72按照调用实例，实现下面的 Person 方法
```js
Person("Li");
// 输出： Hi! This is Li!

Person("Dan").sleep(10).eat("dinner");
// 输出：
// Hi! This is Dan!
// 等待10秒..
// Wake up after 10
// Eat dinner~

Person("Jerry").eat("dinner").eat("supper");
// 输出：
// Hi This is Jerry!
// Eat dinner~
// Eat supper~

Person("Smith").sleepFirst(5).eat("supper");
// 输出：
// 等待5秒
// Wake up after 5
// Hi This is Smith!
// Eat supper
```

### 代码实现

```js
class PersonGenerator {
  taskQueue = [];
  constructor(name) {
    this.taskQueue.push(() => this.sayHi(name));
    this.runTaskQueue();
  }
  nextTask = () => {
    if (this.taskQueue.length > 0) {
      const task = this.taskQueue.shift();
      if (typeof task === "function") {
        task();
        this.nextTask();
      }
      if (typeof task === "number") {
        console.log(`Sleep ${task} seconds \n`);
        setTimeout(() => this.nextTask(), task * 1000);
      }
    }
  };

  runTaskQueue = () => {
    setTimeout(() => this.nextTask());
  };

  sayHi(name) {
    console.log(`Hi! This is ${name}! \n`);
    return this;
  }

  sleep(seconds) {
    this.taskQueue.push(seconds);
    return this;
  }

  sleepFirst(seconds) {
    this.taskQueue.splice(-1, 0, seconds);
    return this;
  }

  eat(food) {
    this.taskQueue.push(() => console.log(`Eat ${food}~ \n`));
    return this;
  }
}

const Person = name => new PersonGenerator(name);

Person("helloWorld").sleepFirst(3).sleep(3).eat("little_cute");
```

### 73请实现一个 JSON.parse

### 代码实现

- 实现一：直接eval

```js
function parse(jsonStr) {
    return eval('(' + jsonStr + ')');
}
```

> 避免在不必要的情况下使用 eval，eval() 是一个危险的函数， 它执行的代码拥有着执行者的权利。如果你用 eval() 运行的字符串代码被恶意方（不怀好意的人）操控修改，他可能会在你写的的网页/扩展程序的权限下，在用户计算机上运行恶意代码。

- 实现方式二:Function

核心：Function 与 eval 有相同的字符串参数特性。

```js
function parse(jsonStr){
	return new Function('return'+jsonStr)();
}
var jsonStr='{"age":20,"name":"jack"}';
parse(jsonStr);
```

eval 与 Function 都有着动态编译 js 代码的作用，但是在实际的编程中并不推荐使用

### 74实现一个打点计时器
```js
/* 
  1.从start至end,每隔100毫秒console.log一个数字，每次数字增幅为1
  2.返回的对象中需要包含一个cancel方法，用于停止定时操作
  3.第一个数字需要立即输出
*/
```

### 代码实现

#### 1.简单直接

```js
 const count = (start, end) => {
    console.log(start)
    let timer = setInterval(
        ()=>{
            if(start<end) console.log(start+=1);
        },100)
    return {cancel:()=>{clearInterval(timer)}}
}
const fn = count(1,100);
fn.cancel();
```

#### 2.完善一些

```js
function tapper (start, end) {
  if (start > end || Number.isNaN(Number(start)) || Number.isNaN(Number(end))) throw new Error('invalid input');
  const interval = 100;
  let isCancel = false;
  const init = async () => {
    console.info(start);
    start++;
    while (start <= end && !isCancel) {
      await new Promise((resolve) => {
        setTimeout(() => {
          if (!isCancel) {
            console.info(start);
            start++;
          }
          resolve();
        }, interval)
      })
    }
  };

  const cancel = () => {
    isCancel = true;
  };

  return {
    init,
    cancel
  }
}

const demo = tapper(1, 100);
demo.init();
setTimeout(() => {
  demo.cancel();
}, 2000);
```



### 75按要求完成代码
```js
const timeout = (ms) =>
  new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, ms);
  });
const ajax1 = () =>
  timeout(2000).then(() => {
    console.log("1");
    return 1;
  });
const ajax2 = () =>
  timeout(1000).then(() => {
    console.log("2");
    return 2;
  });
const ajax3 = () =>
  timeout(2000).then(() => {
    console.log("3");
    return 3;
  });
const mergePromise = (ajaxArray) => {
  // 1,2,3 done [1,2,3] 此处写代码 请写出ES6、ES3 2中解法
};
mergePromise([ajax1, ajax2, ajax3]).then((data) => {
  console.log("done");
  console.log(data); // data 为[1,2,3]
});
// 执行结果为：1 2 3 done [1,2,3]
```

### 代码实现

#### 1.实现方式一

```js
// es6 串行
const mergePromise = (ajaxArray) => {
  return (async function () {
      let ret = []
      let idx = 0
      let len = ajaxArray.length
      while(idx < len) {
          let data = await ajaxArray[idx]()
          ret.push(data)
          idx++
      }
      return ret
  })()
}

mergePromise([ajax1, ajax2, ajax3]).then(data => {
  console.log('done')
  console.log(data)
})
```

#### 2.实现方式二

```js
// 串行
const mergePromise = (ajaxArray) => {
  return new Promise((resolve, reject) => {
    let tem = []
    let promise = ajaxArray.map(ajax => () => ajax().then(data => tem.push(data)))
      .reduce((memo, cur) => {
        return () => {
          return memo().then(cur)
        }
      })
    promise().then(() => {
      resolve(tem)
    })
  })
}

mergePromise([ajax1, ajax2, ajax3]).then(data => {
  console.log('done')
  console.log(data)
})
```

#### 3.实现方式三

```js
const mergePromise = (ajaxArray) => {
  //串行
  return new Promise((resolve, reject) => {
      let len = ajaxArray.length
      let idx = 0
      let tem = []
      function next() {
          if (idx === len) return resolve(tem)
          ajaxArray[idx]().then((data) => {
              tem.push(data)
              idx++
              next()
          }).catch(reject)
      }
      next()
  })
}

mergePromise([ajax1, ajax2, ajax3]).then(data => {
  console.log('done')
  console.log(data)
})
```

#### 4.实现方式四

```js
function mergePromise(promiselist) {
  var result = []
  mergePromise.then = function (callback) {
    function fn(i) {
      // console.log(promiselist[i]())
      promiselist[i]().then((data) => {
        result.push(data)
        if (i !== promiselist.length - 1) {
          fn(++i)
        }
        if (result.length === promiselist.length) {
          callback(result)
        }
      })
    }
    fn(0)
  }
  return mergePromise
}
mergePromise([ajax1, ajax2, ajax3]).then((data) => {
  console.log('done')
  console.log(data) // data 为[1,2,3]
})
// 执行结果为：1 2 3 done [1,2,3]
```


### 76在一个 ul 里有 10 个 li,实现点击对应的 li,输出对应的下标

### 代码实现

#### 1.实现方式一

- 声明一个函数马上调用

```js
var oli = document.getElementsByTagName('li');
for (var i = 0; len = oli.length, i < len; i++) {
    oli[i].onclick = (function (n) {
    return function () {
        alert(n)
    }
    })(i)
}
```

#### 2.实现方式二

- 把下标i变成一个li的属性

```js
var oli = document.getElementsByTagName('li');
for (var i = 0; len = oli.length, i < len; i++) {
    oli[i].index = i;
    oli[i].onclick = function () {
    alert('你点击的列表的下标是：' + this.index); //列表下标从0开始  
    };
}
```

#### 3.实现方式三

- forEach

```js
var lis = document.getElementsByTagName('li');
lis = Array.prototype.slice.call(lis, 0);
lis.forEach(function (v, i) {
    v.onclick = function () {
    alert(i);
    }
})
```

#### 4.实现方式四

- let

```js
var oli = document.getElementsByTagName('li');
for (let i = 0; len = oli.length, i < len; i++) {
    console.log(oli[i]);
    oli[i].onclick = function () {
    alert(i)
    }
}
```



### 77请手动实现一个浅拷贝

### 代码实现

#### 1.Object.assign

ES6中拷贝对象的方法，接受的第一个参数是拷贝的目标target，剩下的参数是拷贝的源对象sources（可以是多个）

```js
let target = {};
let source = {a:'123',b:{name:'yd'}};
Object.assign(target ,source);
console.log(target);
// {a: "123", b: {name: "yd"}}

```

Object.assign注意事项

- 只拷贝源对象的自身属性（不拷贝继承属性）
- 不会拷贝对象不可枚举的属性
- undefined和null无法转成对象，它们不能作为Object.assign参数，但是可以作为源对象
- 属性名为Symbol 值的属性，可以被Object.assign拷贝。

#### 2.Array.prototype.slice

```js
let array = [{a: 1}, {b: 2}];
let array1 = array.slice(0);
console.log(array1);
```

- slice:从已有的数组中返回选定的元素

#### 3.Array.prototype.concat

```js
let array = [{a: 1}, {b: 2}];
let array1 = [].concat(array);
console.log(array1);
```

#### 4.扩展运算符

```js
let obj = {a:1,b:{c:1}}
let obj2 = {...obj};
console.log(obj2);
```

#### 5.自己实现一个

**1）实现原理**

新的对象复制已有对象中非对象属性的值和对象属性的引用,也就是说对象属性并不复制到内存。

```js
function cloneShallow(source) {
    var target = {};
    for (var key in source) {
        if (Object.prototype.hasOwnProperty.call(source, key)) {
            target[key] = source[key];
        }
    }
    return target;
}
```

**2）for in**

for...in语句以任意顺序遍历一个对象自有的、继承的、可枚举的、非Symbol的属性。对于每个不同的属性，语句都会被执行。

**3）hasOwnProperty**

该函数返回值为布尔值，所有继承了 Object 的对象都会继承到 hasOwnProperty 方法，和 in 运算符不同，该函数会忽略掉那些从原型链上继承到的属性和自身属性。



### 78编写一个 Person 类，并创建两个不同的 Person 对象

### 代码实现

#### 1.ES5实现

```js
function Person(name,age,gender){
    this.name = name;
    this.age = age;
    this.gender = gender
}
Person.prototype.run = function(){
    console.log(this.name + ' can run fast !')
}
let lilin = new Person('lilin',25,'women');
let lc = new Person('lc',25,'men');
console.log(lilin,lc);
lilin.run();
```

#### 2.ES6实现

```js
class Person{
    constructor(name,age,gender){
        this.name = name;
        this.age = age;
        this.gender = gender
    }
    run(){
        console.log(this.name + ' can run fast !')
    }
}
let lilin = new Person('lilin',25,'women');
let lc = new Person('lc',25,'men');
console.log(lilin,lc);
lilin.run();
```

### 79JavaScript 是什么范式语言

### 什么是范式

编程范型、编程范式或程序设计法（英语：Programming paradigm），（范即模范、典范之意，范式即模式、方法），是一类典型的编程风格，是指从事软件工程的一类典型的风格（可以对照方法学）。如：函数式编程、过程式编程、面向对象编程、指令式编程等等为不同的编程范型。

编程范型提供了（同时决定了）程序员对程序执行的看法。例如，在面向对象编程中，程序员认为程序是一系列相互作用的对象，而在函数式编程中一个程序会被看作是一个无状态的函数计算的序列。

### JavaScript

JavaScript® （通常简写为JS）是一种轻量的、解释性的、面向对象的头等函数语言，其最广为人知的应用是作为网页的脚本语言，但同时它也在很多非浏览器环境下使用。**JS是一种动态的基于原型和多范式的脚本语言，支持面向对象、命令式和函数式的编程风格。**

### 80JavaScript 为什么要区分微任务和宏任务

### 为什么要区分微任务和宏任务


区分微任务和宏任务是为了将异步队列任务划分优先级，通俗的理解就是为了插队。

一个Event Loop，Microtask 是在 Macrotask 之后调用，Microtask 会在下一个Event Loop 之前执行调用完，并且其中会将 Microtask 执行当中新注册的 Microtask 一并调用执行完，然后才开始下一次 Event loop，所以如果有新的 Macrotask 就需要一直等待，等到上一个 Event loop 当中 Microtask 被清空为止。由此可见， 我们可以在下一次 Event loop 之前进行插队。

如果不区分 Microtask 和 Macrotask，那就无法在下一次 Event loop 之前进行插队，其中新注册的任务得等到下一个 Macrotask 完成之后才能进行，这中间可能你需要的状态就无法在下一个 Macrotask 中得到同步。




### 81JavaScript 中如何模拟实现方法的重载

### 一、背景知识

JavaScript不支持重载的语法，它没有重载所需要的函数签名。
ECMAScript函数不能像传统意义上那样实现重载。而在其他语言（如 Java）中，可以为一个函数编写两个定义，只要这两个定义的签名（接受的参数的类型和数量）不同即可。如前所述，ECMAScirpt函数没有签名，因为其参数是由包含零或多个值的数组来表示的。而没有函数签名，真正的重载是不可能做到的。 — JavaScript高级程序设计（第3版）

### 二、什么是函数重载

重载函数是函数的一种特殊情况，为方便使用，允许在同一范围中声明几个功能类似的同名函数，但是这些同名函数的形式参数（指参数的个数、类型或者顺序）必须不同，也就是说用同一个函数完成不同的功能。这就是重载函数

### 三、模拟实现

#### 1.借助流程控制语句

通过判断传入参数的个数，执行相应的代码块。

```js
function toDo(){
  switch(arguments.length){
    case 0:
      /* 代码块0 */
      break;
    ...
    case n:
      /* 代码块n */
      break;
  }
}
```

#### 2.利用闭包特性

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





### 82除了 jsonp、postmessage 后端控制，怎么实现跨页面通讯

### 一、同源页面之间的通信

- BroadCast Channel
- Service Worker
- LocalStorage
- Shared Worker
- IndexedDB
- window.open + window.opener

### 二、非同源页面之间的通信

对于非同源页面，则可以通过嵌入同源 iframe 作为“桥”，将非同源页面通信转换为同源页面通信。

### 三、总结

- 广播模式：Broadcast Channe / Service Worker / LocalStorage + StorageEvent
- 共享存储模式：Shared Worker / IndexedDB / cookie
- 口口相传模式：window.open + window.opener
- 基于服务端：Websocket / Comet / SSE 等

### 83使用原型最大的好处

### 一、原型优缺点简单分析

1. 通过原型链继承的方式，原先存在父类型的实例中的所有属性和方法，现在也能存在于子类型的原型中了
2. 在通过原型链实现继承时，原型实际上会成为另一个类型的实例。所以父类的实例属性实际上会成为子类的原型属性。结果就是所有的子类的实例都会共享父类的实例属性（引用类型的）。
3. 在创建子类型的实例时，没有办法在不影响所有实例的情况下，向父类型的构造函数传递参数。

### 二、原型详细分析

#### 2.1 原型的好处

- javascript 采用原型编程，所有的对象都能共享原型上的方法，通过构造函数生成的实例所拥有的方法都指向一个函数的索引，这样可以节省内存，节省内存，如果不使用原型法就会造成每创建一个对象就会产生一个内存地址。
- 方便实现继承

#### 2.2 原型链

原型链是一种机制，指的是 JavaScript 每个对象都有一个内置的 **proto** 属性指向创建它的构造函数的 prototype（原型）属性。原型链的作用是为了实现对象的继承，要理解原型链，需要先从**函数对象、constructor、new、prototype、proto** 这五个概念入手


**2.2.1 函数对象**


在 JavaScript 里，函数即对象，程序可以随意操控它们。比如，可以把函数赋值给变量，或者作为参数传递给其他函数，也可以给它们设置属性，甚至调用它们的方法。下面示例代码对「普通对象」和「函数对象」进行了区分。

普通对象：

```js
var o1 = {};
var o2 = new Object();
```

函数对象：

```js
function f1(){};
var f2 = function(){};
var f3 = new Function('str','console.log(str)');
```

简单的说，凡是使用 function 关键字或 Function 构造函数创建的对象都是函数对象

**2.2.2 constructor 构造函数**

函数还有一种用法，就是把它作为构造函数使用。像 Object 和 Array 这样的原生构造函数，在运行时会自动出现在执行环境中。此外，也可以创建自定义的构造函数，从而自定义对象类型的属性和方法。如下代码所示：

```js
function Person(name, age, job){
    this.name = name;
    this.age = age;
    this.job = job;
    this.sayName = function(){
        console.log(this.name);
    };
}

var person1 = new Person("alice", 28, "Software Engineer");
var person2 = new Person("Sophie", 29, "English Teacher");
```

在这个例子中，我们创建了一个自定义构造函数 Person()，并通过该构造函数创建了两个普通对象 person1 和 person2，这两个普通对象均包含3个属性和1个方法。

你应该注意到函数名 Person 使用的是大写字母 P。按照惯例，构造函数始终都应该以一个大写字母开头，而非构造函数则应该以一个小写字母开头。这个做法借鉴自其他面向对象语言，主要是为了区别于 JavaScript 中的其他函数；因为构造函数本身也是函数，只不过可以用来创建对象而已。

**2.2.3new操作符**

要创建 Person 的新实例，必须使用 new 操作符。以这种方式调用构造函数实际上会经历以下4个步骤：

- 创建一个新对象；
- 将构造函数的作用域赋给新对象（因此 this 就指向了这个新对象）；
- 执行构造函数中的代码（为这个新对象添加属性）；
- 返回新对象 (return)

将构造函数当作函数

构造函数与其他函数的唯一区别，就在于调用它们的方式不同。不过，构造函数毕竟也是函数，不存在定义构造函数的特殊语法。任何函数，只要通过 new 操作符来调用，那它就可以作为构造函数；而任何函数，如果不通过 new 操作符来调用，那它跟普通函数也不会有什么两样。例如，前面例子中定义的 Person() 函数可以通过下列任何一种方式来调用。

```js
// 当作构造函数使用
var person = new Person("alice", 28, "Software Engineer");
person.sayName(); // "alice"

// 作为普通函数调用
Person("Sophie", 29, "English Teacher"); // 添加到 window
window.sayName(); // "Sophie"

// 在另一个对象的作用域中调用
var o = new Object();
Person.call(o, "Tommy", 3, "Baby");
o.sayName(); // "Tommy"
```

这个例子中的前两行代码展示了构造函数的典型用法，即使用 new 操作符来创建一个新对象。接下来的两行代码展示了不使用 new 操作符调用 Person() 会出现什么结果，属性和方法都被添加给 window 对象了。当在全局作用域中调用一个函数时，this 对象总是指向 Global 对象（在浏览器中就是 window 对象）。因此，在调用完函数之后，可以通过 window 对象来调用 sayName() 方法，并且还返回了 "Sophie" 。最后，也可以使用 call()（或者 apply()）在某个特殊对象的作用域中调用 Person() 函数。这里是在对象 o 的作用域中调用的，因此调用后 o 就拥有了所有属性和 sayName() 方法。


**2.2.4构造函数的问题**

构造函数模式虽然好用，但也并非没有缺点。使用构造函数的主要问题，就是每个方法都要在每个实例上重新创建一遍。在前面的例子中，person1 和 person2 都有一个名为 sayName() 的方法，但那两个方法不是同一个 Function 的实例。因为 JavaScript

```js
function Person(name, age, job){
   this.name = name;
   this.age = age;
   this.job = job;
   this.sayName = new Function("console.log(this.name)"); // 与声明函数在逻辑上是等价的
}
```

从这个角度上来看构造函数，更容易明白每个 Person 实例都包含一个不同的 Function 实例（sayName() 方法）。说得明白些，以这种方式创建函数，虽然创建 Function 新实例的机制仍然是相同的，但是不同实例上的同名函数是不相等的，以下代码可以证明这一点。

```js
console.log(person1.sayName == person2.sayName);  // false
```

然而，创建两个完成同样任务的 Function 实例的确没有必要；况且有 this 对象在，根本不用在执行代码前就把函数绑定到特定对象上面。因此，大可像下面这样，通过把函数定义转移到构造函数外部来解决这个问题。

```js
function Person(name, age, job){
   this.name = name;
   this.age = age;
   this.job = job;
   this.sayName = sayName;
}

function sayName(){
   console.log(this.name);
}

var person1 = new Person("alice", 28, "Software Engineer");
var person2 = new Person("Sophie", 29, "English Teacher")
```

在这个例子中，我们把 sayName() 函数的定义转移到了构造函数外部。而在构造函数内部，我们将 sayName 属性设置成等于全局的 sayName 函数。这样一来，由于 sayName 包含的是一个指向函数的指针，因此 person1 和 person2 对象就共享了在全局作用域中定义的同一个 sayName() 函数。这样做确实解决了两个函数做同一件事的问题，可是新问题又来了，在全局作用域中定义的函数实际上只能被某个对象调用，这让全局作用域有点名不副实。而更让人无法接受的是，如果对象需要定义很多方法，那么就要定义很多个全局函数，于是我们这个自定义的引用类型就丝毫没有封装性可言了。好在，这些问题可以通过使用原型来解决。


**2.2.5 prototype 原型**

我们创建的每个函数都有一个 prototype（原型）属性。使用原型的好处是可以让所有对象实例共享它所包含的属性和方法。换句话说，不必在构造函数中定义对象实例的信息，而是可以将这些信息直接添加到原型中，如下面的例子所示。

```js
   function Person(){}

   Person.prototype.name = "alice";
   Person.prototype.age = 28;
   Person.prototype.job = "Software Engineer";
   Person.prototype.sayName = function(){
       console.log(this.name);
   };

   var person1 = new Person();
   person1.sayName();   // "alice"

   var person2 = new Person();
   person2.sayName();   // "alice"

   console.log(person1.sayName == person2.sayName);  // true
```

在此，我们将 sayName() 方法和所有属性直接添加到了 Person 的 prototype 属性中，构造函数变成了空函数。即使如此，也仍然可以通过调用构造函数来创建新对象，而且新对象还会具有相同的属性和方法。但与前面的例子不同的是，新对象的这些属性和方法是由所有实例共享的。换句话说，person1 和 person2 访问的都是同一组属性和同一个 sayName() 函数。


**理解原型对象**,在默认情况下，所有原型对象都会自动获得一个 constructor（构造函数）属性，这个属性包含一个指向 prototype 属性所在函数的指针。就拿前面的例子来说，Person.prototype.constructor 指向 Person。而通过这个构造函数，我们还可继续为原型对象添加其他属性和方法。只有对象方法才会有prototype.

虽然可以通过对象实例访问保存在原型中的值，但却不能通过对象实例重写原型中的值。如果我们在实例中添加了一个属性，而该属性与实例原型中的一个属性同名，那我们就在实例中创建该属性，该属性将会屏蔽原型中的那个属性。

**更简单的原型语法**，前面例子中每添加一个属性和方法就要敲一遍 Person.prototype。为减少不必要的输入，也为了从视觉上更好地封装原型的功能，更常见的做法是用一个包含所有属性和方法的对象字面量来重写整个原型对象，如下面的例子所示。


```js
function Person(){}

Person.prototype = {
    name : "alice",
    age : 28,
    job: "Software Engineer",
    sayName : function () {
        console.log(this.name);
    }
};
```

在上面的代码中，我们将 Person.prototype 设置为等于一个以对象字面量形式创建的新对象。最终结果相同，但有一个例外：constructor 属性不再指向 Person 了。前面曾经介绍过，每创建一个函数，就会同时创建它的 prototype 对象，这个对象也会自动获得 constructor 属性。而我们在这里使用的语法，本质上完全重写了默认的 prototype 对象，因此 constructor 属性也就变成了新对象的 constructor 属性（指向 Object 构造函数），不再指向 Person 函数。此时，尽管 instanceof 操作符还能返回正确的结果，但通过 constructor 已经无法确定对象的类型了，如下所示

```js
var friend = new Person();

console.log(friend instanceof Object);        // true
console.log(friend instanceof Person);        // true
console.log(friend.constructor === Person);    // false
console.log(friend.constructor === Object);    // true
```

在此，用 instanceof 操作符测试 Object 和 Person 仍然返回 true，但 constructor 属性则等于 Object 而不等于 Person 了。如果 constructor 的值真的很重要。需要重新指定一下constructor的指向


#### 2.3 原型的动态性

由于在原型中查找值的过程是一次搜索，因此我们对原型对象所做的任何修改都能够立即从实例上反映出来，即使是先创建了实例后修改原型也照样如此。请看下面的例子。

```js
var friend = new Person();

Person.prototype.sayHi = function(){
    console.log("hi");
};

friend.sayHi();   // "hi"（没有问题！）
```

以上代码先创建了 Person 的一个实例，并将其保存在 person 中。然后，下一条语句在 Person.prototype 中添加了一个方法 sayHi()。即使 person 实例是在添加新方法之前创建的，但它仍然可以访问这个新方法。其原因可以归结为实例与原型之间的松散连接关系。当我们调用 person.sayHi() 时，首先会在实例中搜索名为 sayHi 的属性，在没找到的情况下，会继续搜索原型。因为实例与原型之间的连接只不过是一个指针，而非一个副本，因此就可以在原型中找到新的 sayHi 属性并返回保存在那里的函数。

尽管可以随时为原型添加属性和方法，并且修改能够立即在所有对象实例中反映出来，但如果是重写整个原型对象，那么情况就不一样了。我们知道，调用构造函数时会为实例添加一个指向最初原型的 [[Prototype]] 指针，而把原型修改为另外一个对象就等于切断了构造函数与最初原型之间的联系。请记住：实例中的指针仅指向原型，而不指向构造函数。看下面的例子。

```js
function Person(){}

var friend = new Person();

Person.prototype = {
    constructor: Person,
    name : "alice",
    age : 28,
    job : "Software Engineer",
    sayName : function () {
        console.log(this.name);
    }
};

friend.sayName();   // Uncaught TypeError: friend.sayName is not a function
```

在这个例子中，我们先创建了 Person 的一个实例，然后又重写了其原型对象。然后在调用 friend.sayName() 时发生了错误，因为 friend 指向的是重写前的原型对象，其中并不包含以该名字命名的属性


#### 2.4 原型对象的问题

原型模式也不是没有缺点。首先，它省略了为构造函数传递初始化参数这一环节，结果所有实例在默认情况下都将取得相同的属性值。虽然这会在某种程度上带来一些不方便，但还不是原型的最大问题。原型模式的最大问题是由其共享的本性所导致的。

原型中所有属性是被很多实例共享的，这种共享对于函数非常合适。对于那些包含基本值的属性倒也说得过去，毕竟（如前面的例子所示），通过在实例上添加一个同名属性，可以隐藏原型中的对应属性。然而，对于包含引用类型值的属性来说，问题就比较突出了。来看下面的例子。


```js
function Person(){}

Person.prototype = {
    constructor: Person,
    name : "alice",
    age : 28,
    job : "Software Engineer",
    friends : ["ZhangSan", "LiSi"],
    sayName : function () {
        console.log(this.name);
    }
};

var person1 = new Person();
var person2 = new Person();

person1.friends.push("WangWu");

console.log(person1.friends);    // "ZhangSan,LiSi,WangWu"
console.log(person2.friends);    // "ZhangSan,LiSi,WangWu"
console.log(person1.friends === person2.friends);  // true
```

在此，Person.prototype 对象有一个名为 friends 的属性，该属性包含一个字符串数组。然后，创建了 Person 的两个实例。接着，修改了 person1.friends 引用的数组，向数组中添加了一个字符串。由于 friends 数组存在于 Person.prototype 而非 person1 中，所以刚刚提到的修改也会通过 person2.friends（与 person1.friends 指向同一个数组）反映出来。假如我们的初衷就是像这样在所有实例中共享一个数组，那么对这个结果我没有话可说。可是，实例一般都是要有属于自己的全部属性的。

#### 2.5构造函数和原型结合(寄生组合继承)

```js
function inheritPrototype(subType,superType){
  var prototype = Object.create(superType.prototype);
  prototype.constructor = subType;
  subType.prototype = prototype;
}

function A(name) {
  this.name = name;
}

A.prototype.getName = function () {
  console.log(this.name)
}

function B(name, age) {
  A.call(this, name);
  this.age = age;
  this.firends = ['前端', '资深'];
}

inheritPrototype(B,A)
B.prototype.getFirends = function () {
  console.log(this.firends);
}


const instance1 = new B('jingcheng', 3);
instance1.getName(); // jingcheng
instance1.firends.push('React');
console.log(instance1.firends);  //['前端', '资深','React']
const instance2 = new B('yideng', 4);
instance2.getName(); // yideng
console.log(instance2.firends); // ['前端', '资深']

console.log(instance1, instance2)
```

在这个例子中，实例属性都是在构造函数中定义的，在子类继承父类的时候，将子类的prototype.constructor指向自己，子类再将自己的prototype指向父级的prototype。方法getName是在原型上定义的,。而修改了 instance1.friends（向其中添加一个新字符串），并不会影响到 instance1.friends，因为它们分别引用了不同的数组。

这种构造函数与原型混成的模式，是目前在 JavaScript 中使用最广泛、认同度最高的一种创建自定义类型的方法。可以说，这是用来定义引用类型的一种默认模式。


#### 2.6 原型链

JavaScript 中描述了原型链的概念，并将原型链作为实现继承的主要方法。其基本思想是利用原型让一个引用类型继承另一个引用类型的属性和方法。简单回顾一下构造函数、原型和实例的关系：每个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型对象的内部指针。

### 84对作用域和闭包的理解，解释下 let 和 const 的块级作用域

### 一、作用域

作用域是什么呢？它指的是你的变量和函数运行到某个地方的代码处能否被访问到。

为什么需要作用域呢？为什么要限制变量的访问性而非全部暴露到公共域下呢？

这是计算机科学中最基本的概念和理念：隔离性（The Principle of Least Access）。为了职责明确，你只能刚好访问到你需要的所有东西，不多也不少。附带地，它带来了模块化、命名空间等好处，让你写出更易阅读、更易维护的代码。可以说，作用域是许多现代编程语言都从语言层面支持的一个特性。

我们可以这样理解：作用域就是一个独立的地盘，让变量不会外泄、暴露出去。也就是说作用域最大的用处就是隔离变量，不同作用域下同名变量不会有冲突。


### 二、闭包

一个函数返回一个函数的引用，就形成了一个闭包。

**闭包:** 当函数能记住并访问所在词法作用域，即使函数在词法作用域范围之外，此时就产生了闭包。

闭包就是能够读取其他函数内部变量的函数。由于在Javascript语言中，只有函数内部的子函数才能读取局部变量，因此可以把闭包简单理解成"定义在一个函数内部的函数"。所以，在本质上，闭包就是将函数内部和函数外部连接起来的一座桥梁。

从实现上讲，闭包是一条记录，它存储了一个函数与其环境的上下文信息。这个上下文主要记录了：函数的每个自由变量（在内层函数使用，但在外层函数处被定义的变量）与其被绑定的值或引用之间的关联,主要是用来实现信息封装。

### 三、Let块级作用域

let定义的变量，只能在块作用域里访问，不能跨块访问，也不能跨函数访问，无变量提升，不可以重复声明。

#### 1.let 声明的变量只在块级作用域内有效

```js
'use strict';
function func(args){
    if(true){
        let i = 6;
        console.log('inside: ' + i);  //不报错
    }
    console.log('outside: ' + i);  // 报错 "i is not defined"
};
func();
```

#### 2.不存在变量提升，而是“绑定”在暂时性死区

```js
// 不存在变量提升
'use strict';
function func(){
    console.log(i);
    let i;
};
func(); // 报错
```

在let声明变量前，使用该变量，它是会报错的，而不是像var那样会‘变量提升’。 其实说let没有‘变量提升’的特性，不太对。或者说它提升了，但是ES6规定了在let声明变量前不能使用该变量。

```js
'use strict';
var test = 1;
function func(){
    console.log(test);
    let test = 2;
};
func();  // 报错
```

如果let声明的变量没有变量提升，应该打印’1’（func函数外的test）；而它却报错，说明它是提升了的，只是规定了不能在其声明之前使用而已。我们称这特性叫“暂时性死区（temporal dead zone）”。且这一特性，仅对遵循‘块级作用域’的命令有效（let、const）。

### 四、Const

const用来定义常量，使用时必须初始化(即必须赋值)，只能在块作用域里访问，而且不能修改，无变量提升，不可以重复声明。

const 与 let 的使用规范一样，与之不同的是：const 声明的是一个常量，且这个常量必须赋值，否则会报错。

**注意:** const常量，指的是常量对应的内存地址不得改变，而不是对应的值不得改变，所有把应用类型的数据设置为常量，其内部的值是可以改变的，例如：const a={}; a.b=13;//不会报错 const arr=[]; arr.push(123);//不会报错

```js
'use strict';
function func(){
    const PI;
    PI = 3.14;
    console.log(PI);
};
func(); // 报错“Missing initializer in const declaration”
```



### 85介绍宏任务和微任务

### 一、任务机制

介绍宏任务微任务之前需要先了解任务执行机制。

JavaScript是单线程语言。JavaScript任务需要排队顺序执行，如果一个任务耗时过长，后边一个任务也的等着，但是，假如我们需要浏览新闻，但新闻包含的超清图片加载很慢，总不能网页一直卡着直到图片完全出来，所以将任务设计成了两类：**同步任务** 和 **异步任务**

![任务机制](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-536-task.png)

同步和异步任务分别进入不同的执行“场所”，同步进入主线程，异步进入Event Table并注册函数。当指定的额事情完成时，Event Table 会将这个函数移入Event Queue。主线程内的任务执行完毕，会去Event Queue读取对应的函数，进入主线程。

上述过程会不断重复，也就是常说的Event Loop（事件循环）。

### 二、异步任务中的宏任务微任务

![task](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-536-async.png)

#### 1.微任务 （microtask）

当前（此次事件循环中）宏任务执行完，在下一个宏任务开始之前需要执行的任务,可以理解为回调事件。

宏任务中的事件放在callback queue中，由事件触发线程维护；微任务的事件放在微任务队列中，由js引擎线程维护。

- Promise
- Object.observe(已经废弃)
- MutationObserver
- process.nextTick(nodejs)


#### 2.宏任务（macrotask）

当前调用栈中执行的代码成为宏任务。

- 主代码块
- setTimeout
- setInterval
- I/O（ajax）
- UI rendering
- setImmediate(nodejs) 
- 可以看到，事件队列中的每一个事件都是一个 macrotask，现在称之为宏任务队列

### 86如何处理异常捕获

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

### 87介绍 JS 全部数据类型，基本数据类型和引用数据类型的区别

### 一、JavaScript全部数据类型

#### 1.内置类型

1. **空值** null
2. **未定义** undefined
3. **布尔值** boolean
4. **数字** Number
5. **字符串** String
6. **对象** Object
7. **符号** symbol
8. **长整型** BigInt

#### 1.基本数据类型

undefined,null,number,boolean,string,symbol。

基本数据类型是按值访问的，就是说我们可以操作保存在变量中的实际的值。

1. 基本数据类型的值是不可变的
2. 基本数据类型不可以添加属性和方法
3. 基本数据类型的赋值是简单赋值
4. 基本数据类型的比较是值的比较
5. 基本数据类型是存放在栈区的

#### 2.引用类型

JavaScript中除了上面的基本类型之外就是引用类型了，也可以说就是对象了，比如：Object,Array,Function,Data等

1. 引用类型的值是可以改变的
2. 引用类型可以添加属性和方法
3. 引用类型的赋值是对象引用
4. 引用类型的比较是引用的比较
5. 引用类型是同时存在栈区和堆区的

### 二、基本数据类型和引用数据类型的区别

#### 1.声明变量时不同的内存分配

**原始值:** 存储在栈（stack）中的简单数据段，也就是说，它们的值直接存储在变量访问的位置。这是因为这些原始类型占据的空间是固定的，所以可将他们存储在较小的内存区域 – 栈中。这样存储便于迅速查寻变量的值。

**引用值:** 存储在堆（heap）中的对象，也就是说，存储在变量处的值是一个指针（point），指向存储对象的内存地址。这是因为：引用值的大小会改变，所以不能把它放在栈中，否则会降低变量查寻的速度。相反，放在变量的栈空间中的值是该对象存储在堆中的地址。地址的大小是固定的，所以把它存储在栈中对变量性能无任何负面影响。    

#### 2.不同的内存分配机制也带来了不同的访问机制

在javascript中是不允许直接访问保存在堆内存中的对象的，所以在访问一个对象时,首先得到的是这个对象在堆内存中的地址，然后再按照这个地址去获得这个对象中的值，这就是传说中的按引用访问。
     
而原始类型的值则是可以直接访问到的。      

#### 3.复制变量时的不同

**原始值:** 在将一个保存着原始值的变量复制给另一个变量时，会将原始值的副本赋值给新变量，此后这两个变量是完全独立的，他们只是拥有相同的value而已。   

**引用值:** 在将一个保存着对象内存地址的变量复制给另一个变量时，会把这个内存地址赋值给新变量，也就是说这两个变量都指向了堆内存中的同一个对象，他们中任何一个作出的改变都会反映在另一个身上。（这里要理解的一点就是，复制对象时并不会在堆内存中新生成一个一模一样的对象，只是多了一个保存指向这个对象指针的变量罢了）。多了一个指针

#### 4.参数传递的不同（把实参复制给形参的过程）

首先我们应该明确一点：ECMAScript中所有函数的参数都是按值来传递的。   

但是为什么涉及到原始类型与引用类型的值时仍然有区别呢？还不就是因为内存分配时的差别。 
  
**原始值:** 只是把变量里的值传递给参数，之后参数和这个变量互不影响。   

**引用值:** 对象变量它里面的值是这个对象在堆内存中的内存地址，这一点你要时刻铭记在心！因此它传递的值也就是这个内存地址，这也就是为什么函数内部对这个参数的修改会体现在外部的原因了，因为它们都指向同一个对象。

### 88if([] == 0), [1,2] == "1,2", if([]), [] == 0 具体是怎么对比的

### 一、 `if`判断原理

`if`判断原理是和`Boolean()`这个函数有关的，所以`if(***)`中`***`的判断结果取决于`Boolean(***)`的结果，那么`Boolean()`函数判断的规则是什么呢？

Boolean()函数判断规则

- 数字类型：NaN、0结果为false，其他情况为true
- 字符串类型：空字符串为false，其他情况为true
- Boolean类型：false为false，true为true
- 对象类型：undefined、null为false，其他情况为true

### 二、 宽松相等(==)比较时的隐士转换规则

宽松相等（==）和严格相等（===）的区别在于宽松相等会在比较中进行隐式转换。

1）布尔类型和其他类型的相等比较，只要布尔类型参与比较，该布尔类型的值首先会被转换为数字类型

2）数字类型和字符串类型的相等比较，当数字类型和字符串类型做相等比较时，字符串类型会被转换为数字类型

3）当对象类型和原始类型做相等比较时，对象类型会依照ToPrimitive规则转换为原始类型

4）当两个操作数都是对象时，JavaScript会比较其内部引用，当且仅当他们的引用指向内存中的相同对象（区域）时才相等，即他们在栈内存中的引用地址相同。

5）ECMAScript规范中规定null和undefined之间互相宽松相等（==），并且也与其自身相等，但和其他所有的值都不宽松相等（==）

### 三、字符串析构赋值原理

> let [a, b, c, d] = 'abcd'

```
function _slicedToArray(arr, i) {
return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest(); }

function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance"); }

function _iterableToArrayLimit(arr, i) {
var _arr = [];
var _n = true;
var _d = false;
var _e = undefined;
try
{
for (var _i = arrSymbol.iterator, _s; !(_n = (_s = _i.next()).done); _n = true)
{ _arr.push(_s.value); if (i && _arr.length === i) break; }
}
catch (err) { _d = true; _e = err; }
finally {
try { if (!_n && _i["return"] != null) _i"return"; }
finally { if (_d) throw _e; } } return _arr; }

function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }

var _abcd = "abcd",
_abcd2 = _slicedToArray(_abcd, 4),
a = _abcd2[0],
b = _abcd2[1],
c = _abcd2[2],
d = _abcd2[3];
```

### 四、答案解析

```js
// if([]==0)
1. Boolean(Number([])==0)
2. Boolean(0==0)

// [1,2]=="1,2"
1. 1=="1"&&2=="2"
2. true&&true

// if([])
1. Boolean([])
2. Boolean(true)  // []是一个复杂类型存在地址引用，转化为Boolean值为true

// []==0
1. Number([])==0
2. 0==0
3. true
```

### 五、知识点

**ToString、ToNumber、ToBoolean、ToPrimitive转换规则：**

#### 5.1 ToString

这里所说的ToString可不是对象的toString方法，而是指其他类型的值转换为字符串类型的操作。

看下null、undefined、布尔型、数字、数组、普通对象转换为字符串的规则：

- ①null：转为"null"
- ②undefined：转为"undefined"
- ③布尔类型：true和false分别被转为"true"和"false"
- ④数字类型：转为数字的字符串形式，如10转为"10"， 1e21转为"1e+21"
- ⑤数组：转为字符串是将所有元素按照","连接起来，相当于调用数组的Array.prototype.join()方法，如[1, 2, 3]转为"1,2,3"，空数组[]转为空字符串，数组中的null或undefined，会被当做空字符串处理
- ⑥普通对象：转为字符串相当于直接使用Object.prototype.toString()，返回"[object Object]"

#### 5.2 ToNumber

ToNumber指其他类型转换为数字类型的操作。

- ①null： 转为0
- ②undefined：转为NaN
- ③字符串：如果是纯数字形式，则转为对应的数字，空字符转为0, 否则一律按转换失败处理，转为NaN
- ④布尔型：true和false被转为1和0
- ⑤数组：数组首先会被转为原始类型，也就是ToPrimitive，然后在根据转换后的原始类型按照上面的规则处理，
- ⑥对象：同数组的处理

#### 5.3 ToBoolean

ToBoolean指其他类型转换为布尔类型的操作

js中的假值只有false、null、undefined、空字符、0和NaN，其它值转为布尔型都为true。

#### 5.4 ToPrimitive

ToPrimitive指对象类型类型（如：对象、数组）转换为原始类型的操作。

- ①当对象类型需要被转为原始类型时，它会先查找对象的valueOf方法，如果valueOf方法返回原始类型的值，则ToPrimitive的结果就是这个值
- ②如果valueOf不存在或者valueOf方法返回的不是原始类型的值，就会尝试调用对象的toString方法，也就是会遵循对象的ToString规则，然后使用toString的返回值作为ToPrimitive的结果。如果valueOf和toString都没有返回原始类型的值，则会抛出异常。
- ③注意：对于不同类型的对象来说，ToPrimitive的规则有所不同，比如Date对象会先调用toString，a.Number([])， 空数组会先调用valueOf，但返回的是数组本身，不是原始类型，所以会继续调用toString，得到空字符串，相当于Number('')，所以转换后的结果为"0",Number(['10'])相当于Number('10')，得到结果10




### 89setInterval 需要注意的点

### setInterval

```js
var intervalID = scope.setInterval(func, delay, [arg1, arg2, ...]);
var intervalID = scope.setInterval(code, delay);
```

- `func`:要重复调用的函数。`A function to be executed every delay milliseconds. The function is not passed any arguments, and no return value is expected.`
- `code`:这个语法是可选的，你可以传递一个字符串来代替一个函数对象，传递的字符串会被编译然后每个`delay`毫秒时间内执行一次。（不被推荐）
- `delay`:每次延迟的毫秒数(一秒等于1000毫秒)，函数的每次调用会在该延迟之后发生，和setTimeout一样，**实际的延迟时间可能会长一点**。这个时间计算单位是毫秒（千分之一秒。）如果这个参数值小于10，则默认使用值为10。

#### 1.返回值

intervalID为非0数值，用来标识通过`setInterval`创建的计时器，这个值可以用来作为`clearInterval`的参数来清楚对应值

#### 2.注意点

1. `setInterval`和`setTimeout`共享一个ID池
2. `setInterval`需要及时清除，防止内存泄漏
3. 参数`code`传入的值为函数:`setInterval('app()',200)`
4. setInterval可能不是精确的

详细介绍下

**1）被忽略的参数**

setInterval 和 setTimeout 一样，参数为任意参数，第一个是回调。第二个是时间戳，从第三个参数开始，参数会被作为第一个参数（也就是回调函数）的形参使用，类似于闭包传值，当然，从第三个参数开始以及后面的参数，我们可以理解为 rest 表达式（及...args）,下面的这段代码，足以说明一切

```js
function sum(x,y,z){
  console.log(x+y+z);
}
setTimeout(sum,1000,1,2,3);
```

**2）setInterval 为什么容易造成内存泄漏**

什么是内存泄漏：通俗一些，就是我们创建的变量或者定义的对象，用完或者没用之后，未能被 GC，导致系统内有新的内存可以分配给后面的变量，导致内存泄漏

比如一般我们实现一个简单的计时器，我们会想到 setInterval，如果我们不停的改变 dom，而且内部引用变量庞大，很容易造成内存泄漏，当然，甚至还有更气人的开发者，还是以计时器为例，点击 dom 开始计时，而没有做任何的限制，用户多点几下，setInterval 被多次创建等等问题

总结:setInterval 并不会造成内存泄漏，是使用者的滥用，导致现在只要看到 setInterval 等就会觉得心烦

**3）回收 setInterval**

```js
const timer = setInterval(()=>{console.log('i am here')},500);
clearInterval(timer);
```

看上面这段代码，我们在使用 clearInterval 或 clearTimeout 清除了 setInterval 之后，timer会被GC掉吗，答案是不会，因为clearInterval 或 clearTimeout只能清除对应id的setInterval(或setTimeout)，清除之后timer会被赋值为id，所以不会被GC，当然，我们可以手动赋值为null,等待回收

**4）this指向的问题**

来看一个易错的例子，下面用setTimeout来看

```js
var i = 0;
const o = {
    i: 1;
    fn: function(){
        console.log(this.i);
    }
}
setTimeout(o.fn, 1000); //0
```

答案为什么是0，fn不是对象o的吗，确实是o的，但是我们setTimeout是在全局环境(window EC)下的，其实相当于：

```js
var a = o.fn;
a();
```

### 90介绍 defineProperty 方法，什么时候需要用到

### Object.defineProperty

`Object.defineProperty()` 方法会直接在一个对象上定义一个新属性，或者修改一个对象的现有属性，并返回此对象。

- 通过定义或修改属性描述符来控制属性的访问
- 通过 getter/setter 对属性进行劫持，比如 VUE 的响应式

#### 1.1语法

`Object.defineProperty(obj, prop, descriptor)`

参数说明：

- obj:要定义属性的对象
- prop:要定义或修改的属性的名称或 Symbol 。
- descriptor:要定义或修改的属性描述符

返回值：

- 被传递给函数的对象

针对属性，我们可以给这个属性设置一些特性，比如是否只读不可以写；是否可以被for..in或Object.keys()遍历。

给对象的属性添加特性描述，目前提供两种形式：数据描述和存取器描述。

#### 1.2数据描述

当修改或定义对象的某个属性的时候，可以给这个属性添加一些特性：

```js
var obj = {
    test:"hello"
}
//对象已有的属性添加特性描述
Object.defineProperty(obj,"test",{
    configurable:true | false,
    enumerable:true | false,
    value:任意类型的值,
    writable:true | false
});
//对象新添加的属性的特性描述
Object.defineProperty(obj,"newKey",{
    configurable:true | false,
    enumerable:true | false,
    value:任意类型的值,
    writable:true | false
});
```
- **value** :可以是任意类型的值，默认是undefined
- **writeable** : 属性值是否可以被重写。设置为true可以被重写，设置为false,不能被重写。默认为false。
- **enumerable** : 此属性是否可以被枚举（使用for...in或Object.keys()）。设置为true可以被枚举；设置为false，不能被枚举。默认为false。
- **configurable** : 是否可以删除目标属性或是否可以再次修改属性的特性（writable, configurable, enumerable）。设置为true可以被删除或可以重新设置特性；设置为false，不能被可以被删除或不可以重新设置特性。默认为false。

除了可以给新定义的属性设置特性，也可以给已有的属性设置特性

> 提示：一旦使用Object.defineProperty给对象添加属性，那么如果不设置属性的特性，那么configurable、enumerable、writable这些值都为默认的false

#### 1.3 存储器描述

当使用存取器描述属性的特性的时候，允许设置以下特性属性：

```js
var obj = {};
Object.defineProperty(obj,"newKey",{
    get:function (){} | undefined,
    set:function (value){} | undefined
    configurable: true | false
    enumerable: true | false
});
```

> 注意：当使用了getter或setter方法，不允许使用writable和value这两个属性

**getter/setter**

当设置或获取对象的某个属性的值的时候，可以提供getter/setter方法。

- getter 是一种获得属性值的方法
- setter是一种设置属性值的方法。

```js
var obj = {};
var initValue = 'hello';
Object.defineProperty(obj,"newKey",{
    get:function (){
        //当获取值的时候触发的函数
        return initValue;    
    },
    set:function (value){
        //当设置值的时候触发的函数,设置的新值通过参数value拿到
        initValue = value;
    }
});
//获取值
console.log( obj.newKey );  //hello

//设置值
obj.newKey = 'change value';

console.log( obj.newKey ); //change value
```

> 注意：get或set不是必须成对出现，任写其一就可以。如果不设置方法，则get和set的默认值为undefined

#### 1.4 局限性

**检测不到对象属性的添加、删除**

```js
var data = {_obj:{}}
obj.defineProperty(obj,"obj",{
    get:function(){
        return this._data;
    },
    set:function(newValue){
        console.log("变化了")
    }
})
data.obj.name = "张三";//监测不到
```

**检测不到数组长度的变化，检测不到给数组的某一项赋值**

```js
var arr = [1,2,3,5];
arr.length = 0;//监测不到
arr[0] = 10;//监测不到
```

#### 1.5 使用场景

**1.5.1MVVM中数据的双向绑定**

如vue等大部分mvvm框架(angular 用的脏处理)都是通过Object.defineProperty来实现数据绑定的。

**1.5.2优化对象获取和修改属性的方式**

比如，过去设置dom节点transform时是这样的

```js
//加入有一个目标节点， 我们想设置其位移时是这样的
var targetDom = document.getElementById('target');
var transformText = 'translateX(' + 10 + 'px)';
targetDom.style.webkitTransform = transformText;
targetDom.style.transform = transformText;
```

向上面这种写法，当页面中有很多动画时，这样写是非常痛苦的。

通过Object.defineProperty的方式

```js
//这里只是简单设置下translateX的属性，其他如scale等属性可自己去尝试

Object.defineProperty(dom, 'translateX', {
set: function(value) {
         var transformText = 'translateX(' + value + 'px)';
        dom.style.webkitTransform = transformText;
        dom.style.transform = transformText;
}
//这样再后面调用的时候, 十分简单
dom.translateX = 10;
dom.translateX = -10;
//甚至可以拓展设置如scale, originX, translateZ,等各个属性，达到下面的效果
dom.scale = 1.5;  //放大1.5倍
dom.originX = 5;  //设置中心点X
}
```

这样是不是就会好很多了。

### 91JavaScript 执行过程分为哪些阶段

### JavaScript 执行过程

JavaScript 执行分两个阶段：**解析阶段、运行阶段**
- 解析阶段分为：词法分析、语法分析
- 运行阶段分为：预解析、运行。

**词法分析:** 将代码中的字符串分割为有意义的代码块（token），这些代码块可称之为“词法单元”。如 `var a = 1` 会被分为 var、a、=、1，这些零散的单元会组成一个词法单元流进行解析。

**语法分析:** 将词法单元流转换成一颗抽象语法树（AST）。

**预解析:** 在 JS 代码在正式执行之前，会进行一些解析工作。如寻找 var 声明的变量和 function声明的函数，找到后进行提升，但是在变量提升时不会赋值，因此它的默认值是 undefined。通过提升，函数可以在声明函数体之上进行调用，变量也可以在赋值之前进行输出，只是这时输出的值为 undefined。

### 92介绍 instanceof 原理，并手动实现

### instanceof

instanceof 主要用于判断某个实例是否属于某个类型，也可用于判断某个实例是否是其父类型或者祖先类型的实例。

instanceof 主要的实现原理就是只要右边变量的 prototype 在左边变量的原型链上即可。因此，instanceof 在查找的过程中会遍历左边变量的原型链，直到找到右边变量的 prototype，如果查找失败，则会返回 false。


```js
function instanceof(left, right) {
  const rightVal = right.prototype
  const leftVal = left.__proto__
  // 若找不到就到一直循环到父类型或祖类型
  while (leftVal) {
    if (leftVal === rightVal) {
      return true
    }
    leftVal = leftVal.__proto__ // 获取祖类型的__proto__
  }
  return false;
}
```

### 93介绍 class 和 ES5 的类以及区别

### ES5的类

function

### class

类声明创建一个基于原型继承的具有给定名称的新类

### 区别

1. 类声明不可以提升
2. 类声明不允许再次声明已经存在的类，否则将会抛出一个类型错误。
3. class 内部是严格模式，构造函数是可选的
4. class 的静态方法或者原型方法都不可枚举，且这些方法都没有原型，不可被new
5. class 必须使用new 来调用
6. class 内部无法重写类名

### 代码示例

```js
/**
 *ES6的类
**/
const bar = Symbol('bar');
const snaf = Symbol('snaf');
class Parent {
    constructor(a) {
        this.a = a;
        this.printName = this.printName.bind(this)
    }
    print() {
        console.log('parent')
    }
    printName(name = 'there') {
        this.print(`Hello ${name}`);
    }
    // 公有方法
    foo(baz) {
        this[bar](baz);
    }
    // 私有方法
    [bar](baz) {//[bar]用方括号代表从表达式获取的属性名
        return this[snaf] = baz;
    }

}
```

- Parent中定义的方法不可用Object.keys(Point.prototype)枚举到
- 重复定义Parent class会报错;
- 可通过实例的__proto__属性向原型添加方法
- 没有私有方法和私有属性用symbol模拟
- class静态方法与静态属性
    - class定义的静态方法前加static关键字
    - 只能通过类名调用
    - 不能通过实例调用
    - 可与实例方法重名
    - 静态方法中的this指向类而非实例
    - 静态方法可被继承
    - 在子类中可通过super方法调用父类的静态方法
    - class内部没有静态属性，只能在外面通过类名定义。
- new target属性指向当前的构造函数,不能在构造函数外部调用会报错

**等同于es5**

```js
Parent.prototype = {
    constructor() { },
    print() { },
}
```

- function构造器原型方法可被Object.keys(Point.prototype)枚举到，除过constructor
- 重复定义Parent function ,之前的会被覆盖掉
- 可通过实例的__proto__属性向原型添加方法
- 没有私有属性

所有原型方法属性都可用Object.getOwnPropertyNames(Point.prototype)访问到

### 94Array 是 Object 类型吗

### Array

看下代码例子

```js
var a=[ ]
a instanceof Array
// 输出 Array
```


```js
a.constructor == Array
// 输出： true
```

去a的原型链上看看到底继承了什么东西：

```js
a.__proto__.constructor
// 输出：ƒ Array() { [native code] }
```

```js
a.__proto__.__proto__.constructor
// 输出：ƒ Object() { [native code] }
```

```js
a.__proto__.__proto__.__proto__
// 输出null
```

由此可以看出：a的创建过程是 `null->Object->Array`，所以说 Array 属于Object;






### 95setTimeout(1)和 setTimeout(2)之间的区别

###  区别

#### 1.返回值timeoutID 不一样

每个setTimeout 会对应一个 timeoutID ,即定时器的编号。这个timeoutID可以传递给clearTimeout() 来取消定时器。

#### 2.code 值不一样

setTimeout 语法

```js
var timeoutID = scope.setTimeout(function[, delay, arg1, arg2, ...]);
var timeoutID = scope.setTimeout(function[, delay]); 
var timeoutID = scope.setTimeout(code[, delay]);
```

除了可以接受function,还可以接受code。

这是一个可选语法，你可以使用字符串而不是function ，在delay毫秒之后编译和执行字符串。

> 但是需要注意，使用该语法是不推荐的, 原因和使用 eval()一样，有安全风险。

#### 3. 执行的时间不一样

虽然在不设定delay延时时间的情况下，都是默认延时0毫秒执行，但是
setTimeout 有一个显著的缺陷在于时间是不精确的，setTimeout 只能保证延时或间隔不小于设定的时间。因为它们实际上只是把任务添加到了任务队列中，但是如果前面的任务还没有执行完成，它们必须要等待。




### 96Async/Await 怎么实现



### 97ES6 中 let 块作用域是怎么实现的



### 98formData 和原生的 ajax 有什么区别



### 99介绍下表单提交，和 formData 有什么关系



### 100如何对相对路径引用进行优化



### 101介绍 localstorage 的 api



### 102使用闭包特权函数的使用场景



### 103Promise 和 setTimeout 的区别



### 104请写出正确的执行结果
```js
var yideng = {
  bar: function () {
    return this.baz;
  },
  baz: 1,
};
(function () {
  console.log(typeof arguments[0]());
})(yideng.bar);
```



### 105请写出正确的执行结果
```js
function test() {
  console.log("out");
}
(function () {
  if (false) {
    function test() {
      console.log("in");
    }
    test();
  }
})();
```



### 106请写出正确的执行结果
```js
var x = [typeof x, typeof y][1];
typeof x;
```



### 107请写出正确的执行结果
```js
(function (x) {
  delete x;
  return x;
})(1);
```



### 108请写出正确的执行结果
```js
var x = 1;
if (function f() {}) {
  x += typeof f;
}
x;
```



### 109请写出正确的执行结果
```js
function f() {
  return f;
}
new f() instanceof f;
```



### 110请写出代码正确执行结果，并解释原因
```js
Object.prototype.a = "a";
Function.prototype.a = "a1";
function Person() {}
var yideng = new Person();
console.log(yideng.a);
```



### 111请写出正确的执行结果
```js
var yideng = [0];
if (yideng) {
  console.log(yideng == true);
} else {
  console.log("yideng");
}
```



### 112请写出正确的执行结果
```js
function yideng() {
  return;
  {
    a: 1;
  }
}
var result = yideng();
console.log(result.a);
```



### 113请写出正确的执行结果
```html
<script>
  //使用未定义的变量yideng
  yideng;
  console.log(1);
</script>
<script>
  console.log(2);
</script>
```



### 114请写出正确的执行结果
```js
var yideng = Array(3);
yideng[0] = 2;
var result = yideng.map(function (elem) {
  return "1";
});
console.log(result);
```



### 115请写出代码正确执行结果
```js
[1 < 2 < 3, 3 < 2 < 1];
```



### 116请写出代码正确执行结果
```js
2 == [[[2]]];
```



### 117计算以上字节每位 ✈️ 的起码点，并描述这些字节的起码点代表什么
```js
console.log("✈️".length);
// 1.计算以上字节每位✈️的起码点
// 2.描述这些字节的起码点代表什么
```



### 118请写出代码正确执行结果，并解释原因
```js
var yidenga = Function.length,
  yidengb = new Function().length;
console.log(yidenga === yidengb);
```



### 119请写出代码正确执行结果
```js
var length = 10;
function fn() {
  console.log(this.length);
}
var yideng = {
  length: 5,
  method: function (fn) {
    fn();
    arguments[0]();
  },
};
yideng.method(fn, 1);
```



### 120请写出代码正确执行结果，并解释原因
```js
var yi = new Date("2018-08-20"),
  deng = new Date(2018, 08, 20);
[yi.getDay() === deng.getDay(), yi.getMonth() === deng.getMonth()];
```



### 121请写出代码正确执行结果
```js
for (
  let i = (setTimeout(() => console.log("a->", i)), 0);
  setTimeout(() => console.log("b->", i)), i < 2;
  i++
) {
  i++;
}
```



### 122请写出代码正确执行结果，并解释原因
```js
[typeof null, null instanceof Object];
```



### 123请问当前 textarea 文本框展示的内容是什么？
```html
<textarea maxlength="10" id="yideng"></textarea>
<script>
  document.getElementById("yideng").value = "a".repeat(10) + "b";
</script>
```



### 124请写出代码正确执行结果
```js
function sidEffecting(ary) {
  arr[0] = arr[2];
}
function yideng(a, b, c = 3) {
  c = 10;
  sidEffecting(arguments);
  return a + b + c;
}
yideng(1, 1, 1);
```



### 125请写出代码正确执行结果
```js
yideng();
var flag = true;
if (flag) {
  function yideng() {
    console.log("yideng1");
  }
} else {
  function yideng() {
    console.log("yideng2");
  }
}
```



### 126请写出代码正确执行结果，并解释为什么
```js
var min = Math.min(),
  max = Math.max();
console.log(min < max);
```



### 127请写出代码正确执行结果，并解释原因？
```js
console.log("hello" + (1 < 2) ? "word" : "me");
```



### 128请写出代码正确执行结果，并解释原因？
```js
var a = (b = 1);
(function () {
  var a = (b = 2);
})();
console.log(a, b);
```



### 129请写出代码正确执行结果，并解释原因？
```js
if ([] instanceof Object) {
  console.log(typeof null);
} else {
  console.log(typeof undefined);
}
```



### 130请写出代码正确执行结果，并解释原因？
```js
var obj = {};
obj.name = "first";
var peo = obj;
peo.name = "second";
console.log(obj.name);
```



### 131请写出代码正确执行结果，并解释原因？
```js
function say(word) {
  let word = "hello";
  console.log(word);
}
say("hello Lili");
```



### 132请写出代码的正确执行结果，并解释原因？
```js
function fun(n, o) {
  console.log(o);
  return {
    fun: function (m) {
      return fun(m, n);
    },
  };
}
var b = fun(0).fun(1).fun(2).fun(3);
```



### 133怎么判断引用类型数据，兼容判断原始类型数据呢？



### 134分别对以下数组进行去重，1:[1,'1',2,'2',3]，2:[1,[1,2,3['1','2','3'],4],5,6]



### 135简述 JavaScript 中的函数的几种调用方式



### 136说一下 let、const 的实现，动手实现一下



### 137scrollview 如何进行又能优化(例如 page=100 时，往上滚动)



### 138原生 JavaScript 获取 ul 中的第二个 li 里边的 p 标签的内容



### 139数组截取插入 splice，push 返回值，数组的栈方法、队列方法、排序方法、操作方法、迭代方法说一下



### 140判断一个变量的类型，写个方法用 Object.prototype.toString 判断传入数据的类型



### 141以下代码输出什么？
```js
setTimeout(function () {
  console.log(1);
}, 0);
new Promise(function executor(resolve) {
  console.log(2);
  for (var i = 0; i < 10000; i++) {
    i == 9999 && resolve();
  }
  console.log(3);
}).then(function () {
  console.log(4);
});
console.log(5);
```



### 142switch case，case 具体是怎么比较的，哪些情况下会走到 default



### 143说下 typeof()各种类型的返回值？instanceof 呢？



### 144genertor 的实现原理



### 145判断是否是数组的方法



### 146给出的两行代码为什么这么输出
```js
var s = "laohu";
s[0] = 1;
console.log(s); //laohu
var s = "laohu";
s += 2020;
console.log(s); // laohu2020
// 上面两行为什么这么输出
```



### 147对 service worker 的理解



### 148promise 里面和 then 里面执行有什么区别


- 构造函数里面是同步执行的，无法取消
- then里面是异步的，属于微任务；

看个例子

```js
new Promise(function (resolve, reject) {
    // 这里面属于宏任务，是同步执行的
    console.log('macrotask');
    resolve('result');
}).then(function (value) {
    // `then`中的回调函数属于微任务，在`resolve`执行后被推到微任务队列等待执行
    console.log('microtask');
    console.log(value === 'result'); // true
});
```




### 149动画性能如何检测


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

### 150一个 dom 必须要操作几百次，该如何解决，如何优化？


### 解决方案

#### 1.缓存DOM对象

比如在循环之前就将节点获取并缓存到内存，在循环内部直接引用，而不是重新查询；

#### 2.文档碎片

（1）document.createDocumentFragment() 创建的文档碎片是个虚拟节点对象，对它的操作不会影响真实dom，对它进行频繁操作，操作完成再一次性添加到真实的DOM中；

（2）把需要复杂操作的元素，先从页面移除再进行操作，操作完成再添加回来；

（3）把需要复杂操作的元素复制一个副本cloneNode()，在内存中进行操作再替换旧的；

#### 3.使用innerHtml代替高频的appendChild；

#### 4.RAF

把可能导致重绘的操作放到RAF（requestAnimationFrame）中，浏览器空闲的时候去处理；

#### 5.虚拟DOM

Virtual DOM本质是一个JS对象，DOM diff之后最后再批量的更新真实的DOM结构；

### 151概述异步编程模型


### 异步编程模型

Javascript语言的执行环境是"单线程"。也就是指一次只能完成一件任务。如果有多个任务，就必须排队，依次执行任务。

这种模式实现起来虽然相对简单，执行环境相对单纯，但只要有一个任务耗时很长，后面的任务都必须排队等着，会拖延整个程序的执行。常见的浏览器无响应（假死），往往就是因为某一段Javascript代码长时间运行（比如死循环），导致整个页面卡在这个地方，其他任务无法执行。

为了解决这个问题，Javascript语言将任务的执行模式分成两种：同步和异步。常见的异步编程方案有以下几种：
- 回调函数（Callback）
- 事件监听
- 观察者模式（消息订阅/发布）
- Promise/A+ (es6)
- 生成器Generators/ yield (es6)
- async/await (es7)
 
#### 回调函数（Callback）

回调函数可以说是Javascript异步编程最基本的方法。

```js
function loadingDo(callback){
    setTimeout(() => {
        callback()
    }, 2000);
}
function printMe(){
    console.log('我是: 回调函数。。。')
}
loadingDo(printMe)
```

回调函数往往就是调用用户提供的函数，该函数往往是以参数的形式提供的。很容易写出回调地狱式代码。

```js
fn(() => {
    fn1(() => {
        fn2(() => {
            // ...
        })
    })
})
```

回调函数的优点是简单、易理解和实现，缺点是不利于代码的阅读和维护，各个部分之间高度耦合,依赖性很强，使得程序结构混乱、流程难以追踪（尤其是多个回调函数嵌套的情况），而且每个任务只能指定一个回调函数。此外它不能使用 try catch 捕获错误，不能直接 return。

#### 事件监听

事件监听模式下，异步任务的执行不取决于代码的顺序，而取决于某个事件是否发生。如 click事件，ajax/websocket事件等。

```js
$("#btn").click(function(){
    // ...
})
```

事件监听的优点是比较容易理解，可以绑定多个事件，每个事件可以指定多个回调函数，而且可以"去耦合"，有利于实现模块化。缺点是整个程序都要变成事件驱动型，运行流程会变得很不清晰。通过代码不能很明确的判断出主流程。

#### 观察者模式（消息订阅/发布）

观察者模式，又称为消息订阅/发布模式。它的含义是，我们先假设有一个“信号中心”，当某个任务执行完毕就向信号中心发出一个信号（事件），然后信号中心收到这个信号之后将会进行广播。如果有其他任务订阅了该信号，那么这些任务就会收到一个通知，然后执行任务相关的逻辑。

```js
myObserve = {
    tasklist: [],
    <!--添加订阅-->
    subscribe: function(){
        ...
    },
    <!--取消订阅-->
    unsubscribe: function(){
        ...
    },
    <!--具体执行-->
    publish: function(){
        ...
    }
}
myObserve.subscribe('done', function () {
    console.log('end');
});
setTimeout(function () {
    myObserve.publish('done')
}, 2000);
```

观察者模式与“事件监听”类似，但是明显优于后者。因为可以通过查看“消息中心”，了解存在多少信号、每个信号有多少订阅者，从而监控程序的运行。但是复杂的系统如果要用观察者模式来做逻辑，必须要做好事件订阅和发布的设计，否则会导致程序的运行流程混乱。

#### Promise/A+ (es6)

Promise本意是承诺，在程序中的意思就是承诺我过一段时间后会给你一个结果。 什么时候会用到过一段时间？答案是异步操作，异步是指可能比较长时间才有结果的才做，例如网络请求、读取本地文件等。

- promise有三种状态：pending（等待）、fulfilled（成功）、rejected（失败）。其中pending为初始状态。
- promise的状态转换只能是：pending->fulfilled或者pending->rejected。转换方向不可逆，不可更改。
- promise拥有then方法。then方法必须返回一个promise。then支持链式调用，且回调的顺序跟then的声明顺序一致。

```js
const promise = new Promise((resolve, reject) => {
    resolve("step1");
})
.then((data) => {
  console.log("获取到数据：", data);
  return "step2";
})
.then((data) => {
  console.log("获取到数据：", data);
});
```

#### 生成器Generators/ yield (es6)

ES6 新引入了 Generator 函数，可以通过 yield 关键字，把函数的执行流挂起，通过next()方法可以切换到下一个状态，为改变执行流程提供了可能，从而为异步编程提供解决方案。

```js
function* myGenerator() {
  yield '1'
  yield '2'
  return '3'
}

const item = myGenerator(); 
item.next()  //{value: "1", done: false}
item.next()  //{value: "2", done: false}
item.next()  //{value: "3", done: true}

```

- Generator 需要手动调用next()就能自动执行下一步
- Generator 返回的是生成器对象
- Generator 不能够返回Promise的resolve/reject的值

```js
function simpleGenerator(ctx) {
  while (1) {
    switch (ctx.prev = ctx.next) {
      case 0:
        ctx.next = 2;
        return 'step1';

      case 2:
        ctx.next = 4;
        return 'step2';

      case 4:
        ctx.next = 6;
        return 'step3';

      case 6:
      case "end":
        return ctx.stop();
    }
  }
}

let ctx = {
  next:0,
  prev: 0,
  done: false,
  stop: function stop () {
    this.done = true
  }
}


let simpleGeneratorLower = function() {
  return {
    next: function() {
      value = ctx.done ? undefined: simpleGenerator(ctx)
      done = ctx.done
      return {
        value,
        done
      }
    }
  }
}

```

Generator实现的核心在于上下文的保存，每一次yield，执行一遍传入的生成器函数，在这个过程中间用了一个ctx对象储存上下文，使得每次执行生成器函数的时候，都可以从前一次执行的结果开始执行。

#### async/await (es7)

使用async/await，可以轻松地达成之前使用生成器和co函数所做到的工作,它有如下特点：

- async/await是基于Promise实现的，它不能用于普通的回调函数。
- async/await与Promise一样，是非阻塞的。
- async/await使得异步代码看起来像同步代码，这正是它的魔力所在。

```js
let fs = require('fs')
function read(file) {
  return new Promise(function(resolve, reject) {
    fs.readFile(file, 'utf8', function(err, data) {
      if (err) reject(err)
      resolve(data)
    })
  })
}
function readAll() {
  read1()
  read2()//这个函数同步执行
}
async function read1() {
  let r = await read('1.txt','utf8')
  console.log(r)
}
async function read2() {
  let r = await read('2.txt','utf8')
  console.log(r)
}
readAll() // 2.txt 3.txt
```

### 152修改代码不造成死循环
```js
while (1) {
  console.log(Math.random());
}
```


### 代码实现

因为 JavaScript 是单线程执行，所以执行上面代码会导致死循环

#### 1.Concurrent.Thread.js 库

使用异步模拟多线程

```js
Concurrent.Thread.create(function() {
    while(1){
        console.log(Math.random());
    }
})
```

#### 2.Web Worker

提供了在后台非主线程执行 JavaScript 代码的能力

```js
// main.js
const worker = new Worker('worker.js');

worker.onmessage = function(e) {
    // 接收worker传过来的数据
}

// worker.js
while(1){
    const n = Math.random();
    console.log(n);
    if (n > 0.9) {
        postMessage(n);
        break;
    }
}
```

### 153用 html、css、js 模拟实现一个下拉框，使得下拉框在各个浏览器下的样式和行为完全一致，说出你的设计方案，并且重点说明功能设计时要考虑的因素。


### 代码实现

```js
<style>
    div,span,ul,li{margin: 0;padding: 0;}
    ul,li{list-style: none;}
    #box{width: 200px;height: 30px;}
    span{width: 200px;height: 30px;border: 1px solid black;display: block;line-height: 30px;text-align: center;}
    .list{width: 200px;height: 90px;display: none;}
    .list li{width: 200px;height: 30px;border: 1px solid black;border-top:none;text-align: center;}
    .list .active{background: #66f;color: #fff;}
</style>
<body>
  <div id="box">
    <span>上海</span>
    <ul class="list">
      <li class="active">上海</li>
      <li>北京</li>
      <li>广州</li>
      <li>青岛</li>
      <li>杭州</li>
    </ul>
  </div>
</body>

<script>
  var olist = document.querySelector(".list")
  var ospan = document.querySelector("span");
  var ali = document.querySelectorAll(".list li");
  // 1为显示，2为隐藏
  var type = 1;
  // 默认索引样式
  var index = 0;
  clearActive();

  ospan.onclick = function(eve){
    var e = eve || window.event;
    if(type === 1){
      olist.style.display = "block";
      clearActive();
      type = 2;
    }else{
      olist.style.display = "none";
      clearActive();
      type = 1;
    }
    stopBubble(e);
  }
  for (var i = 0; i < ali.length; i++) {
    ali[i].xuhao = i
    ali[i].onclick = function (eve) {
      var e = eve || window.enent;
      ospan.innerHTML = this.innerHTML
      index = this.xuhao
    }
    // 鼠标滑过的样式
    ali[i].onmousemove = function (eve) {
      var e = eve || window.enent;
      index = this.xuhao
      clearActive();
    }
    ali[i].onmouseout = function (eve) {
      var e = eve || window.enent;
      this.className = "";
    }
  }
  //点击空白
  document.onclick = function(){
    olist.style.display = "none";
    type = 1;
  }


  //设置默认样式
  function clearActive(){
    for(var i=0;i<ali.length;i++) {
      ali[i].className = "";
    }
    ali[index].className = "active";
  }

  function stopBubble(e){
    if(e.stopPropagation){
      e.stopPropagation();
    }else{
      e.cancelBubble = true;
    }
  }
</script>
```

### 154promise 如何实现 then 处理，动手实现 then


### 代码实现

Promise 是 ES6 中异步编程的一种解决方案，比传统的解决方案——回调函数和事件——更合理和更强大。Promise 是一个对象，提供统一的 API，各种异步操作都可以用同样的方法进行处理。

另外Promise 是有统一规范的，目的是为了让大家自己实现的 promise 更好的实现兼容，所以出现了 Promises/A+规范；

代码实现

```js
class Promise {
  constructor(executor) {
    // 形参校验
    if (typeof executor !== 'function') throw new TypeError(`Promise resolver ${executor} is not a function`)
    // 初始化
    this.init();

    try {
      executor(this.resolve, this.reject);
    } catch (e) {
      this.reject(e)
    }

  }

  // 初始化值
  init() {
    this.value = null; // 终值
    this.reason = null; // 拒因
    this.status = Promise.PENDING; // 状态
    this.onFulfilledCbs = []; // 成功回调
    this.onRejectedCbs = []; // 失败回调
    // 将 resolve 和 reject 中的 this 绑定到 Promise 实例
    this.resolve = this.resolve.bind(this)
    this.reject = this.reject.bind(this)
  }

  resolve(val) {
    // 成功后的一系列操作（状态改变，成功回调的执行）
    if (this.status === Promise.PENDING) {
      this.status = Promise.FULFILLED;
      this.value = val;
      this.onFulfilledCbs.forEach(fn => fn(this.value));
    }
  }

  reject(err) {
    // 失败后的一系列操作（状态改变， 失败回调的执行）
    if (this.status === Promise.PENDING) {
      this.status = Promise.REJECTED;
      this.reason = err;
      this.onRejectedCbs.forEach(fn => fn(this.reason));
    }
  }

/* 
 then 接收两个回调函数，
 onFulfilled是当 promise 实例状态变为 fulfilled 时调用的函数，
 onRejected 是实例状态变为 rejected 时调用的函数，
 并且 then 返回的是一个 新的 promise 实例
*/
  then(onFulfilled, onRejected) {
    // 参数校验 onFulfilled, onRejected 为可选形参
    onFulfilled = typeof onFulfilled !== 'function' ? val => val : onFulfilled;
    onRejected = typeof onRejected !== 'function' ? reason => { throw reason } : onRejected;

    // 返回一个新的实例来实现链式调用
    let promise2 = new Promise((resolve, reject) => {
      // 同步操作（最开始的状态改变为同步）
      if (this.status === Promise.FULFILLED) {
        // setTimeout 模拟微任务异步 
        // 只有异步后 才能在里面取到 new 好的 promise2
        setTimeout(() => {
          try { // 重新添加try-catch，settimeout 内为异步，无法被外层constructor中的try-catch捕获
            // 以终值作为参数执行 onFulfilled 函数
            let x = onFulfilled(this.value);
            // 分析执行结果 x 与 promise 的关系
            // resolve(x);
            Promise.resolvePromise(promise2, x, resolve, reject);
          } catch (e) { reject(e) }
        })
      }

      if (this.status === Promise.REJECTED) {
        // 以拒因作为参数执行 onRejected 函数
        setTimeout(() => {
          try {
            let x = onRejected(this.reason)
            Promise.resolvePromise(promise2, x, resolve, reject);
          } catch (e) { reject(e) }
        });
      }

      // 异步操作（最开始状态改变为异步，如 settimeout 内包含 resolve）使用发布订阅
      if (this.status === Promise.PENDING) {
        this.onFulfilledCbs.push(value => {
          setTimeout(() => {
            try {
              let x = onFulfilled(value)
              Promise.resolvePromise(promise2, x, resolve, reject);
            } catch (e) { reject(e) }
          })
        });
        this.onRejectedCbs.push((reason) => {
          setTimeout(() => {
            try {
              let x = onRejected(reason)
              Promise.resolvePromise(promise2, x, resolve, reject);
            } catch (e) { reject(e) }
          })
        });
      }
    })

    return promise2
  }

}

Promise.PENDING = 'pending';
Promise.FULFILLED = 'fulfilled';
Promise.REJECTED = 'rejected';

/* 
根据规范，resolvePromise 规则大致如下：
1.promise2 和 x 指向同一对象，抛出一个类型错误
2.x 是一个 Promise 类，则接受它的状态，并对应执行其resolve 或者 reject 函数
3.x 是一个函数或者对象
4.以上都不是，调用 resolve
*/
Promise.resolvePromise = function (promise2, x, resolve, reject) {
  // x 与 promise2 相等 -> 报错
  if (promise2 == x) {
    return reject(new TypeError('Chaining cycle detected for promise'))
  }
  let called; // 防止多次调用 成功 和 失败
  // // x 是否是 promise 类
  // if (x instanceof Promise) {
  //   x.then(value => {
  //     Promise.resolvePromise(promise2, value, resolve, reject);
  //   }, err => {
  //     reject(err)
  //   })
  //   // x 是函数或者对象
  // } else 
  if (x !== null && typeof x == 'object' || typeof x == 'function') {
    try { // 取 x.then 可能报错
      // 如果 x 有 then 方法
      let then = x.then;
      // 如果 then 是一个函数
      if (typeof then == 'function') {
        // 用 call 调用 then 方法指向 x，防止再次取 x.then 报错
        then.call(x, value => {
          if (called) return;
          called = true;
          Promise.resolvePromise(promise2, value, resolve, reject);
        }, err => {
          if (called) return;
          called = true;
          reject(err)
        })
      } else {
        if (called) return;
        called = true;
        resolve(x);
      }
    } catch (e) {
      if (called) return
      called = true
      reject(e)
    }
  } else {
    // x 为基本类型值
    resolve(x);
  }
}

```

### 155请实现一个 JSON.stringfy


### 代码实现

- 实现一

```js
function stringify(jsonObj) {
        var result = '',
            curVal;
        if (jsonObj === null) {
            return String(jsonObj);
        }
        switch (typeof jsonObj) {
            case 'number':
            case 'boolean':
                return String(jsonObj);
            case 'string':
                return '"' + jsonObj + '"';
            case 'undefined':
            case 'function':
                return undefined;
        }

        switch (Object.prototype.toString.call(jsonObj)) {
            case '[object Array]':
                result += '[';
                for (var i = 0, len = jsonObj.length; i < len; i++) {
                    curVal = JSON.stringify(jsonObj[i]);
                    result += (curVal === undefined ? null : curVal) + ",";
                }
                if (result !== '[') {
                    result = result.slice(0, -1);
                }
                result += ']';
                return result;
            case '[object Date]':
                return '"' + (jsonObj.toJSON ? jsonObj.toJSON() : jsonObj.toString()) + '"';
            case '[object RegExp]':
                return "{}";
            case '[object Object]':
                result += '{';
                for (i in jsonObj) {
                    if (jsonObj.hasOwnProperty(i)) {
                        curVal = JSON.stringify(jsonObj[i]);
                        if (curVal !== undefined) {
                            result += '"' + i + '":' + curVal + ',';
                        }
                    }
                }
                if (result !== '{') {
                    result = result.slice(0, -1);
                }
                result += '}';
                return result;

            case '[object String]':
                return '"' + jsonObj.toString() + '"';
            case '[object Number]':
            case '[object Boolean]':
                return jsonObj.toString();
        }
    }
```

- 实现二

```javascript
(function (NS) {
	var simpleTypes = ["number", "boolean", "undefined", "string", "function"];

	function stringify(object) {
		var type = typeof object;
		if (indexOf(simpleTypes, type) > -1) {
			return parseSimpleObject(object);
		}

		if (object instanceof Array) {
			var len = object.length;
			var resArr = [];
			for (var i = 0; i < len; i++) {
				var itemType = typeof object[i];
				if (indexOf(simpleTypes, itemType) > -1) {
					if (itemType !== "undefined") {
						resArr.push(parseSimpleObject(object[i]));
					} else {
						resArr.push("null");
					}
				} else {
					resArr.push(stringify(object[i]));
				}
			}
			return "[" + resArr.join(",") + "]";
		}

		if (object instanceof Object) {
			if (object == null) {
				return "null";
			}
			var resArr = [];
			for (var name in object) {
				var itemType = typeof object[name];
				if (indexOf(simpleTypes, itemType) > -1) {
					if (itemType !== "undefined") {
						resArr.push('"' + name + '":' + parseSimpleObject(object[name]));
					}
				} else {
					resArr.push('"' + name + '":' + stringify(object[name]));
				}
			}
			return "{" + resArr.join(",") + "}";
		}
	}

	function parseSimpleObject(object) {
		var type = typeof object;
		if (type === "string" || type === "function") {
			return '"' + object.toString().replace('"', '\\"') + '"';
		}
		if (type === "number" || type === "boolean") {
			return object.toString();
		}
		if (type == "undefined") {
			return "undefined";
		}
		return '"' + object.toString().replace('"', '\\"') + '"';
	}

	function indexOf(arr, val) {
		for (var i = 0; i < arr.length; i++) {
			if (arr[i] === val) {
				return i;
			}
		}
		return -1;
	}

	NS.stringify = function (object,isEncodeZh) {
		var res = stringify(object);
		if (isEncodeZh) {
			var encodeRes = "";
			for (var i = 0; i < res.length; i++) {
				if (res.charCodeAt(i) < Oxff) {
					encodeRes += res[i];
				} else {
					encodeRes += "\\u" + res.charCodeAt(i).toString(16);
				}
			}
			res = encodeRes;
		}
		return res;
	};
})(window);
```



### 156手写 EventEmitter 实现


### 代码实现

- `on(event, fn)` 监听自定义 event 事件，事件触发时调用 fn 函数（addListener）
- `once(event, fn)` 为指定事件注册一个单次监听器，单词监听最多只触发一次，出发后立即解除监听器
- `emit(event, arg1, arg2, arg3...)` 触发 event 事件，并把参数传给事件处理函数 （trigger）
- `off(event, fn)` 停止监听某个事件 （removeListener）

```js
function checkListener(listener) {
	if (typeof listener !== 'function') {
		throw 'listener 不是函数'
	}
}

function EventEmitter() {
	/**
	 * 缓存列表，存放订阅者回调函数
	 */
	this._events = {};
}

/**
 * 订阅事件
 * @param {string} event - 事件类型
 */
EventEmitter.prototype.addListener = function addListener(event, listener) {
	checkListener(listener);

	if (!this._events[event]) {
		this._events[event] = [];
	}
	this._events[event].push(listener);
}
EventEmitter.prototype.on = EventEmitter.prototype.addListener;

EventEmitter.prototype.emit = function emit(event, ...args) {
	let listeners = this._events[event];

	if (!listeners || !listeners.length) {
		return false;
	}

	for (let i = 0, listener; listener = listeners[i++];) {
		listener.apply(this, [event, ...args]);
	}
}

EventEmitter.prototype.removeListener = function removeListener(event, listener) {
	let listeners = this._events[event];

	if (!listeners) {
		return false;
	}
	if (!listener) {
		listeners && (listeners.length = 0);
	} else {
		for (let i = listeners.length - 1; i >= 0; i--) {
			let _listener = listeners[i];
			if (_listener === listener) {
				listeners.splice(i, 1);
			}
		}
	}
}
EventEmitter.prototype.off = EventEmitter.prototype.removeListener;

EventEmitter.prototype.once = function once(event, listener) {
	checkListener(listener);

	let wrap = (...args) => {
		listener.apply(this, args);
		this.off(event, wrap)
	}
	this.on(event, wrap);
}

var event = new EventEmitter();
var fn1 = function (type, price) {
	console.log(`fn1 订阅 ${type} price: ${price}`);
}
var fn2 = function (type, price) {
	console.log(`fn2 订阅 ${type} price: ${price}`);
};
event.addListener('sm88', fn1);
event.addListener('sm88', fn2);
event.addListener('sm100', fn2);

event.emit('sm88', 100); // 1. fn1-sm88-100, 2. fn2-sm88-100
event.emit('sm100', 1000); // 3. fn2-sm100-1000

event.removeListener('sm88', fn2);
event.emit('sm88', 100); // 4. fn1-sm88-100,

event.once('sm300', fn2);
event.emit('sm300', 1000); // 5. fn2-sm200-1000,
event.emit('sm300', 1000); //
```

### 157写一个函数打乱一个数组，传入一个数组，返回一个打乱的新数组


### 代码实现

#### 1.实现方式一

```js
var arr = [1,2,3,4,5]

function disorder(arr) {
    return Array.from(arr).sort(()=>Math.random()-0.5)
}
var arr2 = disorder(arr)
console.log(arr2)
console.log(arr)
console.log(arr === arr2)
```

#### 2.实现方式二

```js
let arr = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
function shuffle(arr) {
    let i = arr.length;
    while (i) {
        let j = Math.floor(Math.random() * i--);
        [arr[j], arr[i]] = [arr[i], arr[j]];
    }
    return arr;
}
shuffle(arr);
```

### 158平时都用到了哪些设计模式


### 一、设计模式

设计模式是一套被反复使用、分类的代码设计经验的总结。一般有23中，按照分类可以分为：

#### 1.创造型模式

- 抽象工厂模式
- 工厂方法模式
- 单例模式
- 构建模式
- 原型模式

#### 2.结构型模式

- 代理模式
- 装饰者模式
- 组合模式
- 桥接模式
- 适配器模式
- 外观模式
- 享元模式

#### 3.行为型模式

- 策略模式
- 命令模式
- 状态模式
- 责任链模式
- 解释器模式
- 观察者模式
- 备忘录模式
- 迭代器模式
- 模板方法模式
- 访问者模式
- 中介模式

### 二、平常使用的有以下几种：

**单例模式**

单例模式就是保证一个类只有一个实例。

```js
class Car{
  constructor(){
    this.isSale = false;
  }
  
  sale(){
    if(this.isSale){
      console.log("卖了");
      return;
    }
    this.isSale = true;
    console.log('卖车')
  }
  noSale(){
    if(!this.isSale){
      console.log("没卖");
      return;
    }
    this.isSale = false;
    console.log("没卖呢")
  }
}

Car.getInstance = (function(){
  let instance;
  return function(){
    if(!instance){
      instance = new Car();
    }
    return instance;
  }
})();

let men1 = Car.getInstance();
let men2 = Car.getInstance();
console.log(men1 === men2)

```

**工厂模式**

工厂模式定义一个用于创建对象的接口，这个接口由子类决定实例化哪一个类。

```js
var factory = {};
factory.createCar = function(){
  console.log('create car');
}
factory.createMask = function(){
  console.log('create mask');
}

factory.manage = function(create){
  return new factory[create]();
}

let car = factory.manage('createCar');
let mask = factory.manage('mask');
```

### 159说一下栈和堆的区别，垃圾回收时栈和堆的区别


### 一、栈和堆区别

**栈:** 由操作系统自动分配释放 ，存放函数的参数值和局部变量的值等。其操作方式类似于数据结构中的栈。简单的理解就是当定义一个变量的时候，计算机会在内存中开辟一块存储空间来存放这个变量的值，这块空间就叫做栈，然而栈中一般存放的是基本类型数据，栈的特点是先进后出（或后进先出）

**堆:** 一般由程序员分配释放， 若程序员不释放，程序结束时可能由OS回收，分配方式倒是类似于链表。其实在堆中一般存放变量是一些对象类型

#### 1.存储大小

栈内存的存储大小是 **固定** 的，申请时由系统自动分配内存空间，运行的效率比较快，但是因为存储的大小固定，所以容易存储的大小超过存储的大小，导致益栈。

堆内存的存储的值的 **大小不定** ，是有程序员自己申请并指明大小。因为堆内存是 new 分配的内存，所以运行效率会较低。

#### 2.存储对象

栈内存存储的是基础数据类型，并且是按值访问，因为栈是一块连续的内存区域，以**后进先出**的原则存储调用的，所以是连续存储的。

堆内存是向高地址扩展的数据结构，是不连续的内存区域，系统也是用链表来存储空闲的内存地址，所以是不连续的。因为是记录的内存地址，所以获取是通过引用，存储的是对象居多。

#### 3.回收

栈的回收是系统控制实现的。

堆内存的回收是人为控制的，当程序结束后，系统会自动回收。


### 三、垃圾回收栈和堆的区别

- 栈内存中的数据只要运行结束，则直接回收。
- 堆内存中的对象回收标准是否可达，在 V8 中 对象先分配到新生代的 From 中，如果不可达直接释放，如果可达，就复制到 To 中，然后将 To 和 From 互换。当多次复制后依然没有回收，则放入老生代中，进行标记回收。之后将内存碎片进行整合放到一端。

### 160JavaScript 基本数据类型都有哪些？用 typeOf 判断分别显示什么？


### 一、基本数据类型

`undefined,null,number,boolean,string,symbol`

### 二、typeof进行判断

 typeof操作符返回一个字符串，表示未经计算的操作数的类型。

 ```js
typeof undefined     ===  'undefined'
typeof undeclared    ===  'undefined'
typeof true       ===  'boolean'
typeof 22        ===  'number'
typeof NaN        ===  'number'
typeof '22'       ===  'string'
typeof []        ===  'object'
typeof {}        ===  'object'
typeof null       ===  'object'
typeof /regex/      ===  'object'
typeof new Date()    ===  'object'
typeof new String()   ===  'object'
...
typeof new Function()  ===  'function'
typeof function a(){}  ===  'function'
```

 **除了Function之外的所有构造函数的类型都是'object'。**

 `undefined`是值的一种，为未定义，而`undeclared`则表示变量还没有被声明过。在我们试图访问一个`undeclared` 变量时会这样报错：`ReferenceError：a is not defined`。通过typeof对`undefined`和`undeclared`变量都返回`undefined`

 **注意**：变量没有类型，只有值才有。类型定义了值的行为和特征。



### 三、知识扩展

#### 1.instanceof

`instanceof`运算数是用于检测`contructor.prototype`属性是否出现在某个实例对象的原型链上。

```js
object instanceof constructor

22 instanceof Number         => false
'22' instanceof String       => false
[] instanceof Object         => true
{} instanceof Object         => true
undefined instanceof Object  => false
null instanceof Object       => false
null instanceof null         => Uncaught TypeError: Right-hand side of 'instanceof' is not an object

new String('22') instanceof String  => true
new Number(22) instanceof Number   => true
```

 **instanceOf的主要实现原理就是只要右边变量的prototype在左边变量的原型链上即可**。因此，instanceof在查找过程中会遍历左边变量的原型链，知道找到右边变量的prototype，如果查找失败就会返回false。

 #### 2.Object.prototype.toString.call()

 ```js
Object.prototype.toString.call(22)        =>  "[object Number]"
Object.prototype.toString.call('22')      =>  "[object String]"
Object.prototype.toString.call({})        =>  "[object Object]"
Object.prototype.toString.call([])        =>  "[object Array]"
Object.prototype.toString.call(true)      =>  "[object Boolean]"
Object.prototype.toString.call(Math)      =>  "[object Math]"
Object.prototype.toString.call(new Date)  =>  "[object Date]"
Object.prototype.toString.call(Symbol(22))=>  "[object Symbol]"
Object.prototype.toString.call(() => {})  =>  "[object Function]"
Object.prototype.toString.call(null)      =>  "[object Null]"
Object.prototype.toString.call(undefined) =>  "[object Undefined]"
```

### 四、总结


 用 typeof 来判断变量类型的时候，我们需要注意，最好是用 typeof 来判断基本数据类型（包括symbol），避免对 null 的判断。不过需要注意当用typeof来判断null类型时的问题，如果想要判断一个对象的具体类型可以考虑使用instanceof，但是很多时候它的判断有写不准确。所以当我们在要准确的判断对象实例的类型时，可以使用`Object.prototype.toString.call()`进行判断。因为`Object.prototype.toString.call()`是引擎内部的方式。




### 161单例、工厂、观察者项目中实际场景


### 一、单例模式(Singleton)

限制了类的实例化次数只能一次。从经典意义来将，单例模式，**在实例不存在的时候，可以通过一个方法创建一个类来实现创建类的新实例；如果实例已经存在，他会简单返回该对象的引用**。单例模式不同于**静态类**，**可以推迟它们的初始化**，这通常是因为我们需要一些信息，而这些信息在初始化的时候可能无法获取到；对于没有擦觉到之前引用的代码，不会提供方便检索的方法

**优点**： 能够单独划分出一个命名空间，避免和别的内部变量发生冲突，所以单例可以分为简单单例和闭包单例

项目的实际用途：

#### 1.简单单例

```js
// 判断实例是否存在，存在则返回，不存在则创建，这样可以保证一个类只有一个实例对象
var testSingle = testSingle||{
    name: 'jack',
    age: 15,
    gender: '1',
    sayName: function(){
        console.log(this.name)
    },
    sayAge: function(){
        console.log(this.age)
    }
}
```

#### 2.闭包单例

```js
// 闭包的作用是保护一些私有属性，不被外界访问，只有return将属性暴露才能被外界访问到
var testSingle = testSingle||{
    introduction = (function(){
        var _name = 'jack'
        var _age = 15
        var _gender = '1'
        var _sayName = function(){
            console.log(_name)
        }
        var _sayAge = function(){
            console.log(_age)
        }
        return {
            name: _name,
            age: _age,
            gender: _gender,
            sayName: function(){
                return _sayName();
            },
            sayAge: function(){
                return _sayAge()
            }
        }
    }
}
```

#### 3.应用场景
1. 弹窗，无论点击多少次，弹窗只应该被创建一次；
2. 全局缓存
3. `vuex`创建全局的`store`
4. Redux中的Store


### 二、工厂模式

Factory模式是一种创建型模式，涉及到创建对象的概念。其分类不同于其他模式的地方在于它不显式地要求使用一个构造函数。而`Factory`可以提供一个通用的接口来创建对象，我们可以指定我们所希望创建的工厂对象类型

```js
// 一个简单的工厂
function PersonFactory(name) { // 工厂函数
  let obj = new Object();
  obj.name = name;    
  obj.sayName = function(){
      return this.name;
  }
  return obj;
}
let person = new PersonFactory("张三");

console.log(person.name); // 张三
console.log(person.sayName()); // 张三
```
#### 应用场景

1. 创建工具库，导出有且只有一个的引用如：`jquery`可以使用`$ `,`lodash`可以使用`_`
2. 类似React.createElement，屏蔽了开发者直接使用new VNode，符合开放封闭原则，VNode的实现对开发者不可见

### 三、观察者模式

目标和观察者是基类，目标提供维护观察者的一些了方法，观察者提供更新接口。具体观察者和具体目标继承各自的基类，然后具体观察者把自己注册到目标里，在哭啼目标发生变化时候，调度观察者更新方法。

```js
// es6
class Subject {
    constructor() {
        this.state = 0;
        this.observers = []
    }
    getState() {
        return this.state
    }
    setState(state) {
        this.state = state;
        this.notify();
    }
    notify() {
        this.observers.forEach(observer => {
            observer.update()
        })
    }
    add(observer) {
        this.observers.push(observer)
    }
}

class Observer {
    constructor(name, subject) {
        this.name = name;
        this.subject = subject;
        this.subject.add(this)
    }
    update() {
        console.warn(`${this.name} 被更新，状态为${this.subject.getState()}`)
    }
}

let sub = new Subject();
let ob = new Observer("ob", sub); 

sub.setState(1)

// es5
var Subject = function () {
    this.state = 0;
    this.observers = []
}
Subject.prototype.getState = function () {
    return this.state
}
Subject.prototype.setState = function (state) {
    this.state = state;
    this.notify();
}
Subject.prototype.notify = function () {
    this.observers.forEach(observer => {
        observer.update()
    })
}
Subject.prototype.add = function (observer) {
    this.observers.push(observer)
}
var Observer = function (name, subject) {
    this.name = name;
    this.subject = subject;
    this.subject.add(this)
}
Observer.prototype.update = function () {
    console.warn(`${this.name} 被更新，状态为${this.subject.getState()}`)
}
var sub = new Subject();
var ob = new Observer("ob", sub);

sub.setState(1)
```

一个对象（称为subject）维持一系列依赖于它(观察者)的对象，将有关状态的任何变更自动通知给他们

观察者模式一般使用**Publish/Subscribe模式的变量来实现**

```js
const event = {
  registerList: [],
  register: (key, fn) => {
    if(typeof fn !== 'function') {
      console.log('请添加函数');
      return;
    }
    if(!this.registerList[key]) {
      this.registerList[key] = [];
    }
    this.registerList.push(fn);
  },
  trigger(key, ...rest) {
    const funList = this.registerList[key];
    if(!(funList &&funList.length)) {
      return false;
    }
    funList.forEach(fn => {
      fn.apply(this.rest);
    });
  }
}

event.register('click', () => {console.log('我订阅了')});
event.register('click', () => {console.log('我也订阅了')});
event.trigger('click');
```

#### 应用场景

1. onClick的事件绑定
2. vue中的watch
3. Promise
4. jQuery.$callBack
5. NodeJs自定义事件


### 162判断一个变量的类型，写个方法用 Object.prototype.toString 判断传入数据的类型？Object.prototype.toString.call(Symbol) 返回什么？


### 一、Object.prototype.toString 

Object.prototype.toString 方法返回对象的类型字符串，因此可以用来判断一个值的类型。

```js
Object.prototype.toString.call(2) // "[object Number]"
Object.prototype.toString.call('') // "[object String]"
Object.prototype.toString.call(true) // "[object Boolean]"
Object.prototype.toString.call(undefined) // "[object Undefined]"
Object.prototype.toString.call(null) // "[object Null]"
Object.prototype.toString.call(Math) // "[object Math]"
Object.prototype.toString.call({}) // "[object Object]"
Object.prototype.toString.call([]) // "[object Array]"
```

利用这个特性，可以写出一个比 typeof 运算符更准确的类型判断函数

```js
const type  = function (obj) {
    const str = Object.prototype.toString.call(obj);
    return str.match(/\[object (.*?)\]/)[1].toLowerCase();
}

type(true) // "boolean"
type(undefined) // "undefined"
type(null) // "null"
type({}) // "object"
```

### 二、Object.prototype.toString.call(Symbol) 

```js
Object.prototype.toString.call(Symbol);
//"[object Function]"
```

### 163请解释 JSONP 的工作原理


### jsonp原理

#### 1.1 问题背景

由于浏览器同源策略（同一协议，同一域名，同一端口号，当其中一个不满足的时候，请求就会发生跨域）的限制，非同源下的请求，都会产生跨域问题，jsonp即是为了解决这个问题出现的一种简便解决方案。
举个简单的例子：

```
http://www.abc.com:3000到https://www.abc.com:3000的请求会出现跨域（域名、端口相同但协议不同）
http://www.abc.com:3000到http://www.abc.com:3001的请求会出现跨域（域名、协议相同但端口不同）
http://www.abc.com:3000到http://www.def.com:3000的请求会出现跨域（域名不同）
```

#### 1.2 突破同源策略

浏览器的 同源策略 把跨域请求都禁止了，但是页面中 `link`  `script` `img` `iframe` `a` 标签是个例外，这些标签的外链是不受同源策略限制的。

`jsonp` 就是利用了上面 `script` 标签特性来进行跨域数据访问。

#### 1.3 jsonp 的实现机制

1. 与服务端约定好一个 回调函数名 ，在客户端定义好这个函数，在请求url中添加 `callback= 函数名` 的查询字符。
1. 服务端接收到请求之后，将函数名和需要返回的数据，拼接成 `"函数名(data)"` 函数执行的形式返回
1. 页面接收到数据后，解析完直接执行了这个回调函数，这时数据就成功传输到了客户端。

- 客户端代码：

```js
    var flightHandler = function (data) {
        alert('你查询的航班结果是：票价 ' + data.price + ' 元，' + '余票 ' + data.tickets + ' 张。');
    };
    
    var url = "http://localhost:8080/jsonp?callback=flightHandler";
    var script = document.createElement('script');
    script.setAttribute('src', url);
    document.getElementsByTagName('head')[0].appendChild(script);
```

- 服务端代码：koa2实现一个服务

```js
app.use(async (ctx, next) => {
    if (ctx.path == '/jsonp' && ctx.querystring) {
        //querystring处理
        let queryArr = ctx.querystring.split("&");
        let queryObj = {};
        queryArr.forEach((item) => {
            let tmp = item.split("="); 
            queryObj[tmp[0]] = tmp[1];
        })
        const callback = queryObj['callback'];
        const obj = {
            price: '18',
            tickets: 33
        }
        const args = JSON.stringify(obj);
        ctx.body = `${callback}(${args})`;
    }
    await next();
})
```

#### 1.4 总结

所以，就是利用 `<script>`标签没有跨域限制的“漏洞”来达到与第三方通讯的目的。

当需要通讯时，本站脚本创建一个 `<script>` 元素，地址指向第三方的API网址，形如：`<script src="http://www.example.net/api?param1=1&param2=2"></script>` 并提供一个回调函数来接收数据（函数名可约定，或通过地址参数传递）。     

第三方产生的响应为json数据的包装（故称之为jsonp，即json padding），形如：`allback({"name":"hax","gender":"Male"})`     

这样浏览器会调用callback函数，并传递解析后json对象作为参数，完成一次数据交互。

### 164addEventListener 再 removeListener 会不会造成内存泄漏


### addEventListener

addEventListener 再 removeListener 不会造成内存泄漏；

造成内存泄露的原因有
- 不恰当的缓存
- 队列消费不及时
- 作用域未释放

尤其是处理函数中可能引用着父级作用域，导致作用域中的数据不能被回收。所以在恰当的时候，移除监听的事件是很必要的。

### 现在浏览器添加原生事件

添加原生事件

```js
var button = document.getElementById('button');
function onClick(event) {
    button.innerHTML = 'text';
}
button.addEventListener('click', onClick);
```

给元素button添加了一个事件处理器onClick, 而处理器里面使用了button的引用。而老版本的 IE 是无法检测 DOM 节点与 JavaScript 代码之间的循环引用，因此会导致内存泄漏。

如今，现代的浏览器（包括 IE 和 Microsoft Edge）使用了更先进的垃圾回收算法，已经可以正确检测和处理循环引用了。换言之，回收节点内存时，不必非要调用 removeEventListener 了。


### 165面向对象的三要素是啥？都是啥意思？

- **封装：** 把客观事物封装成抽象的类，并且类可以把自己的数据和方法只让可信的类或者对象操作，对不可信的进行信息隐藏
- **继承：** 使用现有类的所有功能，并在无需重新编写原来的类的情况下对这些功能进行扩展
- **多态：** 一个类实例的相同方法在不同情形有不同表现形式。多态机制使具有不同内部结构的对象可以共享相同的外部接口

### 166使用原型链如何实现继承

### 继承

继承是OO语言中的一个最为人津津乐道的概念.许多OO语言都支持两种继承方式: 接口继承 和 实现继承 .接口继承只继承方法签名,而实现继承则继承实际的方法.由于js中方法没有签名,在ECMAScript中无法实现接口继承.ECMAScript只支持实现继承,而且其 实现继承 主要是依靠原型链来实现的.

### 构造函数,原型和实例的关系:

每个构造函数(constructor)都有一个原型对象(prototype),原型对象都包含一个指向构造函数的指针,而实例(instance)都包含一个指向原型对象的内部指针.

看个原型链继承的例子

```js
function Father(){
	this.property = true;
}
Father.prototype.getFatherValue = function(){
	return this.property;
}
function Son(){
	this.sonProperty = false;
}
//继承 Father
Son.prototype = new Father();//Son.prototype被重写,导致Son.prototype.constructor也一同被重写
Son.prototype.getSonVaule = function(){
	return this.sonProperty;
}
var instance = new Son();
alert(instance.getFatherValue());//true
```

但是需要注意的是，原型链并非十分完美，会存在以下问题：

- 问题一: 当原型链中包含引用类型值的原型时,该引用类型值会被所有实例共享;
- 问题二: 在创建子类型(例如创建Son的实例)时,不能向超类型(例如Father)的构造函数中传递参数.

所以在实践中，很少会单独使用原型链。从而出现了一些弥补方案

- 借用构造函数继承
- 组合继承
- 原型继承
- 寄生式继承
- 寄生组合式继承

### 167写出代码执行结果
```js
new Promise((resolve, reject) => {
  reject("1");
})
  .catch((e) => {
    console.log(1);
  })
  .then((res) => {
    console.log(2);
  });
```

### 答案

```js
1 2
```

### 解析

catch() 方法返回一个Promise，并且处理拒绝的情况。它的行为与调用Promise.prototype.then(undefined, onRejected) 相同。 (事实上, calling obj.catch(onRejected) 内部calls obj.then(undefined, onRejected))。

所以输出1，2

### 168Promise.resolve(obj)，obj 有几种可能

### 有三种可能

Promise.resolve(value)方法返回一个以给定值解析后的 Promise 对象。

- 如果这个值是一个 promise ，那么将返回这个 promise ；
- 如果这个值是 thenable（即带有"then" 方法），返回的 promise 会“跟随”这个 thenable 的对象，采用它的最终状态；
- 否则返回的 promise 将以此值完成。此函数将类 promise 对象的多层嵌套展平。

故obj有三种可能，obj可以是正常值，可以是promise对象，可以是thenable。

### 169搜索请求如何处理？搜索请求中文如何请求？

### 搜索请求处理

搜索过程中, 快速的字符输入/更变, 会导致过于频繁的请求, 浪费请求支援, 一般考虑防抖(debounce)进行优化;

**防抖**: 持续触发事件时，一定时间内没有再触发事件，函数执行一次; 如果设定的时间之前，又触发了事件，就重新开始延时

**防抖实现**

```js
function debounce(fn, wait) {    
  var timeout = null;    
  return function() {        
    if(timeout !== null) {
      clearTimeout(timeout)
    };        
    timeout = setTimeout(fn, wait);    
  }
}
```

### 搜索请求中文如何处理

一般是通过encodeURI或encodeURIComponent方法将对应的中文进行编码;


### 170介绍下原型链

### 原型链

![prototype](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-828-prototype.jpg)

#### 1.概念

每个对象都有一个指向它的原型（prototype）对象的内部链接。这个原型对象又有自己的原型，直到某个对象的原型为 null 为止（也就是不再有原型指向），组成这条链的最后一环。这种一级一级的链结构就称为原型链

#### 2.原型链特点

1. 所有的对象都有"[[prototype]]"属性（通过__proto__访问），该属性对应对象的原型
2. 所有的函数对象都有"prototype"属性，该属性的值会被赋值给该函数创建的对象的"__proto__"属性
3. 所有的原型对象都有"constructor"属性，该属性对应创建所有指向该原型的实例的构造函数
4. 函数对象和原型对象通过"prototype"和"constructor"属性进行相互关联

### 171前后端通信使用什么方案

### 前后端通信方案

1. Ajax - 是同源下的通信方式
2. WebSocket - 不受同源限制
3. CORS - 支持跨域也支持同源

#### websocket

HTTP 协议有一个缺陷：通信只能由客户端发起。所以出现了 WebSocket 。它的最大特点就是，服务器可以主动向客户端推送信息，客户端也可以主动向服务器发送信息，是真正的双向平等对话，属于服务器推送技术的一种。

其他特点包括：

1. 建立在 TCP 协议之上，服务器端的实现比较容易。
1. 与 HTTP 协议有着良好的兼容性。默认端口也是 80 和 443 ，并且握手阶段采用 HTTP 协议，因此握手时不容易屏蔽，能通过各种 HTTP 代理服务器。
3. 数据格式比较轻量，性能开销小，通信高效。
4. 可以发送文本，也可以发送二进制数据。
5. 没有同源限制，客户端可以与任意服务器通信。
6. 协议标识符是ws（如果加密，则为wss），服务器网址就是 URL。

#### CORS

CORS是一个 W3C 标准，跨域资源共享（CORS ）是一种网络浏览器的技术规范，它为Web服务器定义了一种方式，允许网页从不同的域访问其资源。而这种访问是被同源策略所禁止的。CORS 系统定义了一种浏览器和服务器交互的方式来确定是否允许跨域请求。 

它是一个妥协，有更大的灵活性，但比起简单地允许所有这些的要求来说更加安全。简言之， CORS 就是为了让 AJAX 可以实现可控的跨域访问而生的。

### 172页面上生成一万个 button，并且绑定事件，如何做（JS 原生操作 DOM）？循环绑定时的 index 是多少，为什么，怎么解决？

### 具体实现


#### 1.生成dom并绑定事件

```js
  for (var i = 0; i < 10000; i++) {
        var btn = document.createElement('button');
        btn.innerHtml = "按钮" + i;
        document.getElementsByClassName('btns')[0].appendChild(btn);
    }
```

添加大量dom元素时，出于性能考虑，可以使用文档碎片的方式添加dom，优势在于只添加一次真实dom操作，减少大量重绘时间

```js
var docFragment = document.createDocumentFragment();

for (var i = 0; i < 10000; i++) {
    var node = document.createElement('button');
    node.className = 'btn' + i
    node.innerHtml = '按钮' + i;
    docFragment.appendChild(node);
}

document.body.appendChild(docFragment);
```

#### 2.绑定事件

- 循环绑定

```javascript
for(var i=0;i < 10000;i++){
document.getElementsByClassName('btn'+i)[0].addEventListener('click', function (e) {
    //TODO ...
    //在循环绑定中，需要用到i的值，这种绑定方式在触发点击时已变为10000
    //解决办法有三种:
    //1. 将循环体内var i= 0;改为 let i = 0;
    //2.使用闭包包裹循环体，将i作为参数传入闭包
    //3.在生成button时，将i写入到button自定义属性上记录下来，如:  btn-index，需要时再读取当前元素的btn-index属性值
}, false)
}
```

不推荐，会产生大量重复的dom事件占用内存空间。

- 使用事件委托, 利用了事件的冒泡机制(假定button父节class为 btns)。推荐使用。

```javascript
document.getElementsByClassName('btns')[0].addEventListener('click', function (e) {
    var e = e || window.event;
    var target = e.target || e.srcElement;
    if (target.tagName == 'BUTTON') {
        //TODO ...
    }
}, false)
```

注意一点就是不要阻止冒泡事件!

### 173异步请求，低版本 fetch 如何低版本适配

### 低版本适配处理

- 当前浏览器不支持 fetch 时，使用 `fetch polyfill`。
- 由于 fetch 的底层实现需要用到全局下的 Promise，对于不支持 Promise 的环境还需在全局添加 `Promise polyfill`。

**fetch polyfill**

- whatwg-fetch,结合 Promise 使用 XMLHttpRequest 的方式来实现
- isomorphic-fetch
- fetch-polyfill2

### 174使用正则去掉 Dom 中的内联样式

### 代码实现

```js
var str = '<h1 id="text" style="background: #ccc;">测试元素</h1>';
var reg1 = /\s+style=\"[^\"]*\"/;

str= str.replace(reg1, '');
console.log('del style', str);
```

### 175介绍 Immuable

### 一、什么是Immutable Data

- `Immutable Data` 就是一旦创建，就不能再被更改的数据
- 对 `Immutable` 对象的任何 `修改` 、 `添加` 、 `删除` 操作都会返回一个新的 `Immutable` 对象
- `Immutable` 实现原理是 **`Persistent Data Structure`** (**持久化数据结构**)，也就是使用旧数据创建新数据时，要保证旧数据同时可用且不变
- 同时为了避免 `deepCopy` 把所有节点都复制一遍带来的性能损耗， `Immutable` 使用了 **`Structural Sharing`** (**结构共享**)，即如果对象树中一个节点发生变化，只修改这个节点和受它影响的父节点，其他节点则进行共享

下边来了解一个库， `Immutable.js` 库

### 二、为什么需要immutable

#### 1.引用带来的副作用

`javascript` 中存在两类数据类型： `基本数据类型` 和 `引用数据类型` 。js中的对象非常灵活、多变，对象赋值仅仅是传递引用地址，所以会引起很多问题。

#### 2.深拷贝带来的问题

针对引用带来的副作用，可以采用深拷贝（deep clone）的方式。深拷贝也有其性能问题，如果只拷贝部分属性，深拷贝会将其他部分也拷贝，数据量大的时候，会有很高的性能损耗。

#### 3.javascript语言本身不足

在js中实现数据不可变，有两个方法： `const` 、 `Object.freeze()` 。但是这两种方法都是浅拷贝，遇到嵌套过深的结构就需要递归处理，又会存在性能上的问题。

### 三、Immutable特点

#### 1.持续化数据结构（Persistent data structure）

`持久化数据结构` ：每次修改数据之后我们都会得到一个新的版本，且旧版本可以完好保留。

Immutable.js提供了7种不可变的数据类型： `List` 、 `Map` 、 `Stack` 、 `OrderdMap` 、 `Set` 、 `OrderedSet` 、 `Record` 。对Immutable对象操作均会返回新对象。

```js
var obj = { count:1 };
var map = Immutable.fromJs(obj);//将javascript对象转换为Immutable对象
var map2 = map.set('count',2);

console.log(map.get('count'));
console.log(map2.get('count'));
```

Immutable.js用树实现了 `持久化结构数据` ，先看下图这棵树

![tree1.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-tree1.png)

如果我们要在 g 下面插入一个节点 h ,如何插入后让原有的树保持不变？最简单的方式就是重新生成一棵树：

![tree2.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-tree2.png)

这样做显然很低效，每次操作都需要生成一颗全新的树，既费时又费空间。

#### 2.结构共享（structural sharing）

`结构共享` 就是针对上面重新生成一颗树做的优化方案。

ImmutableJS基于 `哈希映射树（Hash Array Mapped Trie）` 和 `矢量映射树(Vector Trie)` ，只克隆该副本以及它的祖先继承，其他保持不变。这样可以共享相同的部分，大大提高性能。

```js
var obj = {
	count : 1,
  list : [1,2,3,4,5]
}
var map1 = Immutable.fromJS(obj);
var map2 = map1.set('count',2);
console.log(map1.list === map2.list);//true
```

结构共享过程：

![immutable.gif](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-tree3.gif)

#### 3.支持惰性操作

函数式编程中语言中，有一个特殊的结构Seq(全称Sequence)，其他Immutable对象可以通过 `toSeq()` 进行转换。Seq有以下特性

- **Seq是不可变的** -- 一旦创建Seq，它就不能被更改、附加到、重新排列或以其他方式修改。
- **Seq是懒惰的** -- Seq只需要做很少的工作来响应任何方法调用。值在迭代过程中创建，包括在减少或转换为具体数据结构时的隐氏迭代。

以下内容不会执行任何操作，因为生成Seq值永远不会被迭代

```js
var oddSquares = Immutable.Seq.of(1, 2, 3, 4, 5, 6, 7, 8)
    .filter(x => {
        log(x % 2);
        return x % 2;
    }).map(x => {
        log(x * x);
        return x * x;
    });
```

一旦Seq被使用，它执行必要的工作。以下代码，可以通过console.log可以看出，没有创建任何数据结构，过滤器只被调用了3次，map值被调用了一次

```javascript
console.log(oddSquares.get(1));
/*
1
0
1
9
9
*/
```

Seq通常用于为JavaScript Object提供丰富的集合API。具体见Seq文档。

#### 4.强大的API机制

ImmutableJS，提供更高的方法，有些方法沿用原生js的类似，降低学习成本，有些方法提供了便捷操作，例如`setIn`，`UpdateIn`可以进行深度操作。

```js
var obj = {
  a: {
    b: {
      list: [1, 2, 3]
    }
  }
};
var map = Immutable.fromJS(obj);
var map2 = Immutable.updateIn(['a', 'b', 'list'], (list) => {
  return list.push(4);
});

console.log(map2.getIn(['a', 'b', 'list']))
// List [ 1, 2, 3, 4 ]

```

### 四、Immutable核心API

#### 1.原生js转换为immutableData

```js
Immutable.fromJS([1,2]) // immutable的 list
Immutable.fromJS({a: 1}) // immutable的 map
```

#### 2.从immutableData 回到 JavaScript 对象

```js
immutableData.toJS()
```

#### 3.判断两个immutable数据是否一致

```js
Immutable.is(immutableA, immutableB)
```

#### 4.判断是不是map或List

```js
Immutable.Map.isMap(x)
Immutable.Map.isList(x)

```

#### 5.对象合并(注意是同个类型)

```js
immutableMaB = immutableMapA.merge(immutableMaC)
```

#### 6.Map的增删查改查

```js
immutableData.get('a') // {a:1} 得到1。
immutableData.getIn(['a', 'b']) // {a:{b:2}} 得到2。访问深层次的key

// 增和改(注意不会改变原来的值，返回新的值)
immutableData.set('a', 2) // {a:1} 得到1。
immutableData.setIn(['a', 'b'], 3)
immutableData.update('a',function(x){return x+1})
immutableData.updateIn(['a', 'b'],function(x){return x+1})

// 删
immutableData.delete('a')
immutableData.deleteIn(['a', 'b'])
```

#### 7.List的增删查改

如同Map，不过参数变为数字索引。
比如immutableList.set(1, 2)

#### 8.其它便捷函数

如同underscore的方法，具体请参照文档。

### 五、Immutable优点

#### 1.Immutable降低了Mutable带来的复杂度

可变数据耦合了Time和Value的概念，造成了数据很难被回溯。

```js
function touchAndLog(touchFn) {
  let data = { key: 'value' };
  touchFn(data);
  console.log(data.key); // 猜猜会打印什么？
}
```

在不查看 `touchFn` 的代码的情况下，因为不确定它对 `data` 做了什么，你是不可能知道会打印什么（这不是废话吗）。但如果 `data` 是 Immutable 的呢，你可以很肯定的知道打印的是 `value`。

#### 2.节省内存

`ImmutableJS` 使用 `Structure Sharing` 会尽量复用内存。没有被引用的对象会被垃圾回收。

```js
import { Map} from 'immutable';
let a = Map({
  select: 'users',
  filter: Map({ name: 'Cam' })
})
let b = a.set('select', 'people');
a === b; // false
a.get('filter') === b.get('filter'); // true

```

上面a和b共享了没有变化的 `filter` 节点。

#### 3.Undo/Redo，Copy/Paste，甚至时间旅行这些功能做起来也是小菜一碟

因为每次数据都是不一样的， 只要把这些数据放在一个数组中存储起来，想回退到哪里就拿出对应的数据即可，很容易开发出撤销重做的这种功能。

#### 4.并发安全

传统的并发非常难做，因为要处理各种数据不一致的问题，发明了各种锁来解决问题。但是使用了Immutable之后，数据天生是不可变的，并发锁也不需要了。
对于javascript没有什么特殊意义，因为javascript是单线程运行，未来可能会加入，提前解决问题了。

#### 5.拥抱函数式编程

Immutable本身就是函数式编程的概念，纯函数编程比面向对象更使用于前端开发。因为只要输入一致，输出必然一致，这样开发的组件更易于调试和组装。
像 ClojureScript，Elm 等函数式编程语言中的数据类型天生都是 Immutable 的，这也是为什么 ClojureScript 基于 React 的框架 --- Om 性能比 React 还要好的原因。

### 六、Immutable的缺点

#### 1.需要学习新的API

#### 2.增加了资源文件的大小

#### 3.容易和原生对象混淆

这点是我们使用 `Immutable.js` 过程中遇到的最大问题。写代码要做思维上的转变。

虽然 `Immutable.js` 尽量尝试把API设计的原生对象类似，有的时候还是很难区别到底是 `Immutable` 对象还是原生对象，很容易混淆。

`Immutable` 中的 `Map` 和 `List` 虽对应原生 `Object` 和 `Array` ，但操作非常不同，比如你要用 `map.get('key')` 而不是 `map.key` ， `array.get(0)` 而不是 `array[0]` 。另外 `Immutable` 每次修改丢会返回新对象，很容易就忘记赋值。

使用外部库的时候，一般也需要使用原生的对象，也很容易忘记转换。
一般使用以下办法来避免类似的问题发生：

- 使用Flow或TypeScript这类有静态类型检查的工具
- 约定变量命名规则：如所有 `Immutable` 类型对象都以 `$$` 开头
- 使用 `Immutable.fromJS` 而不是 `Immutable.Map` 或 `Immutable.List` 来创建对象，这样可以避免 `Immutable` 和原生的对象之间的混用。

### 七、实践

#### 1.在React中应用

React是一个 `UI = f(state)` 库，为了解决性能问题，虚拟dom通过diff算法修改DOM，实现高效的DOM更新。

遇到个问题：当执行setState时，即使状态数据没有发生变化，也会去做virtual dom的diff，因为在React的声明周期中，多数情况下 `shouldComponentUpdate` 总是返回true。在 `shouldComponentUpdate` 进行状态比较？

React的解决办法：提供了一个 `PureRenderMixin` 、 `PureRenderMixin` 对 `shouldComponentUpdate` 方法进行了覆盖，但是 `PureRenderMixin` 里面是钱比较：

```js
var ReactComponentWithPureRenderMixin = {
  shouldComponentUpdate: function(nextProps, nextState) {
    return shallowCompare(this, nextProps, nextState);
  },
};

function shallowCompare(instance, nextProps, nextState) {
  return (
    !shallowEqual(instance.props, nextProps) ||
    !shallowEqual(instance.state, nextState)
  );
}
```

浅比较只能进行简单比较，如果数据结构复杂的话，依然会存在多余的diff过程，说明 `PureRenderMixin` 依然不是理想的解决方案。

Immutable来解决：因为immutable的 `不可变性` && `结构共享` ，能够快速进行数据比较：

```js
shouldComponentUpdate: function(nextProps, nextState) {
  return deepCompare(this, nextProps, nextState);
},
  
function deepCompare(instance, nextProps, nextState) {
	return !Immutable.is(instance.props, nextProps) || 
		!Immutable.is(instance.state, nextState);
}
```

**setState技巧**

React建议把 `this.state` 当作 `Immutbale` 的，因为修改前需要做一个deepCopy，显得很麻烦

```js
import '_' from 'lodash';

const Component = React.createClass({
  getInitialState() {
    return {
      data: { times: 0 }
    }
  },
  handleAdd() {
    let data = _.cloneDeep(this.state.data);
    data.times = data.times + 1;
    this.setState({ data: data });
    // 如果上面不做 cloneDeep，下面打印的结果会是已经加 1 后的值。
    console.log(this.state.data.times);
  }
}
```

使用Immutable后：

```javascript
getInitialState() {
    return {
      data: Map({ times: 0 })
    }
  },
  handleAdd() {
    this.setState(({data}) => ({
      data: data.update('times', v => v + 1) })
    });
  }
```

#### 2.与Flux搭配使用

由于Flux没有限定Store中的数据类型，使用 `Immutable` 非常简单。
现在实现一个类似带有添加和撤销功能的Store：

```javascript
import { Map, OrderedMap } from 'immutable';
let todos = OrderedMap();
let history = [];  // 普通数组，存放每次操作后产生的数据

let TodoStore = createStore({
  getAll() { return todos; }
});

Dispatcher.register(action => {
  if (action.actionType === 'create') {
    let id = createGUID();
    history.push(todos);  // 记录当前操作前的数据，便于撤销
    todos = todos.set(id, Map({
      id: id,
      complete: false,
      text: action.text.trim()
    }));
    TodoStore.emitChange();
  } else if (action.actionType === 'undo') {
    // 这里是撤销功能实现，
    // 只需从 history 数组中取前一次 todos 即可
    if (history.length > 0) {
      todos = history.pop();
    }
    TodoStore.emitChange();
  }
});
```

#### 3.与Redux搭配使用

由于Redux中内置的 `combineReducers` 和reducer种的 `initialState` 都为原生的Object对象，所以不能和Immutable原生搭配使用。

幸运的是，Redux不排斥使用 `Immutable` ，可以自己重写 `combineReducers` 或使用 `Redux-immutablejs` 来提供支持

### 八、总结

Immutable可以给应用带来极大的性能提升，但是否使用还是要看项目情况。由于侵入性较强，新项目引入比较容易，老项目迁移需要评估迁移。对于一些提供给外部使用的公共组件，最好不要把Immutable对象之间暴露在对外接口中。

### 九、Immutable实现机制

#### 1.简单例子

研究前先看个例子：

```js
let map1 = Immutable.Map({});

for (let i = 0; i < 800; i++) {
  map1 = map1.set(Math.random(), Math.random());
}

console.log(map1);
```

这段代码往map里写入了800个随机生成的key和value。看控制台输出
![immutable_console.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-out1.png)

- 这是一个树结构，子节点以数组的形式放在nodes属性中，nodes的最大长度是32个
- bitmap涉及到对树宽的压缩（后面讨论）

其中一个节点展开后

![immutable_console_2.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-out2.png)

这个ValueNode存的就是一组值，entry[0]是key，entry[1]是value

#### 2.原理

`Immutable` 的基本原理主要是持久化数据结构和结构共享,这里主要讨论这两部分的原理实现。


**1）Vector Trie**

**1.1 Vector Trie数据结构**

在实现持续化数据结构时，Immutable.js参考了 Vector Trie这种数据结构(这是Clojure里使用的一种数据结构，Immutable.js里的相关实现与其非常相似)。先了解其基本结构

例如我们有一个map，key全部是数字

```js
{
  0:'banana',
  1:'prape',
  2:'lemon',
  3:'orange',
  4:'apple'
}
```

为了造一棵Vector Trie，我们可以先把key转为为二进制形式：

```js
{
  '000':'banana',
  '001':'prape',
  '010':'lemon',
  '011':'orange',
  '100':'apple'
}
```

建图如下:

![vectorTrie1.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-3.png)

可以看到，Vector Trie的每个节点是一个数组，数组中有0和1两个数，表示一个二进制数，所有值都存在在叶子节点上。比如我们要找001的值时，只需要顺着 0  0 1找下来即可得到prape。

想要实现持久化数据结构也不难，添加一个5：'waterlemon'

![vectorTrie2.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-4.png)


- 可见对于一个key全是数字的map，我们完全可以通过一颗Vector Trie来实现它，同时实现持续化数据结构。
- 如果key不是数字的话，用一套映射机制把它转成数字就行。Immutable.js实现一个hash函数，可以吧一个值转换为一个相应的数字。
- 这里为了简化每个节点数组长度仅为2，这样数据量大的时候，树会变得很深，查询很耗时，所以可以扩大数组长度，Immutable选择了32.
### 2.2数字分区（Digit partitioning）
数字分区 指我们把一个key作为数字对应到一颗前缀树上，正如上节所讲。
有个key为 9128 ，以7位基数，即数组长度为7，它在Vector Trie里这么表示：

![base7.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-5.png)

本质就是将9128转化为7进制的35420，无须预先转换好，类似的操作可以每一层上依次执行。

进制转换公式
> key / radix % radix

- 为了简便，/表示向下取整

- radix：每层数组的长度，即转换为几进制
- level：当前层数，第几位数

代码实现如下

```js
const RADIX = 7;

function find(key) {
  let node = root; // root是根节点，在别的地方定义了

  // depth是当前树的深度。这种计算方式跟上面列出的式子是等价的，但可以避免多次指数计算。这个size就是上面的radix^level - 1
  for (let size = Math.pow(RADIX, (depth - 1)); size > 1; size /= RADIX) {
    node = node[Math.floor(key / size) % RADIX];
  }

  return node[key % RADIX];
}
```

**2.3位分区（Bit Partitioning）**

位分区是对数字分区的优化，数字分区方法有些耗时，每一层都要进行两次除法一次取模，并不高效。

位分区是建立在数字分区的基础上的，所有以2的整数次幂为基数的数字分区前缀树，都可以转化为位分区。基于一些位运算，避免一些耗时的计算。

位分区的本质就是：将Vector Trie每层的数字转化为bit（位表示），节省计算时间。

数字分区将key拆分为一个个数字，而位分区把key分成一组组bit。

**举个例子：**

以32路的前缀树为例，数字分区的方法是把key为32的基数拆分，而位分区是把它以5个bits拆分，因为32 = 2

那我们可以把32进制数的每一位看做5个二进制位。

前面的公式

> key / 2 % 2

根据相关位运算相关的知识：

`a / 2 === a >>> n `、`a % 2 === a & (2 - 1) `

这样就可以通过位运算得出该式子的值

代码实现如下

```js
const BITS = 5;
const WIDTH = 1 << BITS, // 25 = 32
const MASK = WIDTH - 1; // 31，即11111

function find(key) {
  let node = root; 

  for (let bits = (depth - 1) * BITS; bits > 0; bits -= BITS) {
    node = node[(key >>> bits) & MASK];
  }

  return node[key & MASK];
}
```

**2.4查找部分源码**

Vector Trie查找部分源码，这也是持久化数据结构核心

```js
get(shift, keyHash, key, notSetValue) {
  if (keyHash === undefined) {
    keyHash = hash(key);
  }
  const idx = (shift === 0 ? keyHash : keyHash >>> shift) & MASK;
  const node = this.nodes[idx];
  return node
    ? node.get(shift + SHIFT, keyHash, key, notSetValue)
    : notSetValue;
}
```

可以看到， Immutable.js 也正是采用了位分区的方式，通过位运算得到当前数组的 index 选择相应分支。

不过它的实现方式和上文所讲的有一点不同，上文中对一个key，都是“正序”存储的。

而Immutable.js里则是“倒序”，先找到key 末尾的 SHIFT 个 bit ，然后再得到它们之前的 SHIFT 个 bit ，依次往前下去，而前面我们的代码是先得到 key 开头的 SHIFT 个 bit，依次往后。

用这种方式的愿意之一也是key的大小（二进制长度）不固定。

**2.5时间复杂度**

因为采用了结构共享，在添加、删除、修改操作后，我们避免了将map所有值拷贝一遍，所有特别在数据量大的时候，Object.assgin有明显提升。

然而查询速度似乎变慢了，map里根据key查找的速度是O(1)；这里由于变成了一棵树，查询时间复杂度变成了O(log N)，因为是32叉树，准确的说是O(log N)
32叉树占用空间过大，Immutable对树的高度和宽度都进行了“压缩”。

**3）HAMT**
HAMT：hash array mapped trie，其原理和Vector Trie非常相似，不过它会对树进行压缩，以节约空间。

Immutable.js参考了HAMT对数的高度和节点内部压缩。

**3.1树高压缩**

树高压缩的原理：通过将和key值无关的节点去掉来达到压缩树高的目的。在需要的时候增加和减少检点即可。

举个例子：

有个2叉Vector Trie，现在存了一个值，key为110，被存到了0 1 1路劲下（源码中读取路径和树的路径相反，见上文）
![HAMT1.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-6.png)

这里已经展示的结构已经最简单的优化，因为现在只存了一个值，所以把与110无关的节点去掉。中间两个节点也可以去掉。如下图：

![hamt2.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-7.png)

获取该值直接从0找下来，发现直接是根节点。

如果需要添加一个值，它的key结尾也是0，怎么办，很简单，如下图：

![HAMT3.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-8.png)

我们只要在需要的时候增加或减少节点即可。

**3.2节点内部压缩-Bitmap**

 Immutable.js 的 Trie 里，每个节点数组的长度是 32 ，然而在很多情况下，这 32 个位置大部分是用不到的，这么大的数组显然也占用了很大空间。使用`Bitmap`，我们就可以对数组进行压缩

**节点内部压缩原理**：用一个二进制假值来表示节点数组的上每个位置是否有值的情况。然后通过popcount算法来从二进制假值上来获取数组有值的数量和下标。

举个例子：

先拿长度为 8 的数组

![bitmap1.jpg](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-9.jpeg)

我们实际上只是用了数组的下标对 key 进行索引，这样想数组第 5、6、7 位显然目前是毫无作用的，那 0、2、3 呢？我们有必要为了一个下标 4 去维持一个长度为5的数组吗？我们只需要指明“假想数组”中下标为 1 和为 4 的位置有数就可以了。这里就可以用到bitmap，如下：

![bitmap2.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-491-10.png)

- 以其二进制形式表达“假想的长度为8的数组”中的占位情况，1 表示数组里相应下标位置有值，0 则表示相应位置为空。
- 比如这个二进制数第 4 位（从右往左，从 0 开始数）现在是 1 ，就表示数组下标为 4 的位置有值。这样原本的长度为 8 的数组就可以压缩到 2 。
- 注意这个数组中的元素还是按照“假想数组”中的顺序排列的，这样我们若要取“假想数组”中下标为 i 的元素时，首先是判断该位置有没有值，若有，下一步就是得到在它之前有几个元素，即在二进制数里第 i 位之前有多少位为 1 ，假设数量为 a ，那么该元素在当前压缩后的数组里下标就是 a 。

具体操作中，我们可以通过`bitmap & (1 << i - 1)`，得到一个二进制数，该二进制数中只有第 i 位之前有值的地方为 1 ，其余全为 0 ，下面我们只需统计该二进制数里 1 的数量即可得到下标。计算二进制数中 1 数量的过程被称作`[popcount](https://en.wikipedia.org/wiki/Hamming_weight)`，

```js
get(shift, keyHash, key, notSetValue) {
  if (keyHash === undefined) {
    keyHash = hash(key);
  }
  const bit = 1 << ((shift === 0 ? keyHash : keyHash >>> shift) & MASK);
  const bitmap = this.bitmap;
  return (bitmap & bit) === 0
    ? notSetValue
    : this.nodes[popCount(bitmap & (bit - 1))].get(
        shift + SHIFT,
        keyHash,
        key,
        notSetValue
      );
}
```

可见它与我们上一篇看到的源码并没有太大不同（Immutable.js 里如果一个数组占用不超过一半（ 16 个），就会对其进行压缩，上一篇的源码就是没有压缩下的情况），就是多了一个用 bitmap 计算数组下标的过程，方式也跟上文所讲的一样，对于这个`popCount`方法，我把源码也贴出来：

```js
function popCount(x) {
  x -= (x >> 1) & 0x55555555;
  x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
  x = (x + (x >> 4)) & 0x0f0f0f0f;
  x += x >> 8;
  x += x >> 16;
  return x & 0x7f;
}
```
**4）Transient**

- Immutable.js 中的数据结构有两种形态，“**不可变**”和“**可变**”。
- 虽然“不可变”是 Immutable.js 的主要优势，但“可变”形态下的操作当然效率更高。有时对于某一系列操作，我们只需要得到**这组操作结束后的状态**，若中间的每一个操作都用不可变数据结构去实现显然有些多余。
- 我们就可以使用`[withMutations](http://facebook.github.io/immutable-js#batching-mutations)`方法对相应数据结构进行临时的“可变”操作，最后再返回一个不可变的结构，这就是`Transient`，比如这样：

```js
let map = new Immutable.Map({});
map = map.withMutations((m) => {
  // 开启Transient
  m.set('a', 1); // 我们可以直接在m上进行修改，不需要 m = m.set('a', 1)
  m.set('b', 2);
  m.set('c', 3);
});
// Transient结束
```

实际上， Immutable.js 里很多方法都使用了`withMutations`构造临时的可变数据结构来提高效率，比如 Map 中的`map`、`deleteAll`方法以及 Map 的构造函数。

**5）hash冲突**

**hash冲突**： Immutable.js 会先对 key 进行 hash ，根据 hash 后的值存到树的相应位置里。不同的 key 被 hash 后的结果是可能相同的，即便概率应当很小。

**解决方法**：将冲突的节点扩展成一个线性结构，即数组，数组里直接存一组组[key,value]，查找到此处时遍历该数组找到匹配的key。

虽然这里的时间复杂度是线性的，考虑到发生hash冲突的概率很低，所以时间复杂度的增加可以忽略不计。

### 176jsonp 为什么不支持 post 方法

### 一、jsonp原理

#### 1.1 跳过同源策略的标签

浏览器的 同源策略 把跨域请求都禁止了，但是页面中 `link`  `script` `img` `iframe` `a` 标签是个例外，这些标签的外链是不受同源策略限制的。

`jsonp` 就是利用了上面 `script` 标签特性来进行跨域数据访问。

#### 1.2 jsonp 的实现机制

1. 与服务端约定好一个 回调函数名 ，在客户端定义好这个函数，在请求url中添加 `callback= 函数名` 的查询字符。
1. 服务端接收到请求之后，将函数名和需要返回的数据，拼接成 `"函数名(data)"` 函数执行的形式返回
1. 页面接收到数据后，解析完直接执行了这个回调函数，这时数据就成功传输到了客户端。

- 客户端代码：

```js
    var flightHandler = function (data) {
        alert('你查询的航班结果是：票价 ' + data.price + ' 元，' + '余票 ' + data.tickets + ' 张。');
    };
    
    var url = "http://localhost:8080/jsonp?callback=flightHandler";
    var script = document.createElement('script');
    script.setAttribute('src', url);
    document.getElementsByTagName('head')[0].appendChild(script);
```

- 服务端代码：koa2实现一个服务

```js
app.use(async (ctx, next) => {
    if (ctx.path == '/jsonp' && ctx.querystring) {
        //querystring处理
        let queryArr = ctx.querystring.split("&");
        let queryObj = {};
        queryArr.forEach((item) => {
            let tmp = item.split("="); 
            queryObj[tmp[0]] = tmp[1];
        })
        const callback = queryObj['callback'];
        const obj = {
            price: '18',
            tickets: 33
        }
        const args = JSON.stringify(obj);
        ctx.body = `${callback}(${args})`;
    }
    await next();
})
```

### 二、为什么不支持 POST

- script 的 src 不能发送 POST 请求
- POST请求会引发 跨域检查

规范要求，对于会给服务器产生副作用的请求（除GET以外的别的HTT请求、或者搭配某种MIME类型的POST），服务器都会使用 OPTIONS 发送一个 预检请求，来获知服务器是否允许该跨域请求。

### 177介绍 koa2，原理是什么？

### Koa2

Koa是继Express之后，Node的又一主流Web开发框架。相比于Express，Koa只保留了核心的中间件处理逻辑，去掉了路由，模板，以及其他一些功能，是一个基于Node实现的Web框架，特点是优雅、简洁、健壮、体积小、表现力强。它所有的功能通过插件的形式来实现。

#### 1.原理

Koa2是一个基于Node实现的Web框架，特点是优雅、简洁、健壮、体积小、表现力强。它所有的功能通过插件的形式来实现。

koa2 是通过封装原生的node http模块。koa的 Context 把 Node 的 Request 对象和 Response 对象封装到单个对象中，并且暴露给中间件等回调函数.

最主要的核心是 **中间件机制洋葱模型**

![洋葱模型](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-487-middleware.png)

通过use()注册多个中间件放入数组中，然后从外层开始往内执行，遇到next()后进入下一个中间件，当所有中间件执行完后，开始返回，依次执行中间件中未执行的部分.整体流程就是递归处理。

```js
function compose(middleware) {
    // console.log(middleware)
    // [ [AsyncFunction: fn1], [AsyncFunction: fn2], [AsyncFunction: fn3] ]
    return () => {
      // 先执行第一个函数
      return dispatch(0)
  
      function dispatch(i) {
        let fn = middleware[i]
        // 如何不存在直接返回 Promise
        if (!fn) {
          return Promise.resolve()
        }
        // step1: 返回一个 Promise，因此单纯变成一个 Promise 且 立即执行
        // step2: 往当前中间件传入一个next()方法，当这个中间件有执行 next 的时候才执行下一个中间件
        return Promise.resolve(fn(function next() {
          // 执行下一个中间件
          return dispatch(i + 1)
        }))
      }
    }
  }
```

核心代码是 `return Promise.resolve(fn(context, dispatch.bind(null, i + 1)));` 递归遍历，直到遍历完所有的中间件next，生成一个多层嵌套的promise函数。

koa的中间件处理可以当做是洋葱模型。中间件数组中中间件的执行是通过递归的方式来执行，调用dispatch函数，从第一个开始执行，当有next方法时创建一个promise，等到下一个中间件执行结果后再执行next后端代码。当第二个中间件也有next方法时，依然会创建一个新的promise等待下一个中间件的执行结果，这也就是中间件next的执行原理

`app.use()` 将中间件push到中间件数组中，然后在listen方法中通过调用compose方法进行集中处理。

#### 2.Koa基本组成

- `application.js`：Application(或Koa)负责管理中间件，以及处理请求
- `context.js`：Context维护了一个请求的上下文环境
- `request.js`：Request对`req`做了抽象和封装
- `response.js`：Response对`res`做了抽象和封装

**1）Application**

主要维护中间件以及其它一些环境

```js
// application.js
module.exports = class Application extends Emitter {
  constructor() {
    super();
    this.proxy = false;
    this.middleware = [];
    this.subdomainOffset = 2;
    this.env = process.env.NODE_ENV || 'development';
    this.context = Object.create(context);
    this.request = Object.create(request);
    this.response = Object.create(response);
  }
  // ...
```

通过 app.use(fn) 可以将 fn 添加到中间件列表 this.middleware 中。

app.listen 方法源码如下：

```js
// application.js
listen() {
  debug('listen');
  const server = http.createServer(this.callback());
  return server.listen.apply(server, arguments);
}
```

首先会通过 this.callback 方法来返回一个函数作为 http.createServer 的回调函数，然后进行监听。我们已经知道， http.createServer 的回调函数接收两个参数: req 和 res，下面来看this.callback 的实现：

```js
// application.js
callback() {
  const fn = compose(this.middleware);
  if (!this.listeners('error').length) this.on('error', this.onerror);
  return (req, res) => {
    res.statusCode = 404;
    const ctx = this.createContext(req, res);
    onFinished(res, ctx.onerror);
    fn(ctx).then(() => respond(ctx)).catch(ctx.onerror);
  };
}
```

首先是将所有的中间件通过 compose 组合成一个函数 fn，然后返回 http.createServer 所需要的回调函数。于是我们可以看到，当服务器收到一个请求的时候，会使用 req 和 res 通过 this.createContext 方法来创建一个上下文环境 ctx，然后使用 fn 来进行中间件的逻辑处理。

**2）Context**

通过上面的分析，我们已经可以大概得知Koa处理请求的过程：当请求到来的时候，会通过 req 和 res 来创建一个 context (ctx)，然后执行中间件。

事实上，在创建 context 的时候，还会同时创建 request 和 response，通过下图可以比较直观地看到所有这些对象之间的关系。

![context](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-487-koa2.png)

- 最左边一列表示每个文件的导出对象
- 中间一列表示每个Koa应用及其维护的属性
- 右边两列表示对应每个请求所维护的一些对象
- 黑色的线表示实例化
- 红色的线表示原型链
- 蓝色的线表示属性

实际上， ctx 主要的功能是代理 request 和 response 的功能，提供了对 request 和 response 对象的便捷访问能力。在源码中，我们可以看到：

```js
// context.js
delegate(proto, 'response')
  .method('attachment')
  // ...
  .access('status')
  // ...
  .getter('writable');

delegate(proto, 'request')
  .method('acceptsLanguages')
  // ...
  .access('querystring')
  // ...
  .getter('ip');
```

这里使用了 delegates 模块来实现属性访问的代理。简单来说，通过 delegate(proto, 'response') ，当访问 proto 的代理属性的时候，实际上是在访问 proto.response 的对应属性。

**3）中间件的执行**

在上面已经提到，所有的中间件会经过 compose 处理，返回一个新的函数。该模块源码如下：

```js
function compose(middleware) {
  // 错误处理
  if (!Array.isArray(middleware)) throw new TypeError('Middleware stack must be an array!')
  for (const fn of middleware) {
    if (typeof fn !== 'function') throw new TypeError('Middleware must be composed of functions!')
  }

  return function(context, next) {
    // last called middleware #
    let index = -1
    return dispatch(0)

    function dispatch(i) {
      if (i <= index) return Promise.reject(new Error('next() called multiple times'))
      // 当前执行第 i 个中间件
      index = i
      let fn = middleware[i]
      // 所有的中间件执行完毕
      if (i === middleware.length) fn = next
      if (!fn) return Promise.resolve()

      try {
        // 执行当前的中间件
        // 这里的fn也就是app.use(fn)中的fn
        return Promise.resolve(fn(context, function next() {
          return dispatch(i + 1)
        }))
      } catch (err) {
        return Promise.reject(err)
      }
    }
  }
}
```

Koa的中间件支持普通函数，返回一个Promise的函数，以及async函数。由于generator函数中间件在新的版本中将不再支持，因此不建议使用。


### 178JavaScript 里垃圾回收机制是什么，常用的是哪种，怎么处理的

### JavaScript中的垃圾回收

V8（javascript引擎）的新老空间内存分配与大小限制

#### 一、新老空间

凡事都有一把双刃剑，在垃圾回收的演变过程中人们发现，没有一种特定的垃圾回收机制是可以完美的解决问题，因此V8采用了新生代与老生代结合的垃圾回收方式，将内存分为新生代和老生代。 新生代频繁进行GC，空间小，采用的是空间换时间的scavenge算法，所以又划分为两块semispace，From和To。 老生代大部分保存的是存活时间较长的或者较大的对象。采用的是mark-sweep（主）&mark-compact（辅）算法。

V8限制了js对象可以使用的内存空间，不止是因为最初V8是作为浏览器引擎而设计的。还有其垃圾回收机制的影响因素。V8使用stop-the-world（全停顿）, generational, accurate的垃圾回收器。在执行回收之时会暂时中断程序的执行，而且只处理对象堆栈。当内存达到一定的体积时，进行一次垃圾回收的时间将会很长，从而影响其相应而造成浏览器假死的状况。因此，在V8中限制老生代64位为1.4GB，32位为0.7GB，新生代64位为32M，32位为16M。 当然，如果需要更大的内存空间，在node中可以进行更改。

#### 二、对象晋升

新生成的对象放入新生代内存中，那哪些对象会被放入老生代中呢？大部分放入老生代的对象是由新生代晋升而来。对象的晋升的方式：

当新生代的To semispace内存占满25%时，此时再从From semispace拷贝对象将不会再放入To空间中以防影响后续的新对象分配，而将其直接复制到老生代空间中。

在进行一次垃圾回收后，第二次GC时，发现已经经历过一次GC的对象在从From空间复制时直接复制到老生代。

在新对象分配时大部分对象被分配到新生代的From semispace，但当这个对象的体积过大，超过1MB的内存页时，直接分配到老生代中的large Object Space。

#### 三、新生代的GC机制与优缺点

**回收机制**

新生代采用Scavenge算法，在scavenge算法的实现过程中，则主要采用了cheney算法。即使用复制方式来实现垃圾回收。它将内存一分为二，每一个空间都是一个semispace。

处于使用状态的是From空间，闲置的是To空间。当分配对象时，先是分配到From空间，垃圾回收时会检查From空间中存活的对象，将其复制到To空间，回收其他的对象。完成复制后会进行紧缩，From和To空间的调换。如此循环往复。

**优势**

由其执行的算法及过程我们可以了解到，在新生代的垃圾回收过程中，总是由一半的semispace是空余的。scavenge只复制存活的对象，在新生代的内存中，存活的对象相对较少，所以使用这个算法恰到好处。

#### 四、老生代的GC机制与优缺点

**回收机制**

由于的scavenge算法只复制存活的对象，如果在老生代中也使用此算法的话就会造成复制很多对象，效率低，并且造成很大的内存空间浪费。 老生代中采用的则是mark-sweep（标记清除）和mark-compact（标记整理）结合的方式。而为什么使用两者结合呢？这就要讲到两者的优点与缺点。

**mark-sweep（标记清除）**

1）优点

- 标记清除需要标记堆内存中的所有对象，标记出在使用的对象，清除那些没有被标记的对象。在老生代内存中与新生代相反，不使用的对象只占很小一部分，所以清除不用的对象效率高。
- mark-sweep不会将内存空间分为两半，所以，不会浪费一半空间。

2）缺点

但标记清除会造成一个问题，就是在清除过后会导致内存不连续，造成内存碎片，如果此时需要储存一个很大的内存而空间又不够的时候就会造成没有必要的反复垃圾回收。

**mark-compact（标记整理）**

1）优点

此时标记整理就可以出场了，在标记清除的过程中，标记整理会将存活的对象和需要清除的对象移动到两端。然后将其中一段需要清除的消灭掉，可以解决标记清除造成的内存碎片问题。

2）缺点

但是在紧缩内存的过程中需要移动对象，效率比较低。所以V8在清理时主要会使用Mark-sweep,在空间不足以对新生代中晋升过来的对象进行分配时才会使用Mark-compact。

#### 五、垃圾回收机制的优化

增量标记(在老空间里引入了此方式)

scavenge算法,mark-sweep及mark-compact都会导致stop-the-world（全停顿）。而全停顿很容易带来明显的程序迟滞，标记阶段很容易就会超过100ms，因此V8引入了增量标记，将标记阶段分为若干小步骤，每个步骤控制在5ms内，每运行一段时间标记动作，就让JavaScript程序执行一会儿，如此交替，明显地提高了程序流畅性，一定程度上避免了长时间卡顿。






### 179addEventListener 的第三个参数的作用



### 180获取 id 为 netease 节点下所有的 checkbox 子元素(不用框架，注意兼容)



### 181如何获取一个对象的深度



### 182说一下 splice 和 slice 的功能用法



### 183函数中的 this 有几种



### 184如何同时获取 html 中的 h1,h2,h3,h4,h5,h6 中的内容



### 185JavaScript 的执行流程



### 186IOC 是啥，应用场景是啥？



### 187写出代码执行的打印结果
```js
function a(obj) {
  obj.a = 2;
  obj = { a: 3 };
  return obj;
}
const obj = { a: 1 };
a(obj);
console.log(obj);
```



### 188实现函数
```js
d1,,,
d2,,,
d3,,,

把上边的字符串输出1，2，3的和 //6
```



### 189怎么实现 this 对象的深拷贝



### 190使用 canvas 绘图时如何组织成通用组件



### 191介绍中介者模式



### 192介绍 service worker



### 193介绍事件代理以及优缺点，主要解决什么问题



### 194介绍下 this 的各种情况



### 195使用路由时出现问题如何解决



### 196介绍 AST（Abstract Syntax Tree）抽象语法树



### 197== 和 ===的区别，什么情况下用相等==



### 198bind、call、apply 的区别



### 199介绍暂时性死区



### 200ES6 中的 map 和原生的对象有什么区别



### 201对纯函数的理解



### 202介绍 JSX



### 203如何设计一个 localStorage，保证数据的实效性



### 204实现 sum 方法，使 sum(x)(y),sum(x,y)返回的结果相同



### 205两个对象如何比较



### 206介绍 dom 树对比



### 207如何设计状态树



### 208Ajax 发生跨域要设置什么（前端）



### 209加上 CORS 之后从发起到请求正式成功的过程



### 210JavaScript 变量类型分为几种，区别是什么



### 211ES5 和 ES6 有什么区别



### 212取数组的最大值（ES5、ES6）



### 213some、every、find、filter、map、forEach 有什么区别



### 214页面上有一个 input，还有一个 p 标签，改变 input 后 p 标签就跟着变化，如何处理？监听 input 的哪个事件，在什么时候触发？



### 215Promise 和 async/await，和 Callback 有什么区别



### 216项目中对于用户体验做过什么优化



### 217RESTful 常用的 Method



### 218如何实现 H5 手机端的适配



### 219如何去除 url 中的#号



### 220介绍 webp 这个图片文件格式



### 221ajax 如何处理跨域？CORSr 如何设置？



### 222Async 里面有多个 await 请求，可以怎么优化


#### 1.可以使俩个请求并行处理

```js
//串行请求
const showColumnInfo = async (id) => {
  console.time('showColumnInfo')
  const Promise1 = await getColumn('awaitPromise1')
  const Promise2 = await getColumn('awaitPromise2')
  console.log(`name:${Promise1.name}`)
  console.log(`description:${Promise1.description}`)
  console.log(`name:${Promise2.name}`)
  console.log(`description:${Promise2.description}`)
  console.timeEnd('showColumnInfo') // 4349.122ms
}
showColumnInfo()

//并行请求
const showColumnInfo = async (id) => {
  console.time('showColumnInfo')
  const Promise1 = getColumn('awaitPromise1')
  const Promise2 = getColumn('awaitPromise2')

  const awaitPromise1 = await Promise1
  const awaitPromise2 = await Promise2
  console.log(`name:${awaitPromise1.name}`)
  console.log(`description:${awaitPromise1.description}`)
  console.log(`name:${awaitPromise2.name}`)
  console.log(`description:${awaitPromise2.description}`)
  console.timeEnd('showColumnInfo') // 2526.615ms
}
showColumnInfo()
```

#### 2.使用Promise.all()让多个await操作并行

```js
const showColumnInfo = async (id) => {
  console.time('showColumnInfo')
  const [Promise1, Promise2] = await Promise.all([
    getZhihuColumn('Promise1'),
    getZhihuColumn('Promise2')
  ])

  console.log(`name:${qianduanzPromise1hidian.name}`)
  console.log(`description:${Promise1.description}`)

  console.log(`name:${Promise2.name}`)
  console.log(`description:${Promise2.description}`)

  console.timeEnd('showColumnInfo')
}
showColumnInfo() // 2630.869ms
```

### 223介绍观察者模式


### 观察者模式

#### 1.定义

观察者模式定义了对象之间的一对多依赖，这样一来，当一个对象改变状态时，它的所有依赖者都会收到通知并自动更新

#### 2.主要解决的问题

一个对象状态改变给其他对象通知的问题，而且要考虑到易用和低耦合，保证高度的协作。

#### 3.优点

1. 观察者和被观察者是抽象耦合的。 
2. 建立一套触发机制。

#### 4.缺点

1. 如果一个被观察者对象有很多的直接和间接的观察者的话，将所有的观察者都通知到会花费很多时间。 
2. 如果在观察者和观察目标之间有循环依赖的话，观察目标会触发它们之间进行循环调用，可能导致系统崩溃。 
3. 观察者模式没有相应的机制让观察者知道所观察的目标对象是怎么发生变化的，而仅仅只是知道观察目标发生了变化。

### 224表单可以跨域吗


### 答案

表单可以直接跨域进行提交, 但更新页面时, 不会获取到任何跨域页面的信息;

ajax实质是脚本运行, 受到同源策略的规范;

### 225nextTick 是在本次循环执行，还是在下次，setTimeout(() => {}, 0)呢？


### 答案

nextTick 在本次循环执行, 且全部执行, setTimeout 在下次循环执行

### 解析

由于js是单线程，js设计者把任务分为同步任务和异步任务，同步任务都在主线程上排队执行，前面任务没有执行完成，后面的任务会一直等待；异步任务则是挂在在一个任务队列里，等待主线程所有任务执行完成后，通知任务队列可以把可执行的任务放到主线程执行。异步任务放到主线程执行完后，又通知任务队列把下一个异步任务放到主线程中执行。这个过程一直持续，直到异步任务执行完成，这个持续重复的过程就叫Event loop。而一次循环就是一次tick 。

在任务队列中的异步任务又可以分为两种microtast（微任务） 和 macrotask（宏任务）

- microtast（微任务）：Promise， process.nextTick， Object.observe， MutationObserver
- macrotask（宏任务）：script整体代码、setTimeout、 setInterval等

执行优先级上，先执行宏任务macrotask，再执行微任务mincrotask。

执行过程中需要注意的几点是：

- 在一次event loop中，microtask在这一次循环中是一直取一直取，直到清空microtask队列，而macrotask则是一次循环取一次。
- 如果执行事件循环的过程中又加入了异步任务，如果是macrotask，则放到macrotask末尾，等待下一轮循环再执行。如果是microtask，则放到本次event loop中的microtask任务末尾继续执行。直到microtask队列清空。

### 226通过什么做到并发请求


### 实现方式

在传统web服务模型中，大多都使用多线程来解决并发的问题，因为I/O 是阻塞的，单线程就意味着用户要等待，显然这是不合理的，所以创建多个线程来响应用户的请求。

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-368-req1.png)

JavaScript是解析性语言，代码按照编码顺序一行一行被压进stack里面执行，执行完成后移除然后继续压下一行代码块进去执行。上面代码块的堆栈图，当主线程接受了request后，程序被压进同步执行的sleep执行块（我们假设这里就是程序的业务处理），如果在这10s内有第二个request进来就会被压进stack里面等待10s执行完成后再进一步处理下一个请求，后面的请求都会被挂起等待前面的同步执行完成后再执行。

事件驱动可以使单线程的效率高，同时处理数万级的并发而不会造成阻塞。

![](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-368-req2.png)

1、每个进程只有一个主线程在执行程序代码，形成一个执行栈（execution context stack)。

2、主线程之外，还维护了一个"事件队列"（Event queue）。当用户的网络请求或者其它的异步操作到来时，都会把它放到Event Queue之中，此时并不会立即执行它，代码也不会被阻塞，继续往下走，直到主线程代码执行完毕。

3、主线程代码执行完毕完成后，然后通过Event Loop，也就是事件循环机制，开始到Event Queue的开头取出第一个事件，从线程池中分配一个线程去执行这个事件，接下来继续取出第二个事件，再从线程池中分配一个线程去执行，然后第三个，第四个。主线程不断的检查事件队列中是否有未执行的事件，直到事件队列中所有事件都执行完了，此后每当有新的事件加入到事件队列中，都会通知主线程按顺序取出交EventLoop处理。当有事件执行完毕后，会通知主线程，主线程执行回调，线程归还给线程池。

4、主线程不断重复上面的第三步。

### 227说一下变量的作用域链


### 变量的作用域链

已知 JavaScript 代码执行一段可执行代码时，会创建对应的执行上下文。在创建执行上下文时，会创建作用域链（因为引用了外部环境）。

查找变量的时候，会先从当前上下文的环境记录中查找，如果没有找到，就会从上级执行上下文的环境记录中查找，一直找到全局上下文的环境记录。这样有多个执行上下文的环境记录构成的链表，就叫做作用域链。

变量的作用域区别于this指针，变量作用域是静态的，在变量声明后就确定的，而this则是动态的，根据最后的调用情况判断；

在js中，术语“全局变量”指的是定义在所有函数之外的变量（也就是定义在全局代码中的变量），与之相对的是“局部变量”，所指的是在某个函数中定义的变量。其中，函数内的代码可以访问自己上层函数的变量，也可以访问全局变量，这样就构成了作用域链。另外，隐式声明（没有使用var等语句）一个变量，该变量就会被默认为全局变量。

### 深入一些

作用域链包含了执行环境有权访问的变量、函数的有序访问。它是一个由变量对象(VO/AO)组成的单向链表，主要用来进行变量查找。

JS内部有一个[[scope]]属性，这个属性就是指向作用域链的顶端。

```js
var val='全局变量'
function handle(y){
  var val='局部变量';
  function s(){
    var z=0;
    alert(val);
  }
  s();
}
handle(5);
```

分析上面的代码的 作用域链：

- 全局执行环境：`[[scope]]----->VO[handle,val]`  只有全局VO，`[[scope]]`直接指向VO。
- 函数AA执行环境：`[[scope]]---->VO[[y,s,val]VO[[handle,val]]`，首先全局VO压入栈，然后函数AA VO压入栈顶，`[[scope]]`属性指向栈顶，变量、函数搜索就从栈顶开始。
- 函数s执行环境:`[[scope]]--->VO[[z]]VO[[y,s,val]VO[[handle,val]]`，首先全局VO压入栈，然后依次AA，s压入栈，s处于栈顶，`[[scope]]`属性直接指向s的VO。
- 应用：比如调用s，进入s执行环境，在执行alert时，首先会去查找bb的申明，会先在作用域链的顶端查找，没查到就会沿着链继续往下查找，直到查到就停止。

**总结：**

函数执行时，将当前的函数的VO放在链表开头，后面依次是上层函数，最后是全局对象。变量查找则依次从链表的顶端开始。JS有个内部属性`[[scope]]`，这个属性包含了函数的作用域对象的集合，这个集合就称为函数的作用域链。它决定了，哪些变量或者函数能在当前函数中被访问，以及它的访问顺序。

### 228观察者和订阅-发布的区别，各自用在哪里


### 区别

订阅-发布是观察者模式的一个变种

订阅-发布，观察者只有订阅了才能接受到被观察者的消息，同时观察者还可以取消接受被观察者的消息，也就是说在观察者和被观察者之间存在一个经纪人Broker来管理观察者和被观察者。

从表面上看：

1. 观察者模式里，只有两个角色 —— 观察者 + 被观察者
2. 而发布订阅模式里，却不仅仅只有发布者和订阅者两个角色，还有一个经常被我们忽略的 —— 经纪人Broker

往更深层次讲：

1. 观察者和被观察者，是松耦合的关系
2. 发布者和订阅者，则完全不存在耦合

从使用层面上讲： 

1. 观察者模式，多用于单个应用内部
2. 发布订阅模式，则更多的是一种跨应用的模式(cross-application pattern)，比如消息中间件

### 其他说明

发布-订阅模式是前端常用的一种设计模式，现在主流的MVVM框架，都大量使用了此设计模式，其主要作用有以下两点：

- 一是可以实现模块间通信
- 二是可以在一定程度上实现异步编程。

前端的事件绑定有三要素：

- 一是传入事件类型
- 二是声明对应的回调方法
- 三是触发条件；触发条件为对应的事件类型。前端DOM的事件系统本质也是发布-订阅模式，而我们在业务处理中所应有的模式也与此类似，只不过发布订阅模式应用的是自定义事件类型，可以自定义。

### 229写一个匹配 Html 标签的正则


### 代码实现

```js
var str1 = '<div class="div">51515<p class="odd" id="odd">123</p>123456</div>';

var regHtml =/<\s*\/?\s*[a-zA-z_]([^>]*?["][^"]*["])*[^>"]*>/g;

console.log('test html <>', str1.match(regHtml));
```

### 230写一个匹配 ip 地址的正则


### 代码实现

```js
var regIp = /^((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}$/;

console.log('test 192.168.4.154', regIp.test('192.168.4.154'));
```

### 231reduce 函数的功能，如何实现的，动手实现一下


### 代码实现

```js
Array.prototype.myReduce = function(fn, initialValue) {
    if (this.length === 0) {
        if (initialValue === undefined) {
            console.error("reduce of empty array with no initialValue")
        } else {
            return initialValue
        }
    } else {
        var prev = initialValue !== undefined ? initialValue : this[0]
        var startIndex = initialValue !== undefined ? 0 : 1
        for (var i = startIndex; i < this.length; i++) {
            prev = fn(prev, this[i])
        }
        return prev
    }
}
var arr1 = [1, 2, 3, 4]
var res = arr1.myReduce(function (sum, item) {
    return sum + item}, 1)
console.log(res);
```

### 232对 async、await 的理解，内部原理是怎样的？


### 一、理解

async 是Generator函数的语法糖，并对Generator函数进行了改进

**async:** 声明一个异步函数，自动将常规函数转换成promise，返回值也是一个promise对象，只有async函数内部的异步操作执行完，才会执行then方法指定的回调函数，内部可以使用await；

**await:** 暂停异步的功能执行，放在promise调用之前，await强制其他代码等待，直到promise完成并返回结果，只能与promise一起使用，不适用于回调，只能在async函数内部使用。

**1）更好的语义化**

async 和 await, 比起星号和yield，语义更加清楚，async表示函数里面有异步操作，await表示紧跟在后面的表达式需要等待结果。

**2）更广的适用性**

co模块约定，yield命令后面只能是Thunk函数或者Promise对象， 而async函数的await后面，可以是Promise和原始类型值(数值、字符串和布尔值，但这时会自动转成立即 resolved 的 Promise 对象,  查看spawn函数中Promise.resolve(next.value))

**3）返回值是Promise**

比Generator函数的返回值是Iterator对象方便，可以使用then方法指定下一步操作


### 二、原理

Async函数的实现原理就是将Generator函数和自动执行器包装在一个函数里。

与 generator 相比，多了以下几个特性：

- 内置执行器，无需手动执行 next() 方法
- await 后面的函数可以是 promise 对象也可以是普通 function，而 yield 关键字后面必须得是 thunk 函数或 promise 对象

```js
async function fn(args) {
  // ...
}

// 等同于

function fn(args) {
  return spawn(function* () {
    // ...
  });
}
```

而 spawn 函数就是所谓的自动执行器了

```js
function spawn(genF){
    return new Promise((resolve, reject)=>{
        const gen = genF() // 先将Generator函数执行下，拿到遍历器对象
        function step(nextF) {
            let next
            try {
                next = nextF()
            } catch(e){
                return reject(e)
            }
            if(next.done){
                return resolve(next.value)
            }
            Promise.resolve(next.value).then((v)=>{
                step(()=>{return gen.next(v)})
            }, (e)=>{
                step(()=>{return gen.throw(e)})
            })
        }
        step(()=> {return gen.next(undefinex)})
    })
}

```


### 233new 的实现原理，动手实现一个 new


### new做了什么

new 运算符创建一个用户定义的对象类型的实例或具有构造函数的内置对象的实例。new 关键字会进行如下的操作：

- 创建一个空的简单JavaScript对象（即{}）；
- 链接该对象（即设置该对象的构造函数）到另一个对象 ；
- 将步骤1新创建的对象作为this的上下文 ；
- 如果该函数没有返回对象，则返回this。

### 代码实现

#### 1.简单实现

```js
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
```

#### 2.更完整的实现

```js
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

### 234JavaScript 异步解决方案的发展历程以及优缺点


### JavaScript 异步解决方案发展历程

- 1.callback
  - 优点：逻辑简单。
  - 缺点：深层级产生回调地狱。
- 2.Promise
  - 优点：一旦状态改变，就不会再变，任何时候都可以得到这个结果；可以将异步操作以同步操作的流程表达出来，避免了层层嵌套的回调函数
  - 缺点：无法取消；当处于 pending 状态时，无法得知目前进展到哪一个阶段。
- 3.Generator
  - 优点：执行可控；每一步可以传递数据，也可以传递异常。
  - 缺点：控制流程复杂，成本较高。
- 4.async/await
  - 优点：代码清晰，不需链式调用就可以处理回调地狱的问题；错误可以被 try catch。
  - 缺点：控制流程复杂，成本较高。

### 235base64 为什么能提升性能，缺点


### base64

图片的 base64 编码就是可以将一副图片数据编码成一串字符串，使用该字符串代替图像地址。

意义:网页上的每一个图片，都是需要消耗一个 http 请求下载而来的（所有才有了 csssprites 技术的应运而生，但是 csssprites 有自身的局限性）。

图片的下载始终都要向服务器发出请求，要是图片的下载不用向服务器发出请求，base64 可以随着 HTML 的下载同时下载到本地.减少 https 请求。

base64减少请求数量，是这几年的一个优秀性能建议。虽然如此，也不是说它就没有缺陷。为了使页面加载更快，我们实际上可以通过高效的传输静态资源来实现，而不只是减少几个请求。

其中一个从减少请求数量诞生并被推崇的实践是使用Base64编码：将外部资源（e.g. 图片）直接嵌入到使用它的文本（e.g.样式表）中。减少HTTP请求数量的关键是，所有资源（样式表或图片）能够在同一时间到达。

**缺点：**

内容编码后的体积会变大，编码和解码需要额外的工作量。

1、CRP 的阻塞 使用 Base64 的好处是能够减少一个图片的 HTTP 请求，然而，与之同时付出的代价则是 CSS 文件体积的增大。 而 CSS 文件体积的增大意味着什么呢？意味着 CRP 的阻塞。 CRP（Critical Rendering Path，关键渲染路径）：当浏览器从服务器接收到一个 HTML 页面的请求时，到屏幕上渲染出来要经过很多个步骤。浏览器完成这一系列的运行，或者说渲染出来我们常常称之为“关键渲染路径”。 通俗而言，就是图片不会导致关键渲染路径的阻塞，而转化为 Base64 的图片大大增加了 CSS 文件的体积，CSS 文件的体积直接影响渲染，导致用户会长时间注视空白屏幕。HTML 和 CSS 会阻塞渲染，而图片不会。

2、页面解析 CSS 生成的 CSSOM 时间增加 Base64 跟 CSS 混在一起，大大增加了浏览器需要解析 CSS 树的耗时。其实解析 CSS 树的过程是很快的，一般在几十微妙到几毫秒之间。 CSS 对象模型 (CSSOM)：CSSOM 是一个建立在 web 页面上的 CSS 样式的映射，它和 DOM 类似，但是只针对 CSS 而不是 HTML。 CSSOM 生成过程大致是，解析 HTML ，在文档的 head 部分遇到了一个 link 标记，该标记引用一个外部 CSS 样式表，下载该样式表后根据上述过程生成 CSSOM 树。 这里我们要知道的是，CSSOM 阻止任何东西渲染，（意味着在 CSS 没处理好之前所有东西都不会展示），而如果 CSS 文件中混入了 Base64，那么（因为文件体积的大幅增长）解析时间会增长到十倍以上。 而且，最重要的是，增加的解析时间全部都在关键渲染路径上。 所以，当我们需要使用到 Base64 技术的时，一定要意识到上述的问题，有取舍的进行使用。

### 236`[] == ![]`为什么

#### 简单表达

```
[] == ! [] -> [] == false -> [] == 0 -> '' == 0 -> 0 == 0 -> true
```

#### 详细

① 根据运算符优先级 ，！ 的优先级是大于 == 的，所以先会执行 ![]

！可将变量转换成boolean类型，null、undefined、NaN以及空字符串('')取反都为true，其余都为false。

所以 ! [] 运算后的结果就是 false

也就是 [] == ! [] 相当于 [] == false

② 根据上面提到的规则（如果有一个操作数是布尔值，则在比较相等性之前先将其转换为数值——false转换为0，而true转换为1），则需要把 false 转成 0

也就是 [] == ! [] 相当于 [] == false 相当于 [] == 0

③ 根据上面提到的规则（如果一个操作数是对象，另一个操作数不是，则调用对象的valueOf()方法，用得到的基本类型值按照前面的规则进行比较，如果对象没有valueOf()方法，则调用 toString()）

而对于空数组，[].toString() ->  '' (返回的是空字符串)

也就是  [] == 0 相当于 '' == 0

④ 根据上面提到的规则（如果一个操作数是字符串，另一个操作数是数值，在比较相等性之前先将字符串转换为数值）

Number('') -> 返回的是 0

相当于 0 == 0 自然就返回 true


### 237讲一下函数式编程

#### 函数式编程描述

函数式编程是一种编程范式，我们常见的编程范式有命令式编程、逻辑式编程，常见的面向对象编程也是一种命令式编程。

如果说面向对象编程的思维方式：把现实世界中的事物抽象成程序世界中的类和对象，通过封装、继承和多态来演示事物事件的联系，

那么函数式编程的思维方式是：把现实世界的事物和事物之间的联系抽象到程序世界（对运算过程进行抽象）。函数编程中的函数，不是指计算机中的函数，而是指数学中的函数。也就是说一个函数的值仅决定于函数参数的值，不依赖其他状态。且，相同的输入始终得到相同的输出（纯函数）。在函数式语言中，函数作为一等公民，可以在任何地方定义，在函数内或函数外，可以作为函数的参数和返回值，可以对函数进行组合。简单的描述：函数式编程用来描述数据（函数）直接的映射 例如 x->f(联系、映射)->y,y=f(x)。

#### 函数式编程优点

在前端中，函数式编程是随着React的流行收到越来越多的关注，Vue3也开始拥抱函数式编程。那么函数式编程有什么优点呢？它的优点其实是由它的不可变性带来的，简单描述如下：

1. 函数式编程可以抛弃this
2. 打包过程中可以更好的利用tree shaking过滤无用代码
3. 函数不依赖外部的状态，也不修改外部的状态，函数调用的结果不依赖函数调用的时间和调用的位置，这样的代码容易进行推理，不容易出错，还可以把运行结果进行缓存。同时，还方便进行单元测试，方便并行处理
4. 由于函数式语言是面向数学的抽象，更接近人的语言，而不是机器语言，代码会比较简洁，也更容易理解

#### 函数式编程风险

至于函数式编程的风险，则是由于不可变性如果掺入了可变性，就带来了风险。就是说，如果一个纯函数变得不纯了，如果函数依赖于外部的状态就无法保证输出相同，就会带来副作用

简单示例如下：

```js
let mini = 18；
function checkAge(age){
	return age>=mini
}
```

上面的示例中，checkAge函数依赖外部的mini，如果mini变成20或者别的数字，那么相同的输入便不是相同的输出了。当然也可以对上面的函数进行改造，但是副作用其实是无法完全避免的。一般副作用的来源：配置文件、数据库、获取用户的输入，等等……

所有的外部交互都有可能带出副作用，副作用也使得方法通用性下降不适合扩展和可重用性，同时副作用会给程序中带来安全隐患，给程序带来不确定性，但是副作用不可能完全禁止，只能尽力控制它们在可控范围内发生。

#### 函数式编程语言特性

- 高阶函数
  - 所谓高阶函数，就是传参为函数或者返回为函数的函数。
- 柯里化
  - 这里采用维基百科的解释：柯里化，英语：Currying，是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回接受余下的参数而且返回结果的新函数的技术。
- 闭包
  - MDN解释：在JavaScript中，每当创建一个函数，闭包便产生。闭包是将函数与其引用的周边状态绑定在一起形成（封装）的组合。

#### 总结

函数式编程是一种编程范式，为我们提供了另一种抽象和思考方式。当然在处理可变状态和处理IO的时候，函数式编程虽然可以通过引入变量来解决，但是其实函数式编程并不太适合处理这种情况。

### 238说一下 base64 的编码方式

#### base64编码

**术语版概念解释**

Base64是一种编码方式。选用大小写字母、0-9、+ 和 / 的64个可打印字符来表示二进制数据。将二进制数据每三个字节一组，一共是 3*8=24 bit，划为 4组， 每组 6个bit。如果要编码的二进制不是 3 的倍数，会用 `x\00` 在末尾补足，然后在编码的末尾加上 1-2 个 `=`号，表示补了多少字节，解码的时候会去掉。将3 字节的二进制数据编码为 4 字节的文本，是可以让数据在邮件正文、网页等直接显示。

**通俗概念解释**

Base64是传输8Bit字节码的编码方式，Base64可以将ASCII字符串或者是二进制编码成只包含A—Z，a—z，0—9，+，/ 这64个字符（ 26个大写字母，26个小写字母，10个数字，1个+，一个 / 刚好64个字符组成）；这64个字符用6个bit位就可以全部表示出来，一个字节有8个bit 位，那么还剩下两个bit位，这两个bit位用0来补充。转换完空出的结果就用就用“=”来补位，总之要保证最后编码出来得字节数是4的倍数。

**注意**

因为标准的 Base64 会有 `+`和`\`在 URL 中不能直接做参数，于是出现了一种 "url safe"的 Base64，将 `+` 和 `\` 转换为 `-` 和 `_`。因为 `=` 用在 URL 和 Cookie 会有歧义，所以很多 Base64 会把 `=` 去掉。由于 Base64 的长度永远是 4 的倍数，所以只要加上 `=` 把长度变为 4 的倍数，就可以解码。

### 239说一下 ajax/axios/fetch 的区别

#### 1）ajax

ajax是对原生XHR的封装，除此以外还增添了对JSONP的支持。有一说一的说一句，JQuery ajax经过多年的更新维护，真的已经是非常的方便了，优点无需多言；如果是硬要举出几个缺点，那可能只有

- 本身是针对MVC的编程,不符合现在前端MVVM的浪潮
- 基于原生的XHR开发，XHR本身的架构不清晰，已经有了fetch的替代方案
- JQuery整个项目太大，单纯使用ajax却要引入整个JQuery非常的不合理（采取个性化打包的方案又不能享受CDN服务）

尽管JQuery对我们前端的开发工作曾有着（现在也仍然有着）深远的影响，但是我们可以看到随着VUE，REACT新一代框架的兴起，以及ES规范的完善，更多API的更新，JQuery这种大而全的JS库，未来的路会越走越窄。

#### 2）axios

Vue2.0之后，尤雨溪推荐大家用axios替换JQuery ajax，想必让Axios进入了很多人的目光中。Axios本质上也是对原生XHR的封装，只不过它是Promise的实现版本，符合最新的ES规范，从它的官网上可以看到它有以下几条特性：

- 从 node.js 创建 http 请求
- 支持 Promise API
- 客户端支持防止CSRF
- **提供了一些并发请求的接口**（重要，方便了很多的操作）

这个支持防止CSRF其实挺好玩的，是怎么做到的呢，就是让你的每个请求都带一个从cookie中拿到的key, 根据浏览器同源策略，假冒的网站是拿不到你cookie中得key的，这样，后台就可以轻松辨别出这个请求是否是用户在假冒网站上的误导输入，从而采取正确的策略。

Axios既提供了并发的封装，也没有下文会提到的fetch的各种问题，而且体积也较小，当之无愧现在最应该选用的请求的方式。

#### 3）fetch 

fetch号称是ajax的替代品，它的好处有以下几点：

- 符合关注分离，没有将输入、输出和用事件来跟踪的状态混杂在一个对象里
- 更好更方便的写法，诸如：

```js
try {
  let response = await fetch(url);
  let data = response.json();
  console.log(data);
} catch(e) {
  console.log("Oops, error", e);
}
```

不管是Jquery还是Axios都已经帮我们把xhr封装的足够好，使用起来也足够方便，为什么我们还要花费大力气去学习fetch？

fetch的优势主要优势：

- 语法简洁，更加语义化
- 基于标准 Promise  实现，支持 async/await
- 更加底层，提供的API丰富（request, response）
- 脱离了XHR，是ES规范里新的实现方式

#### 4）总结 

现在Jquery老迈笨拙，fetch年轻稚嫩，只有Axios正当其年！

### 240es6 类继承中 super 的作用

#### 1.概念

super 关键词用于访问和调用一个对象的父对象上的函数。

super 既可以当作 函数 使用，也可以当作 对象 使用。
语法：

```js
super([arguments]);
//调用父对象/父类 的构造函数
super.functionOnParent([arguments]);
//调用 父对象/父类 上的方法
```

#### 2.super当作函数

super 作为函数调用时，代表父类的 构造函数 。ES6要求，子类的构造函数必须执行一次 super 函数。

```js
class A{}
class B extends A{
	constructor(){
  	super();
  }
}
```

super 代表父类的构造函数被调用时，有以下几点需要注意

1. super 返回的对象是 子类 的实例。super 内部的 this 指的是 B 的实例，这里的的 super() 相当于 A.prototypeof.constructor.call(this) 。
2. super 作为构造函数时，必须在使用 this 关键词之前使用，否则会报错。
3. super() 只能用在子类构造函数中，用在其他地方会报错 

#### 3.super当作对象

**super 作为对象时，在普通方法中，指向父类的原型对象；静态方法中指向父类。**

**1）普通方法中**

- super 指向的是父类原型对象,能获取父类原型对象上面的方法和属性，不能获取父类实例上的方法和属性
- 通过 super 调用父类原型对象上的方法时， this 指向子类实例。

```js
class A {
  constructor() {
    this.x = 1;
  }
  print() {
    console.log(this.x);
  }
}
class B extends A {
  constructor() {
    super();
    this.x = 2;
  }
  m() {
    super.print();
  }
}
let b = new B();
b.m() // 2
```

`super.print()`虽然调用的是`A.prototype.print()`，但是`A.prototype.print()`内部的`this`指向子类`B`的实例，导致输出的是`2`，而不是`1`。也就是说，实际上执行的是`super.print.call(this)`。

通过 super 和对某个属性赋值，这时 super 就是 this ，赋值的属性会变为子类实例的属性。

举个例子：

```js
class A {
  constructor() {
    this.x = 1;
  }
}

class B extends A {
  constructor() {
    console.log(super());
    this.x = 2;
    super.x = 3;
    console.log(super.x); // undefined
    console.log(this.x); // 3
  }
}

let b = new B();
```

- `super() ` ：代表父类的构造函数，返回的是一个B的实例；
- `super.x=3` ：super此处指的子类实例的 `this` 。 `super.x = 3` ，就类似 `this.x = 3` ;
- `super.x` ：获取原型对象的 `x` ，没定义所以返回 `undefined` 
- `this.x` ：最后 `this.x` 返回的是 `super.x` 设置的值。

**2）静态方法中**

在静态方法中，super 对象指的是父类，而不是父类的原型对象.

```js
class Parent {
    static myMehtod(msg) {
        console.log('static', msg);
    }
    myMehtod(msg) {
        console.log('instance', msg);
    }
}
class Child extends Parent {
    static myMethod(msg) {
        super.myMethod(msg);
    }
    myMethod(msg) {
        super.myMehtod(msg);
    }
}
Child.myMehtod(1);
var child = new Child();
child.myMehtod(2);
```

静态方法中，super函数内部的this指向的是子类，而不是子类实例。

举个例子：

```js
class A {
    constructor() {
        this.x = 1;
        console.log(this.x)
    }
    static print() {
        console.log(this.x);
    }
}
class B extends A {
    constructor() {
        super();
        this.x = 2;
        console.log(this.x);
    }
    static m() {
        super.print();//1
    }
}
const b = new B();
B.m();//undefined
B.x = 3;
B.m() // 3
```

- `B.m()` 静态方法中，调用了 `super` ，此时指向的是 父类 , 执行父类静态方法 `super.print()` 。
- 此时父类静态方法中的 `this` 指向的是子类 `B` 。因为 `B` 类上面没有属性 `x` ,所以返回 `undefined` 。
- 通过设置 `B.x` ，再次调用 `B.m()` 返回设置值。

#### 4.super中的this指向

- 代表父类构造函数用的 `super()` ,函数内部的 `this`  指向子类实例。
- 在普通方法中，代表父类原型对象使用的 `super` ，函数内部 `this` 指向 子类实例 。
- 在静态方法中，代表父类使用的 `super` ,函数内部 `this` 指向 子类 。

> tips：注意，使用`super`的时候，必须显式指定是作为函数、还是作为对象使用，否则会报错。

### 241number 为什么会出现精度损失，怎样避免

### 精度损失原因分析

JavaScript 中所有数字包括整数和小数都只有一种类型 — Number。它的实现遵循 IEEE 754 标准，使用 64 位固定长度来表示，也就是标准的 double 双精度浮点数（相关的还有  float 32位单精度）。为什么呢，因为这样节省存储空间。

最简单的例子是 0.1+0.2 = 0.30000000000000004

0.1的二进制表示的是一个无限循环小数，该版本的 JS 采用的是浮点数标准需要对这种无限循环的二进制进行截取，从而导致了精度丢失，造成了0.1不再是0.1，截取之后0.1变成了 0.100…001，0.2变成了0.200…002。所以两者相加的数大于0.3。

### 解决

#### 1.toFixed()

因为toFixed() 进行并转换之后是string类型的，需要在进行强制Number() 转换，需要处理一下兼容性问题，通过判断最后一位是否大于等于5来决定需不需要进位，如果需要进位先把小数乘以倍数变为整数，加1之后，再除以倍数变为小数，这样就不用一位一位的进行判断。

#### 2.一些类库

- math.js，
- decimal.js,
- D.js

#### 3.ES6在Number对象上新增了一个极小的常量——Number.EPSILON

```js
Number.EPSILON
// 2.220446049250313e-16
Number.EPSILON.toFixed(20)
// "0.00000000000000022204"
```

### 242for..of 和 for...in 是否可以直接遍历对象，为什么

### 答案

for..of 不能直接遍历对象，for...in 可以直接遍历对象

### 原因

对于普通的对象，for...of 结构不能直接使用，会报错，必须部署了 Iterator 接口后才能使用

for...in 语句以任意顺序遍历一个对象的除 Symbol 以外的可枚举属性。

函数接受一个对象作为参数。被调用时迭代传入对象的所有可枚举属性然后返回一个所有属性名和其对应值的字符串。

```js
const obj = { a: 1, b: 2, c: 3 };
for (const prop in obj) {
  console.log(prop);
}
// a
// b
// c
```

### 解决办法

#### 1.使用 Object.key()、Object.values()、Object.entries()

```js
const obj = { a: 1, b: 2, c: 3 };
for (const prop of Object.keys(obj)) {
  console.log(prop);
}
// a
// b
// c
for (const val of Object.values(obj)) {
  console.log(val);
}
// 1
// 2
// 3
for (const item of Object.entries(obj)) {
  console.log(item);
}
// ["a", 1]
// ["b", 2]
// ["c", 3]
```

#### 2.部署 Iterator 接口

**Iterator遍历器**

Iterator 的遍历过程是这样的。

1. 创建一个指针对象，指向当前数据结构的起始位置。也就是说，遍历器对象本质上，就是一个指针对象。
2. 第一次调用指针对象的next方法，可以将指针指向数据结构的第一个成员。
3. 第二次调用指针对象的next方法，指针就指向数据结构的第二个成员。
4. 不断调用指针对象的next方法，直到它指向数据结构的结束位置。
每一次调用next方法，都会返回数据结构的当前成员的信息

**iterator和for..of**

一个数据结构只要部署了Symbol.iterator属性，就被视为具有 iterator 接口，就可以用for...of循环遍历它的成员。

也就是说，for...of循环内部调用的是数据结构的Symbol.iterator方法。

for...of循环可以使用的范围包括数组、Set 和 Map 结构、某些类似数组的对象

```js
obj[Symbol.iterator] = function () {
  let index = 0;
  const _this = this;
  const keys = Object.keys(_this);
  const len = keys.length;
  return {
    next() {
      if (index < len) {
        return {
          value: _this[keys[index++]],
          done: false,
        };
      }
      return {
        value: null,
        done: true,
      };
    },
  };
};

// 使用 Generator版
obj[Symbol.iterator] = function* () {
  const keys = Object.keys(this);
  for (let i = 0, len = keys.length; i < len; i++) {
    yield this[keys[i]];
  }
};

for (const item of obj) {
  console.log(item);
}
// 1
// 2
// 3
```

### 243说一下什么是死锁

### 死锁

如果一组进程中每一个进程都在等待仅由该组进程中的其他进程才能引发的事件，那么该组进程是死锁的。换言之：死锁就是两个线程同时占用两个资源，但又在彼此等待对方释放锁。

举例来说：有两个进程A和B,A持有资源a等待b资源，B持有资源b等待a资源，两个进程都在等待另一个资源的同时不释放资源，就形成死锁。

#### 1）死锁产生的四个必要条件：

1. 互斥条件：一个资源每次只能被一个进程使用。
2. 请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放。
3. 不剥夺条件:进程已获得的资源，在末使用完之前，不能强行剥夺。
4. 循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系。

#### 2）死锁处理：

**预防死锁**：破坏四个必要条件中的一个或多个来预防死锁

**避免死锁**：在资源动态分配的过程中，用某种方式防止系统进入不安全的状态。

**检测死锁**：运行时产生死锁，及时发现思索，将程序解脱出来。

**解除死锁**：发生死锁后，撤销进程，回收资源，分配给正在阻塞状态的进程。

**1.预防死锁的办法：**

**破坏请求和保持条件**：一次性的申请所有资源。之后不在申请资源，如果不满足资源条件则得不到资源分配。只获得初期资源运行，之后将运行完的资源释放，请求新的资源。

**破坏不可抢占条件**：当一个进程获得某种不可抢占资源，提出新的资源申请，若不能满足，则释放所有资源，以后需要，再次重新申请。

**破坏循环等待条件**：对资源进行排号，按照序号递增的顺序请求资源。若进程获得序号高的资源想要获取序号低的资源，就需要先释放序号高的资源。

**2.死锁的解除办法：**

- 抢占资源。从一个或多个进程中抢占足够数量的资源，分配给死锁进程，以解除死锁状态。
- 终止（撤销）进程：将一个或多个思索进程终止（撤销），直至打破循环环路，使系统从死锁状态解脱。

### 244数组有哪些方法 讲讲区别跟使用场景

### 数组方法

- valueOf
  - 返回包装对象实例对应的原始类型的值。
- toString
  - 返回对应的字符串形式
- push
  - 数组后方添加元素
- pop
  - 删除数组后方元素并返回，原数组会发生改变；
- shift
  - 用于删除数组的第一个元素，并返回该元素。
  - 该方法会改变原数组。
- unshift
  - 用于在数组的第一个位置添加元素，并返回添加新元素后的数组长度。
  - 该方法会改变原数组。
- join
  - 以指定参数作为分隔符，将所有数组成员连接为一个字符串返回。如果不提供参数，默认用逗号分隔。
  - 如果数组成员是undefined或null或空位，会被转成空字符串。
- concat
  - 用于多个数组的合并。它将新数组的成员，添加到原数组成员的后部，然后返回一个新数组，原数组不变。
  - 如果数组成员包括对象，concat方法返回当前数组的一个浅拷贝。所谓“浅拷贝”，指的是新数组拷贝的是对象的引用。
- reverse
  - 用于颠倒排列数组元素，返回改变后的数组。
  - 该方法将改变原数组。
- slice
  - 用于提取目标数组的一部分，返回一个新数组，原数组不变
  - arr.slice(start, end)
- splice
  - 用于删除原数组的一部分成员，并可以在删除的位置添加新的数组成员，返回值是被删除的元素。
  - 该方法会改变原数组。
  - arr.splice(start, count, addElement1, addElement2, ...);
- sort
  - 对数组成员进行排序，默认是按照字典顺序排序。
  - 原数组将被改变。
  - 函数本身接受两个参数，表示进行比较的两个数组成员。如果该函数的返回值大于0，表示第一个成员排在第二个成员后面；其他情况下，都是第一个元素排在第二个元素前面
- map
  - 将数组的所有成员依次传入参数函数，然后把每一次的执行结果组成一个新数组返回
  - 当前成员、当前位置和数组本身
- forEach
  - 对数组的每个元素执行一次给定的函数。
- filter
  - 用于过滤数组成员，满足条件的成员组成一个新数组返回
  - 它的参数是一个函数，所有数组成员依次执行该函数，返回结果为true的成员组成一个新数组返回。
  - 该方法不会改变原数组。
- some
  - 只要一个成员的返回值是true，则整个some方法的返回值就是true，否则返回false。
- every
  - 所有成员的返回值都是true，整个every方法才返回true，否则返回false。
  - 对于空数组，some方法返回false，every方法返回true，回调函数都不会执行。
- reduce
  - reduce方法和reduceRight方法依次处理数组的每个成员，最终累计为一个值。它们的差别是，reduce是从左到右处理（从第一个成员到最后一个成员），reduceRight则是从右到左（从最后一个成员到第一个成员），其他完全一样。
  - 四个参数
    - 累积变量，默认为数组的第一个成员
    - 当前变量，默认为数组的第二个成员
    - 当前位置（从0开始）
    - 原数组
- indexOf
  - 返回给定元素在数组中第一次出现的位置，如果没有出现则返回-1
  - 还可以接受第二个参数，表示搜索的开始位置
- lastIndexOf
  - 返回给定元素在数组中最后一次出现的位置，如果没有出现则返回-1。

### 245写出代码输出结果
```js
var fullname = "Test1";
var obj = {
  fullname: "Test2",
  prop: {
    fullname: "Test3",
    getFullname: function () {
      return this.fullname;
    },
  },
};
console.log(obj.prop.getFullname());
var test = obj.prop.getFullname;
console.log(test());
```

### 执行结果

```js
Test3
Test1
```

### 解析

在全局执行上下文中，this的值指向全局对象。

在函数执行上下文中，this的值取决于该函数是如何被调用的。如果this被一个引用的对象调用，那么this的值就被设置为该对象，否则被设置为全局对象或者undefined（严格模式）

### 246请写出以下代码执行结果
```js
console.log(1);
setTimeout(() => {
  console.log(2);
});
process.nextTick(() => {
  console.log(3);
});
setImmediate(() => {
  console.log(4);
});
new Promise((resolve) => {
  console.log(5);
  resolve();
  console.log(6);
}).then(() => {
  console.log(7);
});
Promise.resolve().then(() => {
  console.log(8);
  process.nextTick(() => {
    console.log(9);
  });
});
// 写出执行结果
```

### 执行结果

```js
1
5
6
3
7
8
9
2
4
```

### 解析

- **macro-task**: script (整体代码)，setTimeout, setInterval, setImmediate, I/O, UI rendering.
- **micro-task**: process.nextTick, Promise(原生)，Object.observe，MutationObserver

除了script整体代码，micro-task的任务优先级高于macro-task的任务优先级。

### 执行过程分析

```js
console.log(1); // 脚本宏任务 立即执行
setTimeout(() => {
    console.log(2); // 推到宏任务队列 等待执行
});
process.nextTick(() => {
    console.log(3);
});
setImmediate(() => {
    console.log(4); // 推到check回调队列 等待执行
});
new Promise((resolve) => {
    console.log(5); // 脚本宏任务 立即执行
    resolve(); // 即:将 then 推到微任务队列 等待执行
    console.log(6); // 脚本宏任务 立即执行
}).then(() => {
    console.log(7);
});
Promise.resolve() // 即:将 then 推到微任务队列 等待执行
    .then(() => {
        console.log(8);
        process.nextTick(() => {
            console.log(9);
        });
});

// 由上可立即得
// 1
// 5
// 6

```
------
此时队列存储的 log 情况

tick: 3

micro: 7, 8, (tick: 9)

timeout: 2

check: 4

```js
// 已有tick全部执行, 再得
// 3
// 然后清空 microtask, 再得
// 7
// 8
```
------

此时队列存储的 log 情况

tick: 9

micro: 空

timeout: 2

check: 4

```js
// 已有tick全部执行, 再得
// 9
// 没有 IO 时, timeout队列检查在check队列前, 最后得
// 2
// 4
```
------

综上结果为：

没有 IO 时:

`1, 5, 6, 3, 7, 8, 9, 2, 4`

有 IO 时:

`1, 5, 6, 3, 7, 8, 9, 4, 2`



### 247已知函数 A，要求构造⼀个函数 B 继承 A
```js
function A(name) {
  this.name = name;
}
A.prototype.getName = function () {
  console.log(this.name);
};
```

### 实现方式

#### 1.组合继承

称之为伪经典继承

指的是将原型链和借用构造函数的技术组合到一起，从而发挥二者之长的一种继承模式，思路是使用原型链实现对原型属性、方法的继承，而通过借用构造函数来实现对实例属性的继承，这样即通过在原型上定义方法实现了复用，又能保证每个实例都有自己的属性

**缺点**：在使用过程中都会调用两次超类型的构造函数对象(即A)：一次式在创建子类原型的时候，一次是在子类行构造函数时重写这些属性， 子类继承父类的属性，一组在子类实例上，一组在子类原型上(在子类原型上创建了不必要多余的属性) 

代码实现

```js
function A(name) {
  this.name = name;
}

A.prototype.getName = function () {
  console.log(this.name)
}

function B(name,age){
    // 第一次调用 A
  A.call(this,name);
  this.age = age;
  this.firends=['前端','资深'];
}

   // 第二次调用 A
B.prototype = new A();
B.prototype.constructor = B;
// 给子类添加特有的方法，需要在继承之后
B.prototype.getFirends=function(){
  console.log(this.firends);
}


const instance1 = new B('jingcheng',3);
instance1.getName(); // jingcheng
instance1.firends.push('React')
const instance2 = new B('yideng',4);
instance2.getName(); // yideng

console.log(instance1, instance2)
```

#### 2.寄生组合式继承

通过构造函数来继承属性，通过原型链的混成形式来继承方法，思路是：不用指定子类型的原型而调用超类型的构造函数，我们需要的无非就是超类型的一个副本而已，本质上就是使用寄生式继承来继承超类型的原型，然后再将结果指定给子类型的原型

**优点**：这个继承的高效率体现在它只调用了一次超类型的构造函数对象(即A)，因此避免了子类型的构造函数的原型上(`B.prototype`) 上创建不必要、多余的属性，与此同时，原型链还可以保持不变

代码示例

```js
function inheritPrototype(subType,superType){
  var prototype = Object.create(superType.prototype);
  prototype.constructor = subType;
  subType.prototype = prototype;
}


function A(name) {
  this.name = name;
}

A.prototype.getName = function () {
  console.log(this.name)
}

function B(name, age) {
  A.call(this, name);
  this.age = age;
  this.firends = ['前端', '资深'];
}

inheritPrototype(B,A)
B.prototype.getFirends = function () {
  console.log(this.firends);
}

const instance1 = new B('jingcheng', 3);
instance1.getName(); // jingcheng
instance1.firends.push('React')
const instance2 = new B('yideng', 4);
instance2.getName(); // yideng

console.log(instance1, instance2)
```

以上的方法均可以实现构造一个函数B 继承A，下面是用ES6 的class 来实现继承

#### 3.class方式实现继承

```js
class A {
  constructor(name) {
    this.name = name;
  }

  getName=()=>{
    console.log('我是Public',this.name)
  }
}


class B extends A {
  constructor(name,age) {
    super();
    this.name = name;
    this.age =age;
    this.firends = ['前端', '资深'];
  }

  getFirends=()=>{
    console.log(this.firends)
  }

  // 对于继承的方法进行重写
  getName=()=>{
    console.log('我是子类的getName',this.name)
  }

}

const instance1 = new B('jingcheng', 3);
instance1.getName();
instance1.firends.push('React')
const instance2 = new B('yideng', 4);
instance2.getName();
const instance3 = new A('laowang')
instance3.getName();

console.log(instance1, instance2)
```



### 248如何把真实 dom 转变为虚拟 dom，代码实现一下

### 实现方式

#### 1.将DOM结构转换成对象保存到内存中

- `<img /> => { tag: 'img'}`
- `文本节点 => { tag: undefined, value: '文本节点' }`
- `<img title="img" class="c" /> => { tag: 'img', data: { title = "img", class="c" } }`
- `<div><img /></div> => { tag: 'div', children: [{ tag: 'img' }]}`

#### 2.根据上面可以写出虚拟DOM的数据结构

```js
function VNode (tag, data, value, type) {
  this.tag = tag && tag.toLowerCase()
  this.data = data
  this.value = value
  this.type = type
  this.children = []
}
VNode.prototype.appendChild = function (vnode) {
  this.children.push(vnode)
}
```

#### 3.可能用到的基础知识

- 判断元素的节点类型: `node.nodeType`

```js
let nodeType = node.nodeType
if(nodeType === 1) {
  // 元素类型
} else if (nodeType === 3) {
	// 节点类型
}
```

- 获取元素类型的标签名和属性 && 属性中具体的键值对,保存在一个对象中

```js
let nodeName = node.nodeName	// 标签名
let attrs = node.attributes	// 属性
let _data = {} // 保存各个具体的属性的键值对,相当于虚拟DOM中的data属性
let attrLen = attrs.length  // 属性长度
for(let i = 0; i < attrLen; i++){
  _data[attrs[i].nodeName] = attrs[i].nodeValue
}
```

- 获取当前节点的子节点

```js
let childNodes = node.childNodes
let childLen = childNodes.length
for(let i = 0; i < childLen; i++){
	console.log(childNodes[i])
}
```

#### 4.算法思路

- 使用`document.querySelector`获取要转换成虚拟DOM的模板
- 使用`nodeType`方法来获取是元素类型还是文本类型
- 若是元素类型
  - 使用`nodeName`获取标签名
  - 使用`attributes`获取属性名,并将具体的属性保存到一个对象`_data`中
  - 创建虚拟DOM节点
  - 考虑元素类型是否有子节点,使用递归,将子节点的虚拟DOM存入其中
- 若是文本类型
  - 直接创建虚拟DOM,不需要考虑子节点的问题

```js
// 获取要转换的DOM结构
let root = document.querySelector('#root')
// 使用getVNode方法将 真实的DOM结构转换成虚拟DOM
let vroot = getVNode(root)
```

以上写了虚拟DOM的数据结构,以及使用`getVNode`方法将真实DOM结构转换成虚拟DOM，

#### 5.下面开始逐步实现getVNode方法

以上写了虚拟DOM的数据结构,以及使用`getVNode`方法将真实DOM结构转换成虚拟DOM，下面开始逐步实现getVNode方法

- 判断节点类型,并返回虚拟DOM

```js
function getVNode(node){
  // 获取节点类型
  let nodeType = node.nodeType
  if(nodeType === 1) {
    // 元素类型: 获取其属性,判断子元素,创建虚拟DOM
  } 
  else if(nodeType === 3) {
    // 文本类型: 直接创建虚拟DOM
  }
  let _vnode = null
  return _vnode
}
```

- 下面根据元素类型和文本类型分别创建虚拟DOM

```js
if(nodeType === 1){
  // 标签名
  let tag = node.nodeName
  // 属性
  let attrs = node.attributes
  /*
   属性转换成对象形式: <div title ="marron" class="1"></div>
   { tag: 'div', data: { title: 'marron', class: '1' }}
  */
  let _data = {} // 这个_data就是虚拟DOM中的data属性
  let arrtLen = attrs.length // 属性长度
  for(let i = 0; i < arrtLen; i++){
    _data[attrs[i].nodeName] = attrs[i].nodeValue
  }
  // 创建元素类型的虚拟DOM
  _vnode = new VNode(tag, _data, undefined, nodeType)
  // 考虑node的子元素
  let childNodes = node.childNodes
  let childLen = childNodes.length
  for(let i =0; i < childLen; i++){
    _vnode.appendChild(getVNode(childNodes[i]))
  }
}
// 接下来考虑文本类型
else if(nodeType === 3){
  _vnode = new VNode(undefined, undefined, node.nodeValue, nodeType)
}
```

#### 6.总体实现代码

```html
// html
<div id="root">
  <img class="img" />
  <div title="div-box"><p>box</p></div>
  文本节点
</div>
```

```js
// javascript
function VNode (tag, data, value, type) {
  this.tag = tag && tag.toLowerCase()
  this.data = data
  this.value = value
  this.type = type
  this.children = []
}
VNode.prototype.appendChild = function (vnode) {
  this.children.push(vnode)
}
function getVNode (node) {
  let nodeType = node.nodeType
  let _vnode = null
  if (nodeType === 1) {
    let tag = node.nodeName
    let attrs = node.attributes
    let _data = {}
    let attrLen = attrs.length
    for (let i = 0; i < attrLen; i++) {
      _data[attrs[i].nodeName] = attrs[i].nodeValue
    }
    _vnode = new VNode(tag, _data, undefined, nodeType)
    let childNodes = node.childNodes
    let childLen = childNodes.length
    for (let i = 0; i < childLen; i++) {
      _vnode.appendChild(getVNode(childNodes[i]))
    }
  }
  else if (nodeType === 3) {
    _vnode = new VNode(undefined, undefined, node.nodeValue, nodeType)
  }
  return _vnode
}

let root = document.querySelector('#root')
let vroot = getVNode(root)
console.log(vroot)
```


### 249说一下对原型链的理解，画一个经典的原型链图示

### 原型链

![prototype](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-828-prototype.jpg)

#### 1.概念

每个对象都有一个指向它的原型（prototype）对象的内部链接。这个原型对象又有自己的原型，直到某个对象的原型为 null 为止（也就是不再有原型指向），组成这条链的最后一环。这种一级一级的链结构就称为原型链。可以看下上边的图。

#### 2.原型链特点

1. 所有的对象都有"[[prototype]]"属性（通过__proto__访问），该属性对应对象的原型
2. 所有的函数对象都有"prototype"属性，该属性的值会被赋值给该函数创建的对象的"__proto__"属性
3. 所有的原型对象都有"constructor"属性，该属性对应创建所有指向该原型的实例的构造函数
4. 函数对象和原型对象通过"prototype"和"constructor"属性进行相互关联

### 250什么是作用域链

### 作用域链

已知 JavaScript 代码执行一段可执行代码时，会创建对应的执行上下文。在创建执行上下文时，会创建作用域链（因为引用了外部环境）。

查找变量的时候，会先从当前上下文的环境记录中查找，如果没有找到，就会从上级执行上下文的环境记录中查找，一直找到全局上下文的环境记录。这样有多个执行上下文的环境记录构成的链表，就叫做作用域链。

### 251实现一个功能，发送请求 5s 时间后，如果没有数据返回，中断请求,提示错误

### 代码实现

调用XMLHttpRequest.abort(), 可以在请求发出后，立刻中止请求。

再设置一个定时器，定时器计时完成后，如果没有数据返回则中断请求。

简单实现

```js
/**
 * @param {Object} params 
 */
const request = (params) => {
  const option = {
    timeOut: 5000,
    ...params
  }
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest()
    let isTimeOut = false
    const timer = setTimeout(function () {
      isTimeOut = true;
      xhr.abort();
      reject('request is timeout ！！！')
    }, option.timeOut)
    xhr.open("GET", option.url);
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (isTimeOut) return;//忽略中止请求
        clearTimeout(timer);//取消等待的超时
        if ((xhr.status >= 200 && xhr.status < 300) || xhr.status === 304) {
          resolve(xhr.responseText)
        } else {
          reject(`Request was unsuccessful ！！！ ${xhr.status}`)
        }
      }
    }
    // 可以根据不同的请求方法发送数据
    xhr.send(null);
  })
}
```

调用：

```js
const getData = async () => {
  const opt = {
    url: 'http://localhost:3000/timeout'
  }
  try {
    const res = await request(opt)
  } catch (error) {
    console.log(error) // request is timeout ！！！
  }
}

getData()
```

### 252实现函数接受任意二叉树，求二叉树所有根到叶子路径组成的数字之和
```js
class TreeNode{
  value:number
  left?:TreeNode
  right?:TreeNode
}
function getPathSum(root){
  // your code
}
// 例子，一层二叉树如下定义，路径包括1 —> 2 ,1 -> 3
const node = new TreeNode();
node.value = 1;
node.left = new TreeNode();
node.left.value = 2;
node.right = new TreeNode();
node.right.value = 3;
getPathSum(node); // return 7 = (1+2) + (1+3)
```

### 代码实现

```js
function getPathSum(root){
  let num = 0;

	function addNum(node) {
		if(node.left) {
			num += (node.value + node.left.value)
			if(node.left.left) {
				addNum(node.left)
			} else if(node.left.right) {
				addNum(node.left)
			}
		}
		if(node.right) {
			num += (node.value + node.right.value)
			if(node.right.left) {
				addNum(node.right)
			} else if(node.right.right) {
				addNum(node.right)
			}
		}
	}

	addNum(node)
	console.log(num)
}
class TreeNode {}
const node = new TreeNode();
node.value = 1;
node.left = new TreeNode();
node.left.value = 2;
node.right = new TreeNode();
node.right.value = 3;
// 下面数据便于测试使用 结果：39
node.left.left = new TreeNode();
node.left.left.value = 4
node.left.right = new TreeNode();
node.left.right.value = 5
node.right.left = new TreeNode();
node.right.left.value = 6
node.right.right = new TreeNode();
node.right.right.value = 7
```


### 253实现以下代码
```js
function add() {
  // your code
}
function one() {
  // your code
}
function two() {
  // your code
}
console.log(add(one(two()))); //3
console.log(add(two(one()))); //3
```

### 代码实现

```js
function add() {
    // your code
    return arguments[0].reduce((a,b)=>a+b)
}
function one() {
    // your code
    if(arguments.length==0){
        return 1
    }else{
        return [arguments[0],1]
    }
    
}
function two() {
    if(arguments.length==0){
        return 2
    }else{
        return [arguments[0],2]
    }
}

console.log(add(one(two())));  //3
console.log(add(two(one())));  //3
```

### 254用 Promise 封装一个 ajax

### 代码实现

```js
const promiseAjax = function(data){
    function formatParams(param) {
        var arr = [];
        for (var name in param) {
            arr.push(encodeURIComponent(name) + "=" + encodeURIComponent(param[name]));
        }
        arr.push(("v=" + Math.random()).replace(".", ""));
        return arr.join("&");
    }
    if (!data) data = {}
    data.params= data.params || {}

    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();

        if (data.type === 'get') {
            data.params = formatParams(data.params); //options.data请求的数据

            xhr.open("GET", data.url + "?" + data.params, true);
            xhr.send(null);
        } else if (options.type == "post") {
            xhr.open("POST", data.url, true);
            xhr.setRequestHeader("Content-type", "application/json");
            xhr.send(data.params);
        }

        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                if (xhr.status === 200) {
                    resolve(xhr.response)
                } else {
                    reject(xhr.responseText);
                }
            }
        }
    })
}
```

### 255说一下错误监控的实现，错误监控的正确使用方式，日志如何分等级

### 一、错误分类

1. 运行时错误：这个错误往往是在写代码是造成的。如语法错误、逻辑错误等，这种错误一般在测试过程也能够发现。
2. 资源加载错误：这个错误通常是找不到文件或者是文件加载超时造成的。

### 二、错误捕获

#### 1）代码错误捕获

- try…catch…

```js
try{
  //运行可能出错的代码  
}catch(e) {
    //捕获错误
}
```

- window.onerror

```js
window.onerror = function() {
  //捕获错误  
```

```js
/**
同步错误
 * @param {String}  msg    错误信息
 * @param {String}  url    出错文件
 * @param {Number}  row    行号
 * @param {Number}  col    列号
 * @param {Object}  error  错误详细信息
 */
 window.onerror = function (msg, url, row, col, error) {
  console.log('我知道错误了');
  console.log({
    msg,  url,  row, col, error
  })
  return true;
};

error
```

```js
//异步错误
window.onerror = function (msg, url, row, col, error) {
  console.log('我知道异步错误了');
  console.log({
    msg,  url,  row, col, error
  })
  return true;
};
setTimeout(() => {
  error;
});
```

需要注意的是，window.onerror函数只有在返回 true的时候，异常才不会向上抛出，否则即使是知道异常的发生控制台还是会显示Uncaught Error: xxxxx。

由于网络请求异常不会事件冒泡，因此必须在捕获阶段将其捕捉到才行，但是这种方式虽然可以捕捉到网络请求的异常，但是无法判断HTTP的状态是404还是其他比如500等等，所以还需要配合服务端日志才进行排查分析才可以。

```js
<script>
window.addEventListener('error', (msg, url, row, col, error) => {
  console.log('我知道 404 错误了');
  console.log(
    msg, url, row, col, error
  );
  return true;
}, true);
</script>
<img src="./404.png" alt="">
```

在实际的使用过程中，onerror主要是来捕获预料之外的错误，而try-catch则是用来在可预见情况下监控特定的错误，两者结合使用更加高效。

#### 2）资源加载错误

- Object.onerror

```js
var img=document.getElementById('#img');
img.onerror = function() {
  // 捕获错误  
}
```

利用window的error事件代理，但是需要注意的是error事件是不冒泡的，可以使用事件捕获进行代理

```js
 window.addElementListener("error",function(){
  // 捕获错误
},true);
```

### 三、错误上报

常见的错误上报有两种：ajax、image对象（推荐）

ajax上报就是在上文注释错误捕获的地方发起ajax请求，来向服务器发送错误信息

- 利用image对象

```js
function report(error) {
var reportUrl = 'http://xxxx/report';
new Image().src = reportUrl + '?' + 'error=' + error;
}
```

### 四、跨域js文件错误获取

跨域js文件获取是有限制的，如果想获取其他域下的js错误需要再script标签中添加crossorgin属性，然后服务器要设置header('Access-Control-Allow-Origin');

```js
// http://localhost:8080/index.html
<script>
  window.onerror = function (msg, url, row, col, error) {
    console.log('我知道错误了，也知道错误信息');
    console.log({
      msg,  url,  row, col, error
    })
    return true;
  };
</script>
<script src="http://localhost:8081/test.js" crossorigin></script>

// http://localhost:8081/test.js
setTimeout(() => {
  console.log(error);
});
```

### 五、日志分等级

日志，是我们用于输出系统消息的一些节点， 但是由于业务、编码优先级的不同，日志需要通过定义不同的基本来进行输出

比如可以参考chrome的输出划分

- log 普通日志。
- info 普通信息。
- warn 警告值息。
- error 错误值息。

### 256weak-Set、weak-Map 和 Set、Map 区别

### 一、Set & Map

Set 和 Map 主要的应用场景在于 数据重组 和 数据储存

Set 是一种叫做集合的数据结构，Map 是一种叫做字典的数据结构

#### 1.集合 (Set)

ES6 新增的一种新的数据结构，类似于数组，但成员是唯一且无序的，没有重复的值。

Set 本身是一种构造函数，用来生成 Set 数据结构。

```js
new Set([iterable])
```

举个例子：

```js
const s = new Set()
[1, 2, 3, 4, 3, 2, 1].forEach(x => s.add(x))

for (let i of s) {
    console.log(i)	// 1 2 3 4
}

// 去重数组的重复对象
let arr = [1, 2, 3, 2, 1, 1]
[... new Set(arr)]	// [1, 2, 3]

```

Set 对象允许你储存任何类型的唯一值，无论是原始值或者是对象引用。

向 Set 加入值的时候，不会发生类型转换，所以5和"5"是两个不同的值。Set 内部判断两个值是否不同，使用的算法叫做“Same-value-zero equality”，它类似于精确相等运算符（===），主要的区别是**NaN等于自身，而精确相等运算符认为NaN不等于自身。**

```js
let set = new Set();
let a = NaN;
let b = NaN;
set.add(a);
set.add(b);
set // Set {NaN}

let set1 = new Set()
set1.add(5)
set1.add('5')
console.log([...set1])	// [5, "5"]
```

**1)Set 实例属性**

- constructor： 构造函数
- size：元素数量

```js
let set = new Set([1, 2, 3, 2, 1])

console.log(set.length)	// undefined
console.log(set.size)	// 3
```

**2)Set 实例方法**

- 操作方法
    - add(value)：新增，相当于 array里的push
    - delete(value)：存在即删除集合中value
    - has(value)：判断集合中是否存在 value
    - clear()：清空集合

```js
let set = new Set()
set.add(1).add(2).add(1)

set.has(1)	// true
set.has(3)	// false
set.delete(1)	
set.has(1)	// false
```

Array.from 方法可以将 Set 结构转为数组
        
```js
const items = new Set([1, 2, 3, 2])
const array = Array.from(items)
console.log(array)	// [1, 2, 3]
// 或
const arr = [...items]
console.log(arr)	// [1, 2, 3]
```

**3)遍历方法（遍历顺序为插入顺序）**

- keys()：返回一个包含集合中所有键的迭代器
- values()：返回一个包含集合中所有值得迭代器
- entries()：返回一个包含Set对象中所有元素得键值对迭代器
- forEach(callbackFn, thisArg)：用于对集合成员执行callbackFn操作，如果提供了 thisArg 参数，回调中的this会是这个参数，没有返回值

```js
let set = new Set([1, 2, 3])
console.log(set.keys())	// SetIterator {1, 2, 3}
console.log(set.values())	// SetIterator {1, 2, 3}
console.log(set.entries())	// SetIterator {1, 2, 3}

for (let item of set.keys()) {
console.log(item);
}	// 1	2	 3
for (let item of set.entries()) {
console.log(item);
}	// [1, 1]	[2, 2]	[3, 3]

set.forEach((value, key) => {
    console.log(key + ' : ' + value)
})	// 1 : 1	2 : 2	3 : 3
console.log([...set])	// [1, 2, 3]

```

Set 可默认遍历，默认迭代器生成函数是 values() 方法

```js
Set.prototype[Symbol.iterator] === Set.prototype.values	// true
```

所以， Set可以使用 map、filter 方法

```js
let set = new Set([1, 2, 3])
set = new Set([...set].map(item => item * 2))
console.log([...set])	// [2, 4, 6]

set = new Set([...set].filter(item => (item >= 4)))
console.log([...set])	//[4, 6]
```

因此，Set 很容易实现交集（Intersect）、并集（Union）、差集（Difference）

```js
let set1 = new Set([1, 2, 3])
let set2 = new Set([4, 3, 2])

let intersect = new Set([...set1].filter(value => set2.has(value)))
let union = new Set([...set1, ...set2])
let difference = new Set([...set1].filter(value => !set2.has(value)))

console.log(intersect)	// Set {2, 3}
console.log(union)		// Set {1, 2, 3, 4}
console.log(difference)	// Set {1}
```

#### 2.字典（Map）

**集合 与 字典 的区别：**

- 共同点：集合、字典 可以储存不重复的值
- 不同点：集合 是以 [value, value]的形式储存元素，字典 是以 [key, value] 的形式储存

```js
const m = new Map()
const o = {p: 'haha'}
m.set(o, 'content')
m.get(o)	// content

m.has(o)	// true
m.delete(o)	// true
m.has(o)	// false
```

**任何具有 Iterator 接口、且每个成员都是一个双元素的数组的数据结构**都可以当作Map构造函数的参数，例如：

```js
const set = new Set([
  ['foo', 1],
  ['bar', 2]
]);
const m1 = new Map(set);
m1.get('foo') // 1

const m2 = new Map([['baz', 3]]);
const m3 = new Map(m2);
m3.get('baz') // 3
```

如果读取一个未知的键，则返回undefined。

```js
new Map().get('asfddfsasadf')
// undefined
```

注意，只有对同一个对象的引用，Map 结构才将其视为同一个键。这一点要非常小心。

```js
const map = new Map();

map.set(['a'], 555);
map.get(['a']) // undefined
```

上面代码的`set`和`get`方法，表面是针对同一个键，但实际上这是两个值，内存地址是不一样的，因此`get`方法无法读取该键，返回`undefined。`

由上可知，`Map` 的键实际上是跟内存地址绑定的，只要内存地址不一样，就视为两个键。这就解决了同名属性碰撞（`clash`）的问题，我们扩展别人的库的时候，如果使用对象作为键名，就不用担心自己的属性与原作者的属性同名。

如果 `Map` 的键是一个简单类型的值（数字、字符串、布尔值），则只要两个值严格相等，`Map` 将其视为一个键，比如`0`和`-0`就是一个键，布尔值`true`和字符串`true`则是两个不同的键。另外，`undefined`和`null`也是两个不同的键。虽然`NaN`不严格相等于自身，但 `Map` 将其视为同一个键。

```js
let map = new Map();

map.set(-0, 123);
map.get(+0) // 123

map.set(true, 1);
map.set('true', 2);
map.get(true) // 1

map.set(undefined, 3);
map.set(null, 4);
map.get(undefined) // 3

map.set(NaN, 123);
map.get(NaN) // 123
```

**Map 的属性及方法**

属性：

- constructor：构造函数
- size：返回字典中所包含的元素个数

```js
const map = new Map([
  ['name', 'An'],
  ['des', 'JS']
]);

map.size // 2
```

操作方法：

- set(key, value)：向字典中添加新元素
- get(key)：通过键查找特定的数值并返回
- has(key)：判断字典中是否存在键key
- delete(key)：通过键 key 从字典中移除对应的数据
- clear()：将这个字典中的所有元素删除

遍历方法

- `Keys()`：将字典中包含的所有键名以迭代器形式返回
- `values()`：将字典中包含的所有数值以迭代器形式返回
- `entries()`：返回所有成员的迭代器
- `forEach()`：遍历字典的所有成员

```js
const map = new Map([
            ['name', 'An'],
            ['des', 'JS']
        ]);
console.log(map.entries())	// MapIterator {"name" => "An", "des" => "JS"}

console.log(map.keys()) // MapIterator {"name", "des"}
```

`Map` 结构的默认遍历器接口（`Symbol.iterator属性`），就是entries方法。

```js
map[Symbol.iterator] === map.entries
// true
```

`Map` 结构转为数组结构，比较快速的方法是使用扩展运算符（`...`）。

对于 `forEach` ，看一个例子

```js
const reporter = {
  report: function(key, value) {
    console.log("Key: %s, Value: %s", key, value);
  }
};

let map = new Map([
    ['name', 'An'],
    ['des', 'JS']
])
map.forEach(function(value, key, map) {
  this.report(key, value);
}, reporter);
// Key: name, Value: An
// Key: des, Value: JS
```

在这个例子中， forEach 方法的回调函数的 this，就指向 reporter


**与其他数据结构的相互转换**

- Map 转 Array

```js
const map = new Map([[1, 1], [2, 2], [3, 3]])
console.log([...map])	// [[1, 1], [2, 2], [3, 3]]
```

- Array 转 Map

```js
const map = new Map([[1, 1], [2, 2], [3, 3]])
console.log(map)	// Map {1 => 1, 2 => 2, 3 => 3}
```

- Map 转 Object

因为 Object 的键名都为字符串，而Map 的键名为对象，所以转换的时候会把非字符串键名转换为字符串键名。

```js
function mapToObj(map) {
    let obj = Object.create(null)
    for (let [key, value] of map) {
        obj[key] = value
    }
    return obj
}
const map = new Map().set('name', 'An').set('des', 'JS')
mapToObj(map)  // {name: "An", des: "JS"}
```

- Object 转 Map

```js
function objToMap(obj) {
    let map = new Map()
    for (let key of Object.keys(obj)) {
        map.set(key, obj[key])
    }
    return map
}

objToMap({'name': 'An', 'des': 'JS'}) // Map {"name" => "An", "des" => "JS"}
```

- Map 转 JSON

```js
function mapToJson(map) {
    return JSON.stringify([...map])
}

let map = new Map().set('name', 'An').set('des', 'JS')
mapToJson(map)	// [["name","An"],["des","JS"]]
```

- JSON 转 Map

```js
function jsonToStrMap(jsonStr) {
  return objToMap(JSON.parse(jsonStr));
}

jsonToStrMap('{"name": "An", "des": "JS"}') // Map {"name" => "An", "des" => "JS"}
```

### 二、weakSet & weakMap

#### 1.weakSet

WeakSet 对象允许你将弱引用对象储存在一个集合中

**WeakSet 与 Set 的区别：**

- WeakSet 只能储存对象引用，不能存放值，而 Set 对象都可以
- WeakSet 对象中储存的对象值都是被弱引用的，即垃圾回收机制不考虑 WeakSet 对该对象的应用，如果没有其他的变量或属性引用这个对象值，则这个对象将会被垃圾回收掉（不考虑该对象还存在于 WeakSet 中），所以，WeakSet 对象里有多少个成员元素，取决于垃圾回收机制有没有运行，运行前后成员个数可能不一致，遍历结束之后，有的成员可能取不到了（被垃圾回收了），WeakSet 对象是无法被遍历的（ES6 规定 WeakSet 不可遍历），也没有办法拿到它包含的所有元素

属性：

- constructor：构造函数，任何一个具有 Iterable 接口的对象，都可以作参数

```js
const arr = [[1, 2], [3, 4]]
const weakset = new WeakSet(arr)
console.log(weakset)
```


方法：

- add(value)：在WeakSet 对象中添加一个元素value
- has(value)：判断 WeakSet 对象中是否包含value
- delete(value)：删除元素 value
- clear()：清空所有元素，注意该方法已废弃

```js
var ws = new WeakSet()
var obj = {}
var foo = {}

ws.add(window)
ws.add(obj)

ws.has(window)	// true
ws.has(foo)	// false

ws.delete(window)	// true
ws.has(window)	// false
```

#### 2.weakMap

`WeakMap` 对象是一组键值对的集合，其中的键是弱引用对象，而值可以是任意。

注意，`WeakMap` 弱引用的只是键名，而不是键值。键值依然是正常引用。

`WeakMap` 中，每个键对自己所引用对象的引用都是弱引用，在没有其他引用和该键引用同一对象，这个对象将会被垃圾回收（相应的key则变成无效的），所以，`WeakMap` 的 `key` 是不可枚举的。

- 属性：
  - constructor：构造函数

- 方法：
    - has(key)：判断是否有 key 关联对象
    - get(key)：返回key关联对象（没有则则返回 undefined）
    - set(key)：设置一组key关联对象
    - delete(key)：移除 key 的关联对象

```js
let myElement = document.getElementById('logo');
let myWeakmap = new WeakMap();
myWeakmap.set(myElement, {timesClicked: 0});

myElement.addEventListener('click', function() {
let logoData = myWeakmap.get(myElement);
logoData.timesClicked++;
}, false);
```

### 三、总结

- Set
    - 成员唯一、无序且不重复
    - [value, value]，键值与键名是一致的（或者说只有键值，没有键名）
    - 可以遍历，方法有：add、delete、has
-  WeakSet
    - 成员都是对象
    - 成员都是弱引用，可以被垃圾回收机制回收，可以用来保存DOM节点，不容易造成内存泄漏
    - 不能遍历，方法有add、delete、has
- Map
    - 本质上是键值对的集合，类似集合
    - 可以遍历，方法很多可以跟各种数据格式转换
- WeakMap
    - 只接受对象作为键名（null除外），不接受其他类型的值作为键名
    - 键名是弱引用，键值可以是任意的，键名所指向的对象可以被垃圾回收，此时键名是无效的
    - 不能遍历，方法有get、set、has、delete


### 257描述 DOM 事件捕获的具体流程

###  一、DOM事件处理程序

#### 1.DOM0

`element.onClick = function(){}`

#### 2.DOM2

`element.addEventListener('click',function(){},false)` (IE下面说)

`element.addEventListener('click',function(){},false)`，第三个参数 false 表示在冒泡阶段调用事件处理程序 默认为false，true，表示在捕获阶段调用事件处理程序。

addEventListener 添加的事件只能通过 removeEventListener 来移除事件，但是移除的函数不能是匿名函数 移除的函数方法必须是一致的，如果不是特别需要，不建议在事件捕获阶段注册事件处理程序

#### 3.DOM3 

- 添加了更多的事件类型
    - UI 事件
    - 鼠标事件
    - 滚动事件
    - 键盘事件
    - 焦点事件
    - 文本事件
    - 合成事件
    - 变动事件
    - 变动名称事件
- 引入了以统一方式加载和保存文档的方法：在DOM加载和保存模块中定义
- 新增了验证文档的方法，在DOM验证模块中定义
- 支持XML1.0规范


DOM3 添加事件处理程序

```js
element.addEventListener('keyup',function(){},false)
```

### 二、事件流与事件模型

W3c 规定,最先通知window，然后是document，由上到下依次进入直到最底层的被出发的元素(也就是目标元素，通常的 event.target 的值)为止，这个过程称之为捕获，之后，事件会从目标元素开始，冒泡，由下至上逐层传递至windows，这个过程称之为冒泡

一个完整的事件流分成三个部分

- 捕获阶段
- 目标阶段
- 冒泡阶段

![image.png](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-236-buhuo.png)


### 三、描述DOM事件捕获/冒泡的具体流程

事件捕获会按照如下顺序传播：

- `window`
- `document`
- `<html>`
- `<body>`
- `div 父级元素->子级元素`
- `目标元素`

> 注：冒泡流程与之相反


```js
 <div id='box'>
    <a id='alink' href='https://www.baidu.com/'> 去百度</a>
 </div>

  var btn = document.getElementById('box');
  var alink = document.getElementById('alink');
  window.addEventListener('click', function (event) {
    console.log('window capture');
  }, false);

  document.addEventListener('click', function (event) {
    console.log('document capture');
  }, false);

  document.documentElement.addEventListener('click', function (event) {
    console.log('html capture');
  }, false);

  document.body.addEventListener('click', function (event) {
    console.log('body capture');
  }, false);

  alink.addEventListener('click', function (event) {
    event.preventDefault();
    console.log('a clcik')
  }, false)

  btn.addEventListener('click', function (event) {
    console.log('box clicked')
  }, false)

/*
执行结果是
box clicked
body capture
html capture
document capture
window capture
*/
```

如果将上述的addEventListener第三个参数变为false，则函数将在捕获的阶段执行

- window capture
- document capture
- html capture
- body capture
- box clicked


### 四、事件对象常见的应用

事件捕获之后我们所需要的属性以及经常使用的一些特性，如下

#### 1.event.preventDefault();

作用 阻止特定事件的默认行为

如 a标签绑定的click事件，在响应函数中设置方法会阻止链接默认跳转的行为 如上述例子所见，如果在a标签上增加阻止跳转的事件，将不会跳转至baidu.com，否则，在事件处理结束之后将会跳转至baidu.com；

#### 2.event.stopPropagation()

作用 阻止事件进一步冒泡

如果将上面的代码中改成以下的代码
    
```js
  btn.addEventListener('click', function (event) {
    console.log('box clicked')
    event.stopPropagation();
  }, false)

/* 
执行的结果将是 
a clcik 
box clicked 
*/
```

#### 3.event.stopImmediatePropagation()

作用 阻止事件进一步冒泡，同时阻止任何事件处理程序被调用。**事件响应优先级**（DOM3级事件中新增）

如，div绑定了两个click事件，通过优先级的方法，第一个响应的函数是a,第二个是b, 一次注册a,b 两个click 事      件，点击a 不要响应b，就可以使用此方法   

#### 4.event.currentTarget:当前正在处理事件的元素

event.target：**事件真正的目标**，表示当前被点击的元素

### 五、跨浏览器处理

针对不同的浏览器，在这里需要区分的是否是IE浏览器，如果是IE浏览器需要做一些特殊的处理

```js
const eventUtil = {
    // 添加一个事件
    addHandle = function (element, type, handle) {
      if (element.addEventListener) {
        element.addEventListener(type, handle, false) /*非IE*/
      } else if (element.attachEvent) {
        element.attachEvent('on' + type, handle); /*IE*/
      } else {
        element[`on${type}`] = handle
      }
    },

    // 给元素删除一个事件
    removeHandle = function (element, type, handle) {
      if (element.removeEventListener) {
        element.removeEventListener(type, handle, false) /*非IE*/
      } else if (element.detachEvent) {
        element.attachEvent('on' + type, handle); /*IE*/
      } else {
        element[`on${type}`] = null;
      }
    },

    // 获取兼容所有浏览器的一个对象
    getEvent: function (event) {
      return event ? event : window.event;
    },

    //获取事件类型
    getType: function (event) { //此项不存在浏览器兼容问题
      return event.type;
    },

    // 事件来自哪个元素
    getTarget: function (event) {
      return event.target || event.srcElement;
    },

    // 阻止事件默认行为
    preventDefault = function (event) {
      if (event.preventDefault) {
        event.preventDefault(); /*非IE*/
      } else {
        event.returnValue = false; /*IE*/
      }
    },

    // 阻止事件冒泡行为
    stopPropagation=function (event) {
      if (event.stopPropagation) {
        event.stopPropagation(); /*非IE*/
      } else {
        event.cancelBubble = true; /*IE*/
      }
    }
  }
```

```html
  <ul id='ul'>
      <li>sayhello</li>
      <li>sayGodbay</li>
   </ul>
```

```js
  var ulWrap = document.getElementById('ul');
  EventUtil.addHandle(ulWrap, 'click',function(){
    event = EventUtil.getEvent(event);
    console.log('当前选中的元素是', event.target.innerText)
  })

```

### 六、事件委托

针对事件处理程序做的一些优化以及为什么使用事件委托

```html
<ul id='myLinks'>
    <li id='gosomeWhere'>go someWhere</li>
    <li id='dosomething'>do something</li>
    <li id='sayhi'>Say hi</li>
  </ul>

```

包含3个被单击后会执行操作的列表项，按照传统的做法，需要按照以下的方式进行

```js
 // 传统的方法
  var item1 = document.getElementById('gosomeWhere')
  var item2 = document.getElementById('dosomething')
  var item3 = document.getElementById('sayhi')

  EventUtil.addHandle(item1, 'click', function () {
    location.href = 'https://www.baidu.com/';
  });

  EventUtil.addHandle(item2, 'click', function () {
    document.title = 'i changeed the document title'
  });

  EventUtil.addHandle(item3, 'click', function () {
    console.log('hi')
  });

// 使用事件委托，只需在DOM树中尽量噶的层次上添加一个事件处理程序
 var list = document.getElementById('myLinks');
  EventUtil.addHandle(list, 'click', function (event) {
    debugger;
    event = EventUtil.getEvent(event);
    const target = EventUtil.getTarget(event);
    switch (target.id) {
      case 'gosomeWhere':
        location.href = 'https://www.baidu.com/';
        break;
      case 'dosomething':
        document.title = 'i changeed the document title';
        break;
      case 'sayhi':
        console.log('hi');
        break;
    }
  });


```

使用事件委托只取得了一个DOM元素，添加了一个事件处理程序，减少了内存的占用，用到鼠标事件和键盘事件都可以使用事件委托，在需要的情况下，需要移除事件处理程序


### 258Promise 链式调用如何实现

### Promise 链式调用

#### 1.链式调用流程：

- `promise1 = new Promise(excutor = (resolve, reject) => { ... })` 中的 excutor 是立即执行的，但最后执行 resolve 可能是在异步操作中
- `promise1.then` 会给 promise1 添加回调，然后返回一个新的 promise2，这个新的 promise2 的决议依靠之前回调中的 resolvePromise 方法
- promise1 决议后会执行回调，首先执行 then 中传入的 `onFulfilled(promise1.value)`，赋值给变量 x，再执行 `resolvePromise(promise2, x, promise2Resolve, promise2Reject)`
- 如果 x 是个已决议的 Promise 或者普通的数据类型，那么就可以 `promise2Resolve(x)` 决议 promise2
- 如果 x 是个 pending 状态的 promise 或者 thenable 对象，那么执行 `x.then` ，将 resolvePromise 放入 x 的成功回调队列，等待 x 决议后将 `x.value` 成功赋值，然后执行 `resolvePromise(promise2, x.value, promise2Resolve, promise2Reject)`
- 在此期间如果执行了 `promise2.then` 就新建一个 promise3 并返回 ，将新传入的 `onFulfilled(promise2.value)` 和针对 promise3 的 resolvePromise 传入 promise2 的成功回调队列中，等待 promise2 的决议
- promise3.then 同上，就此实现了链式调用

#### 2.链式调用顺序：

- `promise1 => promise2 => promise3`，因为 promise2 的要在 promise1 的成功回调里执行

#### 3.链式调用透传

如果promise1.then 传入的onFulfilled 不是一个函数，此时onfulfilled 会被改写成 val => val

#### 4.promise代码实现：

```js
  // Promise 三种状态
  const PENDING = "Pending";
  const FULFILLED = "Fulfilled";
  const REJECTED = "Rejected";
  // promise  处理过程
  function promiseResolutionProcedure(promise2, x, resolve, reject) {
    // 判断循环引用
    if (promise2 === x) {
      throw new Error("循环引用 promise");
    }
    // 处理 promise 对象
    if (x instanceof MyPromise) {
      if (x.state === PENDING) {
        x.then((y) => {
          promiseResolutionProcedure(promise2, y, resolve, reject);
        }, reject);
      } else {
        x.state === FULFILLED && resolve(x.value);
        x.state === REJECTED && reject(x.value);
      }
    }
    // 判断 thenable 对象
    if ((typeof x === "object" || typeof x === "function") && x !== null) {
      if (typeof x.then === "function") {
        x.then((y) => {
          promiseResolutionProcedure(promise2, y, resolve, reject);
        }, reject);
      } else {
        resolve(x);
      }
    } else {
      resolve(x);
    }
  }
  class MyPromise {
    static all(promiseArray) {
      return new MyPromise((resolve, reject) => {
        let resultArray = [];
        let successTimes = 0;

        function processResult(index, data) {
          resultArray[index] = data;
          successTimes++;
          if (successTimes === promiseArray.length) {
            // 处理成功
            resolve(resultArray);
          }
        }

        for (let i = 0; i < promiseArray.length; i++) {
          promiseArray[i].then(
            (data) => {
              processResult(i, data);
            },
            (err) => {
              // 处理失败
              reject(err);
            }
          );
        }
      });
    }
    constructor(fn) {
      this.state = PENDING;
      this.value = undefined;
      this.resolveCallbacks = [];
      this.rejectCallbacks = [];
      const resolve = (val) => {
        if (
          (typeof val === "object" || typeof val === "function") &&
          val.then
        ) {
          promiseResolutionProcedure(this, val, resolve, reject);
          return;
        }
        setTimeout(() => {
          if (this.state === PENDING) {
            this.state = FULFILLED;
            this.value = val;
            // 执行所有的 then 方法
            this.resolveCallbacks.map((fn) => fn());
          }
        }, 0);
      };
      const reject = (val) => {
        if (
          (typeof val === "object" || typeof val === "function") &&
          val.then
        ) {
          promiseResolutionProcedure(this, val, resolve, reject);
          return;
        }
        setTimeout(() => {
          if (this.state === PENDING) {
            this.value = val;
            this.state = REJECTED;
            // 执行所有的 then 方法
            this.rejectCallbacks.map((fn) => fn());
          }
        }, 0);
      };
      fn(resolve, reject);
    }
    then(
      onFulfilled = (val) => val,
      onRejected = (err) => {
        throw new Error(err);
      }
    ) {
      let promise2 = null;
      // 处理已经完成的 promise
      if (this.state === FULFILLED) {
        promise2 = new MyPromise((resolve, reject) => {
          const x = onFulfilled(this.value);
          promiseResolutionProcedure(promise2, x, resolve, reject);
        });
      }

      // 处理已经完成的 promise
      if (this.state === REJECTED) {
        promise2 = new MyPromise((resolve, reject) => {
          const x = onRejected(this.value);
          promiseResolutionProcedure(promise2, x, resolve, reject);
        });
      }

      // 处理尚未完成的 promise
      if (this.state === PENDING) {
        promise2 = new MyPromise((resolve, reject) => {
          this.resolveCallbacks.push(() => {
            const x = onFulfilled(this.value);
            promiseResolutionProcedure(promise2, x, resolve, reject);
          });

          this.rejectCallbacks.push(() => {
            const x = onRejected(this.value);
            promiseResolutionProcedure(promise2, x, resolve, reject);
          });
        });
      }
      return promise2;
    }
  }
```

### 259gennerator yield 的作用

### Generator

#### 1.概念

**Generator：**指生成器函数，声明方式为 `function*` ，返回一个Generator对象，该对象部署了Iterator接口，可遍历。

- Generator是一种 异步解决方案，Generator可以理解成一个状态机，封装了多个内部状态。
- Generator函数返回一个遍历器对象，除了是个状态机，还是个遍历器对象生成函数。返回的遍历器对象，能依次遍历函数内部每个状态。
- Generator函数有两个特征：
   - `function` 关键字和函数名之间有一个星号
   - 函数内部使用 `yield` 表达式，定义了不同的内部状态

基本语法

```js
function* helloWorldGenerator(){
	yield 'hell0';
  yield 'world';
  return 'ending';
}
var hw = helloWorldGenerator();
hw.next()
// { value: 'hello', done: false }
hw.next()
// { value: 'world', done: false }
hw.next()
// { value: 'ending', done: true }
hw.next()
// { value: undefined, done: true }
```

调用Generator函数，函数并不执行，返回的是一个遍历器对象，也就是一个指向内部状态的 指针对象 。

必须调用遍历器对象的 next 方法，使得指针向下一个状态。

每次调用遍历器对象的 next 方法，就会返回一个有着 value 和 done 两个属性的对象。

- **value**：表示当前内部状态的值，是 yield 后面那个表达式的值
- **done**：是一个布尔值，表示是否遍历结束。

#### 2.yield

- `yield` 表达式用于委托给另一个 generator 或 可迭代的对象。
- `yield` 表达式迭代紧跟其后的对象或generator，返回每次操作的值。
- `yield` 表达式本身的值是当迭代器关闭时返回的值（即done为true时）

**作用**：

用来暂停和恢复一个生成器函数

**语法：**

```javascript
[rv] = yield [expression];
```

- `expression`定义通过迭代器协议从生成器函数返回的值。如果省略，则返回`undefined`。
- `rv`返回传递给生成器的`next()`方法的可选值，以恢复其执行。

**示例**

```js
function* g4() {
  yield* [1, 2, 3];
  return "foo";
}

var result;

function* g5() {
  result = yield* g4();
}

var iterator = g5();

console.log(iterator.next()); // { value: 1, done: false }
console.log(iterator.next()); // { value: 2, done: false }
console.log(iterator.next()); // { value: 3, done: false }
console.log(iterator.next()); // { value: undefined, done: true }, 
// 此时 g4() 返回了 { value: "foo", done: true }
console.log(result);   // "foo"
```

**描述：**

- `yield`关键字使生成器函数执行暂停，`yield`关键字后面的表达式的值返回给生成器的调用者。它可以被认为是一个基于生成器的版本的`return`关键字。
- `yield`关键字实际返回一个`IteratorResult`对象，它有两个属性，`value`和`done`。`value`属性是对`yield`表达式求值的结果，而`done`是`false`，表示生成器函数尚未完全完成。
- 一旦遇到 `yield` 表达式，生成器的代码将被暂停运行，直到生成器的 `next()` 方法被调用。每次调用生成器的`next()`方法时，生成器都会恢复执行，直到达到以下某个值：
   - `yield`，导致生成器再次暂停并返回生成器的新值。 下一次调用`next()`时，在`yield`之后紧接着的语句继续执行。
   - `throw`用于从生成器中抛出异常。这让生成器完全停止执行，并在调用者中继续执行，正如通常情况下抛出异常一样。
   - 到达生成器函数的结尾；在这种情况下，生成器的执行结束，并且`IteratorResult`给调用者返回`undefined`并且`done`为`true`。
   - 到达`return`语句。在这种情况下，生成器的执行结束，并将`IteratorResult`返回给调用者，其值是由`return`语句指定的，并且`done` 为`true`。
- 如果将参数传递给生成器的`next()`方法，则该值将成为生成器当前`yield`操作返回的值。

在生成器的代码路径中的`yield`运算符，以及通过将其传递给`Generator.prototype.next()`指定新的起始值的能力之间，生成器提供了强大的控制力。

#### 3.总结

- yield 是 Generator 函数内部关键字，用于暂停和恢复函数执行。
- yield 和 Generator 函数返回的遍历器对象的 next 方法配合，能实现内部状态遍历过程。
- 调用 GeneratorObj.next() 返回 yield 后面的值以及是否执行结束的标志。将函数执行权交还给外部调用。
- 同时 GeneratorObj.next()也可以通过传参将外部变量，传给函数内部。



### 260cros 的简单请求和复杂请求的区别

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

### 261说一下对`BigInt`的理解，在什么场景下会使用

### BigInt

JavaScript 所有数字都保存成 64 位浮点数，这给数值的表示带来了两大限制。一是数值的精度只能到 53 个二进制位（相当于 16 个十进制位），大于这个范围的整数，JavaScript 是无法精确表示的，这使得 JavaScript 不适合大规模的精确计算。二是大于或等于2的1024次方的数值，JavaScript 无法表示，会返回Infinity。

```js
Math.pow(2, 1024) // Infinity
```

#### 1）使用场景

在对大整数执行数学运算时，以任意精度表示整数的能力尤为重要, 比如应用于科学和金融方面的计算。

#### 2）使用BigInt

为了解决这个问题，JavaScript 新增了基本数据类型 BigInt ，目的就是比Number数据类型支持的范围更大的整数值。

使用 JavaScript 提供的BigInt对象， 可以用作构造函数生成 BigInt 类型的数值。

转换规则基本与 Number() 一致，将其他类型的值转为 BigInt。

```js
BigInt(123) // 123n
BigInt('123') // 123n
BigInt(false) // 0n
BigInt(true) // 1n
```

BigInt()构造函数必须有参数，而且参数必须可以正常转为数值，下面的用法都会报错。 

```js
new BigInt() // TypeError
BigInt(undefined) //TypeError
BigInt(null) // TypeError
BigInt('123n') // SyntaxError
BigInt('abc') // SyntaxError
```

或是直接在整数末尾追加n即可，比如:

```js
console.log(9999999999999999n); // 9999999999999999n
console.log(9999999999999999); // 10000000000000000
```


在类型判断上，不能使用严格运算符去比较BigInt与 Number类型，它们的类型不同因此为false, 而相等运算符则会进行隐式类型转换 , 因此为true

```js
console.log(100n === 100); // false
console.log(100n == 100); // true 
```

BigInt 无法使用`+`一元运算符， 也无法和 Number 一同计算

```js
+10n // Uncaught TypeError: Cannot convert a BigInt value to a number
20n / 10  // Uncaught TypeError: Cannot mix BigInt and other types, use explicit conversions
```

当使用 BigInt 进行计算时，结果同样会返回BigInt值。 并且除法(/)运算符的结果会自动向下舍入到最接近的整数。

```js
25n / 10n  // 10n
```

#### 3）总结
BigInt 是一种新的基本类型，用于当整数值大于 Number 数据类型的范围时。使用 BigInt 避免整数溢出，保证计算安全。
使用过程中要避免 BigInt 与 Number 和 `+`一元运算符同时使用。

### 262改变 this 指向的方式都有哪些？



### 263节流



### 264如何实现 5 秒自动刷新一次页面(具体都有什么方法 reload 之类的)



### 265都了解哪些 ES6、ES7 的新特性，箭头函数可以被 new 吗



### 266说一下 JavaScript 继承都有哪些方法



### 267数组和对象转换为字符串结果
```js
var arry = [];
var obj = {};
// arry,obj 转成字符串的结果是什么？
```



### 268请写出以下代码的打印结果
```js
var a = {
  name: "A",
  fn() {
    console.log(this.name);
  },
};
a.fn();
a.fn.call({ name: "B" });
var fn1 = a.fn;
fn1();
// 写出打印结果
```



### 269请写出以下代码的打印结果
```js
let int = 1;
setTimeout(function () {
  console.log(int);
  int = 2;
  new Promise((resolve, reject) => {
    resolve();
  }).then(function () {
    console.log(int);
    int = 7;
  });
  console.log(int);
});
int = 3;
console.log(int);
new Promise((resolve, reject) => {
  console.log(int);
  return resolve((int = 4));
}).then(function (res) {
  console.log(int);
  int = 5;
  setTimeout(function () {
    console.log(int);
    int = 8;
  });
  return false;
});
console.log(int);
// 写出打印结果
```



### 270请给出识别 Email 的正则表达式



### 271设计 AutoComplete 组件(又叫搜索组件、自动补全组件等)时，需要考虑什么问题？



### 272null 是不是一个对象，如果是，如何判断一个对象是 null，不使用 JavaScript 提供的 api 如何进行判断



### 273请写出以下代码执行结果
```js
var a = { x: 1 };
var b = a;
a.x = a = { n: 1 };
console.log(a); // ?
console.log(b); // ?
```



### 274请写出以下代码执行结果
```js
Function.prototype.a = () = >{alert(1)}
Object.prototype.b = () = >{alert(2)}
function A(){};
const a = new A();
a.a();
a.b();
// 写出执行结果
```



### 275请写出以下代码执行结果
```js
let a = 0;
console.log(a);
console.log(b);
let b = 0;
console.log(c);
function c() {}
// 写出执行结果
```



### 276请写出以下代码执行结果
```js
var x = 10;
function a(y) {
  var x = 20;
  return b(y);
}
function b(y) {
  return x + y;
}
a(20);
// 写出执行结果
```



### 277请写出以下代码执行结果
```js
[1, 2, 3, 4, 5].map(parselnt);
// 写出执行结果
```



### 278请写出以下代码执行结果
```js
typeof typeof typeof [];
// 写出执行结果
```



### 279实现一个函数柯里化



### 280请实现`$on,$emit`



### 281手写实现 sleep 函数



### 282请写出原生 js 如何设置元素高度



### 283换行字符串格式化



### 284输入一个日期 返回几秒前、几小时前、几天前、几月前



### 285将 153812.7 转化为 153,812.7



### 286valueOf 与 toString 的区别



### 287怎么判断是一个空对象



### 288请写出下面代码的执行结果
```js
setTimeout(() => {
  console.log(0);
}, 0);
new Promise((res) => setTimeout(res, 0)).then(() => {
  console.log(1);
  setTimeout(() => {
    console.log(2);
  }, 0);
  new Promise((r = r())).then(() => {
    console.log(3);
  });
});
setTimeout(() => {
  console.log(4);
}, 0);
new Promise((res) => res()).then(() => {
  console.log(5);
});
```



### 289setTimeout 与 setInterval 区别



### 290项目中如何应用数据结构



### 291闭包的核心是什么



### 292介绍事件冒泡、事件代理、事件捕获，以及它们的关系



### 293promise 的状态有哪些



### 294async、await 如何进行错误捕获


### 错误捕获方式

#### 1.try/catch

一般情况下 async/await 在错误处理方面，主要使用 try/catch，像这样

```js
const fetchData = () => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve('fetch data is me')
        }, 1000)
    })
}

(async () => {
    try {
        const data = await fetchData()
        console.log('data is ->', data)
    } catch(err) {
        console.log('err is ->', err)
    }
})()

```

这么看倒是没有什么问题，但是如果有多个异步操作呢？那就需要些多个 `try catch`。所以这种方式间接性就很差。

#### 1.2 优雅的解决方式


优雅的解决方式，async/await 本质就是 promise 的语法糖，既然是 promise 那么就可以使用 then 函数了


1. async函数本身会返回一个promise,可以通过catch获取
2. async内部我们可以通过try...catch来获取，原本就是generator语法糖
3. 基于这个机制我们可以实现错误捕捉

```js
export default function errorHanlder(promise) {
   return promise.then(data => {
      return [null, data];
   })
   .catch(err => [err]);
}
```




### 295请写出一下代码的打印结果
```js
function a(obj) {
  obj.a = 2;
  obj = { a: 3 };
  return obj;
}
const obj = { a: 1 };
a(obj);
console.log(obj);
```


### 执行结果

```js
{a: 3}
{a: 2}
```

### 解析

js 传递值的方式是按值传递，如果传递的是基本数据类型，则传递的是*值的副本*，如果传递的参数是引用类型，则传递的值是数据的*引用地址副本*  
所以，当传递的值为引用类型时，传递的是引用地址副本，通过引用类型的地址副本，所指向的数据地址都是同一个内存堆，所以改变引用地址副本的数据，原来的引用数据也会发生改变，但是，在题中，给 obj 重新赋值了新的对象，即改变了引用地址副本，所以最终看到上面这样的结果

看以下的两个例子，理解以上解释

```js
  function a(obj){
    obj = 123;
    return obj;
  }
  const obj = {
    a: 1
  };
  console.log(a(obj));  // 123
  console.log(obj); // {a:1}  原来引用数据不会受到影响
```

```js
  function a(obj) {
    obj.a = 123;
    return obj;
  }
  const obj = {
      a: 1
  };
  console.log(a(obj)); // {a:123}
  console.log(obj); // {a:123}  原来引用数据受到影响
  console.log(a(obj ==  obj));    // true 指向同一地址
```

```js
  function a(obj) {
    obj.a = 123;
    obj = 'change address'
    return obj;
  }
  const obj = {
      a: 1
  };
  console.log(a(obj)); // {a:change address}  改变了地址副本
  console.log(obj); // {a:123}  原来引用数据受到影响
  console.log(a(obj) == obj);    // false 指向不同地址
```

### 296请写出下面代码的执行结果
```js
function Foo() {
  getName = function () {
    alert(1);
  };
  return this;
}
getName();
Foo.getName = function () {
  alert(2);
};
Foo.prototype.getName = function () {
  alert(3);
};
getName = function () {
  alert(4);
};

// 请写出下面的输出结果
getName90;
Foo.getName();
new Foo().getName();
```


### 执行结果

1. getName();由于这里变量 getName 提升为 undefined，所以报错
2. 忽略第一步；getName 此时赋值成了函数所以打印 4
3. Foo.getName()是 Foo 的静态方法调用所以 2
4. new Foo()优先级大于.运算，所以 getName 是当前实例的调用，则查到到原型的方法 getName 打印 3

```js
报错
4
2
3
```


### 297修改以下代码，使得最后⼀⾏代码能够输出数字 0-9（最好能给多种答案）
```js
var arrys = [];
for (var i = 0; i < 10; i++) {
  arrys.push(function () {
    return i;
  });
}
arrys.forEach(function (fn) {
  console.log(fn());
}); //本⾏不能修改
```


### 代码实现

解决此题的关键就是知道在for循环的时候，如何记住我是谁。

解决方案清晰很多： 块级作用域或者闭包

#### 方案一

let 和const声明的变量遇到{块}都会形成一个块，此时i是个变量，使用let

```js
for (let i = 0; i < 10; i++) {
    arrys.push(function () {
        return i;
    });
}
```

#### 方案二

自执行函数形成闭包

```js
for (var i = 0; i < 10; i++) {
    (function(j){
        arrys.push(function () {
            return j;
        });
    })(i);
}
```

#### 方案三

内部函数自执行形成闭包

```js
for (var i = 0; i < 10; i++) {
    arrys.push((function (j) {
        return _ => j;
    })(i));
}
```


### 298请只用数组方法和 Math.random()在一条语句的情况下，实现生成给定位数的随机数组，例如生成 10 位随机数组[1.1,102.1,2,3,8,4,90,123,11,123],数组内数字随机生成。


### 代码实现

```js
Array.from({length:n}, () => Math.random()*10)

// 生成 长度为10 的随机数组
Array.from({length:10}, () => Math.random()*10)
```

### 299实现一个 setter 方法
```js
let setter = function (conten, key, value) {
  // your code
};
let n = {
  a: {
    b: {
      c: { d: 1 },
      bx: { y: 1 },
    },
    ax: { y: 1 },
  },
};
// 修改值
setter(n, "a.b.c.d", 3);
console.log(n.a.b.c.d); //3
setter(n, "a.b.bx", 1);
console.log(n.b.bx); //1
```


### 代码实现

- 实现一

```js
let setter = function (conten, key, value) {
  let argArr = key.split('.');
      let i = argArr.shift();
    if (argArr.length==0){
        conten[i]=value;
    }else{
        conten[i]=setter(conten[i],argArr.join('.'),value);
    }
      return conten;
};
let n = {
  a: {
    b: {
      c: { d: 1 },
      bx: { y: 1 },
    },
    ax: { y: 1 },
  },
};
// 修改值
setter(n, "a.b.c.d", 3);
console.log(n.a.b.c.d); //3
setter(n, "a.b.bx", 1);
console.log(n.a.b.bx); //1
```

- 实现二

```js
let setter = function (content, key, value) {
    try {
        let keyArr = key.split(".");
        let { obj, k } = keyArr.reduce((content, k, i) => {
        if (i !== keyArr.length - 1) {
            return content[k];
        } else {
            return { obj: content, k };
        }
        }, content);
        obj[k] = value;
    } catch (e) {
        console.warn("输入key有误");
    }
};
let n = {
  a: {
    b: {
      c: { d: 1 },
      bx: { y: 1 },
    },
    ax: { y: 1 },
  },
};
// 修改值
setter(n, "a.b.c.d", 3);
console.log(n.a.b.c.d); //3
setter(n, "a.b.bx", 1);
console.log(n.a.b.bx); //1
```

- 实现三

```js
let setter = function(content,key,value){
	var proto = key.split('.');
	var len = proto.length;
	proto.reduce(function(obj,val,index){
		if(index === len-1){
			return obj[val] = value;
		}
		if (typeof obj[val] != 'object') obj[val] = {};
		return obj[val];
	},content)
}
let n = {
  a: {
    b: {
      c: { d: 1 },
      bx: { y: 1 },
    },
    ax: { y: 1 },
  },
};
// 修改值
setter(n, "a.b.c.d", 3);
console.log(n.a.b.c.d); //3
setter(n, "a.b.bx", 1);
console.log(n.a.b.bx); //1
```

### 300要求⽤不同⽅式对 A 进⾏改造实现 A.name 发⽣变化时⽴即执⾏ A.getName
```js
/*
	已知对象A = {name: 'sfd', getName: function(){console.log(this.name)}},
	现要求⽤不同⽅式对A进⾏改造实现A.name发⽣变化时⽴即执⾏A.getName
*/
```


### 代码实现

#### 方法一

```js
let _name = 'sfd'
A = {
	get name() {
		return _name
	},
    set name(name) {
        _name = name
        this.getName()
    },
    getName: function() {
        console.log(this.name)
    }
}
```

#### 方法二

```js
const A = {
    getName: function() {
        console.log(this.name)
    }
}
let _name = 'sfd'
Object.defineProperty(A, 'name', {
    enumerable: true,
    configurable: true,
    get() {
        return _name
    },
    set(name) {
        _name = name
        this.getName()
    }
})
```

#### 方法三

```js
const _A = {
    name: 'sfd',
	getName: function() {
		console.log(this.name)
	}
}
const A = new Proxy(_A, {
    get(target, key, receiver) {
       return Reflect.get(target, key, receiver) 
    },
    set(target, key, value, receiver) {
        const res = Reflect.set(target, key, value, receiver)
        target.getName()
        return res
    }
})
```

### 301说一下对于堆栈的理解


### 一、理解

堆和栈其实是两种数据结构。堆栈都是一种数据项按序排列的数据结构，只能在一端(称为栈顶(top))对数据项进行插入和删除。堆栈是个特殊的存储区，主要功能是暂时存放数据和地址。


#### 1.堆

- 堆内存的存储的值的大小不定，是由程序员自己申请并指明大小。因为堆内存是 new 分配的内存，所以运行效率会较低。
- 堆内存是向高地址扩展的数据结构，是不连续的内存区域，系统也是用链表来存储空闲的内存地址，所以是不连续的。因为是记录的内存地址，所以获取是通过引用，存储的是对象居多。
- 堆内存的回收是人为控制的，当程序结束后，系统会自动回收。

#### 2.栈

- 栈内存的存储大小是固定的，申请时由系统自动分配内存空间，运行的效率比较快，但是因为存储的大小固定，所以容易存储的大小超过存储的大小，导致溢栈。
- 栈内存存储的是基础数据类型，并且是按值访问，因为栈是一块连续的内存区域，以**后进先出**的原则存储调用的，所以是连续存储的。
- 栈的回收是系统控制实现的。

### 302说一下`module.exports`和`exports`的区别，`export`和`export default`的区别


### 一、区别

`module.exports`和`exports`是node 支持的导出方式，也就是 commonjs 导出规范

`export`和`export default`是 es6 支持的导出方式

#### 1.`module.exports`和`exports`的区别

**exports**

exports 导出的是 module.exports 的引用，为什么这么说，代码如下

```js
console.log(exports)   //{}
console.log(module.exports)  //{}
// a.js
const a = 25;
exports.a = a
// b.js
const test = require('./a')
console.log(test)
// {a:25}
```

我们可以看到，exports.a 这样的导出的方式，其实也是将 module.exports 导出去了，只是往外的将 a 挂载到了 module.exports 的内存地址上  

为什么说一定是 module.exports 的内存地址呢，再看下面的代码

```js
// a.js
const a = 25;
exports = a
// b.js
const test = require('./a')
console.log(test)
// {}
```

可以看到，如果直接 exports 的话，返回是一份新内存地址

**module.exports**

区别其实在上面已经说完了，看下面代码

```js
// a.js
const a = 25;

module.exports = a
// b.js
const test = require('./a')
console.log(test)
// 25
```

#### 2.`export`和`export default`的区别


1、`export default` 只能导出一个变量，而 export 可以导出多个

2、`export` 导出的变量可以修改，`export default` 则不行

```js
// a.js
let e1='export 1';
let e2='export 2';
export {e2};
export default e1;
e1='export 1 modified';
e2='export 2 modified';
// b.js
import e1, {e2} from "./b";
console.log(e1);  //export 1
console.log(e2);  // export 2 modified
```

3、语法差异，export var/let/const xxx = xxx;是合法语句，但是 export default 则不可以




### 303promise 跟 async await 的区别，使用场景  


### 一、区别

#### 1.定义

* `Promise`是对象，用于表示一个异步操作的最终完成 (或失败), 及其结果值。
* async function 是声明语句，用来定义一个返回 `AsyncFunction` 对象的异步函数，它会通过一个隐式的 Promise 返回其结果。
* await 是表达式，用于暂停当前异步函数的执行，等待 Promise 处理完成，只在异步函数内有效。

#### 2.错误的捕获

* 使用 async/await 语法能让开发者在异步代码中也按照类似同步代码中一样的方式使用 try-catch 语句。
* Promise 的错误无法在外部被捕捉到，只能在内部进行预判处理

#### 3.中断

* Promise 是一个状态机，本身是无法完全中止的。
* async function 使用语义化的 await 中断程序。 

### 二、关系

`async`/`await`的目的是简化使用多个 promise 时的同步行为，并对一组 `Promises`执行某些操作。正如`Promises`类似于结构化回调，`async`/`await`更像结合了generators和 promises。

### 三、使用场景

一般在异步处理时使用，而通常的，由于它们之间紧密的关系，都是搭配使用的。

1. Promise 提供的工具函数对应的场景，如 Promise.all 并行执行一组 Promise
2. async/await 避免了繁杂的 Promise 链式调用，且更加语义化，推荐使用 async/await 

### 304在 map 中和 for 中调用异步函数的区别


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

### 305用原生 js 实现自定义事件


### JS 自定义事件

Javascript自定义事件类似设计的观察者模式，通过状态的变更来监听行为，主要功能解耦，易于扩展。多用于组件、模块间的交互。

原型模式下的自定义事件

```js
var EventTarget = function() {
    this._listener = {};
};

EventTarget.prototype = {
    constructor: this,
    addEvent: function(type, fn) {
        if (typeof type === "string" && typeof fn === "function") {
            if (typeof this._listener[type] === "undefined") {
                this._listener[type] = [fn];
            } else {
                this._listener[type].push(fn);
            }
        }
        return this;
    },
    addEvents: function(obj) {
        obj = typeof obj === "object"? obj : {};
        var type;
        for (type in obj) {
            if ( type && typeof obj[type] === "function") {
                this.addEvent(type, obj[type]);
            }
        }
        return this;
    },
    fireEvent: function(type) {
        if (type && this._listener[type]) {
            //event参数设置
            var events = {
                type: type,
                target: this
            };

            for (var length = this._listener[type].length, start=0; start<length; start+=1) {
                //改变this指向
                this._listener[type][start].call(this, events);
            }
        }
        return this;
    },
    fireEvents: function(array) {
        if (array instanceof Array) {
            for (var i=0, length = array.length; i<length; i+=1) {
                this.fireEvent(array[i]);
            }
        }
        return this;
    },
    removeEvent: function(type, key) {
        var listeners = this._listener[type];
        if (listeners instanceof Array) {
            if (typeof key === "function") {
                for (var i=0, length=listeners.length; i<length; i+=1){
                    if (listeners[i] === key){
                        listeners.splice(i, 1);
                        break;
                    }
                }
            } else if (key instanceof Array) {
                for (var lis=0, lenkey = key.length; lis<lenkey; lis+=1) {
                    this.removeEvent(type, key[lenkey]);
                }
            } else {
                delete this._listener[type];
            }
        }
        return this;
    },
    removeEvents: function(params) {
        if (params instanceof Array) {
            for (var i=0, length = params.length; i<length; i+=1) {
                this.removeEvent(params[i]);
            }
        } else if (typeof params === "object") {
            for (var type in params) {
                this.removeEvent(type, params[type]);
            }
        }
        return this;
    }
};
```

### 306在 ES6 中有哪些解决异步的方法


### ES6中可用的异步方法

#### 1.Generator + Promise + 执行器

```js
const fs = require('fs')
 
// Promise 版的readFile
const readFile = function (fileName) {
 return new Promise(function(resolve, reject) {
  fs.readFile(fileName, function(err, data){
   if (err) return reject(error);
   resolve(data);
  })
 })
}
 
const gen = function * () {
 let f1 = yield readFile('a.txt');
 let f2 = yield readFile('b.txt');
 
 console.log('F1--->', f1.toString());
 console.log('F2--->', f2.toString());
}
 
 
// 基于 Generator 和 Promise 的自动执行器
function run(gen) {
 
 let g = gen();
  
 function next(data) {
   
  let result = g.next(data);
 
  if (result.done) return result.value;
 
  result.value.then(function(data) {
   next(data);
  });
 }
 next();
}
 
run(gen);
```

#### 2.Generator + Thunk函数 + 执行器

```js
const fs = require('fs')
 
// 把一个单一执行的函数 ，变成需要再次调用的函数，固定一部分参数
function thunkify(fn, obj = {}) {
  return function () {
    let args = Array.from(arguments);
    return function (m) {
      args.push(m)
      return fn.apply(obj, args)
    }
  }
}
 
const readFile = thunkify(fs.readFile, fs);
 
const gen = function* () {
  let f1 = yield readFile('a.txt');
  let f2 = yield readFile('b.txt');
 
  console.log('F1-->', f1.toString());
  console.log('F2-->', f2.toString());
}
 
 
// 基于 Generator 和 Thunk函数的自动执行器
function run(fn) {
  let gen = fn();
 
  function next(err, data) {
    let result = gen.next(data);
    if (result.done) return 1;
    result.value(next);
  }
 
  next();
 
}
 
run(gen);
```

#### 3.基于 async 函数 和 await 的异步处理方式

```js
const fs = require('fs')
 
// Promise 版的readFile
const readFile = function (fileName) {
 return new Promise(function(resolve, reject) {
  fs.readFile(fileName, function(err, data){
   if (err) return reject(err);
   resolve(data);
  })
 })
}
 
const asyncReadFile = async function () {
 const f1 = await readFile('a.txt');
 const f2 = await readFile('b.txt');
 console.log(f1.toString());
 console.log(f2.toString());
};
 
asyncReadFile();
```

### 307实现 bind 方法，不能使用 call、apply、bind


### bind 

#### 1.1 概念

bind() 方法创建一个新的函数，在 bind() 被调用时，这个新函数的 this 被指定为 bind() 的第一个参数，而其余参数将作为新函数的参数，供调用时使用。

通俗一点，bind与apply/call一样都能改变函数this指向，但bind并不会立即执行函数，而是返回一个绑定了this的新函数，你需要再次调用此函数才能达到最终执行。

#### 1.2 特点

- 可以修改函数this指向。
- bind返回一个绑定了this的新函数·
- 支持函数柯里化
- 新函数的this无法再被修改，使用call、apply也不行。

#### 1.3 模拟实现

- 不准使用call、apply、bind 可以自己模拟一个apply

```js
Function.prototype.myapply = function (context, ...argus) {
    if (typeof this !== 'function') {
        throw new TypeError('not funciton')
    }
    const fn = this
    let result = null

    context = context || window
    argus = argus && argus[0] || []
    context.fn = fn
    result = context.fn(...argus)
    delete context.fn

    return result
}
Function.prototype.mybind = function (context) {
    var me = this;
    var args = Array.prototype.slice.myapply(arguments, [1]);
    var F = function () {};
    F.prototype = this.prototype;
    var bound = function () {
        var innerArgs = Array.prototype.slice.mycall(arguments);
        var finalArgs = args.concat(innerArgs);
        return me.myapply(this instanceof F ? this : context || this, finalArgs);
    }
    bound.prototype = new F();
    return bound;
}
```

### 308请实现一个 cacheRequest 方法，保证发出多次同一个 ajax 请求时都能拿到数据，而实际上只发出一次请求



### 代码实现

- cache 构建Map，用作缓存数据;把URL作为key,用于判断是否同一个请求,
- 请求的更多参数可传入option，如：GET,data等
- 每次请求检查缓存，有则返回缓存数据，无则发起请求
- 请求成功后，保存数据到cache并返回，失败则弹出提示
- 特殊情况，如果请求在pending状态，则返回该请求继续等待
- 代码中ajax请求用setTimeout()函数代替，可自行封装request- 函数或用axios代替

```js
const request = (url,option)=>new Promise((res)=>{
  setTimeout(()=>{
    res({data:option})
  },2000)
})
const cache = new Map();
const cacheRequest = (url,option) => {
  let key = `${url}:${option.method}`;
  if (cache.has(key)) {
    if(cache.get(key).status === 'pending'){
      return cache.get(key).myWait;
    }
    return Promise.resolve(cache.get(key).data)
  } else {
    // 无缓存，发起真实请求
    let requestApi = request(url,option);
    cache.set(key, {status: 'pending',myWait: requestApi})
    return requestApi.then(res => {
      // console.log(cache)
      cache.set(key, {status: 'success',data:res})
      // console.log(cache)
      return Promise.resolve(res)
    }).catch(err => {
      cache.set(key, {status: 'fail',data:err})
      Promise.reject(err)
    })
  }
}
```

调用

```js
cacheRequest('url1')
.then(res => console.log(res))
cacheRequest('url1')
.then(res => console.log(res))

setTimeout(()=>{
  cacheRequest('url1')
  .then(res => console.log(res))
},4000)
```

### 309实现一个函数将中文数字转成数字



### 代码实现

#### 1.基本方法

 1. 从中文数字中逐个识别出数字和权位的组合
 2. 然后根据权位和数字倍数对应关系 计算出每个数字和权位组合的值
 3. 最后求和得出结果

 #### 2.算法实现

1. 将中文数字转换成阿拉伯数字
2. 将中文权位转换成10的倍数

#### 3.代码实现一

```js
function ChineseToNumber(chnString) {
    const CHN_CHAR_LENGTH = 1;

    const chnNumChar = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"];
    const chnUnitChar = ["", "十", "百", "千"]
    const chnUnitSection = ["", "万", "亿", "万亿"]
    const chnValuePair = [
      ["十", 10, false], //  [0] name中文权位名 [1] 10的倍数值 value  [2]secUnit 是否是节权位
      ["百", 100, false],
      ["千", 1000, false],
      ["万", 10000, true],
      ["亿", 100000000, true],
    ]
          //  主要算法
      let rtn = 0;
      let section = 0;
      let number = 0;
      let secUnit = false;
      let pos = 0;
    // 中文数字转换数字，如果返回-1，表示这是一个权位字符。
    function ChineseToValue(chnStr) {
      for (let val = 0; val < chnNumChar.length; val++) {
        if (chnStr == chnNumChar[val]) {
          return val;
        }
      }
      return -1;
    }
    //  chnValuePair 表得到权位对应的10的倍数。
    function ChineseToUnit(chnStr) {
      // console.log(chnStr)
      for (let unit = 0; unit < chnValuePair.length; unit++) {
        if (chnStr == chnValuePair[unit][0]) {
          secUnit = chnValuePair[unit][2];
          // console.log(secUnit)
          return chnValuePair[unit][1];
        }
    }

    return 1;
  }

    while (pos < chnString.length) {
    let num = ChineseToValue(chnString.substr(pos, CHN_CHAR_LENGTH));
    // console.log("num:",num)
    if (num >= 0) // 数字还是单位
    {
        number = num;
        pos += CHN_CHAR_LENGTH;
        if (pos >= chnString.length) //如果是最后一位数字 直接结束
        {
        section += number;
        rtn += section;
        break;
        }
    } else {
        let unit = ChineseToUnit(chnString.substr(pos, CHN_CHAR_LENGTH));
        // console.log("unit",unit,secUnit)
        if (secUnit) //是节权位说明一个节已经结束
        {
        section = (section + number) * unit;
        rtn += section;
        section = 0;
        } else {
        section += (number * unit);
        }
        number = 0;
        pos += CHN_CHAR_LENGTH;
        if (pos >= chnString.length) {
        rtn += section;
        break;
        }
    }
    }

    return rtn;
}

const testPair = [
   [ 0,"零" ],
    [ 1,"一" ],
    [ 2,"二" ],
    [ 3,"三" ],
    [ 4,"四" ],
    [ 5,"五" ],
    [ 6,"六" ],
    [ 7,"七" ],
    [ 8,"八" ],
    [ 9,"九" ],
    [ 10,"一十" ],
    [ 11,"一十一" ],
    [ 110,"一百一十" ],
    [ 111,"一百一十一" ],
    [ 100,"一百" ],
    [ 102,"一百零二" ],
    [ 1020,"一千零二十" ],
    [ 1001,"一千零一" ],
    [ 1015,"一千零一十五" ],
    [ 1000,"一千" ],
    [ 10000,"一万" ],
    [ 20010,"二万零一十" ],
    [ 20001,"二万零一" ],
    [ 100000,"一十万" ],
    [ 1000000,"一百万" ],
    [ 10000000,"一千万" ],
    [ 100000000,"一亿" ],
    [ 1000000000,"一十亿" ],
    [ 1000001000,"一十亿零一千" ],
    [ 1000000100,"一十亿零一百" ],
    [ 200010,"二十万零一十" ],
    [ 2000105,"二百万零一百零五" ],
    [ 20001007,"二千万一千零七" ],
    [ 2000100190,"二十亿零一十万零一百九十" ],
    [ 1040010000,"一十亿四千零一万" ],
    [ 200012301,"二亿零一万二千三百零一" ],
    [ 2005010010,"二十亿零五百零一万零一十" ],
    [ 4009060200,"四十亿零九百零六万零二百" ],
    [ 4294967295,"四十二亿九千四百九十六万七千二百九十五" ]

]

//  测试用例
function  testChineseToNumber()
{
    for(let i = 0; i < testPair.length; i++)
    {
        let  num = ChineseToNumber(testPair[i][1]);
        console.log(num == testPair[i][0]);
    }
}

testChineseToNumber();
// 控制台打印结果 ：39 true
```

#### 4.代码实现二

```js
function transform(str) {
    const numChar = {
        '零':0,
        '一':1,
        '二':2,
        '三':3,
        '四':4,
        '五':5,
        '六':6,
        '七':7,
        '八':8,
        '九':9
    };
    const levelChar = {
        '十':10,
        '百':100,
        '千':1000,
        '万':10000,
        '亿':100000000,
    };
    let ary = Array.from(str)
    let temp = 0
    let sum = 0
    for(let i = 0; i < ary.length; i++) {
        let char = ary[i]
        if(char === '零') continue
        if (char === '亿' || char === '万') {
            sum += temp * levelChar[char]
            temp = 0
        } else {
            let next = ary[i + 1]
            if(next && next !== '亿' && next !== '万') {
                temp += numChar[char] * levelChar[next]
                i++
            } else {
                temp += numChar[char]
            }
        }
    }
    return sum + temp
}

console.log(transform('一十二亿三千零九十六万三千八百九十七'))
```

### 310说一下对面向对象的理解，面向对象有什么好处

可以理解为在做一件事时是：“该让谁来做”。那个谁就是对象，他要怎么做是他自己的事，最后就是一群对象合力把事情做好。相比较于面向过程的“步骤化”分析问题，面向对象则是“功能化”分析问题，其优点体现在：

- 将数据和方法封装在一起，以接口的方式提供给调用者，调用者无需关注问题的解决过程；
- 对象之间通过继承，减少代码的冗余，提高程序的复用性；
- 通过重载/重写方法来拓展对象的功能；

以上的优点来源于面向对象的三大特征：封装、继承和多态。

### 3111000*1000 的画布，上面有飞机、子弹，如何划分区域能够更有效的做碰撞检测，类似划分区域大小与碰撞检测效率的算法，说一下大致的思路

**大致思路**

飞机按照图形中心展开一个坐标序列对应小方块，然后检测的是对应子弹在小方块的覆盖，小方块按照之前说的划分区域可以是`1*1 2*2`的,具体看想要的精度是多少

### 312请实现如下的函数
```js
/*
	可以批量请求数据，所有的 URL 地址在 urls 参数中，
        同时可以通过 max 参数控制请求的并发度，当所有请
        求结束之后，需要执行 callback 回调函数。发请求的
        函数可以直接使用 fetch 即可
*/
```

**1）思路**

1 fetch 请求介绍
2 并发，并发，某个完成后可以继续发请求
3 所有请求结束后 callback
4 注意容错（①参数错误，参数不正确、接口地址不正确、最大数不正确、回调函数不正确；②接口错误）
5 边界值
6 不能在 while 中使用 fetch，因为 while 是同步，它永远不会等待异步的 fetch 结果回来
7 使用 for 循环 + 递归的方法

**2）代码实现**

```js
/**
 *
 * @param { Array } urls  请求地址数组
 * @param { Number } max 最大并发请求数
 * @param { Function } callback  回调地址
 */
function parallelFetch(urls, max, callback) {
  // 如果当前环境不支持 fetch , 则提示程序无法正常运行
  if (!window.fetch || "function" !== typeof window.fetch) {
    throw Error("当前环境不支持 fetch 请求，程序终止");
  }

  // 如果参数有误，则提示输入正确的参数
  if (!urls || urls.length <= 0) {
    throw Error("urls is empty: 请传入正确的请求地址");
  }

  const _urlsLength = urls.length; // 请求地址数组的长度
  const _max = max || 1; // 保证最大并发值的有效性
  let _currentIndex = 0; // 当前请求地址的索引
  let _maxFetch = max <= _urlsLength ? max : _urlsLength; // 当前可以正常请求的数量，保证最大并发数的安全性
  let _finishedFetch = 0; // 当前完成请求的数量，用于判断何时调用回调
  
  console.log(`开始并发请求，接口总数为 ${_urlsLength} ，最大并发数为 ${_maxFetch}`);
  // 根据最大并发数进行循环发送，之后通过状态做递归请求
  for (let i = 0; i < _maxFetch; i++) {
    fetchFunc();
  }
  // 请求方法
  function fetchFunc() {
    // 如果所有请求数都完成，则执行回调方法
    if (_finishedFetch === _urlsLength) {
        console.log(`当前一共 ${_urlsLength} 个请求，已完成 ${_finishedFetch} 个`)
      if ("function" === typeof callback) return callback();
      return false;
    }
    // 如果当前请求的索引大于等于请求地址数组的长度，则不继续请求
    if (_currentIndex >= _urlsLength) {
      _maxFetch = 0;
    }

    //如果可请求的数量大于0，表示可以继续发起请求
    if (_maxFetch > 0) {
      console.log( `当前正发起第 ${_currentIndex + 1 } 次请求，当前一共 ${_urlsLength} 个请求，已完成 ${_finishedFetch} 个，请求地址为：${urls[_currentIndex]}`);
      // 发起 fetch 请求
      fetch(urls[_currentIndex])
        .then((res) => {
          // TODO 业务逻辑，正常的逻辑，异常的逻辑
          // 当前请求结束，正常请求的数量 +1
          _maxFetch += 1;
          _finishedFetch += 1;
          fetchFunc();
        })
        .catch((err) => {
          // TODO 异常处理，处理异常逻辑
          // 当前请求结束，正常请求的数量 +1
          _maxFetch += 1;
          _finishedFetch += 1;
          fetchFunc();
        });
      // 每次请求，当前请求地址的索引  +1
      _currentIndex += 1;
      // 每次请求，可以正常请求的数量 -1
      _maxFetch -= 1;
    }
  }
}

let urls = [];
for (let i = 0; i < 100; i++) {
  urls.push(`https://jsonplaceholder.typicode.com/todos/${i}`);
}
const max = 10;
const callback = () => {
  console.log("我请求完了");
};

parallelFetch(urls, max, callback);
```

### 313怎样判断一个对象是否是数组，如何处理类数组对象

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




### 314实现输出一个十六进制的随机颜色(#af0128a)

#### 代码实现

大体思路

- 生成随机数
- 从随机数中得到16进制的颜色值，颜色值长度是6位或者3位（要么取3位要么取6位）

**1）实现方式一**

- for循环遍历

```js
function getColor(){
    var colorElements = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f";
    var colorArray = colorElements.split(",");
    var color ="#";
    for(var i =0;i<6;i++){
        color+=colorArray[Math.floor(Math.random()*16)];
    }
    return color;
}
```

**2）实现方式二**

- while循环

```js
const getColor = () => {
    var hexNums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
    let i = 0;
    let color = '#';
    while (i < 6) {
        color += hexNums[parseInt(Math.random() * 16)];
        i++;
    }
    return color
}
```

**3）实现方式三**

 `padEnd()` 方法会用一个字符串填充当前字符串（如果需要的话则重复填充），返回填充后达到指定长度的字符串。从当前字符串的末尾（右侧）开始填充。

```js
function randomColor(){
	return '#'+Math.floor(Math.random() * 0xffffff).toString(16).padEnd(6, '0');
}
```

**4）实现方式四**

- substr方法

```js
const randomColor = () => color = '#' + Math.random().toString(16).substr(-6);
```

### 315手写代码实现`kuai-shou-front-end=>KuaiShouFrontEnd`

#### 代码实现

- **考点：** 对字符串的操作以及多种实现方法
- **思路：** 利用String和Array的属性和方法或正则来分割、替换、重组字符串，利用toUpperCase()或charCodeAt()+fromCharCode()实现大写转换

**1）实现方式一**

```js
// 第一种  map
function firstUp1(str) {
    return str.split("-").map(function (key) {
        return key[0].toUpperCase() + key.slice(1);
    }).join("");
}
console.log(firstUp1(string))
```

**2）实现方式二**

```js
// 第二种 正则
function firstUp2(str) {
    return str.replace(/-[a-z]/g, function (match) {
        return match.replace("-", "").toUpperCase()
    })
}
console.log(firstUp2(string))
```

**3）综合版**

```js
// 转化成大写
function myToUpperCase() {
    // 1.String自带方法
    return this.toUpperCase()

    // 2.toLocaleUpperCase一般情况下跟toUpperCase返回的结果一样
    // return this.toLocaleUpperCase()

    // 3.根据ASCII之间的规律用charCodeAt()+fromCharCode()来转换大小写
    // if (!/[a-z]/.test(this)) return this
    // return String.fromCharCode(this.charCodeAt() - 32)
}

String.prototype.myToUpperCase = myToUpperCase

// 分割、替换、重组字符串
function transform(str, separator) {
    // 1.常规String和Array的api
    return str
        .split(separator)
        .map(word => word.charAt(0).myToUpperCase() + word.slice(1))
        .join("")

    // 2.常规String和Array的api
    // return str.split(separator).reduce((pre, word) => {
    //     return pre + word.substr(0, 1).myToUpperCase() + word.substring(1)
    // }, "")

    // 3.使用正则
    // return (separator + str)
    //     .replace(new RegExp(separator+'(.)', "g"), (_,c) => c.myToUpperCase())
}
console.log(transform("kuai-shou-front-end", "-"))
```



### 316如何实现按需加载

#### 什么是按需加载

和异步加载script的目的一样(异步加载script的方法),按需加载/代码切割也可以解决首屏加载的速度。

**设么时候需要按需加载**

如果是大文件,使用按需加载就十分合适。比如一个近1M的全国城市省市县的json文件,在我首屏加载的时候并不需要引入,而是当用户点击选项的时候才加载。如果不点击,则不会加载。就可以缩短首屏http请求的数量以及时间。

如果是小文件,可以不必太在意按需加载。过多的http请求会导致性能问题。

#### 实现按需加载的方法

**1）ES2020 动态导入**

```js
import('./dynamic-module').then((module) => {
    // do something
})
// 也支持await关键字
const module = await import('./dynamic-module')
```

**2）vue 中通过 router 配置**

vue 中通过 router 配置, 实现组件的按需加载, 在一些单个组件文件较大的时候, 采用按需加载能够减少build.js的体积, 优化加载速度(如果组件的体积较小, 那么采用按需加载会增加额外的http请求, 反倒增加了加载时间)

```js
//app.js

import Vue from 'vue'
import App from './App.vue'
import VueRouter from 'vue-router'
Vue.use(VueRouter)

//AMD规范的异步载入
const ComA = resolve => require(['./components/A.vue' ], resolve);
const ComB = resolve => require(['./components/B.vue' ], resolve);
const ComC = resolve => require(['./components/C.vue' ], resolve);

//CMD风格的异步加载
const ComA = resolve => require.ensure([], () => resolve(require('./components/A.vue')));
const ComB = resolve => require.ensure([], () => resolve(require('./components/B.vue')));
const ComC = resolve => require.ensure([], () => resolve(require('./components/C.vue')));

const router = new VueRouter({
  routes: [
    {
      name: 'component-A',
      path: '/a',
      component: ComA
    },
    {
      name: 'component-B',
      path: '/b',
      component: ComB
    },
    {
      name: 'component-C',
      path: '/c',
      component: ComC
    }
  ]
})

new Vue({
  el: '#app',
  router: router,
  render: h => h(App)
})
```

vue-cli配置或webpack配置

```js
//webpack.config.js
output: {
    path: path.resolve(__dirname, './dist'),
    publicPath: '/dist/',
    filename: 'build.js',
    //添加chundkFilename
    chunkFilename: '[name].[chunkhash:5].chunk.js'
}
```

**3）Webpack打包模块工具实现**

在大型项目中, build.js可能过大, 导致页面加载时间过长。这个时候就需要code splitting, code splitting就是将文件分割成块(chunk), 我们可以定义一些分割点(split point), 根据这些分割点对文件进行分块, 并实现按需加载.





### 317类设计：使用面相对象设计一个停车场管理系统
```js
/*
 *题目要求
 *使用面相对象设计一个停车场管理系统，该停车场包含：
 *	1.停车位，用于停放车辆；
 *	2.停车位提示牌，用于展示剩余停车位；
 *可以丰富该系统的元素，给出类，类属性，类接口。
 */
```

#### uml图

![uml图示](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-109-uml.png)

#### 代码实现

```js
// 停车场类
class ParkingLot{
    constructor(n) {
        // 停车位
        this.parkSites = []
        // 剩余停车位个数
        this.leftSites = n
        this.board = new DisplayBoard()
        // 初始化停车位
        for (let i = 1; i <= n; i++) {
            this.parkSites.push(new ParkingSpace(i))
        }
        console.log('停车场初始化完毕')
        this.showLeftSites()
    }

    // 进停车场停车
    inPark(car) {
        if (this.leftSites === 0) {
            console.log('停车位已满')
            return
        }
        if (car.site) {
            console.log(car.carId + '车辆已经在停车场了')
            return
        }
        let len = this.parkSites.length
        for (let i = 0; i < len; i++) {
            const site = this.parkSites[i]
            // 如果停车位是空的
            if(site.car === null) {
                site.car = car
                car.site = site
                this.leftSites--
                console.log(car.carId + '车辆停入' + site.id + '号停车位')
                this.showLeftSites()
                return
            }
        }
    }

    // 出停车场
    outPark (car) {
        if (car.site === null) {
            console.log(car.carId + '本来就没在停车场')
            return;
        }
        let len = this.parkSites.length
        for (let i = 0; i < len; i++) {
            const site = this.parkSites[i]
            // 如果停车位是空的
            if(site.car.carId === car.carId) {
                site.car = null
                car.site = null
                this.leftSites++
                console.log(car.carId + '车辆已从' + site.id + '号停车位，出停车场')
                this.showLeftSites()
                return
            }
        }
    }

    // 显示剩余的停车位数量
    showLeftSites() {
        this.board.showLeftSapce(this.leftSites)
    }

}


// 停车位
class ParkingSpace {
    constructor(id) {
        // 停车位编号
        this.id = id
        // 停入的车辆
        this.car = null
    }
}

// 车 类
class Car{
    constructor(carId) {
        // 车牌号
        this.carId = carId
        // 停入的车位
        this.site = null
    }
    // 进入停车场
    inPark (park) {
        park.inPark(this)
    }
    outPark(park) {
        park.outPark(this)
    }
}

// 展示牌类
class DisplayBoard {
    constructor() {
    }
    // 展示剩余停车位
    showLeftSapce(n) {
        console.log (`当前剩余${n}个停车位` )
    }
}


const park = new ParkingLot(3)

const car1 = new Car('京A1XXX')
const car2 = new Car('京A2XXX')
const car3 = new Car('京A3XXX')
const car4 = new Car('京A4XXX')
car1.inPark(park)
car1.inPark(park)
car1.outPark(park)
car1.outPark(park)
car1.inPark(park)

car2.inPark(park)
car3.inPark(park)
car4.inPark(park)

car2.outPark(park)
car4.inPark(park)

console.log(park.parkSites)
```

### 318说一说 promise，有几个状态，通过 catch 捕获到 reject 之后，在 catch 后面还能继续执行 then 方法嘛，如果能执行执行的是第几个回调函数

#### Promise

Promise 对象是 JavaScript 的异步操作解决方案，为异步操作提供统一接口。它起到代理作用（proxy），充当异步操作与回调函数之间的中介，使得异步操作具备同步操作的接口。Promise 可以让异步操作写起来，就像在写同步操作的流程，而不必一层层地嵌套回调函数。


#### Promise对象状态

Promise 对象通过自身的状态，来控制异步操作。Promise 实例具有三种状态。

- 异步操作未完成（pending）
- 异步操作成功（fulfilled）
- 异步操作失败（rejected）

上面三种状态里面，fulfilled和rejected合在一起称为resolved（已定型）。

这三种的状态的变化途径只有两种。

- 从“未完成”到“成功”
- 从“未完成”到“失败”

一旦状态发生变化，就凝固了，不会再有新的状态变化。这也是 Promise 这个名字的由来，它的英语意思是“承诺”，一旦承诺成效，就不得再改变了。这也意味着，Promise 实例的状态变化只可能发生一次。

因此，Promise 的最终结果只有两种：

- 异步操作成功，Promise 实例传回一个值（value），状态变为fulfilled
- 异步操作失败，Promise 实例抛出一个错误（error），状态变为rejected

#### 错误捕获

通过catch捕获到reject之后，在catch后面还可以继续顺序执行then方法，但是只执行then的第一个回调(resolve回调)

```js
Promise.reject(2)
    .catch(r => {
        // 捕获到错误，执行
        console.log('catch1');
    })
    // 错误已经被捕获，后边的`then`都顺序执行，且只执行`then`的第一个回调（resolve的回调）
    .then(v => {
        console.log('then1');
    }, r => {
        console.log('catch2');
    })
    .catch(r => {
        // 前边没有未捕获的错误，不执行
        console.log('catch3');
    })
    .then(v => {
        console.log('then2');
    }, r => {
        console.log('catch4');
    });
```
结果会打印：catch1、then1、then2

### 319iPhone 里面 Safari 上如果一个输入框 fixed 绝对定位在底部，当软键盘弹出的时候会有什么问题，如何解决

#### ios下fixed失效问题

**原因**

软键盘唤起后，页面的 fixed 元素将失效（ios认为用户更希望的是元素随着滚动而移动，也就是变成了 absolute 定位），既然变成了absolute，所以当页面超过一屏且滚动时，失效的 fixed 元素就会跟随滚动了。

不仅限于 type=text 的输入框，凡是软键盘（比如时间日期选择、select 选择等等）被唤起，都会遇到同样地问题。

**解决**

1）既然会变成absolute，索性直接使用absolute

bottom直接以body作为父元素来进行绝对定位，不过这种网上都不推荐，想来有更多的问题等待修正，前人的经验还是要借鉴的。

2）不让页面滚动，而是让主体部分自己滚动

如果fixed的失效，但是页面并没有超过一屏的长度，那么无论absolut或者fixed也没什么差别。顺着这个思路，完全可以让main直接滚着玩就行了。将吸底的元素和主题作为两大容器，主体部分，设置绝对定位，固定在屏幕中间，超出部分就自行滚动，吸底元素就可以自己玩了

```html
<body>
    <div class='warper'>
        <div class='top'></div>
        <div class='main'></div>
    <div>
    <div class="fix-bottom"></div>
</body>
```

```css
.cont-warper{
    position: absolute;
    width: 100%;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    overflow-y: scroll;
    /* 解决ios滑动不流畅问题 */
    -webkit-overflow-scrolling: touch;
}

.fix-bottom{
  position:fixed;
  bottom:0;
  width: 100%;
}
```

这样就能避免上面那个问题了。但是ios下，对于吸底元素而言在屏幕下半部分唤起键盘的时候，会被遮住部分东西，

对于这种情况，我们只好加个监听事件，当唤起键盘的时候，设置scrollTop值

```js
/**
 * 唤起键盘，滚动
 */
scrollContent() {
    this.interval = setInterval(() => {
        this.scrollToEnd();
    }, 500)
}
scrollToEnd() {
    document.body.scrollTop = document.body.scrollHeight;
}
clearSrcoll() {
    clearInterval(this.interval);
}
```

#### 微信打开网页键盘弹起后页面上滑，导致弹框里的按钮响应区域错位

和上边为题类似，处理方式也是设置scrollTop

**问题**

键盘弹起页面上滑，键盘收起页面不会回到原位置，导致弹框(css设置position为fixed会有问题，absolute不会有问题)后按钮响应区域错位。

**解决**

```js
//滚动到顶部
window.scrollTo(0, 0);
//滚动到底部
window.scrollTo(0, document.documentElement.clientHeight);
```

```js
//解决键盘弹出bug
// 判断是否是ios
if(_.isIOS()){
window.addEventListener('focusout', function(){
    //软键盘收起的事件处理
    setTimeout(()=>{
        window.scrollTo(0 ,document.documentElement.scrollTop || document.body.scrollTop);
    })
  });
}
```



### 320讲一下 import 的原理，与 require 有什么不同

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

### 321setTimeout 有什么缺点，和 requestAnimationFrame 有什么区别

#### 1.setTimeout

setTimeout 有一个显著的缺陷在于时间是不精确的，setTimeout 只能保证延时或间隔不小于设定的时间。因为它们实际上只是把任务添加到了任务队列中，但是如果前面的任务还没有执行完成，它们必须要等待。

#### 2.requestAnimationFrame

requestAnimationFrame 是系统时间间隔，保持最佳绘制效率，不会因为间隔时间过短，造成过度绘制，增加开销，从而节省系统资源，提高系统性能，改善视觉效果。

requestAnimationFrame 和 setTimeout/setInterval 在编写动画时相比，优点如下:

1. requestAnimationFrame 不需要设置时间，采用系统时间间隔，能达到最佳的动画效果。
2. requestAnimationFrame 会把每一帧中的所有DOM操作集中起来，在一次重绘或回流中就完成。
3. 当 `requestAnimationFrame()` 运行在后台标签页或者隐藏的 `<iframe>` 里时，`requestAnimationFrame()` 会被暂停调用以提升性能和电池寿命（大多数浏览器中）。

```js
function step(timestamp) {
    window.requestAnimationFrame(step);
}
window.requestAnimationFrame(step);
```

### 322移动设备安卓与 iOS 的软键盘弹出的处理方式有什么不同

### 软键盘在Android和IOS苹果上面的表现

#### IOS 软键盘弹起表现

在 IOS 上，输入框（input、textarea 或 富文本）获取焦点，键盘弹起，页面（webview）并没有被压缩，或者说高度（height）没有改变，只是页面（webview）整体往上滚了，且最大滚动高度（scrollTop）为软键盘高度。

#### Android 软键盘弹起表现

在 Android 上，输入框获取焦点，键盘弹起，但是页面（webview）高度会发生改变，一般来说，高度为可视区高度（原高度减去软键盘高度），除了因为页面内容被撑开可以产生滚动，webview 本身不能滚动。

#### IOS 软键盘收起表现

触发软键盘上的“收起”按钮键盘或者输入框以外的页面区域时，输入框失去焦点，软键盘收起。

#### Android 软键盘收起表现

触发软键盘上的“收起”按钮键盘或者输入框以外的页面区域时，输入框失去焦点，软键盘收起。

### 解决两端弹出和收起表现不一致方案

- 在 IOS 上，监听输入框的 focus 事件来获知软键盘弹起，监听输入框的 blur 事件获知软键盘收起。
- 在 Android 上，监听 webview 高度会变化，高度变小获知软键盘弹起，否则软键盘收起。

```js
// 判断设备类型
var judgeDeviceType = function () {
  var ua = window.navigator.userAgent.toLocaleLowerCase();
  var isIOS = /iphone|ipad|ipod/.test(ua);
  var isAndroid = /android/.test(ua);

  return {
    isIOS: isIOS,
    isAndroid: isAndroid
  }
}()

// 监听输入框的软键盘弹起和收起事件
function listenKeybord($input) {
  if (judgeDeviceType.isIOS) {
    // IOS 键盘弹起：IOS 和 Android 输入框获取焦点键盘弹起
    $input.addEventListener('focus', function () {
      console.log('IOS 键盘弹起啦！');
      // IOS 键盘弹起后操作
    }, false)

    // IOS 键盘收起：IOS 点击输入框以外区域或点击收起按钮，输入框都会失去焦点，键盘会收起，
    $input.addEventListener('blur', () => {
      console.log('IOS 键盘收起啦！');
      // IOS 键盘收起后操作
    })
  }

  // Andriod 键盘收起：Andriod 键盘弹起或收起页面高度会发生变化，以此为依据获知键盘收起
  if (judgeDeviceType.isAndroid) {
    var originHeight = document.documentElement.clientHeight || document.body.clientHeight;

    window.addEventListener('resize', function () {
      var resizeHeight = document.documentElement.clientHeight || document.body.clientHeight;
      if (originHeight < resizeHeight) {
        console.log('Android 键盘收起啦！');
        // Android 键盘收起后操作
      } else {
        console.log('Android 键盘弹起啦！');
        // Android 键盘弹起后操作
      }

      originHeight = resizeHeight;
    }, false)
  }
}

var $inputs = document.querySelectorAll('.input');

for (var i = 0; i < $inputs.length; i++) {
  listenKeybord($inputs[i]);
}
```

### 323文件上传如何做断点续传

### 答案

断点续传的原理在于前端/服务端需要记住已上传的切片，这样下次上传就可以跳过之前已上传的部分，有两种方案实现记忆的功能

1. 前端使用 localStorage 记录已上传的切片 hash
2. 服务端保存已上传的切片 hash，前端每次上传前向服务端获取已上传的切片

第一种是前端的解决方案，第二种是服务端，而前端方案有一个缺陷，如果换了个浏览器就失去了记忆的效果。

![大文件上传](http://img-static.yidengxuetang.com/wxapp/issue-img/fileupload.png)

#### 一、前端

**1）.前端框架使用Vue+Element UI**

```js
import Vue from 'vue'
import App from './App.vue'
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

Vue.use(ElementUI);

Vue.config.productionTip = false
new Vue({
  render: h => h(App)
}).$mount('#app')

```

**2）.上传组件**

1. 上传、恢复、暂停暂停按钮
2. hash计算进度
3. 上传文件总进度

```js
<template>
  <div id="app">
    <div>
      <input
        type="file"
        :disabled="status !== Status.wait"
        @change="handleFileChange"
      />
      <el-button @click="handleUpload" :disabled="uploadDisabled"
        >上传</el-button
      >
      <el-button @click="handleResume" v-if="status === Status.pause"
        >恢复</el-button
      >
      <el-button
        v-else
        :disabled="status !== Status.uploading || !container.hash"
        @click="handlePause"
        >暂停</el-button
      >
    </div>
    <div>
      <div>计算文件 hash</div>
      <el-progress :percentage="hashPercentage"></el-progress>
      <div>总进度</div>
      <el-progress :percentage="fakeUploadPercentage"></el-progress>
    </div>
    <el-table :data="data">
      <el-table-column
        prop="hash"
        label="切片hash"
        align="center"
      ></el-table-column>
      <el-table-column label="大小(KB)" align="center" width="120">
        <template v-slot="{ row }">
          {{ row.size | transformByte }}
        </template>
      </el-table-column>
      <el-table-column label="进度" align="center">
        <template v-slot="{ row }">
          <el-progress
            :percentage="row.percentage"
            color="#909399"
          ></el-progress>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>
```

**3）文件上传和断点续传逻辑**

1. 核心是`Blob.prototype.slice` 方法，将源文件切成多个切片
2. 根据切片内容生成hash，此处用到的是spark-md5.js，因为解析切片内容比较耗时，所以开辟了WebWorker线程来处理hash的生成，在处理切片hash的时候，还与主线程进行通信返回进度。
3. 向服务器发请求，检验文件切片是否上传,返回是否需要继续上传和已上传列表（断点续传核心）。
4. 利用http 的可并发性，同时上传多个切片，减少上传时间
5. 切片上传完成，给服务器发送合并切片请求

- 常量和基础属性

```js

 //单个切片大小
const SIZE = 10*1024*1024;//10MB
//状态常量
const Status = {
  wait: "wait",
  pause: "pause",
  uploading: "uploading"
};
export default {
   name: "App",
   filters: {
    transformByte(val) {
      return Number((val / 1024).toFixed(0));
    }
  },
    data() {
    return {
      Status,
      container: { //保存文件信息
        file: null,
        hash: "",//所有切片hash
        worker: null
      },
      hashPercentage:0,//hash进度百分比
      data: [],//保存所有切片信息
      requestList: [],//请求列表
      status: Status.wait,//状态，默认为等待
      fakeUploadPercentage: 0//文件上传总进度
    };
  },
}

```

- 计算属性、watch

```js
computed: {
  //上传按钮不可用
    uploadDisabled() {
      return (
        !this.container.file ||
        [Status.pause, Status.uploading].includes(this.status)
      );
    },
      //下载进度百分比
    uploadPercentage() {
      if (!this.container.file || !this.data.length) return 0;
      const loaded = this.data
        .map(item => item.size * item.percentage)
        .reduce((acc, cur) => acc + cur);
      return parseInt((loaded / this.container.file.size).toFixed(2));
    }
  },
  watch: {
    //下载进度百分比
    uploadPercentage(now) {
      if (now > this.fakeUploadPercentage) {
        this.fakeUploadPercentage = now;
      }
    }
  },
```

- methods：三个按钮上面的方法定义

```js
methods: {
  //中止处理函数
    handlePause() {
      this.status = Status.pause;
      this.resetData();
    },
    resetData() {
      //中止请求列表中的所有请求
      this.requestList.forEach(xhr => {
        if (xhr) {
          xhr.abort();
        }
      });
      this.requestList = [];
      if (this.container.worker) {
        this.container.worker.onmessage = null;
      }
    },
     //恢复处理函数
    async handleResume() {
      this.status = Status.uploading;
      //获取已经上传的文件名和hash
      const { uploadedList } = await this.verifyUpload(
        this.container.file.name,
        this.container.hash
      );
      await this.uploadChunks(unloadedList);
    },
    //file input change事件触发
    handleFileChange(e){
      const [file] = e.target.files;
      if(!file) return;
      this.resetData();
      Object.assign(this.$data,this.$options.data());
      this.container.file = file;
    }
}
```

- 核心：文件上传逻辑  **切片=>hash=>校验=>批量上传**

```js
async handleUpload(){
      if(!this.container.file) return;
      this.status = Status.uploading;
      //生成文件切片
      const fileChunkList = this.createFileChunk(this.container.file);
      //根据切片列表计算切片hash
      this.container.hash = await this.calculateHash(fileChunkList);
      //检验文件切片是否上传,返回是否需要上传和已上传列表
      const { shouldUpload,uploadedList } = await this.verifyUpload(
        this.container.file.name,
        this.container.hash
      );
      //没有需要上传的文件切片
      if(!shouldUpload){
        this.$message.sucess('秒传：上传成功');
        this.status = Status.wait;
        return;
      }
      //根据文件列表生成每个切片的信息对象
      this.data = fileChunkList.map(({file},index)=>({
        fileHash : this.container.hash,
        index,
        hash: this.container.hash + '-'+index,
        chunk:file,
        size:file.size,
        percentage:uploadedList.includes(index)?100:0
      }));
      //上传文件切片
      await this.uploadChunks(uploadedList);
    },
```

- 文件核心逻辑实现：生成文件切片：file.slice()

```js
// 生成文件切片 file.slice
createFileChunk(file, size = SIZE) {
  const fileChunkList = [];
  let cur = 0;
  while (cur < file.size) {
    fileChunkList.push({ file: file.slice(cur, cur + size) });
    cur += size;
  }
  return fileChunkList;
},
```

- 生成文件切片hash: webworker

```js
// 生成文件 hash（web-worker）
calculateHash(fileChunkList) {
  return new Promise(resolve => {
    this.container.worker = new Worker("/hash.js");
    //与worker通信
    this.container.worker.postMessage({ fileChunkList });
    this.container.worker.onmessage = e => {
      const { percentage, hash } = e.data;
      this.hashPercentage = percentage;
      //返回总文件生成hash进度的百分比，如果切片hash全部生成，返回所有切片hash组成的对象
      if (hash) {
        resolve(hash);
      }
    };
  });
},
```

- hash.js：边计算边与主线程进行通信，返回hash计算进度

```js
self.importScripts("/spark-md5.min.js"); // 导入脚本

// 生成文件 hash
self.onmessage = e => {
  const { fileChunkList } = e.data;
  const spark = new self.SparkMD5.ArrayBuffer();
  let percentage = 0;
  let count = 0;
  const loadNext = index => {
    const reader = new FileReader();//异步读取文件，在webworker中使用
    reader.readAsArrayBuffer(fileChunkList[index].file);//读取文件完成后，属性result保存着二进制数据对象
    //文件读取完成后触发
    reader.onload = e => {
      //递归计数器
      count++;
      spark.append(e.target.result);//append ArrayBuffer数据
      if (count === fileChunkList.length) {
        self.postMessage({
          percentage: 100,
          hash: spark.end()//完成hash
        });
        self.close();//关闭 Worker 线程。
      } else {
        percentage += 100 / fileChunkList.length;
        self.postMessage({
          percentage
        });
        loadNext(count);//递归继续
      }
    };
  };
  loadNext(0);
};
```

- 断点续传核心：**文件切片完成之后，向服务器发请求检验文件切片是否已经上传**

```js
 async verifyUpload(filename,fileHash){
      const { data } = await this.request({
        url:'http://localhost:3000/verify',//验证接口
        headers:{
          'content-type':'application/json'
        },
        data:JSON.stringify({
          filename,
          fileHash
        })
      })
      //返回数据
      return JSON.parse(data);
    },
```

- 上传文件切片：**过滤已经上传的文件+Promise.all并发请求**

```js
//上传文件切片，同时过滤已经上传的切片
    async uploadChunks(uploadedList = []){
      const requestList = this.data
        .filter(({hash})=>!uploadedList.includes(hash)) //过滤已经上传的chunks
        .map(({chunk,hash,index})=>{
          const formData = new FormData();
          formData.append('chunk',chunk);
          formData.append('hash',hash);
          formData.append("filename", this.container.file.name);
          formData.append("fileHash", this.container.hash);
          return { formData,index }
        })//创建表单数据
        .map(async ({formData,index})=>
          this.request({
            url:'http://localhost:3000',
            data:formData,
            onProgress : this.createProgressHandler(this.data[index]),
            requestList:this.requestList//将xhr push到请求列表
          })
        )//创建请求列表
        //并发上传
        await Promise.all(requestList);
        //已经上传切片数量+本次上传切片数量==所有切片数量时 
        //切片上传完成，给服务器发送合并切片请求
        if(uploadedList.length + requestList.length === this.data.length){
          await this.mergeRequest();
        } 
    }
```

- 合并切片：服务端发送请求

```js
// 通知服务端合并切片
    async mergeRequest() {
      await this.request({
        url: "http://localhost:3000/merge",
        headers: {
          "content-type": "application/json"
        },
        data: JSON.stringify({
          size: SIZE,
          fileHash: this.container.hash,
          filename: this.container.file.name
        })
      });
      this.$message.success("上传成功");
      this.status = Status.wait;
    },
```

- **用原生xhr进行封装http请求**

```js
// xhr
    request({
      url,
      method = "post",
      data,
      headers = {},
      onProgress = e => e,
      requestList
    }) {
      return new Promise(resolve => {
        const xhr = new XMLHttpRequest();
        xhr.upload.onprogress = onProgress;
        xhr.open(method, url);
        Object.keys(headers).forEach(key =>
          xhr.setRequestHeader(key, headers[key])
        );
        xhr.send(data);
        xhr.onload = e => {
          // 将请求成功的 xhr 从列表中删除
          if (requestList) {
            const xhrIndex = requestList.findIndex(item => item === xhr);
            requestList.splice(xhrIndex, 1);
          }
          resolve({
            data: e.target.response
          });
        };
        // 暴露当前 xhr 给外部
        requestList?.push(xhr);
      });
    }
```

#### 二、服务端

**1）开启服务：未使用node框架，原生利用http模块**

```js
const Controller = require("./controller");
const http = require("http");
const server = http.createServer();

const controller = new Controller();

server.on("request", async (req, res) => {
  //设置响应头，允许跨域
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Headers", "*");
  if (req.method === "OPTIONS") {
    res.status = 200;
    res.end();
    return;
  }
  //切片验证
  if (req.url === "/verify") {
    console.log(req);
    await controller.handleVerifyUpload(req, res);
    return;
  }
//切片合并
  if (req.url === "/merge") {
    await controller.handleMerge(req, res);
    return;
  }
//切片提交
  if (req.url === "/") {
    await controller.handleFormData(req, res);
  }
});

server.listen(3000, () => console.log("正在监听 3000 端口"));
```

**2）controller.js**

合并切片的方式：**使用stream pipe方式，节省内存，边读边写入，占用内存更小，效率更高**

```js
const multiparty = require("multiparty");//解析文件上传
const path = require("path");
const fse = require("fs-extra");//fs模块拓展

const extractExt = filename =>
filename&&filename.slice(filename.lastIndexOf("."), filename.length); // 提取后缀名
const UPLOAD_DIR = path.resolve(__dirname, "..", "target"); // 大文件存储目录

//使用stream pipe方式，合并切片
const pipeStream = (path, writeStream) =>
  new Promise(resolve => {
    const readStream = fse.createReadStream(path);
    readStream.on("end", () => {
      fse.unlinkSync(path);
      resolve();
    });
    readStream.pipe(writeStream);
  });

// 合并切片
const mergeFileChunk = async (filePath, fileHash, size) => {
  const chunkDir = path.resolve(UPLOAD_DIR, fileHash);
  const chunkPaths = await fse.readdir(chunkDir);
  // 根据切片下标进行排序
  // 否则直接读取目录的获得的顺序可能会错乱
  chunkPaths.sort((a, b) => a.split("-")[1] - b.split("-")[1]);
  await Promise.all(
    chunkPaths.map((chunkPath, index) =>
      pipeStream(
        path.resolve(chunkDir, chunkPath),
        // 指定位置创建可写流
        fse.createWriteStream(filePath, {
          start: index * size,
          end: (index + 1) * size
        })
      )
    )
  );
  fse.rmdirSync(chunkDir); // 合并后删除保存切片的目录
};

const resolvePost = req =>
  new Promise(resolve => {
    let chunk = "";
    req.on("data", data => {
      chunk += data;
    });
    req.on("end", () => {
      resolve(JSON.parse(chunk));
    });
  });

// 返回已经上传切片名
const createUploadedList = async fileHash =>
  fse.existsSync(path.resolve(UPLOAD_DIR, fileHash))
    ? await fse.readdir(path.resolve(UPLOAD_DIR, fileHash))
    : [];

module.exports = class {
  // 合并切片
  async handleMerge(req, res) {
    const data = await resolvePost(req);
    const { fileHash, filename, size } = data;
    const ext = extractExt(filename);
    const filePath = path.resolve(UPLOAD_DIR, `${fileHash}${ext}`);
    await mergeFileChunk(filePath, fileHash, size);
    res.end(
      JSON.stringify({
        code: 0,
        message: "file merged success"
      })
    );
  }
  // 处理切片
  async handleFormData(req, res) {
    const multipart = new multiparty.Form();
    multipart.parse(req, async (err, fields, files) => {
      if (err) {
        console.error(err);
        res.status = 500;
        res.end("process file chunk failed");
        return;
      }
      const [chunk] = files.chunk;
      const [hash] = fields.hash;
      const [fileHash] = fields.fileHash;
      const [filename] = fields.filename;
      const filePath = path.resolve(
        UPLOAD_DIR,
        `${fileHash}${extractExt(filename)}`
      );
      const chunkDir = path.resolve(UPLOAD_DIR, fileHash);

      // 文件存在直接返回
      if (fse.existsSync(filePath)) {
        res.end("file exist");
        return;
      }

      // 切片目录不存在，创建切片目录
      if (!fse.existsSync(chunkDir)) {
        await fse.mkdirs(chunkDir);
      }
      await fse.move(chunk.path, path.resolve(chunkDir, hash));
      res.end("received file chunk");
    });
  }
  // 验证是否已上传/返回已上传切片下标
  async handleVerifyUpload(req, res) {
    const data = await resolvePost(req);
    console.log(data);
    const { fileHash, filename } = data;
    const ext = extractExt(filename);
    const filePath = path.resolve(UPLOAD_DIR, `${fileHash}${ext}`);
    if (fse.existsSync(filePath)) {
      res.end(
        JSON.stringify({
          shouldUpload: false
        })
      );
    } else {
      res.end(
        JSON.stringify({
          shouldUpload: true,
          uploadedList: await createUploadedList(fileHash)
        })
      );
    }
  }
};
```


### 324实现一个方法判断 html 中的标签是否闭合

### 答案

```js
function checkHtml (data) {
  let tag = ['a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base', 'bdi', 'bdo', 'blockquote', 'body', 'button', 'canvas', 'caption', 'cite', 'code', 'col', 'colgroup', 'datalist', 'dd', 'del', 'dfn', 'dialog', 'div', 'dl', 'dt', 'em', 'fieldset', 'figcaption', 'figure', 'footer', 'form', 'frame', 'head', 'header', 'hgroup', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'i', 'iframe', 'ins', 'label', 'legend', 'li', 'map', 'mark', 'menu', 'meter', 'nav', 'noscript', 'object', 'ol', 'outgroup', 'option', 'output', 'p', 'pre', 'html', 'progress', 'q', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'section', 'select', 'small', 'span', 'strike', 'strong', 'style', 'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'time', 'title', 'tr', 'u', 'ul', 'var', 'video', 'wbr']
  //清除标签中内容、换行符
  data = data.replace(/.*?(<.*>).*/g, '$1').replace(/[\r\n]/g, '').replace(/\s+.*?>/g, '>')
  //排除无内容元素
  data = data.replace(/<(img|br|hr|input|link|meta|area|base|col|command|embed|keygen|param|source|track|wbr).*?>/g, '')
  //清除非标签元素，替换标签为()的形式，例如：<div>替换为(、</div>替换为)
  data = data.replace(/>.*?</g, '><').replace(/<[^\/].*?>/g, '(').replace(/<\/.*?[^<]>/g, ')')
  //判断()是否为偶数
  if (data.length % 2 != 0) {
    return false
  }
  //循环删除()直至没有()或者为空
  while (data.length) {
    let temp = data
    let i = 0
    while (i < tag.length) {
      let key = '<' + tag[i] + '></' + tag[i] + '>'
      data = data.replace(new RegExp(key, 'g'), '')
      i++
    }
    if (data == temp) {
      return false
    }
  }
  return true
}

checkHtml("<div></div>") // true
checkHtml("<div>") // false
checkHtml("<br>") // true
checkHtml("</img>") // false
checkHtml("<img/>") // true
checkHtml("<img>") // true
```


### 325箭头函数和普通函数的区别

### 答案

1. 箭头函数没有自己的 this,只能通过作用域链来向上查找离自己最近的那个函数的 this
2. 箭头函数不能作为 constructor，因此不能通过 new 来调用，所以他并没有`new.target`这个属性
3. 箭头函数没有 argument 属性 ,可以通过 rest 可以获取
4. 箭头函数不能直接使用 call 和 apply，bind 来改变 this
5. 箭头函数不能使用 yield,不能用来做为 generator 函数
6. 箭头函数语法比普通函数更加简洁

> ES6 为 new 命令引入了一个 new.target 属性，该属性一般用在构造函数之中，返回 new 命令作用于的那个构造函数。如果构造函数不是通过 new 命令或 Reflect.construct()调用的，new.target 会返回 undefined，因此这个属性可以用来确定构造函数是怎么调用的）。包括 super 也不存在以及原型 prototype=>因为在执行 new 的时候需要将函数的原型赋值给实例对象的原型属性。


### 326手写实现 Array.flat()

### 答案

**1）方式一**

```js
function flatten(arr){
 const stack = [...arr];
 const res = [];
 while (stack.length) {
  const next = stack.pop();
  if(Array.isArray(next)){
   stack.push(...next);
  }else{
   res.push(next);
  }
 }
 return res.reverse();
}
```

**2）方式二**

```js
//flatten(arr,[depth]),depth指定展开嵌套数组的深度,默认为1
function flatten(arr, depth = 1){
 if(depth > 0){
  return arr.reduce((acc, val) => acc.concat(Array.isArray(val) ? flattenArray(val, depth - 1) : val), []);
 } else {
  return arr.slice();
 }
}
```

**3）方式三**

```js
// 未排除null项
var arr = [1, 2, [3, 4, 5, [6, 7, 8, [9, , 0]]]]
Array.prototype.flat = function (deep = 1) {
    const source = this
    return deep > 0 ?
        source.reduce(
            (res, val) => val === null ? "" : res.concat(
                Array.isArray(val) ? val.flat(deep - 1) : val)
            , [])
        : source.slice();

}
console.log(arr.flat(3))
```

**4）方式四**

```js
// 使用forEach 自动过滤空项
var arr = [1, 2, [3, 4, 5, [6, 7, 8, [9, , 0]]]]
Array.prototype.flat = function (deep = 1) {
    let result = []
    function ergodic(array, deep) {
        array.forEach(element => {
            Array.isArray(element) && deep > 0 ? ergodic(element, deep - 1) : result.push(element)
        });
    }
    ergodic(this, deep)
    return result
}
console.log(arr.flat(3))
```


### 327什么是深拷贝，和浅拷贝有什么区别，动手实现一个深拷贝

### 答案

#### 1.浅拷贝

对于字符串类型，浅拷贝是对值的复制，对于对象来说，浅拷贝是对对象地址的复制, 举个例子，A,B两个对象，A=B，改变A的属性，B也相对会发生改变。因为A,B指向同一个地址。

#### 2.深拷贝

深拷贝开辟一个新的栈，两个对象对应两个不同的地址，修改一个对象的属性，不会改变另一个对象的属性

#### 3.代码实现深拷贝

**1）方式一-JSON.parse(JSON.stringfy(source))**

利用现代浏览器支持的JSON对象做一次中转，实现深度克隆

优点：简单便捷

缺点：

- undefined、函数、symble值，在序列化过程中会被忽略
- 不能处理 BigInt 类型的数据和循环引用，会报错
- Map, Set, RegExp 类型的数据，会引用丢失，变成空值
- Date 类型的数据会被当做字符串处理
- NaN 和 Infinity 格式的数值及 null 都会被当做 null。
- 其他类型的对象，包括 Map/Set/WeakMap/WeakSet，仅会序列化可枚举的属性

```js
function deepClone(obj) {
  var _tmp,result;
  _tmp = JSON.stringify(obj);
  result = JSON.parse(_tmp);
  return result;
}
```

**2）方式二-确定参数类型为object**

确定参数类型为object （这里仅指object literal、Array literal）后，复制源对象的键/值到目标对象，否则直接返回源对象。

```js
function deepClone(obj){
    var result = typeof obj.splice === 'function'?[]:{},
    key;
    if (obj && typeof obj === 'object'){
        for (key in obj ){
            if (obj[key] && typeof obj[key] === 'object'){
                result[key] = deepClone(obj[key]);//如果对象的属性值为object的时候，递归调用deepClone，即再把某个值对象复制一份到新的对象的对应值中
            }else{
                result[key] = obj[key];//如果对象的属性值不为object的时候，直接复制参数对象的每一个键/值到新对象对应的键/值中
            }
        }
        return result;
    }
    return obj;
}
```

**3）方式三-Reflect代理法**

```js
function deepClone(obj) {
    if (!isObject(obj)) {
        throw new Error('obj 不是一个对象！')
    }
    let isArray = Array.isArray(obj)
    let cloneObj = isArray ? [...obj] : { ...obj }
    Reflect.ownKeys(cloneObj).forEach(key => {
        cloneObj[key] = isObject(obj[key]) ? deepClone(obj[key]) : obj[key]
    })
    return cloneObj
}
```

**4）方式四-终极版**

> 循环引用的问题，即obj.x = obj
> 用一个weakMap<原对象引用,新对象引用>保存已经创建的对象，如果再下次递归中如果当前等于原对象引用，那么直接返回新创建对象的引用

```js
function isObject(obj) {
    return (typeof obj === 'object' || typeof obj === 'function') && obj !== null
}
function isFunc(obj) {
    return typeof obj === 'function'
}
function isArray(obj) {
    return Array.isArray(obj)
}
function isDate(obj) {
    return Object.prototype.toString.call(obj) === '[object Date]'
}
function isMap(obj) {
    return Object.prototype.toString.call(obj) === '[object Map]'
}
function isSet(obj) {
    return Object.prototype.toString.call(obj) === '[object Set]'
}
function isRegExp(obj) {
    return Object.prototype.toString.call(obj) === '[object RegExp]'
}

function deepCopy(obj,weakMap = new WeakMap()) {
    if (!isObject(obj)) return obj
    if (weakMap.get(obj)) return weakMap.get(obj)
    // 如果是函数
    if (isFunc(obj)) {
        let result = null
        // 获得函数的主体
        const bodyReg = /(?<={)(.|\n)+(?=})/m;
        // 获得参数
        const paramReg = /(?<=\().+(?=\)\s+{)/;
        const funcString = obj.toString();
        // 判断是否是箭头函数
        if (obj.prototype) {
            const param = paramReg.exec(funcString);
            const body = bodyReg.exec(funcString);
            if (body) {
                if (param) {
                    const paramArr = param[0].split(',');
                    result = new Function(...paramArr, body[0]);
                } else {
                    result = new Function(body[0]);
                }
            }
        } else {
            result = eval(funcString);
        }
        weakMap.set(obj,result)
        return result
    }

    // 如果是数组
    if (Array.isArray(obj)) {
        let result = []
        for (let val of obj) {
            result.push(deepCopy(val, weakMap))
        }
        weakMap.set(obj,result)
        return result
    }
    // 如果是Date
    if (isDate(obj)) {
        let result = new obj.constructor(obj)
        weakMap.set(obj,result)
        return result
    }
    // 如果是map
    if (isSet(obj)) {
        let result = new Set()
        obj.forEach((val)=> {
            result.add(deepCopy(val, weakMap))
        })
        weakMap.set(obj,result)
        return result
    }
    // 如果是set
    if (isMap(obj)) {
        let result = new Map()
        obj.forEach((val, key) => {
            result.set(key, deepCopy(key, weakMap))
        })
        weakMap.set(obj,result)
        return result
    }
    // 如果是正则
    if (isRegExp(obj)) {
        const reFlags = /\w*$/;
        const result = new obj.constructor(obj.source, reFlags.exec(obj));
        result.lastIndex = obj.lastIndex;
        weakMap.set(obj,result)
        return result;
    }
    let result = {}
    weakMap.set(obj,result)
    // 考虑symbol类型的属性名
    let symbols = Object.getOwnPropertySymbols(obj)
    if(symbols.length > 0) {
        for(let key of symbols) {
            let val = obj[key]
            result[key] = isObject(val) ? deepCopy(val, weakMap) : val
        }
    }
    // 非symbol类型属性名
    for (let key in obj) {
        if (obj.hasOwnProperty(key)) {
            let val = obj[key]
            result[key] = isObject(val) ? deepCopy(val, weakMap) : val
        }
    }
    return result
}

var map = new Map()
map.set(1,1)
map.set(2,2)
var obj = {
    a: 1,
    b: '1',
    c: Symbol(),
    d: undefined,
    e: null,
    f: true,
    g: {
        g1: 1,
        g2: '2',
        g3: undefined
    },
    [Symbol()]: 'symbol',
    h: function (a) {
        console.log(a)
    },
    i: [1,2,3],
    j: new Date(),
    k: new Set([1,2,3,4]),
    l: map,
    m: /\w*$/g,
}
obj.x = obj.i

var deepObj = deepCopy(obj)
console.log(deepObj.x === deepObj.i) // true
console.log(deepObj)
```


### 328给定起止日期，返回中间的所有月份
```js
// 输入两个字符串 2018-08  2018-12
// 输出他们中间的月份 [2018-10, 2018-11]
```

### 实现代码

```js
const getMonths = (startDateStr, endDateStr) => {
  let startTime = getDate(startDateStr).getTime()
  const endTime = getDate(endDateStr).getTime()
  const result = []
  while (startTime < endTime) {
    let curDate = new Date(startTime)
    result.push(formatDate(curDate))
    curDate.setMonth(curDate.getMonth() + 1)
    startTime = curDate.getTime()
  }
  return result.slice(1)
}
const getDate = (dateStr) => {
  const [year, month] = dateStr.split('-')
  return new Date(year, month - 1)
}
const formatDate = (date) => {
  return `${date.getFullYear()}-${(date.getMonth()+1).toString().padStart(2, '0')}`
}
console.log(getMonths('2018-08', '2018-12'))
```

### 329请写一个函数，输出出多级嵌套结构的 Object 的所有 key 值
```js
var obj = {
  a: "12",
  b: "23",
  first: {
    c: "34",
    d: "45",
    second: { 3: "56", f: "67", three: { g: "78", h: "89", i: "90" } },
  },
};
// => [a,b,c,d,e,f,g,h,i]
```

### 代码实现

```js
function getAllKey(obj) {
  if (typeof obj !== 'object') {
    return
  }
  let keys = []

  for (let index in obj) {
    if (obj[index] instanceof Object && !Array.isArray(obj[index])) {
      keys = keys.concat(getAllKey(obj[index]))
    } else {
      keys.push(index)
    }
  }
  return keys
}
getAllKey(obj)
```

### 330es5 实现 isInteger

### 代码实现

`Number.isInteger()` 方法用来判断给定的参数是否为整数

**1）代码实现一**

- `isFinite` 方法检测它参数的数值。如果参数是 NaN，Infinity或者-Infinity，会返回false，其他返回 true。
- `Number.isInteger(Infinity) === false`, 而`typeof Infinity` 和 `Math.floor(Infinity)`得到的均为true
- 取整：`Math.floor`、`Math.ceil`、`Math.round`均可

```js
Number.isInteger = function(value) {
    return typeof value === "number" && 
           isFinite(value) && 
           Math.floor(value) === value;
};
```

**2）代码实现二**

- 异或运算

```js
function isInteger(x) {
  return typeof value === "number" && 
           isFinite(value) && x ^ 0 === x
}
```

**3）代码实现三**

- 取余

```js
function isInteger(x) {
  return typeof value === "number" && 
           isFinite(value)  && (x % 1 === 0)
}
```



### 331给定一个数组，按找到每个元素右侧第一个比它大的数字，没有的话返回-1 规则返回一个数组
```js
/*
 *示例：
 *给定数组：[2,6,3,8,10,9]
 *返回数组：[6,8,8,10,-1,-1]
 */
```

### 代码实现

**1）暴力双重循环**

```js
function findMaxRight(array) {
    let result = []
    for (let i = 0; i < array.length - 1; i++) {
        for (let j = i + 1; j < array.length; j++) {
            if (array[j] > array[i]) {
                result[i] = array[j]
                break
            } else {
                result[i] = -1
            }
        }
    }
    result[result.length] = -1
    return result
}
```

**2）利用栈的特性**

```js
function findMaxRightWithStack(array) {
    const size = array.length
    let indexArr = [0]
    let result = []
    let index = 1
    while (index < size) {
        if (indexArr.length > 0 && array[indexArr[indexArr.length - 1]] < array[index]) {
            result[indexArr[indexArr.length - 1]] = array[index]
            indexArr.pop()
        } else {
            indexArr.push(index)
            index++
        }
    }
    indexArr.forEach((item) => {
        result[item] = -1
    })
    return result
}
```

**3）单调递减栈, 反向遍历**

```js
const firstBiggerItem = (T) => {
    const res = new Array(T.length).fill(-1);
    const stack = [];
    for (let i = T.length - 1; i >= 0; i--) {
        while (stack.length && T[i] >= T[stack[stack.length - 1]]) {
        stack.pop();
        }
        if (stack.length && T[i] < T[stack[stack.length - 1]]) {
        res[i] = T[stack[stack.length - 1]];
        }
        stack.push(i);
    }
    return res;
};
// test
var T = [2, 6, 3, 8, 10, 9];
console.log(firstBiggerItem(T));
```



### 332怎样用 css 实现一个弹幕的效果，动手实现一下

### 代码实现

#### 1.简单实现演示

```html
<style>
    .box {
      width: 800px;
      height: 400px;
      background: rgba(0, 0, 0, 0.1);
      margin: 100px auto 0;
      overflow: hidden;
    }

    .track {
      height: 40px;
      line-height: 40px;
      border: 2px solid rgba(0, 0, 0, 0.3);
      margin-bottom: 5px;
    }

    .child {
      width: 80px;
      line-height: 20px;
      margin-bottom: 10px;
      text-shadow: 2px 2px 2px rgba(0, 0, 0, 0.1)
    }

    .child-1 {
      color: brown;
      text-shadow: 2px 2px 3px rgb(248, 81, 20);
      transform: translateX(1000px);
      animation: scrollTo linear 4s infinite;
    }

    .child-2 {
      color: rgb(127, 197, 35);
      text-shadow: 2px 2px 3px rgb(173, 255, 80);
      transform: translateX(1050px);
      animation: scrollTo linear 7s infinite;
    }

    .child-3 {
      color: coral;
      text-shadow: 2px 2px 3px coral;
      transform: translateX(800px);
      animation: scrollTo linear 5s infinite;
    }

    @keyframes scrollTo {
      to {
        transform: translateX(-100px);
      }
    }
  </style>

  <div class="box">//屏幕
    <div class="track">//弹幕轨道
      <div class="child child-1">我是弹幕</div>
    </div>
    <div class="track">
      <div class="child child-2">我是弹幕</div>
    </div>
    <div class="track">
      <div class="child child-3">我是弹幕</div>
    </div>
  </div>
```

#### 2.可动态添加弹幕

```html
<style>
    * {
      margin: 0;
      padding: 0;
    }

    html,
    body {
      /* 自适应高度 */
      width: 100%;
      height: 100%;
    }

    #main {
      width: 100%;
      height: 100%;
      /*背景色线性变化*/
      background: -webkit-gradient(linear,
          0% 0%,
          0% 100%,
          from(#add8e6),
          to(#f6f6f8));
      overflow: hidden;
    }

    span {
      /*强制不换行*/
      white-space: nowrap;
      position: absolute;
    }

    #mainScreen {
      width: 800px;
      height: 600px;
      margin: 8px auto;
      border: 1px solid gray;
      background-color: white;
      /*隐藏span标签超出oScreen屏幕范围的内容*/
      overflow: hidden;
      position: relative;
    }

    #bottom {
      width: 800px;
      height: 32px;
      margin: 5px auto;
    }

    #txt {
      width: 240px;
      height: 30px;
      line-height: 30px;
      font-family: 微软雅黑;
      padding-left: 8px;
      border: 1px solid lightslategrey;
      float: left;
    }

    #btn {
      width: 60px;
      height: 30px;
      line-height: 30px;
      margin-left: 30px;
      margin-top: 2px;
      border-radius: 4px;
      float: left;
    }
  </style>
  <div id="main">
    <div id="mainScreen"></div>
    <div id="bottom">
      <input id="txt" type="text" value="say some thing..." />
      <input id="btn" type="button" value="Send" />
    </div>
  </div>
  <script>
    window.onload = function () {
      var oBtn = document.getElementById("btn");
      var oText = document.getElementById("txt");
      var oScreen = document.getElementById("mainScreen");
      oBtn.onclick = sendMessage;
      // 每次点击清空输入框
      oText.onclick = function () {
        oText.value = "";
      };
      //添加回车提交事件
      document.onkeydown = function (evt) {
        var event = evt || window.event; //兼容IE
        if (event.keyCode == 13) {
          sendMessage();
        }
      };

      function sendMessage() {
        //如果输入为空则弹出对话框
        if (oText.value.trim() == "") {
          alert("请正确输入");
        } else {
          //如果有输入则动态创建span并将内容添加到span中，然后再将span添加到mainScreen中
          var oDan1 = document.createElement("span");
          oDan1.innerText = oText.value;

          // 定义随机字体大小
          var oFontSize = parseInt(Math.random() * 16 + 16);
          // 创建随机颜色
          var oFontColor =
            "#" + Math.floor(Math.random() * 16777215).toString(16);
          // 随机高度
          var oMax = oScreen.offsetHeight - oFontSize;
          var oMin = oScreen.offsetTop;
          var oHeight = Math.floor(Math.random() * (oMax - oMin) + oMin);

          oDan1.style.color = oFontColor;
          oDan1.style.fontSize = oFontSize + "px";
          oDan1.style.marginTop = oHeight + "px";

          // Move
          var variable = 800; //800是mainScreen的宽度，也可写成：oDan1.offsetLeft
          var timer = setInterval(function () {
            oDan1.style.marginLeft = variable + "px";
            //如果没有超出边界就将span动态添加到oScreen
            if (variable > -oDan1.offsetWidth) {
              variable -= 2;
              oScreen.appendChild(oDan1);
            } else {
              clearInterval(timer);
              // 当显示超出范围就删除节点，这里我之前用display:none不管用
              oDan1.parentNode.removeChild(oDan1);
            }
          }, 10);
        }
      }
    };
  </script>
```

### 333动手实现一个 repeat 方法
```js
function repeat(func, times, wait) {
  // TODO
}
const repeatFunc = repeat(alert, 4, 3000);
// 调用这个 repeatFunc ("hellworld")，会alert4次 helloworld, 每次间隔3秒
```

### 代码实现

#### 1.实现方式一

```js
function repeat (func, times, wait) {
	if (typeof func !== 'function') return;
	if (times <= 0) return;
	return function (value) {
		let timesTmp = times
		let interval = setInterval(function(){
			func(value);
			timesTmp--;
			timesTmp === 0 && clearInterval(interval)
		}, wait)
	}
}
const repeatConsole = repeat(console.log, 4, 2000)
repeatConsole('helllwww')
```

#### 二、实现方式二

```js
function repeat (func, times, wait) {
        return function(...args){
            let i = 0;
            let _args = [...args]
        let handle = setInterval(() => {
            i += 1;
            if(i > times){
                clearInterval(handle);
                return;
            }
            func.apply(null, _args);
        },wait);
    }
}
```

### 334说一下 GC

### 一、常用的垃圾回收机制

#### 1）引用计数法 reference counting

1. 跟踪记录每个值被引用的次数
2. 当声明变量并将一个引用类型的值赋值给该变量时，则这个值的引用次数加1，
3. 同一值被赋予另一个变量，该值的引用计数加1 。
4. 当引用该值的变量被另一个值所取代，则引用计数减1，
5. 当计数为 0 的时候，说明无法在访问这个值了，系统将会收回该值所占用的内存空间。
6. 缺点：循环引用的时候，引用次数不为0，不会被释放；

#### 2）标记清除法 mark-sweep

给存储在内存中的变量都加上标记，判断哪些变量没有在执行环境中引用，进行删除；

#### 3）停止复制 stop-copy

内存分为两块，正在使用的存活对象复制到未被使用的内存块中，清除正在使用的内存块中的所有对象，然后交换两个内存的角色

#### 4）标记压缩 mark-compact

所有可达对象做一次标记，所有存活对象压缩到内存的一端，减少内存碎片

#### 5）增量算法 incremental collecting

每次GC线程只收集一小片内存空间，接着切换到应用程序线程，依次反复，直到垃圾收集完成

### 二、堆、栈的数据的GC

js的内存空间有 调用栈 stack 和堆空间 heap

#### 1）调用栈中的数据的GC

调用栈有一个记录当前执行状态的指针（称为 ESP），JS引擎通过下移ESP指针来销毁栈顶某个执行上下文，释放栈空间

#### 2）堆空间中数据的GC

**分代收集：** 新生代、老生代

提高垃圾回收的效率，V8将堆分为新生代和老生代两个部分：

- 其中新生代为存活时间较短的对象(需要经常进行垃圾回收)，内存占用小，GC频繁；只支持1-8M容量；使用副垃圾回收器；
- 而老生代为存活时间较长的对象(垃圾回收的频率较低)，内存占用多，GC不频繁；使用主垃圾回收器；

**新生代的GC算法**

新生代的对象通过 Scavenge 算法进行GC。在 Scavenge 的具体实现中，主要采用了 Cheney 算法。

1. Cheney 算法是一种采用停止复制（stop-copy）的方式实现的垃圾回收算法。
2. 它将堆内存一分为二，每一部分空间成为 semispace-半空间。
3. 在这两个 semispace 空间中，只有一个处于使用中，另一个处于闲置中。
4. 处于使用中的 semispace 空间成为 From 对象空间，处于闲置状态的空间成为 To 空闲空间。
5. 当我们分配对象时，先是在 From 空间中进行分配。当开始进行垃圾回收时，会检查 From 空间中的存活对象，这些存活对象将被复制到 To 空间中，同时还会将这些对象有序的排列起来~~相当于内存整理，所以没有内存碎片，而非存活对象占用的空间将被释放。
完成复制后，From空间和To空间的角色发生对换。
6. Scavenge 是典型的空间换取时间的算法，而且复制需要时间成本，无法大规模地应用到所有的垃圾回收中，但非常适合应用在新生代中进行快速频繁清理。

**对象晋升策略**

对象从新生代中移动到老生代中的过程称为晋升。

晋升条件主要有两个：

- 对象是否经历过两次 Scavenge 回收都未清除，则移动到老生代
- To 空间已经使用超过 25%，To 空间对象移动到老生代

> 因为这次 Scavenge 回收完成后，这个 To 空间将变成 From 空间，接下来的内存分配将在这个空间中进行，如果占比过高，会影响后续的内存分配

**写屏障**

 写缓冲区中有一个列表(CrossRefList)，列表中记录了所有老生区对象指向新生区的情况

 这样可以快速找到指向新生代该对象的老生代对象，根据他是否活跃，来清理这个新生代对象；

 **老生代的GC**

老生代的内存空间较大且存活对象较多，使用新生代的Scavenge 复制算法，会耗费很多时间，效率不高；而且还会浪费一半的空间；

为此V8使用了标记-清除算法 (Mark-Sweep)进行垃圾回收，并使用标记-压缩算法 (Mark-Compact)整理内存碎片，提高内存的利用率。步骤如下：

1. 对老生代进行第一遍扫描，标记存活的对象,从一组根元素开始，递归遍历这组根元素，在这个遍历过程中，能到达的元素称为活动对象，没有到达的元素就可以判断为垃圾数据；
2. 对老生代进行第二次扫描，清除未被标记的对象
3. 标记-整理算法，标记阶段一样是递归遍历元素，整理阶段是将存活对象往内存的一端移动
4. 清除掉存活对象边界外的内存

> 注意，不管那种，整理内存后只要地址有变化，需要及时更新到调用栈的

 **全停顿Stop-The-World**

JavaScript 是运行在主线程之上的，一旦执行垃圾回收算法，都需要将正在执行的 JavaScript 脚本暂停下来，待垃圾回收完毕后再恢复脚本执行。我们把这种行为叫做全停顿（Stop-The-World）；

新生代因为内存小，活动对象少，全停顿影响不大，但是老生代可能会造成卡顿明显；

解决办法：增量标记算法Incremental Marking

V8 将标记过程分为一个个的子标记过程，同时让垃圾回收标记和 JavaScript 应用逻辑交替进行，直到标记阶段完成；


### 三、JavaScript中的垃圾回收

V8（javascript引擎）的新老空间内存分配与大小限制

#### 新老空间

凡事都有一把双刃剑，在垃圾回收的演变过程中人们发现，没有一种特定的垃圾回收机制是可以完美的解决问题，因此V8采用了新生代与老生代结合的垃圾回收方式，将内存分为新生代和老生代。 新生代频繁进行GC，空间小，采用的是空间换时间的scavenge算法，所以又划分为两块semispace，From和To。 老生代大部分保存的是存活时间较长的或者较大的对象。采用的是mark-sweep（主）&mark-compact（辅）算法。

V8限制了js对象可以使用的内存空间，不止是因为最初V8是作为浏览器引擎而设计的。还有其垃圾回收机制的影响因素。V8使用stop-the-world（全停顿）, generational, accurate的垃圾回收器。在执行回收之时会暂时中断程序的执行，而且只处理对象堆栈。当内存达到一定的体积时，进行一次垃圾回收的时间将会很长，从而影响其相应而造成浏览器假死的状况。因此，在V8中限制老生代64位为1.4GB，32位为0.7GB，新生代64位为32M，32位为16M。 当然，如果需要更大的内存空间，在node中可以进行更改。

#### 对象晋升

新生成的对象放入新生代内存中，那哪些对象会被放入老生代中呢？大部分放入老生代的对象是由新生代晋升而来。对象的晋升的方式：

当新生代的To semispace内存占满25%时，此时再从From semispace拷贝对象将不会再放入To空间中以防影响后续的新对象分配，而将其直接复制到老生代空间中。

在进行一次垃圾回收后，第二次GC时，发现已经经历过一次GC的对象在从From空间复制时直接复制到老生代。

在新对象分配时大部分对象被分配到新生代的From semispace，但当这个对象的体积过大，超过1MB的内存页时，直接分配到老生代中的large Object Space。

#### 新生代的GC机制与优缺点

**回收机制**

新生代采用Scavenge算法，在scavenge算法的实现过程中，则主要采用了cheney算法。即使用复制方式来实现垃圾回收。它将内存一分为二，每一个空间都是一个semispace。

处于使用状态的是From空间，闲置的是To空间。当分配对象时，先是分配到From空间，垃圾回收时会检查From空间中存活的对象，将其复制到To空间，回收其他的对象。完成复制后会进行紧缩，From和To空间的调换。如此循环往复。

**优势**

由其执行的算法及过程我们可以了解到，在新生代的垃圾回收过程中，总是由一半的semispace是空余的。scavenge只复制存活的对象，在新生代的内存中，存活的对象相对较少，所以使用这个算法恰到好处。

#### 老生代的GC机制与优缺点

**回收机制**

由于的scavenge算法只复制存活的对象，如果在老生代中也使用此算法的话就会造成复制很多对象，效率低，并且造成很大的内存空间浪费。 老生代中采用的则是mark-sweep（标记清除）和mark-compact（标记整理）结合的方式。而为什么使用两者结合呢？这就要讲到两者的优点与缺点。

**mark-sweep（标记清除）**

1）优点

- 标记清除需要标记堆内存中的所有对象，标记出在使用的对象，清除那些没有被标记的对象。在老生代内存中与新生代相反，不使用的对象只占很小一部分，所以清除不用的对象效率高。
- mark-sweep不会将内存空间分为两半，所以，不会浪费一半空间。

2）缺点

但标记清除会造成一个问题，就是在清除过后会导致内存不连续，造成内存碎片，如果此时需要储存一个很大的内存而空间又不够的时候就会造成没有必要的反复垃圾回收。

**mark-compact（标记整理）**

1）优点

此时标记整理就可以出场了，在标记清除的过程中，标记整理会将存活的对象和需要清除的对象移动到两端。然后将其中一段需要清除的消灭掉，可以解决标记清除造成的内存碎片问题。

2）缺点

但是在紧缩内存的过程中需要移动对象，效率比较低。所以V8在清理时主要会使用Mark-sweep,在空间不足以对新生代中晋升过来的对象进行分配时才会使用Mark-compact。

#### 垃圾回收机制的优化

增量标记(在老空间里引入了此方式)

scavenge算法,mark-sweep及mark-compact都会导致stop-the-world（全停顿）。而全停顿很容易带来明显的程序迟滞，标记阶段很容易就会超过100ms，因此V8引入了增量标记，将标记阶段分为若干小步骤，每个步骤控制在5ms内，每运行一段时间标记动作，就让JavaScript程序执行一会儿，如此交替，明显地提高了程序流畅性，一定程度上避免了长时间卡顿。










### 335简单封装一个异步 fecth，使用 async await 的方式来使用

### 一、基本操作

一个基本的fetch操作很简单。就是通过fetch请求，返回一个promise对象，然后在promise对象的then方法里面用fetch的response.json()等方法进行解析数据，由于这个解析返回的也是一个promise对象，所以需要两个then才能得到我们需要的json数据。

```js
fetch('http://example.com/movies.json')
.then(function(response) {
    return response.json();
})
.then(function(myJson) {
    console.log(myJson);
});
```

### 二、为何不直接使用基本操作

fetch规范与jQuery.ajax()主要有两种方式的不同：

1. 当接收到一个代表错误的 HTTP 状态码时,比如400, 500，fetch不会把promise标记为reject, 而是标记为resolve，仅当网络故障时或请求被阻止时，才会标记为 reject。
2. 默认情况下，fetch 不会从服务端发送或接收任何 cookies, 如果站点依赖于用户 session，则会导致未经认证的请求（要发送 cookies，必须设置 credentials 选项）。

从这里可以看出来，如果我们要在fetch请求出错的时候及时地捕获错误，是需要对response的状态码进行解析的。又由于fetch返回的数据不一定是json格式，我们可以从header里面Content-Type获取返回的数据类型，进而使用正确的解析方法。

### 三、使用async/awiait的原因

Promise 将异步操作规范化.使用then连接, 使用catch捕获错误, 堪称完美, 美中不足的是, then和catch中传递的依然是回调函数, 与心目中的同步代码不是一个套路.

为此, ES7 提供了更标准的解决方案 — async/await. async/await 几乎没有引入新的语法, 表面上看起来, 它就和alert一样易用。

```js
let searchWord = '123',
    url = `https://www.baidu.com/s?wd=${searchWord}`;
(async ()=>{
  try {
    let res = await fetch(url, {mode: 'no-cors'});//等待fetch被resolve()后才能继续执行
    console.log(res);//fetch正常返回后才执行
    return res;//这样就能返回res不用担心异步的问题啦啦啦
  } catch(e) {
    console.log(e);
  }
})();
```

### 三、简单封装

```js
class EasyHttp{
    //get 
    async get(url) {
        const response = await fetch(url);
        const data = await response.json();
        return data;
    }

    //POST
    async post(url,datas){
        const response = await fetch(url,{
            method: "POST",
            headers: {
                'Content-type': 'application/json'
            },
            body: JSON.stringify(datas)            
        })
        const data = await response.json();
        return data;
    }

    //PUT
    async put(url,datas){
        const response = await fetch(url,{
            method: "PUT",
            headers: {
                'Content-type': 'application/json'
            },
            body: JSON.stringify(datas)            
        })
        const data = await response.json();
        return data;
    }

    //delete
    async delete(url){
        const response = await fetch(url,{
            method: "DELETE",
            headers: {
                'Content-type': 'application/json'
            }
        })
        const data = await "数据删除成功";   //await后面还可以直接跟字符串额 这操作666...
        return data;
    }
}
```



### 336随便打开一个网页，用 JavaScript 打印所有以 s 和 h 开头的标签，并计算出标签的种类

## 代码实现

```js
// 转换为真正的数组
let el = Array.from(document.getElementsByTagName("*"));
let elObj = {};
// 正则判断是否是h/s开头
let reg = /^[h|s].+/gi
el.map(item=>{
  const tagName = item.tagName;
  if(reg.test(tagName)){
    !elObj[tagName] ? elObj[tagName] = 1 : elObj[tagName]++
  }
});
console.log(elObj)
```


### 337大数计算如何实现



### 338写出输出结果
```js
function Foo() {
  getName = function () {
    alert(1);
  };
  return this;
}
var getName;
function getName() {
  alert(5);
}
Foo.getName = function () {
  alert(2);
};
Foo.prototype.getName = function () {
  alert(3);
};
getName = function () {
  alert(4);
};

Foo.getName(); // ？
getName(); // ？
Foo().getName(); // ？
getName(); // ？
new Foo.getName(); // ?
new Foo().getName(); // ?
new new Foo().getName(); // ？
```



### 339是否用过 restful 接口，和其他风格的有什么区别



### 340说一下 get、post、put 的区别



### 341justify-content:space-between around 有什么区别



### 342实现 Promise.then



### 343平时在项目开发中都做过哪些前端性能优化



### 344输入两个字符串，输出他们中间的月份
```js
// 给两个数组 [A1,A2,B1,B2,C1,C2,D1,D2] [A,B,C,D]
// 输出 [A1,A2,A,B1,B2,B,C1,C2,C,D1,D2,D]
```



### 345按要求实现一个 sum 函数
```js
const a = sum(); // => a === 0
const b = sum(); // => b === 2
const c = sum(4)(5); // c === 9
const k = sum(n1)...(nk) // k === n1 + n2 + ... + nk
```



### 346写出代码执行结果
```js
async function async1() {
  console.log("async1 start");
  await async2();
  console.log("async1 end");
}
async function async2() {
  console.log("async2");
}
console.log("script start");
setTimeout(function () {
  console.log("setTimeout");
}, 0);
async1();
new Promise(function (resolve) {
  console.log("promise1");
  resolve();
}).then(function () {
  console.log("promise2");
});
console.log("scripts end");
// 写出代码执行完成打印的结果
```


### 执行结果

```js
script start
async1 start
async2
promise1
scripts end
async1 end
promise2
setTimeout
```

### 说明

- 首先，同步代码执行
- script start
- async1 start
- 这里遇到了 await async2() ,我们知道 await 会造成同步代码阻塞，所以会执行 async2,await 下一行的代码并不会等待，会产生一个微任务
- 可以这样理解，async 会隐式返回 promise 作为结果的函数，await 后面的函数执行完，会产生一个 promise.then，也就是微任务
- async2
- 继续同步代码执行
- promise1
- scripts end
- 同步代码执行完毕，开始看微任务队列
- 因为上面 async/await 的原因，await 后面打印的会被推入至微任务队列
- async1c end
- promise2
- 微任务队列执行完毕，现在开始执行宏任务队列
- setTimeout

### 347设计一个 Student 组件，实现输入姓名性别成绩（这三个必填），还有几个不是必填的属性，要设置默认值，点击弹出成绩


### 代码实现

```js
import React, { useState } from 'react';

const Student = () => {
  const [name, setName] = useState('');
  const [sex, setSex] = useState('');
  const [score, setScore] = useState('');
  const [habby, setHabby] = useState('FE');
  const handleClick = () => {
    if (name && sex && score) {
      alert(score);
    }
  };
  return (
    <>
      <input
        placeholder="请输入学生姓名"
        value={name}
        onChange={(e) => setName(e.target.value)}/>
      <input
        placeholder="请输入学生性别"
        value={sex}
        onChange={(e) => setSex(e.target.value)}/>
      <input
        placeholder="请输入学生分数"
        value={score}
        onChange={(e) => setScore(e.target.value)}/>
      <input
        placeholder="请输入学生爱好"
        value={habby}
        onChange={(e) => setHabby(e.target.value)}/>
      <button onClick={handleClick} />
    </>
  );
};

export default Student;
```

### 348versions 是一个项目的版本号列表，因多人维护，不规则，动手实现一个版本号处理函数
```js
var versions = ["1.45.0", "1.5", "6", "3.3.3.3.3.3.3"];
// 要求从小到大排序，注意'1.45'比'1.5'大
function sortVersion(versions) {
  // TODO
}
// => ['1.5','1.45.0','3.3.3.3.3.3','6']
```


### 代码实现

```js
function sortVersion(list){
  return list.sort((a, b) => {
      let aa = a.split('.') 
      let bb = b.split('.') 
      let length = aa.length>bb.length?aa.length:bb.length
      for (var i =0; i < length; i++){
          let x = aa[i] || 0;
          let y = bb[i] || 0;
          if(x-y !==0 )return x - y;
      }
  });
}
sortVersion(['1.0.0', '1.2.3.4.5','2.12.1', '0.18.1','3.3.2','0.18.1'])
```

### 349设计一个函数，奇数次执行的时候打印 1，偶数次执行的时候打印 2


### 代码实现

```js
const fn = () => {
    (fn.count & 1) === 0 ? console.log(2) : console.log(1)
    fn.count++
}
fn.count = 1
```

### 350用尽量短的代码实现一个 arrary 的链式操作，将数组中的大于 10 的值进行一个累加


### 代码实现

- 方式一

```js
[1,2,3,4,5,10,12,13].reduce((acc, cur, index, arr) => {
    if(cur > 10){
        acc += cur;
    }
    return acc;
}, 0);
```

- 方式二

```js
eval([1,2,3,4,5,10,12,13].filter(item=>item > 10).join('-').replace('-','+'));
```

### 351var、let、const 的区别


### 一、简洁版

1. var声明的变量会挂载在window上，而let和const声明的变量不会
2. var声明变量存在变量提升，let和const不存在变量提升
3. let和const声明形成块作用域
4. 同一作用域下let和const不能声明同名变量，而var可以
5. const一旦声明必须赋值,不能使用null占位；声明后不能再修改 ；如果声明的是复合类型数据，可以修改其属性

### 二、详细版

#### 1.var

**var定义的变量，没有块的概念，可以跨块访问, 不能跨函数访问（如果你定义为全局变量，是可以跨函数访问的），有变量提升（是指变量重新赋值）。**

```js
var a = 1;
// var a;//不会报错
console.log('函数外var定义a：' + a);//可以输出a=1
function change(){
a = 4;
console.log('函数内var定义a：' + a);//可以输出a=4
}
change();
console.log('函数调用后var定义a为函数内部修改值：' + a);//可以输出a=4
```

#### 2.let

**let定义的变量，只能在块作用域里访问，不能跨块访问，也不能跨函数访问，无变量提升，不可以重复声明。**

```js
'use strict';
function func(args){
    if(true){
        let i = 6;
        console.log('inside: ' + i);  //不报错
    }
    console.log('outside: ' + i);  // 报错 "i is not defined"
};
func();
```

let 声明的变量只在块级作用域内有效

```js
'use strict';
function func(args){
    if(true){
        let i = 6;
        console.log('inside: ' + i);  //不报错
    }
    console.log('outside: ' + i);  // 报错 "i is not defined"
};
func();
```

不存在变量提升，而是“绑定”在暂时性死区

```js
// 不存在变量提升
'use strict';
function func(){
    console.log(i);
    let i;
};
func(); // 报错
```

在let声明变量前，使用该变量，它是会报错的，而不是像var那样会‘变量提升’。 其实说let没有‘变量提升’的特性，不太对。或者说它提升了，但是ES6规定了在let声明变量前不能使用该变量。

```js
'use strict';
var test = 1;
function func(){
    console.log(test);
    let test = 2;
};
func();  // 报错
```

如果let声明的变量没有变量提升，应该打印’1’（func函数外的test）；而它却报错，说明它是提升了的，只是规定了不能在其声明之前使用而已。我们称这特性叫“暂时性死区（temporal dead zone）”。且这一特性，仅对遵循‘块级作用域’的命令有效（let、const）。

#### 3.const

const用来定义常量，使用时必须初始化(即必须赋值)，只能在块作用域里访问，而且不能修改，无变量提升，不可以重复声明。

const 与 let 的使用规范一样，与之不同的是：const 声明的是一个常量，且这个常量必须赋值，否则会报错。

**注意:** const常量，指的是常量对应的内存地址不得改变，而不是对应的值不得改变，所有把应用类型的数据设置为常量，其内部的值是可以改变的，例如：const a={}; a.b=13;//不会报错 const arr=[]; arr.push(123);//不会报错

```js
'use strict';
function func(){
    const PI;
    PI = 3.14;
    console.log(PI);
};
func(); // 报错“Missing initializer in const declaration”
```


### 352怎么理解 to B 和 to C 的业务


### 一、B 和 C 的含义

`B`其实是`Bussiness`的缩写，直译的意思就是商业，大家普遍把它作为机构客户的代名词。`C`其实是`Consumer` 的缩写，直译的意思是消费者、用户或者顾客，因为日常生活中接触的绝大部分直接消费者都是个人，所以大家普遍把`C`作为个人客户的代名词。

- To B 就是 To business，面向企业或者特定用户群体的面商类产品
- To C 就是 To customer，产品面向消费者
- To C 产品是你去挖掘用户需求，是创造，从无到有；更注重的是用户体验
- To B 产品是公司战略或相关方给你提出要求，产品经理将这类「线下已有的需求」系统化，达到提高现有流程的效率的目的。产品更注重的是功能价值以及系统性

### 二、ToB 和 ToC 需要注意的点

1. **业务形态不同**。`ToC`的需求更多的是围绕衣食住行来展开的,ToB 的需求更多的是围绕机构所处的某个行业或者某个领域来展开的，场景更为复杂多样。总之，`ToC`是**生活**，是**因点生点**；`ToB`是面向生产，是因**因面生点**
2. **产品需求不同**。`ToC`作为独立的个体所存在，面向的用户是更加大众的：90 后的叔叔阿姨，00 后，10 后，对产品的需求是是功能的外部化，体验和视觉效果要好。`ToB`更多的考虑的是产品的功能时效化以及专业化，要求产品能够实实在在的价值和效用
3. **产品单体消费量不同**。`ToC`的消费能力一般情况下要远小于`ToB`的消费能力.所以一般`ToC`需要一定的客户群体才能支撑起一个业务的发展
4. **性价比要求不同**。`ToC`对于性价比的实际要求要远低于理论需求，因为`ToC`大多数无法具有准确分析`性`的专业能力，所以产生了**贵的就是好的**的理论，相比而言`ToB`具有相对专业判断能力，而且需要考虑到投入/产出比，同时具有需要实现性价比的意愿和能力
5. **市场声誉影响力不同**。个人更容易受外部环境的影响而做出不适合自己的决策。具有很好市场声誉（市场曝光度比较高）的企业，往往对`ToC`更具有吸引力。这个就是从众心理的“妙用”。反之`ToB`除了会考虑市场声誉（这个可能是进入门槛），更多的会关注产品本身的质量、效能，然后综合评估产品的可购买性。一句话总结，`ToC`**感性**，`ToB`**理性**。
6. **售后要求不同**。`ToC`对产品的售后要求一般比较低，商家也多是标准化服务，其中缘由一是产品的生命周期偏短，很多属于“阅后即焚”类型的产品；二是因为产品的技术含量并不十分复杂，大家可以`DIY`维修。反观`ToB`，其对产品的售后要求普遍偏高，不仅因为量大，而且因为复杂。所以`ToB`的行业一般都建立完备的客户服务系统，包括产品维修、咨询、投诉等等。
7. **决策体系不同**。`ToC`的决策相对简单，对于是否购买，有时候只需要一个人就能决定，`ToB`的决策流程相对复杂从部门的相互合作，经过`boss`等等，所以需要的时间也相对较长
8. **可拓展性不同**。所谓的可拓展性，指的就是除了一种商品之外，是否还有向其出售更多商品的可行性。这个在流量经济时代尤为重要。基于以上所述的种种差别和特殊属性来看，`ToC`的可拓展性较强，可以实现以点带面，一件极具诱惑力的产品就可能把客户牢牢抓住，比如外卖。这个也是为什么现在很多人看好美团的原因。`ToB`的可拓展性偏弱，只能实现以点带点，面上的横向拓展难度很大，纵向产业链还有些可能。

### 三、陷阱

个人客户是 ToC 的范畴，但是机构客户就一定属于 ToB 么？其实未必。很多你所谓的 B 端客户，其实只能算作是大 C 客户！（包括一部分中小型企业）


