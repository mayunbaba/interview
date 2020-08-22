### 1、计算属性和普通属性的区别

**区别**

computed属性是vue的计算属性，是数据层到视图层的数据转化映射；

计算属性是基于他们的依赖进行缓存的，只有在相关依赖发生改变时，他们才会重新求值，也就是说，只要他的依赖没有发生变化，那么每次访问的时候计算属性都会立即返回之前的计算结果，不再执行函数；

- computed是响应式的，methods并非响应式。
- 调用方式不一样，computed定义的成员像属性一样访问，methods定义的成员必须以函数形式调用。
- computed是带缓存的，只有依赖数据发生改变，才会重新进行计算，而methods里的函数在每次调用时都要执行。
- computed中的成员可以只定义一个函数作为只读属性，也可以定义get/set变成可读写属性，这点是methods中的成员做不到的
- computed不支持异步，当computed内有异步操作时无效，无法监听数据的变化

> 如果声明的计算属性计算量非常大的时候，而且访问量次数非常多，改变的时机却很小，那就需要用到computed；缓存会让我们减少很多计算量




### 2、按要求完成题目
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


### 3、Vue 双向绑定原理

#### 1.原理

![vm](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-726-model.png)

View的变化能实时让Model发生变化，而Model的变化也能实时更新到View。

Vue采用数据劫持&发布-订阅模式的方式，通过ES5提供的 Object.defineProperty() 方法来劫持（监控）各属性的 getter 、setter ，并在数据（对象）发生变动时通知订阅者，触发相应的监听回调。并且，由于是在不同的数据上触发同步，可以精确的将变更发送给绑定的视图，而不是对所有的数据都执行一次检测。要实现Vue中的双向数据绑定，大致可以划分三个模块：Observer、Compile、Watcher，如图：

![model](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-726-define.png)

- **Observer 数据监听器**,负责对数据对象的所有属性进行监听（数据劫持），监听到数据发生变化后通知订阅者。
- **Compiler 指令解析器**，扫描模板，并对指令进行解析，然后绑定指定事件。
- **Watcher 订阅者**，关联Observer和Compile，能够订阅并收到属性变动的通知，执行指令绑定的相应操作，更新视图。Update()是它自身的一个方法，用于执行Compile中绑定的回调，更新视图。

模板渲染解析时watcher会对应绑定指令(一对一)。

此时会通过调用订阅者watcher初始化(watcher中get()方法)去触发对应属性在发布者observer里 (object.defineProperty)的getter,observer会判断是不是通过watcher初始化调用的（Dep.target,实例化之后会清空），只有是才会通过dep类 依赖收集。

observer通过depend通知Dep类收集(addDep方法，在watcher类中，会传入当前Dep实例调用自身)当前该订阅者(watcher)中的触发更新的 方法，同时第一次初始化watcher.update()初始化视图。此后每次的数据更新都会通过observer中的setter去触发dep类中的回调update执行收集依赖 的所有方法更新订阅者中的状态同时更新视图。

observer在处理对象和数组的时候，如果是数组，并且调用的方法会改变数组长度，则会重新增加索引之后更 新数组，进行重新监听。(因为调用数组原生APi可能多次触发getter setter 且索引不会变)，如果是对象则通过对象的getter获取值和setter更新值.


#### 2.版本比较

vue是基于依赖收集的双向绑定；

3.0之前的版本使用 Object.defineProperty，3.0新版使用 Proxy

**1）基于 数据劫持/依赖收集 的双向绑定的优点**

- 不需要显示的调用，Vue 利用数据劫持+发布订阅，可以直接通知变化并且驱动视图
- 直接得到精确的变化数据，劫持了属性setter，当属性值改变我们可以精确的获取变化的内容 newVal，不需要额外的 diff 操作

**2）object.defineProperty的缺点**

- 不能监听数组；因为数组没有getter和setter，因为数组长度不确定，如果太长性能负担太大。
- 只能监听属性，而不是整个对象；需要遍历属性；
- 只能监听属性变化，不能监听属性的删减；

**3）proxy好处**

- 可以监听数组；
- 监听整个对象不是属性；
- 13种拦截方法，强大很多；
- 返回新对象而不是直接修改原对象，更符合immutable；

**4）proxy缺点**

- 兼容性不好，且无法用polyfill磨平；



### 4、描述下自定义指令(你是怎么用自定义指令的)

### 自定义指令

在 Vue2.0 中，代码复用和抽象的主要形式是组件。然而，有的情况下，你仍然需要对普通 DOM 元素进行底层操作，这时候就会用到自定义指令。

一般需要对DOM元素进行底层操作时使用，尽量只用来操作DOM展示，不修改内部的值。当使用自定义指令直接修改value值时绑定v-model的值也不会同步更新；如必须修改可以在自定义指令中使用keydown事件，在vue组件中使用change事件，回调中修改vue数据；


**1.自定义指令基本内容**

- 全局定义：Vue.directive("focus",{})
- 局部定义：directives:{focus:{}}
- 钩子函数：指令定义对象提供钩子函数
    - `bind`：只调用一次，指令第一次绑定到元素时调用。在这里可以进行一次性的初始化设置。
    - `inserted`：被绑定元素插入父节点时调用（仅保证父节点存在，但不一定已被插入文档中）。
    - `update`：所在组件的VNode更新时调用，**但是可能发生在其子VNode更新之前调用**。指令的值可能发生了改变，也可能没有。但是你可以通过比较更新前后的值来忽略不必要的模板更新。
    - `componentUpdate`：指令所在组件的VNode及其子VNode全部更新后调用。
    - `unbind`：只调用一次，指令与元素解绑时调用。
- 钩子函数参数
  - el：绑定元素
  - bing：指令核心对象，描述指令全部信息属性
    - name
    - value
    - oldValue
    - expression
    - arg
    - modifers
  - vnode：虚拟节点
  - oldVnode：上一个虚拟节点（更新钩子函数中才有用）

**2.使用场景**

- 普通DOM元素进行**底层操作**的时候，可以使用自定义指令
- 自定义指令是用来操作DOM的。尽管Vue推崇数据驱动视图的理念，但并非所有情况都适合数据驱动。自定义指令就是一种有效的补充和扩展，不仅可用于定义任何的DOM操作，并且是可复用的。

**3.使用案例**

初级应用：

- 鼠标聚焦
- 下拉菜单
- 相对时间转换
- 滚动动画

高级应用：

- 自定义指令实现图片懒加载
- 自定义指令集成第三方插件



### 5、Vuex 和 localStorage 的区别

### 区别

#### 1.最重要的区别

- vuex存储在内存
- localstorage则以文件的方式存储在本地，localstorage只能存储

> localstorage只能存储字符串类型的数据，存储对象需要JSON的stringify和parse方法进行处理。
> 读取内存比读取硬盘速度要快

#### 2.应用场景

- Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。它采用集中式存储管理应用的所有组件的状态， 并以相应的规则保证状态以一种可预测的方式发生变化。vuex用于组件之间的传值。
- localstorage是本地存储，是将数据存储到浏览器的方法，一般是在跨页面传递数据时使用。
- vuex能做到数据的响应式，localstorage不能

#### 3.永久性

- 刷新页面时vuex存储的值会丢失，localstorage不会。

> 注：很多同学觉得用localstorage可以代替vuex, 对于不变的数据确实可以，但是当两个组件共用一个数据源（对象或数组）时，如果其中一个组件改变了该数据源，希望另一个组件响应该变化时，localstorage无法做到，原因就是区别1。

### 6、说一下路由钩子在 Vue 生命周期的体现？

### 一、Vue-Router导航守卫

有的时候，我们需要通过路由来进行一些操作，比如最常见的登录权限验证，当用户满足条件时，才让其进入导航，否则就取消跳转，并跳到登录页面让其登录。

为此我们有很多种方法可以植入路由的导航过程：全局的, 单个路由独享的, 或者组件级的

#### 1.全局路由钩子

vue-router全局有三个路由钩子：

- router.beforeEach 全局前置守卫 进入路由之前
- router.beforeResolve 全局解析守卫(2.5.0+) 在beforeRouteEnter调用之后调用
- router.afterEach 全局后置钩子 进入路由之后

具体使用：

- beforeEach （判断是否登录了，没登录就跳转到登录页）

```js
router.beforeEach((to, from, next) => {  
    let ifInfo = Vue.prototype.$common.getSession('userData');  // 判断是否登录的存储信息
    if (!ifInfo) { 
        // sessionStorage里没有储存user信息    
        if (to.path == '/') { 
            //如果是登录页面路径，就直接next()      
            next();    
        } else { 
            //不然就跳转到登录      
            Message.warning("请重新登录！");     
            window.location.href = Vue.prototype.$loginUrl;    
        }  
    } else {    
        return next();  
    }
})
```

- afterEach（跳转之后滚动条返回顶部）

```js
router.afterEach((to, from) => {  
    // 跳转之后滚动条回到顶部  
    window.scrollTo(0,0);
});
```

#### 2.单个路由独享钩子

**beforeEnter**

如果你不想全局配置守卫的话，你可以为某些路由单独配置守卫

有三个参数：to、from、next

```js
export default [    
    {        
        path: '/',        
        name: 'login',        
        component: login,        
        beforeEnter: (to, from, next) => {          
            console.log('即将进入登录页面')          
            next()        
        }    
    }
]
```

#### 3.组件内钩子

**beforeRouteEnter、beforeRouteUpdate、beforeRouteLeave**

这三个钩子都有三个参数：to、from、next

- beforeRouteEnter：进入组件前触发
- beforeRouteUpdate：当前地址改变并且改组件被复用时触发，举例来说，带有动态参数的路径foo/:id，在 /foo/1 和 /foo/2 之间跳转的时候，由于会渲染同样的foo组件，这个钩子在这种情况下就会被调用
- beforeRouteLeave：离开组件被调用

注意点，beforeRouteEnter组件内还访问不到this，因为该守卫执行前组件实例还没有被创建，需要传一个回调给next来访问，例如

```js
beforeRouteEnter(to, from, next) {      
    next(target => {        
        if (from.path == '/classProcess') {          
            target.isFromProcess = true        
        }      
    })    
}
```

