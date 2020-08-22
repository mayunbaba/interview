### 1、css 伪类与伪元素区别

1）伪类(pseudo-classes)
- 其核⼼就是⽤来选择DOM树之外的信息,不能够被普通选择器选择的⽂档之外的元素，⽤来添加⼀些选择器的特殊效果。
- ⽐如:hover :active :visited :link :visited :first-child :focus :lang等
- 由于状态的变化是⾮静态的，所以元素达到⼀个特定状态时，它可能得到⼀个伪类的样式；当状态改变时，它⼜会失去这个样式。
- 由此可以看出，它的功能和class有些类似，但它是基于⽂档之外的抽象，所以叫 伪类。

2）伪元素(Pseudo-elements)
- DOM树没有定义的虚拟元素
- 核⼼就是需要创建通常不存在于⽂档中的元素，
- ⽐如::before ::after 它选择的是元素指定内容，表示选择元素内容的之前内容或之后内容。
- 伪元素控制的内容和元素是没有差别的，但是它本身只是基于元素的抽象，并不存在于⽂档中，所以称为伪元素。⽤于将特殊的效果添加到某些选择器

2）伪类与伪元素的区别
- 表示⽅法
  - CSS2 中伪类、伪元素都是以单冒号:表示,
  - CSS2.1 后规定伪类⽤单冒号表示,伪元素⽤双冒号::表示，
  - 浏览器同样接受 CSS2 时代已经存在的伪元素(:before, :after, :first\ufffeline, :first-letter 等)的单冒号写法。
  - CSS2 之后所有新增的伪元素(如::selection)，应该采⽤双冒号的写法。
  - CSS3中，伪类与伪元素在语法上也有所区别，伪元素修改为以::开头。浏览器对以:开头的伪元素也继续⽀持，但建议规范书写为::开头

- 定义不同
  - 伪类即假的类，可以添加类来达到效果
  - 伪元素即假元素，需要通过添加元素才能达到效果
- 总结:
  - 伪类和伪元素都是⽤来表示⽂档树以外的"元素"。
  - 伪类和伪元素分别⽤单冒号:和双冒号::来表示。
  - 伪类和伪元素的区别，关键点在于如果没有伪元素(或伪类)，
  - 是否需要添加元素才能达到效果，如果是则是伪元素，反之则是伪类。

4）相同之处：
- 伪类和伪元素都不出现在源⽂件和DOM树中。也就是说在html源⽂件中是看不到伪类和伪元素的。
不同之处：
- 伪类其实就是基于普通DOM元素⽽产⽣的不同状态，他是DOM元素的某⼀特征。
- 伪元素能够创建在DOM树中不存在的抽象对象，⽽且这些抽象对象是能够访问到的。

### 2、屏幕正中间有个元素A，元素A中有文字A，随着屏幕宽度的增加，始终需要满足下列条件
```js
/* 
  A元素垂直居中于屏幕中央
  A元素距离屏幕左右边距各10px
  A元素里面的文字A的font-size:20px；水平垂直居中
  A元素的高度始终是A元素宽度的50%；(如果搞不定可以实现为A元素的高度固定为200px)
  
  请用html及css实现
*/
```

### 代码实现

#### 1.实现一

- postion+transform 实现水平垂直居中
- padding-top 实现高是宽的50%

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>居中</title>
</head>

<body>
  <style>
    html,
    body {
      width: 100%;
      height: 100%;
      padding: 0;
      margin: 0;
    }

    .wrap {
      width: 100%;
      height: 100%;
      background-color: bisque;
      position: relative;
    }

    .A {
      font-size: 20px;
      text-align: center;
      background-color: blueviolet;
      position: absolute;
      top: 50%;
      left: 10px;
      right: 10px;
      transform: translate(0, -50%);
      padding-top: 50%;
    }

    .f {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
    }
  </style>
  <div class="wrap">
    <div class="A">
      <div class="f">A</div>
    </div>
  </div>
</body>

</html>
```

#### 2.实现二

- calc+vw

```js
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>居中</title>
</head>

<body>
  <style>
    * {
      padding: 0;
      margin: 0;
    }

    .A {
      margin: 0 10px;
      text-align: center;
      font-size: 20px;
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: calc(100vw - 20px);
      height: calc(50vw - 10px);
      line-height: calc(50vw - 10px);
      background-color: aquamarine;
    }
  </style>
  <div class="A">
    A
  </div>
</body>

</html>
```

#### 3.实现方式三

- flex + 伪元素

```js
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>居中</title>
</head>

<body>
  <style>
    html,
    body {
      padding: 0;
      margin: 0;
      height: 100%;
    }

    body {
      display: flex;
      align-items: center;
    }

    .A {
      flex: 1;
      margin: 0 10px;
      padding-top: 50%;
      position: relative;
      background: #999;
    }

    .A::after {
      content: 'A';
      display: block;
      font-size: 20px;
      position: absolute;
      /* 样式1 */
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);

      /* 样式2 */
      /* top: 0%;
            left: 0%;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center; */
    }
  </style>
  <div class="A"></div>
</body>

</html>
```


说一下对 vue3.0 的了解，vue3.0 为什么要用代理?是怎么用 proxy 实现数据监听的?

知道语义化吗？说说你理解的语义化，如果是你，平时会怎么做来保证语义化？说说你了解的 HTML5 语义化标签？

### 3、列举出 css 选择器有哪些分类，并至少写出三个 css 选择器之间的区别，适用场景



### 4、Css 实现 div 宽度自适应，宽高保持等比缩放



### 5、ul 内部除最后一个 li 以外设置右边框效果



### 6、flex:1 的完整写法是？分别是什么意思？



### 7、行内元素和块级元素有什么区别



### 8、link 和@inmport 区别



### 9、请画出 css 盒模型，基于盒模型的原理，说明相对定位、绝对定位、浮动实现样式是如何实现的？


### Css盒模型

页面上任何一个元素我们都可以看成是一个盒子，盒子会占用一定的空间和位置他们之间相互制约，就形成了网页的布局.

w3c的盒模型的构成：content border padding margin

**IE盒模型与标准盒模型**

IE模型和标准模型唯一的区别是内容计算方式的不同

- IE盒模型,宽度width=content+padding

![IE盒模型](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-711-iebox.png)

- 标准盒模型,宽度width = content

![标准盒模型](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-711-box.png)

### 不同定位

#### 1.相对定位

relative(相对定位) 对象不可层叠、不脱离文档流，参考自身静态位置通过 top,bottom,left,right 定位，并且可以通过z-index进行层次分级。

#### 2.绝对定位

absolute(绝对定位) 脱离文档流，通过 top,bottom,left,right 定位。选取其最近一个最有定位设置的父级对象进行绝对定位，如果对象的父级没有设置定位属性，absolute元素将以body坐标原点进行定位，可以通过z-index进行层次分级。

#### 3.浮动

脱离文档流，也就是将元素从普通的布局排版中拿走，其他盒子在定位的时候，会当做脱离文档流的元素不存在而进行定位。





### 10、Css 实现多列等高布局，要求元素实际占用的高度以多列中较高的为准

### 代码实现

#### 1.flex布局

`flex-direction` 属性定义的主轴方向，默认值为row，水平展示。`align-item` 属性定义子项在 `flex` 容器的当前行的侧轴方向的对齐方式，默认为 `stretch` ，元素被拉伸以适应容器。

```html
    <style>
        html,
        body,
        p {
            padding: 0;
            margin: 0;
        }
        .wrap {
            display: flex;
        }
        .item {
            width: 0;
          	flex:1;
            margin-right: 5px;
            background-color: brown;
        }
    </style>
	<div class="wrap">
        <div class="item">left</div>
        <div class="item">
            <p>center</p>
            <p>center</p>
            <p>center</p>
            <p>center</p>
            <p>center</p>
            <p>center</p>
        </div>
        <div class="item">right</div>
    </div>
