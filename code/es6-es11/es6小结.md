1.变量
var   重复声明、函数级作用域
let   不能重复声明、块级、变量
const   不能重复声明、块级、常量

2.箭头函数
  方便
    如果只有一个参数（）可以省略
    如果只有一个return，{}也可以省略
  修正this
    this相对正常

3.参数扩展
  收集
  扩展
  默认参数

4.数组方法
  forEach 循环
  map   映射
  reduce    汇总：一堆 --> 一个
  filter    过滤：一堆 --> 剩下的

5.字符串
  startsWith/endsWith
  `{$a}`

6.Promise
  封装异步操作
  Promise.all([]);
  Promise.race([]);

7.generator
  function *show(){
    yield
  }

8.JSON
  JSON.stringify
  JSON.parse

9.面向对象
  class Test{
    <!-- 构造函数 -->
    constructor(){
      this.xxx = ;
    }
    方法1(){

    }
  }

  class Cls2 extends Cls1{
    constructor(){
      super();
    }
  }

10.解构赋值
  let [a,b] = [1,2];
  左右结构一样
  右边是个合法变量
  声明、赋值一次完成

=========es7 && es8=============