beforeRouteUpdate和beforeRouteLeave可以访问组件实例this


### 二、完整的路由导航解析流程(不包括其他生命周期)

- 触发进入其他路由。
- 调用要离开路由的组件守卫beforeRouteLeave
- 调用局前置守卫：beforeEach
- 在重用的组件里调用 beforeRouteUpdate
- 调用路由独享守卫 beforeEnter。
- 解析异步路由组件。
- 在将要进入的路由组件中调用beforeRouteEnter
- 调用全局解析守卫 beforeResolve
- 导航被确认。
- 调用全局后置钩子的 afterEach 钩子。
- 触发DOM更新(mounted)。
- 执行beforeRouteEnter 守卫中传给 next 的回调函数

### 二、Vue路由钩子在生命周期函数的体现

#### 1.完整的路由导航解析流程(不包括其他生命周期)

- 触发进入其他路由。
- 调用要离开路由的组件守卫beforeRouteLeave
- 调用局前置守卫：beforeEach
- 在重用的组件里调用 beforeRouteUpdate
- 调用路由独享守卫 beforeEnter。
- 解析异步路由组件。
- 在将要进入的路由组件中调用beforeRouteEnter
- 调用全局解析守卫 beforeResolve
- 导航被确认。
- 调用全局后置钩子的 afterEach 钩子。
- 触发DOM更新(mounted)。
- 执行beforeRouteEnter 守卫中传给 next 的回调函数

#### 2.触发钩子的完整顺序

路由导航、keep-alive、和组件生命周期钩子结合起来的，触发顺序，假设是从a组件离开，第一次进入b组件：

- beforeRouteLeave:路由组件的组件离开路由前钩子，可取消路由离开。
- beforeEach: 路由全局前置守卫，可用于登录验证、全局路由loading等。
- beforeEnter: 路由独享守卫
- beforeRouteEnter: 路由组件的组件进入路由前钩子。
- beforeResolve:路由全局解析守卫
- afterEach:路由全局后置钩子
- beforeCreate:组件生命周期，不能访问this。
- created:组件生命周期，可以访问this，不能访问dom。
- beforeMount:组件生命周期
- deactivated: 离开缓存组件a，或者触发a的beforeDestroy和destroyed组件销毁钩子。
- mounted:访问/操作dom。
- activated:进入缓存组件，进入a的嵌套子组件(如果有的话)。
- 执行beforeRouteEnter回调函数next。


#### 3.导航行为被触发到导航完成的整个过程

- 导航行为被触发，此时导航未被确认。
- 在失活的组件里调用离开守卫 beforeRouteLeave。
- 调用全局的 beforeEach 守卫。
- 在重用的组件里调用 beforeRouteUpdate 守卫 (2.2+)。
- 在路由配置里调用 beforeEnter。
- 解析异步路由组件（如果有）。
- 在被激活的组件里调用 beforeRouteEnter。
- 调用全局的 beforeResolve 守卫 (2.5+)，标示解析阶段完成。
- 导航被确认。
- 调用全局的 afterEach 钩子。
- 非重用组件，开始组件实例的生命周期
  - beforeCreate&created
  - beforeMount&mounted
- 触发 DOM 更新。
- 用创建好的实例调用 beforeRouteEnter 守卫中传给 next 的回调函数。
- 导航完成




### 7、说一下 Vue 中所有带\$的方法



### 8、Vue-router 除了 router-link 怎么实现跳转



### 9、Vue 子组件和父组件执行顺序

#### 加载渲染过程

1. 父组件 beforeCreate
2. 父组件 created
3. 父组件 beforeMount
4. 子组件 beforeCreate
5. 子组件 created
6. 子组件 beforeMount
7. 子组件 mounted
8. 父组件 mounted

#### 更新过程

1. 父组件 beforeUpdate
2. 子组件 beforeUpdate
3. 子组件 updated
4. 父组件 updated

#### 销毁过程

1. 父组件 beforeDestroy
2. 子组件 beforeDestroy
3. 子组件 destroyed
4. 父组件 destoryed

### 10、怎么定义 vue-router 的动态路由？怎么获取传过来的动态参数？

### 实现方式

#### 1.param方式

- 配置路由格式:/router/:id
- 传递的方式:在path后面跟上对应的值
- 传递后形成的路径:/router/123

**1）路由定义**

```js
//在APP.vue中
<router-link :to="'/user/'+userId" replace>用户</router-link>    
 
//在index.js
{
   path: '/user/:userid',
   component: User,
},
```

**2）路由跳转**

```js
// 方法1：
<router-link :to="{ name: 'users', params: { uname: wade }}">按钮</router-link

// 方法2：
this.$router.push({name:'users',params:{uname:wade}})

// 方法3：
this.$router.push('/user/' + wade)
```

**3）参数获取**

通过 `$route.params.userid` 获取传递的值

#### 2.query方式

- 配置路由格式:/router,也就是普通配置
- 传递的方式:对象中使用query的key作为传递方式
- 传递后形成的路径:/route?id=123

**1）路由定义**

```html
//方式1：直接在router-link 标签上以对象的形式
<router-link :to="{path:'/profile',query:{name:'why',age:28,height:188}}">档案</router-link>

// 方式2：写成按钮以点击事件形式

<button @click='profileClick'>我的</button>    

profileClick(){
  this.$router.push({
    path: "/profile",
    query: {
        name: "kobi",
        age: "28",
        height: 198
    }
  });
}
```

**2）跳转方法**

```js
// 方法1：
<router-link :to="{ name: 'users', query: { uname: james }}">按钮</router-link>

// 方法2：
this.$router.push({ name: 'users', query:{ uname:james }})

// 方法3：
<router-link :to="{ path: '/user', query: { uname:james }}">按钮</router-link>

// 方法4：
this.$router.push({ path: '/user', query:{ uname:james }})

// 方法5：
this.$router.push('/user?uname=' + jsmes)
```

**3）获取参数**

```js
通过$route.query 获取传递的值
```

### 11、Vue data 中某一个属性的值发生改变后，视图会立即同步执行重新渲染吗？

### 一、答案解析

**不会**

Vue 实现响应式并不是数据发⽣变化之后 DOM ⽴即变化，⽽是按⼀定的策略进⾏ DOM 的更新。

Vue 在更新 DOM 时是**异步执行**的。只要侦听到数据变化，Vue 将开启一个队列，并缓冲在同一事件循环中发生的所有数据变更。

如果同一个watcher被多次触发，只会被推入到队列中一次。这种在缓冲时去除重复数据对于避免不必要的计算和 DOM 操作是非常重要的。

然后，在下一个的事件循环“tick”中，Vue 刷新队列并执行实际 (已去重的) 工作。

### 二、异步执⾏的运⾏机制

1. 所有同步任务都在主线程上执⾏，形成⼀个执⾏栈（execution context stack）。
2. 主线程之外，还存在⼀个"任务队列"（task queue）。只要异步任务有了运⾏结果，就在"任务队列"之中放置⼀个事件。
3. ⼀旦"执⾏栈"中的所有同步任务执⾏完毕，系统就会读取"任务队列"，看看⾥⾯有哪些事件。那些对应的异步任务，于是结束等待状 态，进⼊执⾏栈，开始执⾏。
4. 主线程不断重复上⾯的第三步

![任务队列](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-640-task.png)

#### 事件循环说明

简单来说，Vue 在修改数据后，视图不会⽴刻更新，⽽是等同⼀事件循环中的所有数据变化完成之后，再统⼀进⾏视图更新。

```js
// 改变数据
vm.message = "changed";

// 想要立即使用更新后的dom,这样不行，因为设置message后dom还没更新。
console.log(vm.$el.textConteng);// 并不会得到changed

// 这样可以，nextTck里面的代码会在dom更新后执行
Vue.nextTick(function(){
    console.log(vm.$el.textConteng); // 可以得到changed
})
```

![事件循环](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-640-domrender.png)

#### 事件循环：

**1）第⼀个 tick**

图例中第⼀个步骤，即'本次更新循环'

⾸先修改数据，这是同步任务。同⼀事件循环的所有的同步任务都在主线程上执⾏，形成⼀个执⾏栈，此时还未涉及 DOM 。

Vue 开启⼀个异步队列，并缓冲在此事件循环中发⽣的所有数据改变。如果同⼀个 watcher 被多次触发，只会被推⼊到队列中⼀次。

**2）第二个tick**

图例中第⼆个步骤，即'下次更新循环'

同步任务执⾏完毕，开始执⾏异步 watcher 队列的任务，更新 DOM 。Vue 在内部尝试对异步队列使⽤原⽣的 Promise.then 和 MessageChannel ⽅法，如果执⾏环境不⽀持，会采⽤ setTimeout(fn, 0) 代替。

**3）第三个tick**

此时就是⽂档所说的下次DOM更新循环结束之后

此时通过Vue.nextTick获取到改变后的DOM。通过setTimeout(fn,0)也可以同样获取到。

#### 总结

同步代码执⾏ -> 查找异步队列，推⼊执⾏栈，执⾏Vue.nextTick[事件循环1] ->查找异步队列，推⼊执⾏栈，执⾏Vue.nextTick[事件循环2]...

总之，异步是单独的⼀个tick，不会和同步在⼀个 tick ⾥发⽣，也是 DOM 不会⻢上改变的原因。

### 三、更新原理解读

![render](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-640-render.png)

1. 当我们把对象传入 Vue 实例作为 data 选项，Vue 会遍历此对象所有的 property，并使用 Object.defineProperty 把这些 property 全部转为 getter/setter。

2. 每个组件实例都对应一个 watcher 实例，它会在组件渲染的过程中把“接触”过的数据 property 记录为依赖。

3. 当 data 的某一个值发生改变之后，就会触发实例 setter，同时通知 watcher，使它关联的组件重新渲染视图。

#### 1.简易原理

```js
// 数据变化渲染视图
function renderView() {
  console.log("render view");
}
// 数据劫持
function defineReactive(target, key, value) {
  observe(value);
  Object.defineProperty(target, key, {
    get() {
      return value;
    },
    set(newVal) {
      if (newVal !== value) {
        observe(newVal);
        value = newVal;
        // 触发视图更新
        renderView();
      }
    },
  });
}
function observe(target) {
  // 不是对象直接返回
  if (typeof target !== "object" || target === null) {
    return target;
  }
  // 递归遍历对象，数据劫持
  for (let key in target) {
    defineReactive(target, key, target[key]);
  }
}
let data = { name: "小王" };
const reactiveData = observe(data);
data.name = "老王";
// render view
```