```

#### 2.table-cell布局

table布局具有天然等高特性

```html
<style>
    html,body,p{
        margin:0;
        padding:0;
    }
    .wrap{
        width:100%;
        display: table;
        background-color: darkgrey;
        table-layout:fixed;
    }
    .left,.centerWrap,.right{
        display: table-cell;
    }
    .left,.right,.center{
        background-color: brown;
    }
    .center{
        margin: 0 10px;
    }
    </style>
    <div class="wrap">
        <div class="left">left</div>
        <div class="centerWrap">
            <div class="center">
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
            </div>
        </div>
        <div class="right">right</div>
    </div>
```

#### 3.假等高布局，内外边距底部正负值

设置父容器的 `overflow` 属性为 `hidden` ，给每列设置比较大的底内边距 `padding-bottom` ,然后用数值相似的负外边距消除这个高度 `margin-bottom`

```html
<style>
        html,body,p {
            padding: 0;
            margin: 0;
        }
        .wrap {
            overflow: hidden;
            background-color: darkgray;
        }
        .left,.centerWrap,.right {
            float: left;
            width: 33.3%;
            padding-bottom: 9999px;
            margin-bottom: -9999px;
        }
        .left,.center,.right{
            background-color:brown;
        }
        .center{
            margin: 0 10px;
        }
    </style>
	<div class="wrap">
        <div class="left">left</div>
        <div class="centerWrap">
            <div class="center">
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
                <p>center</p>
            </div>
        </div>
        <div class="right">right</div>
    </div>
```

#### 4.grid布局：

`grid-template-columns` 设置列宽， `grid-auto-flow` 自动布局算法，设置优先填充列

```html
   <style>
        html,
        body,
        p {
            margin: 0;
            padding: 0;
        }

        .wrap {
            display: grid;
            grid-template-columns: 33.3% 33.3% 33.3%;
            grid-auto-flow: column;
            grid-gap: 10px;
            background-color: grey;
        }

        .item {
            background-color: brown;
        }
    </style>
    <div class="wrap">
        <div class="item">left</div>
        <div class="item">
            <p>center</p>
            <p>center</p>
            <p>center</p>
            <p>center</p>
            <p>center</p>
        </div>
        <div class="item">right</div>
    </div>
```

### 11、以下选项为 css 盒模型属性有哪些？(多选题)
```js
A.font
B.margin
C.padding
D.visible
E.border

```



### 12、说下盒模型的区别？介绍一下标准的 CSS 盒模型？border-box 和 content-box 有什么区别？



### 13、Css 单位都有哪些？



### 14、一个标签的 class 样式的渲染顺序，id、class、标签、伪类的优先级



### 15、css 如何实现动画



### 16、Css 如何实现一个半圆



### 17、上下固定，中间滚动布局如何实现

### 代码实现

#### 1.flex布局

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>flex</title>
    <style>
        html,
        body {
            padding: 0;
            margin: 0;
            height: 100%;
        }

        .wrap {
            display: flex;
            height: 100%;
            flex-direction: column;
        }
        .header,.footer{
            height:40px;
            line-height:40px;
            text-align: center;
            background-color:cadetblue;
        }
        .main{
            flex:1;
            background-color:chocolate;
            overflow:auto;
            text-align: center;
        }
    </style>
</head>

<body>
    <div class="wrap">
        <div class="header">header</div>
        <div class="main">
            main
            <div style="height: 2000px;"></div>
        </div>
        <div class="footer">footer</div>
    </div>
</body>

</html>
```

#### 2.绝对定位

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>position</title>
    <style>
        html,
        body {
            padding: 0;
            margin: 0;
            height: 100%;
        }

        .header,
        .footer {
            position: absolute;
            width: 100%;
            height: 40px;
            line-height: 40px;
            text-align: center;
            background-color: chocolate;
        }

        .header {
            top: 0;
            left: 0;
        }

        .footer {
            bottom: 0;
            left: 0;
        }

        .main {
            width: 100%;
            position: absolute;
            top: 40px;
            left: 0;
            bottom: 40px;
            right: 0;
            background-color: cadetblue;
            overflow:auto;
            text-align:center;
        }
    </style>
</head>

<body>
    <div class="wrap">
        <div class="header">header</div>
        <div class="main">
            main
            <div style="height:2000px;"></div>
        </div>
        <div class="footer">footer</div>
    </div>
</body>

</html>
```

### 18、居中为什么要使用 transform（为什么不使用 marginLeft/marginTop）

### 一、原因

**transform是独立的层，而margin会导致重绘回流**

### 二、浏览器渲染过程

![渲染过程](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-356-process.jpg)

拿Chrome举例，Chrome渲染主要包括：Parse Html(html解析)、Recalculate Style(查找并计算样式)、Layout(排布)、Paint(绘制)、Image Decode(图片解码)、Image Resize(图片大小设置)、Composite Layers(合并图层并输出页面到屏幕)。浏览器最终渲染出来的页面。

### 三、transform的原理

transform是通过创建一个RenderLayers（渲染）合成层，拥有独立的GraphicsLayers（绘图层）。每一个GraphicsLayers都有一个Graphics Context，其对应的RenderLayers会paint进Graphics Context中。合成器（Compositor）最终会负责将由Graphics Context输出的位图合并成最终屏幕展示的图案。

### 四、独立的合成层

满足如下条件的RenderLayers，会被认为是一个独立的合成层：

- 有3D或者perspective transform的CSS属性的层
- video元素的层
- canvas元素的层
- flash
- 对opacity和transform应用了CSS动画的层
- 使用了CSS滤镜（filters）的层
- 有合成层后代的层
- 同合成层重叠，且在该合成层上面（z-index）渲染的层

如果RenderLayer是一个合成层，那么它有属于它自己的单独的GraphicsLayer，否则它和它的最近的拥有GraphicsLayer的父layer共用一个GraphicsLayer。

由此可见，transform发生在Composite Layer这一步，它所引起的paint也只是发生在单独的GraphicsLayer中
，并不会引起整个页面的回流重绘。

### 五、margin

marign：外边距，定义元素周围的空间；简言之，可以改变元素的位移。在浏览器页面渲染的时候，margin可以控制元素的位置，也就是说，改变margin，就会改变render tree的结构，必定会引起页面layout回流和repaint重绘。

因此，从浏览器性能考虑，transform会比margin更省时间。

### 六、transform的局限性

上面提到，transform实际上也是用到了GPU加速，也就是说占用了内存。由此可见创建GraphicsLayer，虽然洁身了layout，paint阶段，但Layer创建的越多，占用内存就会越大，而过多的渲染开销会超过性能的改善。







### 19、移动端适配 1px 的问题



### 20、介绍 css3 中 position:sticky



### 21、清除浮动的方式



### 22、transform 动画和直接使用 left、top 改变位置有什么优缺点



### 23、如何实现高度自适应



### 24、em 和 px 的区别



### 25、介绍下 Flex 布局，属性都有哪些，都是干啥的

#### 1.父元素属性

- **display:flex**  *定义了一个flex容器*

- **flex-direction** *决定主轴的方向*
   - row *默认值，水平从左到右*
   - colunm *垂直从上到下*
   - row-reverse *水平从右到左*
   - *column-reverse *垂直从下到上*
- **flex-wrap** *定义如何换行*
  - nowrap *默认值，不换行*
  - wrap *换行*
  - wrap-reverse *换行，且颠倒行顺序，第一行在下方*
- **flex-flow** *属性是 flex-direction 属性和 flex-wrap 属性的简写形式，默认值为row nowrap*
- **justify-content** *设置或检索弹性盒子元素在主轴（横轴）方向上的对齐方式*
  - flex-start *默认值、弹性盒子元素将向行起始位置对齐*
  - flex-end *弹性盒子元素将向行结束位置对齐*
  - center *弹性盒子元素将向行中间位置对齐。该行的子元素将相互对齐并在行中居中对齐*
  - space-between *弹性盒子元素会平均地分布在行里*
  - space-around *弹性盒子元素会平均地分布在行里，两端保留子元素与子元素之间间距大小的一半*
- **align-items** *设置或检索弹性盒子元素在侧轴（纵轴）方向上的对齐方式*
  - flex-start *弹性盒子元素的侧轴（纵轴）起始位置的边界紧靠住该行的侧轴起始边界*
  - flex-end *弹性盒子元素的侧轴（纵轴）起始位置的边界紧靠住该行的侧轴结束边界*
  - center *弹性盒子元素在该行的侧轴（纵轴）上居中放置。（如果该行的尺寸小于弹性盒子元素的尺寸，则会向两个方向溢出相同的长度）*
  - baseline *如弹性盒子元素的行内轴与侧轴为同一条，则该值与flex-start等效。其它情况下，该值将参与基线对齐。*
  - stretch *如果指定侧轴大小的属性值为'auto'，则其值会使项目的边距盒的尺寸尽可能接近所在行的尺寸，但同时会遵照'min/max-width/height'属性的限制*
- **align-content** *设置或检索弹性盒堆叠伸缩行的对齐方式*
  - flex-start *各行向弹性盒容器的起始位置堆叠。弹性盒容器中第一行的侧轴起始边界紧靠住该弹性盒容器的侧轴起始边界，之后的每一行都紧靠住前面一行*
  - flex-end *各行向弹性盒容器的结束位置堆叠。弹性盒容器中最后一行的侧轴起结束界紧靠住该弹性盒容器的侧轴结束边界，之后的每一行都紧靠住前面一行*
  - center *各行向弹性盒容器的中间位置堆叠。各行两两紧靠住同时在弹性盒容器中居中对齐，保持弹性盒容器的侧轴起始内容边界和第一行之间的距离与该容器的侧轴结束内容边界与第最后一行之间的距离相等*
  - space-between *各行在弹性盒容器中平均分布。第一行的侧轴起始边界紧靠住弹性盒容器的侧轴起始内容边界，最后一行的侧轴结束边界紧靠住弹性盒容器的侧轴结束内容边界，剩余的行则按一定方式在弹性盒窗口中排列，以保持两两之间的空间相等*
  - space-around *各行在弹性盒容器中平均分布，两端保留子元素与子元素之间间距大小的一半。各行会按一定方式在弹性盒容器中排列，以保持两两之间的空间相等，同时第一行前面及最后一行后面的空间是其他空间的一半*
  - stretch *各行将会伸展以占用剩余的空间。剩余空间被所有行平分，以扩大它们的侧轴尺寸*
   
#### 2.子元素上属性

- **.order** *默认情况下flex order会按照书写顺训呈现，可以通过order属性改变，数值小的在前面，还可以是负数*
- **flex-grow** *设置或检索弹性盒的扩展比率,根据弹性盒子元素所设置的扩展因子作为比率来分配剩余空间*
- **.flex-shrink** *设置或检索弹性盒的收缩比率,根据弹性盒子元素所设置的收缩因子作为比率来收缩空间*
- **flex-basis** *设置或检索弹性盒伸缩基准值，如果所有子元素的基准值之和大于剩余空间，则会根据每项设置的基准值，按比率伸缩剩余空间*
- **flex**  *flex属性是flex-grow, flex-shrink 和 flex-basis的简写，默认值为0 1 auto。后两个属性可选*
- **align-self** *设置或检索弹性盒子元素在侧轴（纵轴）方向上的对齐方式，可以覆盖父容器align-items的设置*

### 26、动手实现一个左右固定100px，中间自适应的三列布局？(至少三种)

### 代码实现

#### 1.双飞翼布局

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>3-items双飞翼布局</title>
    <style>
        html,
        body {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
        body{
            overflow: hidden;
        }
        .main {
            width: 100%;
            height: 100%;
            float: left;
        }
        .middle {
            margin: 0 100px;
            height: 100%;
            background: blueviolet;
        }
        .left {
            width: 100px;
            height: 100%;
            background: red;
            float: left;
            margin-left: -100%;
        }
        .right {
            width: 100px;
            height: 100%;
            background: red;
            float: left;
            margin-left: -100px;
        }
    </style>
</head>
<body>
    <div class="main">
        <div class="middle"></div>
    </div>
    <div class="left"></div>
    <div class="right"></div>
</body>
</html>
```

#### 2.圣杯布局

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>3-items圣杯布局</title>
    <style>
        html,
        body {
            height: 100%;
            margin: 0;
            padding: 0
        }

        body {
            overflow: hidden;
            padding: 0 100px;
        }
        .main{
            width: 100%;
            height: 100%;
            background: blue;
            float: left;
        }
        .left{
            width:100px;
            height:100%;
            background: red;
            float: left;
            margin-left: -100%;
            position: relative;
            left: -100px;
        }
        .right{
            width: 100px;
            height: 100%;
            background: red;
            float: left;
            margin-left: -100px;
            position: relative;
            right: -100px;
        }
    </style>
</head>

<body>
    <div class="main">mainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmainmain</div>
    <div class="left"></div>
    <div class="right"></div>
</body>
</html>
```

#### 3.浮动布局

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>浮动布局</title>
    <style>
        html,
        body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
        }

        .main {
            height: 100%;
            margin: 0 100px;
            background: blue;
        }

        .left {
            float: left;
            width: 100px;
            height: 100%;
            background: red;
        }

        .right {
            width: 100px;
            height: 100%;
            background: red;
            float: right;
        }
    </style>
</head>

<body>
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</body>

</html>
```