#### 2.对于数组，Vue 是可以对数组进行更新的

重写了数组的方法，下面是简易版：

```js
const prototype = Array.prototype;
const newProto = Object.create(prototype);
const methods = [
  "push",
  "pop",
  "shift",
  "unshift",
  "splice",
  "sort",
  "reverse",
];
methods.forEach((method) => {
  newProto[method] = () => {
    newProto[method].call(this, ...args);
    renderView();
  };
});
```

#### 3.Object.defineProperty 存在的问题

1. 无法对原生数组进行更新
2. 对象嵌套是，递归消耗部分性能
3. 无法对新添加的属性进行监听

#### 4.Proxy

```js
function defineReactive(target) {
  if (typeof target !== "object" || target == null) {
    return target;
  }
  const handler = {
    get(target, property, receiver) {
      return Reflect.get(target, property, receiver);
    },
    set(target, property, value) {
      if (val !== target[property]) {
        renderView();
      }
      return Reflect.set(target, property, value);
    },
  };
  return new Proxy(target, handler);
}

// 数据响应式监听
const reactiveData = defineReactive(data)
```

**proxy解决的问题**

- Proxy支持监听原生数组
- Proxy的获取数据，只会递归到需要获取的层级，不会继续递归
- 可对新添加的属性监听




### 12、简述 mixin、extends 的覆盖逻辑

### 一、mixin 和 extends

mixin 和 extends均是用于合并、拓展组件的，两者均通过 `mergeOptions` 方法实现合并。

`mixins` 接收一个混入对象的数组，其中混入对象可以像正常的实例对象一样包含实例选项，这些选项会被合并到最终的选项中。Mixin 钩子按照传入顺序依次调用，并在调用组件自身的钩子之前被调用。

`extends` 主要是为了便于扩展单文件组件，接收一个对象或构造函数。

![总结](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-644-mix.jpg)

### 二、mergeOptions 的执行过程

1. 规范化选项（normalizeProps、normalizeInject、normalizeDirectives）

2. 对未合并的选项，进行判断

    ```js
    if(!child._base) {
        if(child.extends) {
            parent = mergeOptions(parent, child.extends, vm)
        }
        if(child.mixins) {
            for(let i = 0, l = child.mixins.length; i < l; i++){
                parent = mergeOptions(parent, child.mixins[i], vm)
            }
        }
    }
    ```

3. 合并处理。根据一个通用 Vue 实例所包含的选项进行分类逐一判断合并，如 props、data、methods、watch、computed、生命周期等，将合并结果存储在新定义的 options 对象里。

4. 返回合并结果 options。

### 三、代码演示

- 用赋值的方式将 mixins 对象里的方法都挂载到原对象上，就实现了对对象的混入。

```js
const mixin = function(obj, mixins) {
  const newObj = obj;
  newObj.prototype = Object.create(obj.prototype);
  for (let prop in mixins) {
    if (mixins.hasOwnProperty(prop)) {
      newObj.prototype[prop] = mixins[prop];
    }
  }
  return newObj;
}
const BigMixin = {
  fly: () => {
    console.log('I can fly');
  }
};
const Big = function() {
  console.log('new big');
};
const FlyBig = mixin(Big, BigMixin);
const flyBig = new FlyBig(); // 'new big'
flyBig.fly(); // 'I can fly'


function extends(subClass, superClass) {
   // 创建一个__proto__ 指向超类的原型的实例
   const instance  = Object.create(superClass.prototype);
   // 将实例的原型的构造器指向子类(主要用于继承子类的实例属性)
   instance.constructor = subClass;
   // 将实例赋值给子类的原型,这里主要是为了获取到父类的原型;
   subClass.prototype = instance;
}
```




### 13、vue hooks 有哪些

### Vue Hooks  当我们需要在两个组件之间共享行为的场景,我们通常使用mixin。不过随着hooks的出现，现在又有另一种可选方案，我们可以使用custom hook 复用业务逻辑。同时可以拿到暴露出来的render方法, 只需要在withHooks的方法中传入一个函数参数即可。我们不需要关心函数内部this的指向，但却依旧可以使用state,以及life-cycle。 使用函数的方式去实现一个组件（并不是functional component），这种方式会让组件的实现变得更加灵活。但是前提条件是需要我们使用render函数代替template模板。  vue hooks提供了三种类型的hooks  - state hooks - effect hooks - custom hooks  **注意:** 钩子只能在传递给withHooks的函数中调用或者在hooks方法内部调用。  #### 1.withHooks  hooks 是在传递给withHooks的函数中调用的  ```js const Foo = withHooks(h => {   // state   const [count, setCount] = useState(0)    // effect   useEffect(() => {     document.title = "count is " + count   })    return h("div", [     h("span", `count is: ${count}`),     h(       "button",       {         on: {           click: () => setCount(count + 1)         }       },       "+"     ),   ]) }) ```  withHooks是一个高阶函数，传入一个函数，这个函数内部返回一个vnode， withHooks 方法返回的是一个vue的选项对象。  ```js Foo = {   created() {},   data() {},   render () {} }; ```  这个选项对象可以直接调用Vue.component 方法生成全局组件，或者在render 方法中生成vnode  ```js Vue.component('v-foo', Foo);  // or render(h) {     return h("div", [h(Foo), h(Foo)]) } ```  #### 2.state hooks  关于状态类的hooks 有三个，useState 和 useData、useComputed，  ```js const data = useData({     count: 0   })  const double = useComputed(() => data.count * 2)  const [count, setCount] = useState(0) ```  useState 可以看成useData和change data的结合，执行后返回一个数组，数组的第一项是状态state，第二个项是change state 的方法updater、useComputed 传入一个方法，该方法返回一个基于当前状态的衍生，与computed 一致。  #### 3.effect hooks  useEffect 用于添加组件状态更新后，需要执行的副作用逻辑。  useEffect 指定的副作用逻辑，会在组件挂载后执行一次、在每次组件渲染后根据指定的依赖有选择地执行、并在组件卸载时执行清理逻辑(如果指定了的话)。  ```js import { withHooks, useState, useEffect } from "vue-hooks"  const Foo = withHooks(h => {   const [count, setCount] = useState(0)   useEffect(() => {     document.title = "count is " + count   })   return h("div", [     h("span", `count is: ${count}`),     h("button", { on: { click: () => setCount(count + 1) } }, "+" )   ]) }) ```  代码中，通过 useEffect 使每当 count 的状态值变化时，都会重置 document.title。  **注意:** 这里没有指定 useEffect 的第二个参数 deps，表示只要组件重新渲染都会执行 useEffect 指定的逻辑，不限制必须是 count 变化时。  #### 4.custom hooks  ```js // a custom hook that sync with window width function useWindowWidth() {   const [width, setWidth] = useState(window.innerWidth)   const handleResize = () => {     setWidth(window.innerWidth)   };   useEffect(() => {     window.addEventListener("resize", handleResize)     return () => {       window.removeEventListener("resize", handleResize)     }   }, [])   return width }  // custom hook const width = useWindowWidth() ```  如果把useState和useEffect用单独的函数抽离出来，当作通用的方法，其实就是custom hooks、本质就是复用代码的逻辑而已。

### 14、介绍单页应用和多页应用？



### 15、下面关于 Vue 说法正确的是？(单选题)
```js
A.data 中某一属性的值发生改变后，视图会立即同步进行重新渲染
B.Vue 实例创建后再添加的属性，该属性改动将不会触发视图更新
C.计算属性只有在它的相关依赖发生改变时才会重新求值
D.Vue 组件的 data 选项必须是函数

```



### 16、为什么 Vue data 必须是函数



### 17、介绍 Vue template 到 render 的过程


### 过程分析

vue的模版编译过程主要如下: **template->ast->render函数**

vue在模版编译版本的源码中会执行 `compileToFunctions`将template转化为render函数

```js
// 将模板编译为render函数
const { render, staticRenderFns } = compileToFunctions(template,optinos//省略}, this)
```

compileToFunctions中的主要逻辑如下:

#### 1.调用parse方法将template转化为ast(抽象语法树)

`const ast = parse(template.trim(), options)`

**parse的目标:** 是把tamplate转换为AST树，它是一种用JavaScript对象的形式来描述整个模板。

**解析过程:** 利用正则表达式顺序解析模板，当解析到开始标签、闭合标签、文本的时候都会分别执行对应的 回调函数，来达到构造AST树的目的。

AST元素节点总共三种类型：type为1表示普通元素、2位表达式、3为纯文本

#### 2.对静态节点做优化

`optimize(ast, options)`

这个过程主要分析出哪些是静态节点，给其打一个标记，为后续更新渲染可以直接跳过静态节点做优化

**深度遍历AST**，查看每个子树的节点元素是否为静态节点或者静态节点根。如果为静态节点，他们生成的DOM永远不会改变，这对运行时模板更新起到了极大的优化作用。

#### 3.生成代码

`const code = generate(ast, options)`

generate将ast抽象语法树编译成`render字符串`并将静态部分放到staticRenderFns中，最后通过 `new Function(render)` 生成render函数。






### 18、为什么要用 Vuex 或者 Redux，不要说为了保存状态


### 为什么要用 Vuex 或者 Redux

由于传参的方法对于多层嵌套的组件将会非常繁琐，并且对于兄弟组件间的状态传递无能为力。我们经常会采用父子组件直接引用或者通过事件来变更和同步状态的多份拷贝。以上的这些模式非常脆弱，通常会导致代码无法维护。

所以我们需要把组件的共享状态抽取出来，以一个全局单例模式管理。在这种模式下，我们的组件树构成了一个巨大的“视图”，不管在树的哪个位置，任何组件都能获取状态或者触发行为！

另外，通过定义和隔离状态管理中的各种概念并强制遵守一定的规则，我们的代码将会变得更结构化且易维护。

### 19、子组件可以直接改变父组件的数据么，说明原因

### 答案

不可以

### 解析

**主要是为了维护父子组件的单向数据流。**

每次父级组件发生更新时，子组件中所有的 prop 都将会刷新为最新的值。

如果这样做了，Vue 会在浏览器的控制台中发出警告。

Vue提倡单向数据流,即父级 props 的更新会流向子组件,但是反过来则不行。这是为了防止意外的改变父组件状态，使得应用的数据流变得难以理解，导致数据流混乱。如果破坏了单向数据流，当应用复杂时，debug 的成本会非常高。

**只能通过 $emit 派发一个自定义事件，父组件接收到后，由父组件修改。**

### 20、对虚拟 DOM 的理解？虚拟 DOM 主要做了什么？虚拟 DOM 本身是什么？

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




### 21、Vue 中一次性 200 条弹幕怎么处理



### 22、说一下对 vue3.0 的了解，vue3.0 为什么要用代理


### 一、Vue3

#### 1.Vue 3 重写了多种机制

主要是基于：

1. 主流浏览器对新的 JavaScript 语言特性的普遍支持。
2. 当前Vue代码库随着时间的推移而暴露出来的设计和体系架构问题。

#### 2.Vue 3 较 2 做了很多优化

1. **重写 VDOM 机制:** 通过编译时的标记优化运行时的速度。
2. **优化插槽（slot）生成:** 原来的实现，父组件重渲染时子组件也必须同时重渲染，而在 3 中子组件提取函数，可以分别渲染。
3. **静态树提升:** 没有响应式绑定的部分被提取出来作为常量，用到的时候不用再次执行它的渲染函数。
4. **静态属性提升:** 没有响应式绑定的组件属性（props）被提取出来作为常量，用到的时候不用再进行创建。
5. **项目结构优化:** 内部解耦，更好维护，支持了细粒度的 tree-shaking 如可选的生命周期。

#### 3.Object.defineProperty与Proxy

在 Vue2 中，`Object.defineProperty` 会改变原始数据，而 `Proxy` 是创建对象的虚拟表示，并提供 `set`、`get` 和 `deleteProperty` 等处理器，这些处理器可在访问或修改原始对象上的属性时进行拦截，有以下特点：

1. 不需用使用 `Vue.$set` 或 `Vue.$delete` 触发响应式。
2. 全方位的数组变化检测，消除了 Vue2 无效的边界情况。
3. 支持 `Map`，`Set`，`WeakMap` 和 `WeakSet`。

Proxy 实现的响应式原理与 Vue2 的实现原理相同，实现方式大同小异：

- get 收集依赖
- set、delete 等触发依赖
- 对于集合类型，就是对集合对象的方法做一层包装：原方法执行后执行依赖相关的收集或触发逻辑。

### 23、简述 Vue 的生命周期以及每个阶段做的事

### 生命周期

- **beforeCreate（创建前）** 在数据观测和初始化事件还未开始
- **created（创建后）** 完成数据观测，属性和方法的运算，初始化事件，$el属性还没有显示出来
- **beforeMounted(挂载前)** 在挂载开始之前被调用，相关的render函数首次被调用。实例已完成以下的配置：编译模板，把data里面的数据和模板生成html。此时还没有挂载html到页面上。
- **mounted（挂载后)** 在el被新创建的 vm.$el 替换，并挂载到实例上去之后调用。实例已完成以下的配置：用上面编译好的html内容替换el属性指向的DOM对象。完成模板中的html渲染到html   页面中。此过程中进行ajax交互。
- **beforeUpdate（更新前）** 在数据更新之前调用，发生在虚拟DOM重新渲染和打补丁之前。可以在该钩子中进一步地更改状态，不会触发附加的重渲染过程。
- **updated（更新后）** 在由于数据更改导致的虚拟DOM重新渲染和打补丁之后调用。调用时，组件DOM已经更新，所以可以执行依赖于DOM的操作。然而在大多数情况下，应该避免在此期间更改状态，   因为这可能会导致更新无限循环。该钩子在服务器端渲染期间不被调用。
- **beforeDestroy（销毁前）** 在实例销毁之前调用。实例仍然完全可用。
- **destroyed（销毁后）** 在实例销毁之后调用。调用后，所有的事件监听器会被移除，所有的子实例也会被销毁。该钩子在服务器端渲染期间不被调用。

### 24、vue 对数组的方法做了重写的操作，如何实现对 vue2 中对数组操作的 push()方法

### 源码实现

重写的方法有

- `push`
- `pop`
- `shift`
- `unshift`
- `splice`
- `sort`
- `reverse`

简单来说,Vue 通过原型拦截的方式重写了数组的 7 个方法,首先获取到这个数组的**ob**,也就是它的 Observer 对象,如果有新的值,就调用 observeArray 对新的值进行监听,然后手动调用 notify,通知 render watcher,执行 update

```js
const arrayProto = Array.prototype;
export const arrayMethods = Object.create(arrayProto);
const methodsToPatch = [  "push",  "pop",  "shift",  "unshift",  "splice",  "sort",  "reverse"];
/** * Intercept mutating methods and emit events */
methodsToPatch.forEach(function(method) {  // cache original method  
  const original = arrayProto[method];  
  def(arrayMethods, method, function mutator(...args) {    
    const result = original.apply(this, args);    
    const ob = this.__ob__;    
    let inserted;    
    switch (method) {      
      case "push":      
      case "unshift":        
        inserted = args;        
        break;      
      case "splice":        
        inserted = args.slice(2);        
        break;    
    }    
    if (inserted) ob.observeArray(inserted);    
    // notify change    
    ob.dep.notify();    
    return result;  
  });
});
/** * Observe a list of Array items. */
Observer.prototype.observeArray = function observeArray(items) {  
  for (var i = 0, l = items.length; i < l; i++) {
    observe(items[i]);  
  }
};
```

### 25、说一下 vue-router 的原理

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

### 26、简述 Vue 的基本原理

### 基本原理

当一个Vue实例创建时，vue会遍历data选项的属性，用 `Object.defineProperty` (vue3.0使用proxy )将它们转为 `getter/setter` 并且在内部追踪相关依赖，在属性被访问和修改时通知变化。 每个组件实例都有相应的watcher程序实例，它会在组件渲染的过程中把属性记录为依赖，之后当依赖项的setter被调用时，会通知watcher重新计算，从而致使它关联的组件得以更新。

![vue](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-217-vue.png)




### 27、说一下 Vue 的\$nextTick 原理

### 一、首先来了解下js的运行机制

> JS 运行机制（Event Loop）

JS 执行是单线程的，它是基于事件循环的。

- 所有同步任务都在主线程上执行，形成一个执行栈。
- 主线程之外，会存在一个任务队列，只要异步任务有了结果，就在任务队列中放置一个事件。
- 当执行栈中的所有同步任务执行完后，就会读取任务队列。那些对应的异步任务，会结束等待状态，进入执行栈。
- 主线程不断重复第三步。

这里主线程的执行过程就是一个 tick，而所有的异步结果都是通过任务队列来调度。Event Loop 分为宏任务和微任务，无论是执行宏任务还是微任务，完成后都会进入到一下 tick，并在两个 tick 之间进行 UI 渲染。

由于 Vue DOM 更新是异步执行的，即修改数据时，视图不会立即更新，而是会监听数据变化，并缓存在同一事件循环中，等同一数据循环中的所有数据变化完成之后，再统一进行视图更新。为了确保得到更新后的 DOM，所以设置了 Vue.nextTick()方法

### 一、什么是 $nextTick

Vue 的核心方法之一，官方文档解释如下： 在下次 DOM 更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，获取更新后的 DOM。

#### 1.MutationObserver

先简单介绍下 MutationObserver：MO 是 HTML5 中的 API，是一个用于监视 DOM 变动的接口，它可以监听一个 DOM 对象上发生的子节点删除、属性修改、文本内容修改等。 调用过程是要先给它绑定回调，得到 MO 实例，这个回调会在 MO 实例监听到变动时触发。这里 MO 的回调是放在 microtask 中执行的。

```js
// 创建MO实例
const observer = new MutationObserver(callback)
const textNode = "想要监听的Don节点"
observer.observe(textNode, {
  characterData: true, // 说明监听文本内容的修改
})
```

#### 2.源码浅析

nextTick 的实现单独有一个 JS 文件来维护它，在 src/core/util/next-tick.js 中。 nextTick 源码主要分为两块：能力检测和根据能力检测以不同方式执行回调队列。

**能力检测**

由于宏任务耗费的时间是大于微任务的，所以在浏览器支持的情况下，优先使用微任务。如果浏览器不支持微任务，再使用宏任务。

```js
// 空函数，可用作函数占位符
import { noop } from "shared/util"

// 错误处理函数
import { handleError } from "./error"

// 是否是IE、IOS、内置函数
import { isIE, isIOS, isNative } from "./env"

// 使用 MicroTask 的标识符，这里是因为火狐在<=53时 无法触发微任务，在modules/events.js文件中引用进行安全排除
export let isUsingMicroTask = false

// 用来存储所有需要执行的回调函数
const callbacks = []

// 用来标志是否正在执行回调函数
let pending = false

// 对callbacks进行遍历，然后执行相应的回调函数
function flushCallbacks() {
  pending = false
  // 这里拷贝的原因是：
  // 有的cb 执行过程中又会往callbacks中加入内容
  // 比如 $nextTick的回调函数里还有$nextTick
  // 后者的应该放到下一轮的nextTick 中执行
  // 所以拷贝一份当前的，遍历执行完当前的即可，避免无休止的执行下去
  const copies = callbcks.slice(0)
  callbacks.length = 0
  for (let i = 0; i < copies.length; i++) {
    copies[i]()
  }
}

let timerFunc // 异步执行函数 用于异步延迟调用 flushCallbacks 函数

// 在2.5中，我们使用(宏)任务(与微任务结合使用)。
// 然而，当状态在重新绘制之前发生变化时，就会出现一些微妙的问题
// (例如#6813,out-in转换)。
// 同样，在事件处理程序中使用(宏)任务会导致一些奇怪的行为
// 因此，我们现在再次在任何地方使用微任务。
// 优先使用 Promise
if (typeof Promise !== "undefined" && isNative(Promise)) {
  const p = Promise.resolve()
  timerFunc = () => {
    p.then(flushCallbacks)

    // IOS 的UIWebView, Promise.then 回调被推入 microTask 队列，但是队列可能不会如期执行
    // 因此，添加一个空计时器强制执行 microTask
    if (isIOS) setTimeout(noop)
  }
  isUsingMicroTask = true
} else if (
  !isIE &&
  typeof MutationObserver !== "undefined" &&
  (isNative(MutationObserver) ||
    MutationObserver.toString === "[object MutationObserverConstructor]")
) {
  // 当 原生Promise 不可用时，使用 原生MutationObserver
  // e.g. PhantomJS, iOS7, Android 4.4

  let counter = 1
  // 创建MO实例，监听到DOM变动后会执行回调flushCallbacks
  const observer = new MutationObserver(flushCallbacks)
  const textNode = document.createTextNode(String(counter))
  observer.observe(textNode, {
    characterData: true, // 设置true 表示观察目标的改变
  })

  // 每次执行timerFunc 都会让文本节点的内容在 0/1之间切换
  // 切换之后将新值复制到 MO 观测的文本节点上
  // 节点内容变化会触发回调
  timerFunc = () => {
    counter = (counter + 1) % 2
    textNode.data = String(counter) // 触发回调
  }
  isUsingMicroTask = true
} else if (typeof setImmediate !== "undefined" && isNative(setImmediate)) {
  timerFunc = () => {
    setImmediate(flushCallbacks)
  }
} else {
  timerFunc = () => {
    setTimeout(flushCallbacks, 0)
  }
}
```