#### 4.position定位

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>position</title>
    <style>
        html,body{
            width: 100%;
            height:100%;
            margin: 0;
            padding:0;
            position:relative;
        }
        .left{
            width: 100px;
            height:100%;
            background-color: red;
            position: absolute;
            left: 0;
            top: 0;
        }
        .right{
            width: 100px;
            height: 100%;
            background-color: red;
            position:absolute;
            top:0;
            right:0;
        }
        .main{
            height: 100%;
            background-color: blue;
            margin: 0 100px;
        }
    </style>
</head>
<body>
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</body>
</html>
```

#### 5.flex

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>flex</title>
    <style>
        html,
        body {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
            background-color: blue;
            display: flex;
            flex-direction:row;
        }
        .left{
            width: 100px;
            height: 100%;
            background-color: brown;
        }
        .main{
            flex:1;
            height: 100%;
            background-color: blue;
        }
        .right{
            width: 100px;
            height: 100%;
            background-color: brown;
        }
    </style>
</head>

<body>
    <div class="left"></div>
    <div class="main">main</div>
    <div class="right"></div>
</body>

</html>
```

#### 6.calc函数

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>calc</title>
    <style>
        html,
        body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
        }

        .left {
            width: 100px;
            height: 100%;
            background-color: red;
            float: left;
        }

        .right {
            width: 100px;
            height: 100%;
            background-color: red;
            float: right;
        }
        .main{
            width: calc(100% - 200px);
            float: left;
            height: 100%;
            background-color: blue;
        }
    </style>
</head>

<body>
    <div class="left"></div>
    <div class="right"></div>
    <div class="main"></div>
</body>

</html>
```



### 27、Css 选择器都有什么，权重是怎么计算的



### 28、`nth-child`和`nth-type-of` 有什么区别



### 29、`<img>`是什么元素



### 30、flex 布局，如何实现把八个元素分两行摆放



### 31、Css 方式实现一个不知道宽高的 div 居中都有哪几种方法



### 32、以下 css 最后是什么颜色
```html
<style>
  div {
    color: red;
  }
  #title {
    color: yellow;
  }
  div.title {
    color: bule;
  }
</style>
<div class="title" id="title">abc</div>
```



### 33、简述 Grid 布局



### 34、屏幕占满和未占满的情况下，使 footer 固定在底部，尽量多种方法



### 35、Css 画一个三角形



### 36、Css 超出省略怎么写，三行超出省略怎么写



### 37、Css inherit、initial、unset 三者的区别



### 38、响应式布局用到的技术，移动端需要注意什么


### 一、响应式布局

Responsive design，意在实现不同屏幕分辨率的终端上浏览网页的不同展示方式。通过响应式设计能使网站在手机和平板电脑上有更好的浏览阅读体验。

传统的开发方式是PC端开发一套，手机端再开发一套，而使用响应式布局只要开发一套就够，缺点就是CSS比较重。


### 二、响应式布局实现方案

#### 1.媒体查询

CSS3媒体查询可以让我们针对不同的媒体类型定义不同的样式，当重置浏览器窗口大小的过程中，页面也会根据浏览器的宽度和高度重新渲染页面。

**1）如何选择屏幕大小分割点**

如何确定媒体查询的分割点也是一个开发中会遇到的问题，不同品牌和型号的设备屏幕分辨率一般都不一样。

选择600px,900px,1200px,1800px作为分割点，也可以选择480px,800px,1400px,1400px作为分割点。

![分割点](http://img-static.yidengxuetang.com/wxapp/issue-img/qid-294-got.png)

如果自己确定分割点不好确定，可以参考经典的响应式布局框架，Bootstrap 是如何进行断点的。

- 超小屏幕手机（<768px）
- 小屏幕 平板（>=768px）
- 中等屏幕 桌面显示器（>=992px）
- 大屏幕 大桌面显示器（>=1200px）

**2）移动优先 OR PC优先**

不管是移动优先还是PC优先，都是依据当随着屏幕宽度增大或减小的时候，后面的样式会覆盖前面的样式。因此，移动端优先首先使用的是min-width，PC端优先使用的max-width。

- 移动优先

```css
/* iphone6 7 8 */
body {
    background-color: yellow;
}
/* iphone 5 */
@media screen and (max-width: 320px) {
    body {
      background-color: red;
    }
}
/* iphoneX */
@media screen and (min-width: 375px) and (-webkit-device-pixel-ratio: 3) {
    body {
      background-color: #0FF000;
    }
}
/* iphone6 7 8 plus */
@media screen and (min-width: 414px) {
    body {
      background-color: blue;
    }
}
/* ipad */
@media screen and (min-width: 768px) {
    body {
      background-color: green;
    }
}
/* ipad pro */
@media screen and (min-width: 1024px) {
    body {
      background-color: #FF00FF;
    }
}
/* pc */
@media screen and (min-width: 1100px) {
    body {
      background-color: black;
    }
}
```

- PC优先

```css
/* pc width > 1024px */
    body {
        background-color: yellow;
    }
/* ipad pro */
@media screen and (max-width: 1024px) {
    body {
        background-color: #FF00FF;
    }
}
/* ipad */
@media screen and (max-width: 768px) {
    body {
        background-color: green;
    }
}
/* iphone6 7 8 plus */
@media screen and (max-width: 414px) {
    body {
        background-color: blue;
    }
}
/* iphoneX */
@media screen and (max-width: 375px) and (-webkit-device-pixel-ratio: 3) {
    body {
        background-color: #0FF000;
    }
}
/* iphone6 7 8 */
@media screen and (max-width: 375px) and (-webkit-device-pixel-ratio: 2) {
    body {
        background-color: #0FF000;
    }
}
/* iphone5 */
@media screen and (max-width: 320px) {
    body {
        background-color: #0FF000;
    }
}
```

#### 2.百分比布局

通过百分比单位，可以使得浏览器中组件的宽和高随着浏览器的高度的变化而变化，从而实现响应式的效果。Bootstrap里面的栅格系统就是利用百分比来定义元素的宽高，CSS3支持最大最小高，可以将百分比和max(min)一起结合使用来定义元素在不同设备下的宽高。

如果使用百分比布局，我们必须要弄清楚css中子元素的百分比到底是相对谁的百分比。

- 子元素的height或width中使用百分比，是相对于子元素的直接父元素，width相对于父元素的width，height相对于父元素的height；
- 子元素的top和bottom如果设置百分比，则相对于直接非static定位(默认定位)的父元素的高度，同样子元素的left和right如果设置百分比，则相对于直接非static定位(默认定位的)父元素的宽度；
- 子元素的padding如果设置百分比，不论是垂直方向或者是水平方向，都相对于直接父亲元素的width，而与父元素的height无关。
- 跟padding一样，margin也是如此，子元素的margin如果设置成百分比，不论是垂直方向还是水平方向，都相对于直接父元素的width；
- border-radius不一样，如果设置border-radius为百分比，则是相对于自身的宽度
- 除了border-radius外，还有比如translate、background-size等都是相对于自身的；

所以百分比布局有明显的两个缺点：

- 计算困难，如果我们要定义一个元素的宽度和高度，按照设计稿，必须换算成百分比单位。
- 可以看出，各个属性中如果使用百分比，相对父元素的属性并不是唯一的。比如width和height相对于父元素的width和height，而margin、padding不管垂直还是水平方向都相对比父元素的宽度、border-radius则是相对于元素自身等等，造成我们使用百分比单位容易使布局问题变得复杂。

#### 3.rem布局

REM是CSS3新增的单位，并且移动端的支持度很高，Android2.x+,ios5+都支持。rem单位都是相对于根元素html的font-size来决定大小的,根元素的font-size相当于提供了一个基准，当页面的size发生变化时，只需要改变font-size的值，那么以rem为固定单位的元素的大小也会发生响应的变化。 因此，如果通过rem来实现响应式的布局，只需要根据视图容器的大小，动态的改变font-size即可（而em是相对于父元素的）。

**1）rem响应式的布局思想**

- 一般不要给元素设置具体的宽度，但是对于一些小图标可以设定具体宽度值
- 高度值可以设置固定值，设计稿有多大，我们就严格有多大
- 所有设置的固定值都用rem做单位（首先在HTML总设置一个基准值：px和rem的对应比例，然后在效果图上获取px值，布局的时候转化为rem值)
- js获取真实屏幕的宽度，让其除以设计稿的宽度，算出比例，把之前的基准值按照比例进行重新的设定，这样项目就可以在移动端自适应了

**2）rem布局的缺点**

在响应式布局中，必须通过js来动态控制根元素font-size的大小，也就是说css样式和js代码有一定的耦合性，且必须将改变font-size的代码放在css样式之前

```js
/*
上述代码中将视图容器分为10份，
font-size用十分之一的宽度来表示，
最后在header标签中执行这段代码，
就可以动态定义font-size的大小，
从而1rem在不同的视觉容器中表示不同的大小，
用rem固定单位可以实现不同容器内布局的自适应。
*/
function refreshRem() {
    var docEl = doc.documentElement;
    var width = docEl.getBoundingClientRect().width;
    var rem = width / 10;
    docEl.style.fontSize = rem + 'px';
    flexible.rem = win.rem = rem;
}
win.addEventListener('resize', refreshRem);