延迟调用优先级如下： Promise > MutationObserver > setImmediate > setTimeout

```js
export function nextTick(cb? Function, ctx: Object) {
    let _resolve
    // cb 回调函数会统一处理压入callbacks数组
    callbacks.push(() => {
        if(cb) {
            try {
                cb.call(ctx)
            } catch(e) {
                handleError(e, ctx, 'nextTick')
            }
        } else if (_resolve) {
            _resolve(ctx)
        }
    })

    // pending 为false 说明本轮事件循环中没有执行过timerFunc()
    if(!pending) {
        pending = true
        timerFunc()
    }

    // 当不传入 cb 参数时，提供一个promise化的调用
    // 如nextTick().then(() => {})
    // 当_resolve执行时，就会跳转到then逻辑中
    if(!cb && typeof Promise !== 'undefined') {
        return new Promise(resolve => {
            _resolve = resolve
        })
    }
}
```

next-tick.js 对外暴露了 nextTick 这一个参数，所以每次调用 Vue.nextTick 时会执行：

- 把传入的回调函数 cb 压入 callbacks 数组
- 执行 timerFunc 函数，延迟调用 flushCallbacks 函数
- 遍历执行 callbacks 数组中的所有函数

这里的 callbacks 没有直接在 nextTick 中执行回调函数的原因是保证在同一个 tick 内多次执行 nextTick，不会开启多个异步任务，而是把这些异步任务都压成一个同步任务，在下一个 tick 执行完毕。

**附加**

noop 的定义如下

```js
/**
 * Perform no operation.
 * Stubbing args to make Flow happy without leaving useless transpiled code
 * with ...rest (https://flow.org/blog/2017/05/07/Strict-Function-Call-Arity/).
 */
export function noop(a?: any, b?: any, c?: any) {}
```


### 二、使用方式 

- 语法：Vue.nextTick([callback, context]) 
- 参数：
  - {Function} [callback]：回调函数，不传时提供 promise 调用
  - {Object} [context]：回调函数执行的上下文环境，不传默认是自动绑定到调用它的实例上。

```js
//改变数据
vm.message = "changed"

//想要立即使用更新后的DOM。这样不行，因为设置message后DOM还没有更新
console.log(vm.$el.textContent) // 并不会得到'changed'

//这样可以，nextTick里面的代码会在DOM更新后执行
Vue.nextTick(function () {
  // DOM 更新了
  //可以得到'changed'
  console.log(vm.$el.textContent)
})

// 作为一个 Promise 使用 即不传回调
Vue.nextTick().then(function () {
  // DOM 更新了
})
```

Vue 实例方法 vm.$nextTick 做了进一步封装，把 context 参数设置成当前 Vue 实例。

使用 Vue.nextTick()是为了可以获取更新后的 DOM 。 触发时机：在同一事件循环中的数据变化后，DOM 完成更新，立即执行 Vue.nextTick()的回调。

> 同一事件循环中的代码执行完毕 -> DOM 更新 -> nextTick callback 触发

三、应用场景

在 Vue 生命周期的 created()钩子函数进行的 DOM 操作一定要放在 Vue.nextTick()的回调函数中。原因：是 created()钩子函数执行时 DOM 其实并未进行渲染。

在数据变化后要执行的某个操作，而这个操作需要使用随数据改变而改变的 DOM 结构的时候，这个操作应该放在 Vue.nextTick()的回调函数中。原因：Vue 异步执行 DOM 更新，只要观察到数据变化，Vue 将开启一个队列，并缓冲在同一事件循环中发生的所有数据改变，如果同一个 watcher 被多次触发，只会被推入到队列中一次。


### 四、总结

- Vue 的 nextTick 其本质是对 JavaScript 执行原理 EventLoop 的一种应用
- nextTick 的核心利用了如 Promise 、 MutationObserver 、 setImmediate 、 setTimeout 的原生 JavaScript 方法来模拟对应的微/宏任务的实现，本质是为了利用 JavaScript 的这些异步回调任务队列来实现 Vue 框架中自己的异步回调队列
- nextTick 不仅是 Vue 内部的异步队列的调用方法，同时也允许开发者在实际项目中使用这个方法来满足实际应用中对 Dom 更新数据时机的后续逻辑处理
- nextTick 是典型的将底层 JavaScript 执行原理应用到具体案例中的示例
- 引入异步更新队列机制的原因：
    - 如果是同步更新，则多次对一个或多个属性赋值，会频繁触发 UI/Dom 的渲染，可以减少一些无用渲染
    - 同时由于 VirtualDOM 的引入，每一次状态发生变化后，状态变化的信号会发送给组件，组件内部使用 VirtualDOM 进行计算得出需要更新的具体的 DOM 节点，然后对 DOM 进行更新操作，每次更新状态后的渲染过程需要更多的计算，而这种无用功也将浪费更多的性能，所以异步渲染变得更加至关重要

### 28、Vue v-model 是如何实现的，语法糖实际是什么

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


### 29、说一下 Vue 单页与多页的区别

### 一、定义

**SPA单页面应用（SinglePage Web Application ）** ，指只有一个主页面的应用，一开始只需要加载一次js、css等相关资源。所有内容都包含在主页面，对每一  个功能模块组件化。单页应用跳转，就是切换相关组件，仅仅刷新局部资源。

**MPA多页面应用 （MultiPage Application）** ,指有多个独立页面的应用，每个页面必须重复加载js、css等相关资源。多页应用跳转，需要整页资源刷新

### 区别

#### 1.刷新方式

- SPA:相关组件切换，页面局部刷新或更改
- MPA:整页刷新

#### 2.路由模式

- SPA：可以使用hash，也可以使用history
- MPA: 普通链接跳转

#### 3.用户体验

- SPA:  页面片段间时间的切换快，用户体验良好,当初次加载文件过多时，需要做相关调优。
- MPA：页面切换加载缓慢，流畅度不够，用户体验比较差，尤其网速慢的时候

#### 4.转场动画

- SPA: 容易实现转场动画
- MPA：无法实现专场动画

#### 5.数据传递

- SPA: 容易实现数据传递，方法有很多（通过路由带参数传值，Vuex传值等等）
- MPA： 依赖url传参，cookie ， 本地存储等

#### 6.搜索引擎优化（SEO）

- SPA: 需要单独方案，实现较为困难，不利于SEO检索，可利用服务器端渲染（SSR）优化
- MPA:实现方法容易  

#### 7.使用范围

- SPA：高要求的体验度、追求界面流畅的应用
- MPA：适用于追求高度支持搜索引擎的应用

#### 8.开发成本

- SPA: 较高，长需要借助专业的框架
- MPA:较低，但也页面代码重复的多

#### 9.维护成本

- SPA：相对容易
- MPA：相对复杂

#### 10.结构

- SPA:一个主页面+许多模块的组件
- MPA:许多完整的页面

#### 11.资源文件

- SPA:组件公用的资源只需要加载一次
- MPA:每个页面都需要自己加载公用的资源


![区别](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-258-spa-map.jpg)



### 30、说一下 Vue3 与 Vue2 的对比

### 一、Vue3 beta 新优势

#### 1.optionsAPI -> composition API