```

REM布局也是目前多屏幕适配的最佳方式。默认情况下我们html标签的font-size为16px,我们利用媒体查询，设置在不同设备下的字体大小。

```css
/* pc width > 1100px */
html{ font-size: 100%;}
body {
    background-color: yellow;
    font-size: 1.5rem;
}
/* ipad pro */
@media screen and (max-width: 1024px) {
    body {
      background-color: #FF00FF;
      font-size: 1.4rem;
    }
}
/* ipad */
@media screen and (max-width: 768px) {
    body {
      background-color: green;
      font-size: 1.3rem;
    }
}
/* iphone6 7 8 plus */
@media screen and (max-width: 414px) {
    body {
      background-color: blue;
      font-size: 1.25rem;
    }
}
/* iphoneX */
@media screen and (max-width: 375px) and (-webkit-device-pixel-ratio: 3) {
    body {
      background-color: #0FF000;
      font-size: 1.125rem;
    }
}
/* iphone6 7 8 */
@media screen and (max-width: 375px) and (-webkit-device-pixel-ratio: 2) {
    body {
      background-color: #0FF000;
      font-size: 1rem;
    }
}
/* iphone5 */
@media screen and (max-width: 320px) {
    body {
      background-color: #0FF000;
      font-size: 0.75rem;
    }
}
```

#### 4.视口单位

css3中引入了一个新的单位vw/vh，与视图窗口有关，vw表示相对于视图窗口的宽度，vh表示相对于视图窗口高度，除了vw和vh外，还有vmin和vmax两个相关的单位。

- vw:相对于视窗的宽度，1vw等于视口宽度的1%，即视窗宽度是100vw
- vh:相对于视窗的高度，1vh等于视口高度的1%，即视窗高度是100vh
- vmin:vw和vh中较小的值
- vmax:vw和vh中较小的值

使用视口单位来实现响应式有两种做法：

**1）仅使用vw作为CSS单位**

- 对于设计稿的尺寸转换为为单位，我们使用Sass函数编译

```js
//iPhone 6尺寸作为设计稿基准
$vm_base: 375; 
@function vw($px) {
    @return ($px / 375) * 100vw;
}
```

- 无论是文本还是布局宽度、间距等都使用vw作为单位

```js
.mod_nav {
    background-color: #fff;
    &_list {
        display: flex;
        padding: vm(15) vm(10) vm(10); // 内间距
        &_item {
            flex: 1;
            text-align: center;
            font-size: vm(10); // 字体大小
            &_logo {
                display: block;
                margin: 0 auto;
                width: vm(40); // 宽度
                height: vm(40); // 高度
                img {
                    display: block;
                    margin: 0 auto;
                    max-width: 100%;
                }
            }
            &_name {
                margin-top: vm(2);
            }
        }
    }
}
```

**2）搭配vw和rem**

虽然采用vw适配后的页面效果很好，但是它是利用视口单位实现的布局，依赖视口大小而自动缩放，无论视口过大还是过小，它也随着时候过大或者过小，失去了最大最小宽度的限制，此时我们可以结合rem来实现布局

- 给根元素大小设置随着视口变化而变化的vw单位，这样就可以实现动态改变其大小
- 限制根元素字体大小的最大最小值，配合body加上最大宽度和最小宽度

```js
// rem 单位换算：定为 75px 只是方便运算，750px-75px、640-64px、1080px-108px，如此类推
$vm_fontsize: 75; // iPhone 6尺寸的根元素大小基准值
@function rem($px) {
     @return ($px / $vm_fontsize ) * 1rem;
}
// 根元素大小使用 vw 单位
$vm_design: 750;
html {
    font-size: ($vm_fontsize / ($vm_design / 2)) * 100vw; 
    // 同时，通过Media Queries 限制根元素最大最小值
    @media screen and (max-width: 320px) {
        font-size: 64px;
    }
    @media screen and (min-width: 540px) {
        font-size: 108px;
    }
}
// body 也增加最大最小宽度限制，避免默认100%宽度的 block 元素跟随 body 而过大过小
body {
    max-width: 540px;
    min-width: 320px;
}
```

#### 5.图片响应式

图片响应式包括两个方面，一个就是大小自适应，这样能够保证图片在不同的屏幕分辨率下出现压缩、拉伸的情况；一个就是根据不同的屏幕分辨率和设备像素比来尽可能选择高分辨率的图片，也就是当在小屏幕上不需要高清图或大图，这样我们用小图代替，就可以减少网络带宽了。

**1）使用max-width（图片自适应）**

图片自适应意思就是图片能随着容器的大小进行缩放

```css
img {
    display: inline-block;
    max-width: 100%;
    height: auto;
}
```

**2）使用srcset**

```html
<img srcset="photo_w350.jpg 1x, photo_w640.jpg 2x" src="photo_w350.jpg" alt="">
```

如果屏幕的dpi = 1的话则加载1倍图，而dpi = 2则加载2倍图，手机和mac基本上dpi都达到了2以上，这样子对于普通屏幕来说不会浪费流量，而对于视网膜屏来说又有高清的体验。

如果浏览器不支持srcset，则默认加载src里面的图片。

**2）使用background-image**

```css
.banner{
  background-image: url(/static/large.jpg);
}

@media screen and (max-width: 767px){
  background-image: url(/static/small.jpg);
}
```

**3）使用picture标签**

解决IE等浏览器不支持 的问题,可以引入 `picturefill.min.js `

```html
<picture>
    <source srcset="banner_w1000.jpg" media="(min-width: 801px)">
    <source srcset="banner_w800.jpg" media="(max-width: 800px)">
    <img src="banner_w800.jpg" alt="">
</picture>

<!-- picturefill.min.js 解决IE等浏览器不支持 <picture> 的问题 -->
<script type="text/javascript" src="js/vendor/picturefill.min.js"></script>
```

#### 6.总结

响应式布局的实现可以通过媒体查询+px,媒体查询+百分比，媒体查询+rem+js,vm/vh,vm/vh +rem这几种方式来实现。但每一种方式都是有缺点的，

媒体查询需要选取主流设备宽度尺寸作为断点针对性写额外的样式进行适配，但这样做会比较麻烦，只能在选取的几个主流设备尺寸下呈现完美适配，另外用户体验也不友好，布局在响应断点范围内的分辨率下维持不变，而在响应断点切换的瞬间，布局带来断层式的切换变化，如同卡带的唱机般“咔咔咔”地一下又一下。

通过百分比来适配首先是计算麻烦，第二各个属性中如果使用百分比，其相对的元素的属性并不是唯一的，这样就造成我们使用百分比单位容易使布局问题变得复杂。

通过采用rem单位的动态计算的弹性布局，则是需要在头部内嵌一段脚本来进行监听分辨率的变化来动态改变根元素字体大小，使得CSS与JS 耦合了在一起。

通过利用纯css视口单位实现适配的页面，是既能解决响应式断层问题，又能解决脚本依赖的问题的，但是兼容性还没有完全能结构接受。


### 三、响应式布局成型方案

现在的css，UI框架等都已经考虑到了适配不同屏幕分辨率的问题，实际项目中我们可以直接使用这些新特性和框架来实现响应式布局。可以有以下选择方案：

- 利用前面介绍的方法自己来实现，比如CSS3 Media Query,rem，vw等
- Flex弹性布局
- Grid网格布局
- Columns栅格系统，往往需要依赖某个UI库，如Bootstrap


### 四、响应式布局的要点

在实际项目中，我们可能需要综合上面的方案，比如用rem来做字体的适配，用srcset来做图片的响应式，宽度可以用rem，flex，栅格系统等来实现响应式，然后可能还需要利用媒体查询来作为响应式布局的基础，因此综合上面的实现方案，项目中实现响应式布局需要注意下面几点：

- 设置viewport
- 媒体查询
- 字体的适配（字体单位）
- 百分比布局
- 图片的适配（图片的响应式）
- 结合flex，grid，BFC，栅格系统等已经成型的方案

### 五、移动端需要注意什么

#### 1.添加禁止浏览器主动缩放功能

涉及到网页开发历史遗留问题，最开始的手机浏览器网页是直接访问电脑网页或访问专门为诺基亚手机开发的WAP页面，对于电脑网页由于手机分辨率太低，浏览器会使用缩放页面的方式来展示原页面，这个也是为什么在手机页面上直接使用document.documentElement.clientWidth获取到的值为 980（之所以是这个值也是因为国外做过调查，那个时候的网页一般宽度都在980px左右），所以为了避免浏览器的自动缩放，需要在手机端的<head>内添加一行以下代码：

```html
<meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=1.0,maximum=1.0,minimum=1.0" />
```

#### 2.移动端字体放大问题

当可视部分的宽度小于480px也就是iPhone横屏时的宽时,需要进行一下处理

- 禁用html节点的字号自动调整。默认情况下，iPhone会将过小的字号放大，我们可以通过 `-webkit-text-size-adjust` 属性进行调整。
- 将main-nav中的字号设置为90%

```css
@media screen and (max-width: 480px) {
    html {
        -webkit-text-size-adjust: none;
    }
    #main-nav a {
        font-size: 90%;
        padding: 10px 8px;
    }
 } 