[composition API参考](https://vue-composition-api-rfc.netlify.app)

举个简单的例子

**1）声明变量**

```js
const { reactive } = Vue
var App = {
  template: `
    <div>
         {{message}}
    </div>`,
  setup() {
  	const state = reactive({message: "Hello World!!!"})
	return {
		...state
	}
  }
}
Vue.createApp().mount(App, '#app')
```

**2）双向绑定**

```js
const { reactive } = Vue
let App = {
  template: `
    <div>
        <input v-model="state.value"/>{{state.value}}
    </div>`,
  setup() {
    const state = reactive({ value: '' })
    return { state }
  }
}
Vue.createApp().mount(App, '#app')
```

- setup
  - **被诟病得地方，内容要写在这个地方**。setup 实际上是一个组件的入口，它运行在组件被实例化时候，props 属性被定义之后，实际上等价于 vue2 版本的 beforeCreate 和 Created 这两个生命周期
- reactive
  - 创建一个响应式得状态，几乎等价于 vue2.x 中的 Vue.observable() API，为了避免于 rxjs 中得 observable 混淆进行了重命名

**3）观察属性**

```js
import { reactive, watchEffect } from 'vue'

const state = reactive({
  count: 0,
})

watchEffect(() => {
  document.body.innerHTML = `count is ${state.count}`
})
return {...state}
```

> watchEffect 和 2.x 中的 watch 选项类似，但是它不需要把被依赖的数据源和副作用回调分开。组合式 API 同样提供了一个 watch 函数，其行为和 2.x 的选项完全一致。

**5）ref**

> vue3 允许用户创建单个的响应式对象

```js
const App = {
  template: `
      <div>
        {{value}}
      </div>`,
  setup() {
    const value = ref(0)
    return { value }
  }
}
Vue.createApp().mount(App, '#app')
```

**6）计算属性**

```js
setup() {
  const state = reactive({
    count: 0,
    double: computed(() => state.count * 2),
   })

  function increment() {
    state.count++
  }

  return {
    state,
    increment,
  }
},
```

**7）生命周期的变更**

![lifcycle](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-199-vue3lifcycle.png)

生命周期使用举例：

```js
import { onMounted } from 'vue'

export default {
  setup() {
    onMounted(() => {
      console.log('component is mounted!')
    })
  },
}
```

#### 2.performance 优化

- 重构了虚拟 DOM，保持兼容性，使 dom 脱离模板渲染，提升性能
- 优化了模板编译过程，增加 patchFlag，遍历节点的时候，会跳过静态节点
- 高效的组件初始化
- 组件 upload 的过程性能提升 1.3~2 倍
- SSR 速度提升 2~3 倍

**vue3.0如何实现的 domdiff和vDOM的优化**

**1）编译模板的静态标记**

举例：

```html
<div id="app">
    <p>周一呢</p>
    <p>明天就周二了</p>
    <div>{{week}}</div>
</div>
```

在vue2会被解析成一下代码

```js
function render() {
  with(this) {
    return _c('div', {
      attrs: {
        "id": "app"
      }
    }, [_c('p', [_v("周一呢")]), _c('p', [_v("明天就周二了")]), _c('div', [_v(
      _s(week))])])
  }
}
```

可以看出，两个`p`标签是完全静态的，以至于在后续的渲染中，其实没有任何变化的，但是在`vue2.x`中依然会使用`_c`新建成一个vdom，在`diff`的时候仍然需要去比较，这样就造成了一定量的性能消耗

在vue3中

```js
import { createVNode as _createVNode, toDisplayString as _toDisplayString, openBlock as _openBlock, createBlock as _createBlock } from "vue"

export function render(_ctx, _cache) {
  return (_openBlock(), _createBlock("div", { id: "app" }, [
    _createVNode("p", null, "周一呢"),
    _createVNode("p", null, "明天就周二了"),
    _createVNode("div", null, _toDisplayString(_ctx.week), 1 /* TEXT */)
  ]))
}

```

只有当`_createVNode`的第四个参数不为空的时候，这时，才会被遍历，而静态节点就不会被遍历到

同时发现了在`vue3`最后一个非静态的节点编译后：出现了`/* TEXT */`，这是为了标记当前内容的类型以便进行`diff`，如果不同的标记，只需要去比较对比相同的类型。这就不会去浪费时间对其他类型进行遍历了

```js
export const enum PatchFlags {
  
  TEXT = 1,// 表示具有动态textContent的元素
  CLASS = 1 << 1,  // 表示有动态Class的元素
  STYLE = 1 << 2,  // 表示动态样式（静态如style="color: red"，也会提升至动态）
  PROPS = 1 << 3,  // 表示具有非类/样式动态道具的元素。
  FULL_PROPS = 1 << 4,  // 表示带有动态键的道具的元素，与上面三种相斥
  HYDRATE_EVENTS = 1 << 5,  // 表示带有事件监听器的元素
  STABLE_FRAGMENT = 1 << 6,   // 表示其子顺序不变的片段（没懂）。 
  KEYED_FRAGMENT = 1 << 7, // 表示带有键控或部分键控子元素的片段。
  UNKEYED_FRAGMENT = 1 << 8, // 表示带有无key绑定的片段
  NEED_PATCH = 1 << 9,   // 表示只需要非属性补丁的元素，例如ref或hooks
  DYNAMIC_SLOTS = 1 << 10,  // 表示具有动态插槽的元素
}

```

如果存在两种类型，那么只需要对这两个值对应的`patchflag`进行位晕眩

如：`TEXT`和`PROPS`

```js
TEXT: 1 ,PROPRS: 1<<3 => 8

// 那么对1和8进行按位与运算得到=>9
```


**2）事件储存**

> 绑定的事件会缓存在缓存中

```html
<div id="app">
  <button @click="handleClick">周五啦</button>
</div>

```

经过转换

```js
import { createVNode as _createVNode, openBlock as _openBlock, createBlock as _createBlock } from "vue"

export function render(_ctx, _cache) {
  return (_openBlock(), _createBlock("div", { id: "app" }, [
    _createVNode("button", {
      onClick: _cache[1] || (_cache[1] = ($event, ...args) => (_ctx.handleClick($event, ...args)))
    }, "周五啦")
  ]))
}

```

在代码中可以看出在绑定点击事件的时候，会生成并缓存了一个内联函数在cache中，变成了一个静态的节点

**3）静态提升**

```html
<div id="app">
    <p>周一了</p>
    <p>周二了</p>
    <div>{{week}}</div>
    <div :class="{red:isRed}">周三呢</div>
</div>
```

转换成

```js
import { createVNode as _createVNode, toDisplayString as _toDisplayString, openBlock as _openBlock, createBlock as _createBlock } from "vue"

const _hoisted_1 = { id: "app" }
const _hoisted_2 = /*#__PURE__*/_createVNode("p", null, "周一了", -1 /* HOISTED */)
const _hoisted_3 = /*#__PURE__*/_createVNode("p", null, "周二了", -1 /* HOISTED */)

export function render(_ctx, _cache) {
  return (_openBlock(), _createBlock("div", _hoisted_1, [
    _hoisted_2,
    _hoisted_3,
    _createVNode("div", null, _toDisplayString(_ctx.week), 1 /* TEXT */),
    _createVNode("div", {
      class: {red:_ctx.isRed}
    }, "周三呢", 2 /* CLASS */)
  ]))
}
```

在这里可以看出来将一些静态的节点放放在了`render`函数的外部，这样就避免了每次`render`都会去生成一次静态节点

#### 3.提供了tree shaking

- 打包的时候自动去除没用到的 vue 模块

#### 4.更好的 ts 支持

- 类型定义提示
- tsx 支持
- class 组件的支持

### 5.全家桶修改

vite 的使用，放弃原来vue2.x使用的 webpack

1. 开发服务器启动后不需要进行打包操作
2. 可以自定义开发服务器:`const {createSever} = require('vite')`
3. 热模块替换的性能和模块数量无关，替换变快，即时热模块替换
4. 生产环境和 rollup 捆绑

### 二、vue2和vue3响应式对比

#### 1.vue2.x 使用的是defineProperty，有两个难解决的问题

1. 只能做第一层属性的响应，再往深处就无法实现了
2. 数组问题：defineProperty无法检测数组长度的变化，准确的是说，是无法检测通过改变`length`的方法而增加的长度无法检测到

```js
// length的属性被初始化成为了
enumberable: false
configurable: false
writable: true
// 所以说直接去删除或者修改length属性是不行的
var a = [1,2,3]
Object.defineProperty(a,'length',{
   enumberable: true,
configurable: true,
writable: true ,
})

// Uncaught TypeError: Cannot redefine property: length
```

#### 2.vue3 使用的是Proxy和Reflect，直接代理整个对象

```js
function reactive(data) {
    if (typeof data !== 'object' || data === null) {
        return data
    }
    const observed = new Proxy(data, {
        get(target, key, receiver) {
            // Reflect有返回值不报错
            let result = Reflect.get(target, key, receiver)

            // 多层代理
            return typeof result !== 'object' ? result : reactive(result) 
        },
        set(target, key, value, receiver) {
            effective()
            // proxy + reflect
            const ret = Reflect.set(target, key, value, receiver)
            return ret
        },

        deleteProperty(target,key){
            const ret = Reflect.deleteProperty(target,key)
            return ret
        }

    })
    return observed
}
```

#### 3.总结

1. Object.defineProperty 只能劫持对象的属性，而 Proxy 是直接代理对象,由于 Object.defineProperty 只能对属性进行劫持，需要遍历对象的每个属性。而 Proxy 可以直接代理对象。
2. Object.defineProperty 对新增属性需要手动进行 Observe， 由于 Object.defineProperty 劫持的是对象的属性，所以新增属性时，需要重新遍历对象，对其新增属性再使用 Object.defineProperty 进行劫持。 也正是因为这个原因，使用 Vue 给 data 中的数组或对象新增属性时，需要使用 vm.$set 才能保证新增的属性也是响应式的。
3. Proxy 支持 13 种拦截操作，这是 defineProperty 所不具有的新标准性能红利
4. Proxy 作为新标准，长远来看，JS 引擎会继续优化 Proxy，但 getter 和 setter 基本不会再有针对性优化。
5. Proxy 兼容性差 目前并没有一个完整支持 Proxy 所有拦截方法的 Polyfill 方案


### 31、说一下 Vue dom diff 算法

### 一、Diff算法

Diff算法是一种通过同层的树节点进行比较的高效算法，避免对树的逐层遍历，减少时间复杂度。diff算法在很多场景下都有应该用，比如vue虚拟dom渲染生成真实dom的新旧VNonde比较更新。

diff算法两个特点：

- 只会同级比较，不跨层级
- diff比较循环两边往中间收拢，

### 二、Vue Diff算法

**vue的虚拟domdiff核心在与patch过程**

#### 1.首先将新旧VNode进行开始位置和结束位置的标记

```js
let oldStartIndex = 0;
let oldEndIndex = oldChildren.length -1;
let oldStartVnode = oldChidren[0];
let oldEndVnode = oldChildren[oldEndIndex];
let newStartIndex = 0;
let newEndIndex = newChildren.length - 1;
let newStartVnode = newChildren[0];
let newEndVnode = newChildren.length;
```

#### 2.标记好节点位置，进行循环处理节点

- 如果当前oldStartVnode和newStartVnode节点相同，直接用新节点复用老节点，进行patchVnode复用，更新oldStartVnode，newStartVnode，oldStartIndex++ 和 newStartIndex++
- 如果当前oldEndVnode和newEndVnode节点相同，直接用新节点复用老节点，进行patchVnode复用，更新oldEndVnode，newEndVnode，oldEndIndex-- 和 newEndIndex--
- 如果当前oldStartVnode和newEndVnode节点相同，直接用新节点复用老节点，进行patchVnode复用，将将老节点移动到oldEndVnode节点之后，， 更新oldStartVnode，newEndVnode，oldStartIndex++ 和 newEndIndex--
- 如果当前oldEndVnode和newStartVnode节点相同，直接用新节点复用老节点，进行patchVnode复用，将复用老节点移动oldStartVnode的elm之前，， 更新oldStartVnode，newEndVnode，oldEndIndex-- 和 newStartIndex--
- 如果都不满足则没有相同节点复用，进行key的对比。满足条件进行patchVnode过程，并将dom移动到oldStartVnode对应真是dom之前。没找到则重新创

#### 3.递归处理


### 二、Vue Diff图解

![domdiff](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-227-domdiff.png)

![domdiff](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-227-domdiff.gif)


- **第一步：** 创建四个指针，分别为旧`VNode`的开始指针和结束指针、新`VNode`的开始和结束指针
- **第二步：** 先比较旧`VNode`的开始指针和新`VNode`的开始指针，即`A`和`E`，发现不是同一个节点
- **第三步：** 再比较旧`VNode`的结束指针和新`VNode`的结束指针，即`D`和`F`，依然不是相同节点
- **第四步：** 再比较旧`VNode`的开始指针和新`VNode`的结束指针，即`A`和`F`，不是相同节点
- **第五步：** 再比较旧`VNode`的结束指针和新`VNode`的开始指针，即`E`和`D`，不是相同节点
- **第六步：** 通过上述四种比对方式都不是相同节点，下面就在旧`VNode`节点中查找是否有与`E`节点相同的节点
- **第七步：** 发现旧`VNode`节点中没有`E`节点，那么就会在旧`VNode`开始指针前插入一个新的`E`节点
- **第八步：** 第一个节点操作完后，指针后移，继续进行比较，重复\**第二至第七步**，结果为：**新增**、**删除**、**移动**
- **第九步：** 当找到相同节点时，会通过`patchVnode`进行这两个节点更细致的`Diff`


**总结**

每次`Diff`都会调用`updateChildren`方法来比较，就这样层层递归下去，直到将旧`VNode`和新`VNode`中的所有子节点比对完。`DomDiff`的过程更像是两个树的比较，每找到相同节点时，都会一层一层的往下比较它们的子节点，是一个\**深度递归遍历比较**的过程。








### 32、Vue 是如何收集依赖的

### Vue依赖收集

在初始化`Vue`的每个组件时，会对组件的`data`进行初始化，就会将由普通对象变成响应式对象，在这个过程中便会进行依赖收集的相关逻辑，如下所示:

```js
function defieneReactive (obj, key, val){
  const dep = new Dep();
  ...
  Object.defineProperty(obj, key, {
    ...
    get: function reactiveGetter () {
      if(Dep.target){
        dep.depend();
        ...
      }
      return val
    }
    ...
  })
}
```

以上只保留了关键代码，主要就是 `const dep = new Dep()`实例化一个`Dep`的实例，然后在`get`函数中通过`dep.depend()`进行依赖收集。

#### 1.Dep

`Dep`是整个依赖收集的核心，关键代码如下：

```js
class Dep {
  static target;
  subs;
  
  constructor () {
    ...
    this.subs = [];
  }
  addSub (sub) {
    this.subs.push(sub)
  }
  removeSub (sub) {
    remove(this.sub, sub)
  }
  depend () {
    if(Dep.target){
      Dep.target.addDep(this)
    }
  }
  notify () {
    const subs = this.subds.slice();
    for(let i = 0;i < subs.length; i++){
      subs[i].update()
    }
  }
}
```

`Dep`是一个`class`，其中有一个关键的静态属性`static`，它指向了一个全局唯一`Watcher`，保证了同一时间全局只有一个`watcher`被计算，另一个属性`subs`则是一个`Watcher`的数组，所以`Dep`实际上就是对`Watcher`的管理，再看看`Watcher`的相关代码：

#### 2.Watcher

```javascript
class Watcher {
  getter;
  ...
  constructor (vm, expression){
    ...
    this.getter = expression;
    this.get();
  }
  get () {
    pushTarget(this);
    value = this.getter.call(vm, vm)
    ...
    return value
  }
  addDep (dep){
		...
    dep.addSub(this)
  }
  ...
}
function pushTarget (_target) {
  Dep.target = _target
}
```

`Watcher`是一个`class`，它定义了一些方法，其中和依赖收集相关的主要有`get`、`addDep`等。

#### 3.过程

在实例化`Vue`时，依赖收集的相关过程如下：

初始化状态`initState`，这中间便会通过`defineReactive`将数据变成响应式对象，其中的`gette r`部分便是用来依赖收集的。

初始化最终会走`mount`过程，其中会实例化`Watcher`，进入`Watcher`中，便会执行`this.get()`方法，

```js
updateComponent = () => {
  vm._update(vm._render())
}
new Watcher(vm, updateComponent)
```

`get`方法中的`pushTarget`实际上就是把`Dep.target`赋值为当前的`watcher`。

`this.getter.call(vm, vm)`，这里的`getter`会执行`vm._render()`方法，在这个过程中便会	触发数据对象的`getter`。

那么每个对象值的 getter 都持有一个 `dep`，在触发 getter 的时候会调用 `dep.depend()` 方法，也就会执行 `Dep.target.addDep(this)`。

刚才 `Dep.target` 已经被赋值为 `watcher`，于是便会执行 `addDep` 方法，然后走到`dep.addSub()`方法，便将当前的 `watcher` 订阅到这个数据持有的 `dep` 的 `subs` 中，这个目的是为后续数据变化时候能通知到哪些 `subs` 做准备。

所以在 `vm._render()` 过程中，会触发所有数据的 getter，这样便已经完成了一个依赖收集的过程。

### 33、说一下 Vue 组件的通信方式都有哪些？(父子组件，兄弟组件，多级嵌套组件等等)



### 34、说一下 Vue 路由实现原理



### 35、Vue3.0 为什么要用 proxy？是怎么用 proxy 实现数据监听的?



### 36、说一下对 React 和 Vue 的理解，它们的异同


### 一、相似之处

- 都将注意力集中保持在核心库，而将其他功能如路由和全局状态管理交给相关的库
- 都有自己的构建工具，能让你得到一个根据最佳实践设置的项目模板。
- 都使用了'Virtual DOM'（虚拟DOM）提高重绘性能
- 都有’props’的概念，允许组件间的数据传递
- 都鼓励组件化应用，将应用分拆成一个个功能明确的模块，提高复用性

### 二、不同之处

#### 1.数据流

Vue默认支持数据双向绑定，而React一直提倡单向数据流

#### 2.虚拟DOM

Vue2.x 开始引入“Virtual DOM”，消除了和React在这方面的差异，但是在具体的细节还是有各自的特点

- Vue宣称可以更快地计算出Virtual DOM的差异，这是由于它在渲染过程中，会跟踪每一个组件的依赖关系，不需要重新渲染整个组件树。

- 对于React而言，每当应用的状态被改变时，全部子组件都会重新渲染。当然，这可以通过PureComponent/shouldComponentUpdate这个生命周期方法来进行控制，但Vue将此视为默认的优化。

#### 3.组件化

React与Vue最大的不同是模板的编写。

Vue鼓励你去写近似常规HTML的模板。写起来很接近标准HTML元素，只是多了一些属性。React推荐你所有的模板通用JavaScript的语法扩展——JSX书写。

具体来讲：

React中render函数是支持闭包特性的，所以我们import的组件在render中可以直接调用。但是在Vue中，由于模板中使用的数据都必须挂在 this 上进行一次中转，所以我们import 一个组件完了之后，还需要在 components 中再声明下。

#### 4.监听数据变化的实现原理不同

- Vue 通过 `getter/setter` 以及一些函数的劫持，能精确知道数据变化，不需要特别的优化就能达到很好的性能
- React 默认是通过比较引用的方式进行的，如果不优化（PureComponent/shouldComponentUpdate）可能导致大量不必要的VDOM的重新渲染。这是因为Vue 使用的是可变数据，而React更强调数据的不可变。

#### 5.高阶组件

react可以通过高阶组件（Higher Order Components--HOC）来扩展，而vue需要通过mixins来扩展

原因高阶组件就是高阶函数，而React的组件本身就是纯粹的函数，所以高阶函数对React来说易如反掌。相反Vue.js使用HTML模板创建视图组件，这时模板无法有效的编译，因此Vue不采用HoC来实现。

#### 6.构建工具

两者都有自己的构建工具

- React ==> Create React APP
- Vue ==> vue-cli

#### 7.跨平台

- React ==> React Native
- Vue ==> Weex

### 37、说一下 Vuex 的原理以及自己的理解


### Vuex

![vuex流程图](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-220-vuex.png)

Vuex为Vue Components建立起了一个完整的生态圈，包括开发中的API调用一环。

#### 1.核心流程中的主要功能：

1. Vue Components 是我们的 vue 组件，组件会触发（dispatch）一些事件或动作，也就是图中的 Actions；
2. 我们在组件中发出的动作，肯定是想获取或者改变数据的，但是在 vuex 中，数据是集中管理的，我们不能直接去更改数据，所以会把这个动作提交（Commit）到 Mutations 中；
3. 然后 Mutations 就去改变（Mutate）State 中的数据；
4. 当 State 中的数据被改变之后，就会重新渲染（Render）到 Vue Components 中去，组件展示更新后的数据，完成一个流程。

#### 各模块在核心流程中的主要功能：

- **Vue Components:** Vue组件。HTML页面上，负责接收用户操作等交互行为，执行dispatch方法触发对应action进行回应。
- **dispatch:** 操作行为触发方法，是唯一能执行action的方法。
- **actions:** 操作行为处理模块。负责处理Vue Components接收到的所有交互行为。包含同步/异步操作，支持多个同名方法，按照注册的顺序依次触发。向后台API请求的操作就在这个模块中进行，包括触发其他action以及提交mutation的操作。该模块提供了Promise的封装，以支持action的链式触发。
- **commit:** 状态改变提交操作方法。对mutation进行提交，是唯一能执行mutation的方法。
- **mutations:** 状态改变操作方法。是Vuex修改state的唯一推荐方法，其他修改方式在严格模式下将会报错。该方法只能进行同步操作，且方法名只能全局唯一。操作之中会有一些hook暴露出来，以进行state的监控等。
- **state:** 页面状态管理容器对象。集中存储Vue components中data对象的零散数据，全局唯一，以进行统一的状态管理。页面显示所需的数据从该对象中进行读取，利用Vue的细粒度数据响应机制来进行高效的状态更新。
- **getters:** state对象读取方法。图中没有单独列出该模块，应该被包含在了render中，Vue Components通过该方法读取全局state对象。

### 38、Redux 和 Vuex 有什么区别，说下一它们的共同思想

**1）Redux 和 Vuex区别**

- Vuex改进了Redux中的Action和Reducer函数，以mutations变化函数取代Reducer，无需switch,只需在对应的mutation函数里改变state值即可
- Vuex由于Vue自动重新渲染的特性，无需订阅重新渲染函数，只要生成新的State即可
- Vuex数据流的顺序是:View调用store.commit提交对应的请求到Store中对应的mutation函数->store改变(vue检测到数据变化自动渲染)

通俗点理解就是，vuex 弱化 dispatch, 通过commit进行store状态的一次更变;取消了action概念, 不必传入特定的action形式进行指定变更; 弱化reducer, 基于commit参数直接对数据进行转变, 使得框架更加简易;

**2）共同思想**

- 单一的数据源
- 变化可以预测

**本质上：** redux与vuex都是对mvvm思想的服务, 将数据从视图中抽离的一种方案;

**形式上：** vuex借鉴了redux, 将store作为全局的数据中心, 进行mode管理;



### 39、说一下 Vue 的 keep-alive 是如何实现的，具体缓存的是什么？

### 一、keep-alive

#### Props

- include 字符串或正则表达式，只有名称匹配的组件会被匹配
- exclude 字符串或正则表达式。任何名称匹配的组件都不会被缓存。
- max 数字。最多可以缓存多少组件实例

> keep-alive 包裹动态组件时，会缓存**不活动的组件实例**

#### 主要流程

1. 判断组件`name`，不在`include`或者在`exclude`中，直接返回`vnode`，说明该组件不被缓存。
2. 获取组件实例`key`，如果有获取实例的`key`，否则重新生成。
3. key生成规则，`cid + "::"+ tag`，仅靠cid是不够的的，因为相同的构造函数可以注册为不同的本地组件。
4. 如果缓存对象内存在，则直接从缓存对象中获取组件实例给`vnode`，不存在则添加到缓存对象中。
5. 最大缓存数量，当缓存组件数量超过`max`值时，清除`keys`数组内第一个组件。

### 二、keep-alive 的实现

```js
const patternTypes: Array<Function> = [String, RegExp, Array] // 接收：字符串，正则，数组

export default {
  name: 'keep-alive',
  abstract: true, // 抽象组件，是一个抽象组件：它自身不会渲染一个 DOM 元素，也不会出现在父组件链中。

  props: {
    include: patternTypes, // 匹配的组件，缓存
    exclude: patternTypes, // 不去匹配的组件，不缓存
    max: [String, Number], // 缓存组件的最大实例数量, 由于缓存的是组件实例（vnode），数量过多的时候，会占用过多的内存，可以用max指定上限
  },

  created() {
    // 用于初始化缓存虚拟DOM数组和vnode的key
    this.cache = Object.create(null)
    this.keys = []
  },

  destroyed() {
    // 销毁缓存cache的组件实例
    for (const key in this.cache) {
      pruneCacheEntry(this.cache, key, this.keys)
    }
  },

  mounted() {
    // prune 削减精简[v.]
    // 去监控include和exclude的改变，根据最新的include和exclude的内容，来实时削减缓存的组件的内容
    this.$watch('include', (val) => {
      pruneCache(this, (name) => matches(val, name))
    })
    this.$watch('exclude', (val) => {
      pruneCache(this, (name) => !matches(val, name))
    })
  },
}
```

#### render函数

1. 会在 keep-alive 组件内部去写自己的内容，所以可以去获取默认 slot 的内容，然后根据这个去获取组件
2. keep-alive 只对第一个组件有效，所以获取第一个子组件。
3. 和 keep-alive 搭配使用的一般有：`动态组件`和`router-view

```js
render () {
  //
  function getFirstComponentChild (children: ?Array<VNode>): ?VNode {
    if (Array.isArray(children)) {
  for (let i = 0; i < children.length; i++) {
    const c = children[i]
    if (isDef(c) && (isDef(c.componentOptions) || isAsyncPlaceholder(c))) {
      return c
    }
  }
  }
  }
  const slot = this.$slots.default // 获取默认插槽
  const vnode: VNode = getFirstComponentChild(slot)// 获取第一个子组件
  const componentOptions: ?VNodeComponentOptions = vnode && vnode.componentOptions // 组件参数
  if (componentOptions) { // 是否有组件参数
    // check pattern
    const name: ?string = getComponentName(componentOptions) // 获取组件名
    const { include, exclude } = this
    if (
      // not included
      (include && (!name || !matches(include, name))) ||
      // excluded
      (exclude && name && matches(exclude, name))
    ) {
      // 如果不匹配当前组件的名字和include以及exclude
      // 那么直接返回组件的实例
      return vnode
    }

    const { cache, keys } = this

    // 获取这个组件的key
    const key: ?string = vnode.key == null
      // same constructor may get registered as different local components
      // so cid alone is not enough (#3269)
      ? componentOptions.Ctor.cid + (componentOptions.tag ? `::${componentOptions.tag}` : '')
      : vnode.key

    if (cache[key]) {
      // LRU缓存策略执行
      vnode.componentInstance = cache[key].componentInstance // 组件初次渲染的时候componentInstance为undefined

      // make current key freshest
      remove(keys, key)
      keys.push(key)
      // 根据LRU缓存策略执行，将key从原来的位置移除，然后将这个key值放到最后面
    } else {
      // 在缓存列表里面没有的话，则加入，同时判断当前加入之后，是否超过了max所设定的范围，如果是，则去除
      // 使用时间间隔最长的一个
      cache[key] = vnode
      keys.push(key)
      // prune oldest entry
      if (this.max && keys.length > parseInt(this.max)) {
        pruneCacheEntry(cache, keys[0], keys, this._vnode)
      }
    }
    // 将组件的keepAlive属性设置为true
    vnode.data.keepAlive = true // 作用：判断是否要执行组件的created、mounted生命周期函数
  }
  return vnode || (slot && slot[0])
}
```

keep-alive`具体是通过`cache`数组缓存所有组件的`vnode`实例。当`cache`内原有组件被使用时会将该组件`key`从`keys`数组中删除，然后`push`到`keys`数组最后，以便清除最不常用组件。

#### 步骤总结

1. 获取 keep-alive 下第一个子组件的实例对象，通过他去获取这个组件的组件名
2. 通过当前组件名去匹配原来 include 和 exclude，判断当前组件是否需要缓存，不需要缓存，直接返回当前组件的实例 vNode
3. 需要缓存，判断他当前是否在缓存数组里面，存在，则将他原来位置上的 key 给移除，同时将这个组件的 key 放到数组最后面（LRU）
4. 不存在，将组件 key 放入数组，然后判断当前 key 数组是否超过 max 所设置的范围，超过，那么削减未使用时间最长的一个组件的 key 值
5. 最后将这个组件的 keepAlive 设置为 true

### 三、keep-alive 本身的创建过程和 patch 过程

缓存渲染的时候，会根据 vnode.componentInstance（首次渲染 vnode.componentInstance 为 undefined） 和 keepAlive 属性判断不会执行组件的 created、mounted 等钩子函数，而是对缓存的组件执行 patch 过程：**直接把缓存的 DOM 对象直接插入到目标元素中，完成了数据更新的情况下的渲染过程**。

#### 首次渲染

- 组件的首次渲染：判断组件的 abstract 属性，才往父组件里面挂载 DOM

```js
// core/instance/lifecycle
function initLifecycle (vm: Component) {
  const options = vm.$options

  // locate first non-abstract parent
  let parent = options.parent
  if (parent && !options.abstract) { // 判断组件的abstract属性，才往父组件里面挂载DOM
    while (parent.$options.abstract && parent.$parent) {
      parent = parent.$parent
    }
    parent.$children.push(vm)
  }

  vm.$parent = parent
  vm.$root = parent ? parent.$root : vm

  vm.$children = []
  vm.$refs = {}

  vm._watcher = null
  vm._inactive = null
  vm._directInactive = false
  vm._isMounted = false
  vm._isDestroyed = false
  vm._isBeingDestroyed = false
}
```

- 判断当前 keepAlive 和 componentInstance 是否存在来判断是否要执行组件 prepatch 还是执行创建 componentInstance

```js
// core/vdom/create-component
init (vnode: VNodeWithData, hydrating: boolean): ?boolean {
    if (
      vnode.componentInstance &&
      !vnode.componentInstance._isDestroyed &&
      vnode.data.keepAlive
    ) { // componentInstance在初次是undefined!!!
      // kept-alive components, treat as a patch
      const mountedNode: any = vnode // work around flow
      componentVNodeHooks.prepatch(mountedNode, mountedNode) // prepatch函数执行的是组件更新的过程
    } else {
      const child = vnode.componentInstance = createComponentInstanceForVnode(
        vnode,
        activeInstance
      )
      child.$mount(hydrating ? vnode.elm : undefined, hydrating)
    }
  },
```

prepatch 操作就不会在执行组件的`mounted`和`created`生命周期函数，而是直接将 DOM 插入

### 四、LRU (least recently used)缓存策略

**LRU 缓存策略：** 从内存中找出最久未使用的数据并置换新的数据.

LRU（Least rencently used）算法根据数据的历史访问记录来进行淘汰数据，其核心思想是“如果数据最近被访问过，那么将来被访问的几率也更高”。
最常见的实现是使用一个链表保存缓存数据，详细算法实现如下：

1. 新数据插入到链表头部
2. 每当缓存命中（即缓存数据被访问），则将数据移到链表头部
3. 链表满的时候，将链表尾部的数据丢弃。