```

#### 3.移动端1px的问题

在移动端 web 开发中，UI 设计稿中设置边框为 1 像素，前端在开发过程中如果出现 `border:1px`，测试会发现在某些机型上，1px 会比较粗，即是较经典的 移动端 1px 像素问题。 设备的 物理像素[设备像素]和逻辑像素[CSS 像素] 可以使用 `viewport + rem` 或者 `transform: scale(0.5)` 来实现

### 39、布局都有什么方式，float 和 position 有什么区别



### 一、布局方式

1. 静态块级
2. 弹性布局(Flex)
3. 网格布局(Grid)
4. 自适应布局(根据当前访问设备进行多套样式来适配)
5. 响应式布局(通过媒体查询进行适配，rem/em)
6. 浮动布局(float)
7. 定位布局(position)

### 二、float 和 position 有什么区别

#### 1.float

`float: none、left、right、inherit`

**特性**

- 浮动会脱离文档流，并且会随着分辨率和窗口尺寸的变化而变化。
- 浮动后面的元素如果是块级元素，会占据块级元素的文本位置，但会与块级背景和边框重叠。
- 多个浮动不会产生重叠现象。
- 会将块级元素和行内元素变为行内块元素。

#### 2.position

`position: relative，absolute，fixed，static`

**特性**

- relative 和 static 不会脱离文档流。
- absolute 和 fixed 会脱离文档流。
- absolute 根据 relative 定位。fixed 根据 body 定位。
- absolute 和 fixed 会触发 BFC 。
- 定位的优先级高于浮动。




### 40、什么情况会出现浏览器分层

#### 分层与合成

通常页面的组成是非常复杂的，有的页面里要实现一些复杂的动画效果，比如点击菜单时弹出菜单的动画特效，滚动鼠标滚轮时页面滚动的动画效果，当然还有一些炫酷的 3D 动画特效。如果没有采用分层机制，从布局树直接生成目标图片的话，那么每次页面有很小的变化时，都会触发重排或者重绘机制，这种“牵一发而动全身”的绘制策略会严重影响页面的渲染效率。

为了提升每帧的渲染效率，Chrome 引入了分层和合成的机制。

你可以把一张网页想象成是由很多个图片叠加在一起的，每个图片就对应一个图层，Chrome 合成器最终将这些图层合成了用于显示页面的图片。如果你熟悉 PhotoShop 的话，就能很好地理解这个过程了，PhotoShop 中一个项目是由很多图层构成的，每个图层都可以是一张单独图片，可以设置透明度、边框阴影，可以旋转或者设置图层的上下位置，将这些图层叠加在一起后，就能呈现出最终的图片了。

在这个过程中，将素材分解为多个图层的操作就称为分层，最后将这些图层合并到一起的操作就称为合成。所以，分层和合成通常是一起使用的。

考虑到一个页面被划分为两个层，当进行到下一帧的渲染时，上面的一帧可能需要实现某些变换，如平移、旋转、缩放、阴影或者 Alpha 渐变，这时候合成器只需要将两个层进行相应的变化操作就可以了，显卡处理这些操作驾轻就熟，所以这个合成过程时间非常短。


#### 生成层的方式

在某些特定条件下，浏览器会主动将渲染层提至合成层，那么影响 composite 的因素有哪些？

- 3D transforms: translate3d, translateZ 等;
- video, canvas, iframe 等元素;
- 通过 Element.animate() 实现的 opacity 动画转换;
- 通过 СSS 动画实现的 opacity 动画转换;
- position: fixed;
- will-change;
- filter;
- 有合成层后代同时本身 overflow 不为 visible（如果本身是因为明确的定位因素产生的 SelfPaintingLayer，则需要 z-index 不为 auto）
- ...

### 41、BFC 是什么？触发 BFC 的条件是什么？有哪些应用场景？

#### 1.概念

**BFC(Box Formatting context ):**  Box 是 CSS 布局的对象和基本单位，BFC就是页面上的一个隔离的独立 容器，容器里面的子元素不会影响到外面的元素。反之也如此。

块级格式化上下文布局规则

- 内部的BOX会在垂直方向一个接一个的放置；
- 属于同一个BFC的两个相邻Box的margin会重叠；不同BFC就不会；
- 是页面上一个隔离的独立容器，里面的元素不会影响到外面的元素；反之亦然；
- BFC的区域不会和float box重叠；
- 计算BFC的高度，浮动元素也参与计算；

#### 2.触发条件

**触发条件简要概括**

- 根元素
- float属性不为none
- position为absolute或fixed
- overflow不为visible
- display为inline-block, table-cell, table-caption, flex, inline-flex。

**触发条件详细介绍:**

1. 根元素(<html>)
2. 浮动元素（元素的 float 不是 none）
3. 绝对定位元素（元素的 position 为 absolute 或 fixed）
4. 行内块元素（元素的 display 为 inline-block）
5. 表格单元格（元素的 display为 table-cell，HTML表格单元格默认为该值）
6. 表格标题（元素的 display 为 table-caption，HTML表格标题默认为该值）
7. 匿名表格单元格元素（元素的 display为 table、table-row、 table-row-group、table-header-group、table-footer-group（分别是HTML table、row、tbody、thead、tfoot的默认属性）或 inline-table）
8. overflow 值不为 visible 的块元素
9. display 值为 flow-root 的元素
10. contain 值为 layout、content或 paint 的元素
11. 弹性元素（display为 flex 或 inline-flex元素的直接子元素）
12. 网格元素（display为 grid 或 inline-grid 元素的直接子元素）
13. 多列容器（元素的 column-count 或 column-width 不为 auto，包括 column-count 为 1）
14. column-span 为 all 的元素始终会创建一个新的BFC，即使该元素没有包裹在一个多列容器中（标准变更，Chrome bug）。

#### 3.应用场景

**1）清除内部的浮动，触发父元素的BFC属性，会包含float元素；**

防止浮动导致父元素高度塌陷父级设置overflow：hidden,元素float:right;

**2）分属于不同的BFC，可以阻止Margin重叠；**

避免margin重叠,两个块相邻就会导致外边距被折叠，给中间的设置BFC就会避免，方法就是套个父级设置overflow：hidden

**3）阻止元素被浮动元素覆盖，各自是独立的渲染区域；**

**4）自适应两栏布局；**



### 42、通过 link 进来的 css 会阻塞页面渲染吗，Js 会阻塞吗，如果会如何解决？

#### 1.`<link>`标签不会阻塞DOM解析但会阻塞DOM渲染

`<link>`标签并不会像带scr属性的`<script>`标签一样会触发页面paint。浏览器并行解析生成DOM` Tree 和 CSSOM Tree，当两者都解析完毕，才会生成rending tree，页面才会渲染。所以应尽量减小引入样式文件的大小，提高首屏展示速度。


#### 2.`<script>`标签会阻塞DOM的解析和渲染；

`<script>`标签会阻塞DOM解析和渲染，但在阻塞同时，其他线程会解析文档的其余部分（预解析），找出并加载需要通过网络加载的其他资源。通过这种方式，资源可以在并行连接上加载，从而提高总体速度。预解析不会修改解析出来的 DOM 树，只会解析外部资源（例如外部脚本、样式表和图片）的引用。

#### 3.优化

- 合理放置脚本位置
- 预加载 Link preload
- DNS Prefetch 预解析
- script 延迟脚本加载 defer/async


#### 4.总结

html代码中往往会引入一些额外的资源，比如图片、CSS、JS脚本等，图片和CSS这些资源需要通过网络下载或从缓存中直接加载，这些资源不会阻塞html的解析，因为他们不会影响DOM树的生成，但当HTML解析过程中遇到script标签，就会停止html解析流程，转而去加载解析并且执行JS。这是因为浏览器并不知道JS执行是否会改变当前页面的HTML结构，如果JS代码里用了document.write方法来修改html，之前的和html解析就没有任何意义了，这也就是为什么我们一直说要把script标签要放在合适的位置，或者使用async或defer属性来异步加载执行JS。



### 43、Css 如何画出一个扇形，动手实现下

### 答案

**简单版**

```css
/* 简版一  */
.sector1 {
   border-radius: 0  0  0 200px;
   width: 200px;
   height: 200px;
   background: yellowgreen;
}
 /* 简版二  */
.sector1 {
  width: 0;
  height: 0;
  border-width: 100px;
  border-style: solid;
  border-color: transparent transparent red;
  border-radius: 100px;
}

```

**1）实现方式一**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>使用css3绘制任意角度扇形</title>
  <style>
  .pie {
    position: relative;
    margin: 1em auto;
    padding: 0;
    width: 32em;
    height: 32em;
    border-radius: 100%;
    list-style: none;
    overflow: hidden;
    transform: rotate(0deg) /*针对mac safari浏览器兼容*/

  }
  .slice {   /*一个slice最多设置成一个90度的扇形，超过就需要多个slice进行拼接*/
    overflow: hidden;
    position: absolute;
    top: 0;
    right: 0;
    width: 50%;
    height: 50%;
    transform-origin: 0% 100%;/*设置旋转的基准点*/
  }
  .slice-1 {
    transform: rotate(-36deg) skewY(-54deg);/*通过配置rotate和skewY的值来设置扇形的角度和位置*/
    background: #FF0088;
 }
  .slice-2 {
    transform: rotate(-72deg) skewY(-54deg);
    background: #FF0000;
 }
 
  </style>
</head>
<body>
   <ul class='pie'>
      <li class='slice-1 slice'> </li>
      <li class='slice-2 slice'> </li>
  <ul>
</body>
</html>
```


**2）实现方式二**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>扇形绘制</title>
    <style>
      .shanxing {
        position: relative;
        width: 200px;
        height: 200px;
        border-radius: 100px;
        background-color: yellow;
      }
      .sx1 {
        position: absolute;
        width: 200px;
        height: 200px;
        transform: rotate(0deg);
        clip: rect(
          0px,
          100px,
          200px,
          0px
        ); /*这个clip属性用来绘制半圆，在clip的rect范围内的内容显示出来，使用clip属性，元素必须是absolute的 */
        border-radius: 100px;
        background-color: #f00;
        /*-webkit-animation: an1 2s infinite linear; */
      }
      .sx2 {
        position: absolute;
        width: 200px;
        height: 200px;
        transform: rotate(0deg);
        clip: rect(0px, 100px, 200px, 0px);
        border-radius: 100px;
        background-color: #f00;
        /*-webkit-animation: an2 2s infinite linear;*/
      }
      /*绘制一个60度扇形*/
      .shanxing1 .sx1 {
        transform: rotate(-30deg);
      }
      .shanxing1 .sx2 {
        transform: rotate(-150deg);
      }

      /*绘制一个85度扇形*/
      .shanxing2 .sx1 {
        transform: rotate(-45deg);
      }
      .shanxing2 .sx2 {
        transform: rotate(-140deg);
      }

      /*绘制一个向右扇形，90度扇形*/
      .shanxing3 .sx1 {
        transform: rotate(45deg);
      }
      .shanxing3 .sx2 {
        transform: rotate(-45deg);
      }

      /*绘制一个颜色扇形 */
      .shanxing4 .sx1 {
        transform: rotate(45deg);
        background-color: #fff;
      }
      .shanxing4 .sx2 {
        transform: rotate(-45deg);
        background-color: #fff;
      }

      /*绘制一个不同颜色半圆夹角 */
      .shanxing5 .sx1 {
        transform: rotate(45deg);
        background-color: #f00;
      }
      .shanxing5 .sx2 {
        transform: rotate(-45deg);
        background-color: #0f0;
      }
    </style>
  </head>
  <body>
    <h2>CSS之如何绘制任意角度的扇形</h2>
    <div>
      扇形制作原理，底部一个纯色原形， 里面2个相同颜色的半圆，可以是白色,
      内部半圆按一定角度变化，就可以产生出扇形效果
    </div>
    <div class="shanxing">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
    <div class="shanxing shanxing1">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
    <div class="shanxing shanxing2">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
    <div class="shanxing shanxing3">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
    <div class="shanxing shanxing4">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
    <div class="shanxing shanxing5">
      <div class="sx1"></div>
      <div class="sx2"></div>
    </div>
  </body>
</html>
```


### 44、说一下盒子模型，以及标准情况和 IE 下的区别

### 答案

**1.什么是盒模型**

盒模型是css中的一种基础设计模式，web页面中的所有元素都可以当做一个盒模型，每一个盒模型都是由 display，position，float， width，height，margin，padding和border等属性组合所构成的，不同类型的盒模型会有不一样的布局，css中主要有 inline, inline-block, block, table, absolute position, float 等类型。

**2.W3C标准模型和IE的传统模型(IE6以下)**

css中的盒模型有两种：W3C标准模型和IE的传统模型，相同之处是都是对web中元素计算尺寸的模型， 不同之处在于两者的计算方式不同。

w3c盒子模型的范围包括margin、border、padding、content,并且content部分不包含其他部分，IE盒子模型的范围包括margin、border、padding、content,和w3c盒子模型不同的是，IE盒子模型的content部分包含了padding和border

**3.W3C标准模型中元素尺寸的计算方式**

height(空间高度) = 内容高度 + 内距 + 边框 + 外距   （height为内容高度）

width(空间宽度) = 内容宽度 + 内距 + 边框 + 外距    （width为内容宽度）

**4.IE的传统模型中元素尺寸的计算方式**

height(空间高度) = 内容高度 + 外距  （height包含了 元素内容高度，边框， 内距）

width(空间宽度) = 内容宽度 + 外距  （width包含了 元素内容宽度，边框， 内距）

**5.代码示例**

```css
.box{
    border:20px solid;
    padding:30px;
    margin:30px;
    background:red;
    width:300px;
}
/* 标准模型 空间宽度 = 300 + 20*2 + 30*2 + 30*2  */
/* IE的传统模型 空间宽度  = 300 + 30*2  */
/* IE的传统模型中的width是包括了padding和border的，而标准模型不包括，不管padding和borde加多少内容区域的宽度不会改变。 */
```

**6.CSS如何设置标准模型和IE模型**

box-sizing: content-box   标准盒模型

box-sizing: border-box   IE的传统模型


### 45、说一下 Css 预处理器，Less 带来的好处？

### 一、CSS预处理器

为CSS增加**编程特性**的拓展语言，可以使用变量、简单逻辑判断、函数等基本编程技巧；

CSS预处理器编译输出还是标准的CSS样式

Less、Sass都是是动态的样式语言，是CSS预处理器,CSS上的一种抽象层。他们是一种特殊的语法/语言而编译成CSS。

less变量符号是@，Sass变量符号是$;

### 二、解决的问题

- CSS语法不够强大，因为**无法嵌套**导致有很多**重复的选择器**
- 没有变量和合理的样式**复用机制**，导致逻辑上相关的属性值只能以字面量的形式重复输出，难以维护

### 三、常用规范

变量、嵌套语法、混入、@import、运算、函数、继承等

### 四、CSS预处理器带来的好处

- CSS代码更加整洁，更易维护，代码量更少
- 修改更快,基础颜色使用变量,一处动处处动.
- 常用代码使用代码块,节省大量代码
- CSS嵌套减少了大量的重复选择器，避免一些低级错误
- 变量、混入大大提升了样式的复用性
- 额外的工具类似颜色函数(`lighten`, `darken`, `transparentize`等等)，mixins，loops，这些方法使css更像一个真正的编程语言，让开发者能够有能力生成更加复杂的css样式。

> 编译需要一定时间

### 46、说一下什么是重绘重排，哪些操作会造成重绘重排



### 47、使用 Css 实现一个水波纹效果



### 48、position 定位都有什么属性（不仅仅是绝对定位和相对定位/fix 定位）



### 49、写出打印结果，并解释为什么
```js
var a = { k1: 1 };
var b = a;
a.k3 = a = { k2: 2 };
console.log(a); // ?
console.log(b); // ?
```



### 50、实现一个多并发的请求
```js
let urls = ['http://dcdapp.com', …];
/*
	*实现一个方法，比如每次并发的执行三个请求，如果超时（timeout）就输入null，直到全部请求完
	*batchGet(urls, batchnum=3, timeout=3000);
	*urls是一个请求的数组，每一项是一个url
	*最后按照输入的顺序返回结果数组[]
*/
```


### 代码实现

并发请求，而且不能被请求失败影响 可以考虑Promise.allsettled

```js
async function batchGet(urls, batchnum = 3, timeout = 3000) {
  let ret = [];
  while (urls.length > 0) {
    var preList = urls.splice(0, batchnum);
    let requestList = preList.map((url) => {
      return request(url, timeout);
    });
    const result = await Promise.allsettled(requestList);
    ret.concat(
      result.map((item) => {
        if (item.status === "rejected") {
          return null;
        } else {
          return item.value;
        }
      })
    );
  }
  return ret;
}
function request(url, timeout) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      reject();
    }, timeout);
    // ajax发送请求
    ajax({ url }, (data) => {
      resolve(data);
    });
  });
}
// urls为一个不定长的数组
batchGet(["http1", "http2", "http3"]);
```

