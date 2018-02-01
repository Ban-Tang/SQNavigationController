# SQNavigationController

### 介绍

* `SQNavigationController`继承自 UINavigationController，支持全屏滑动返回，部分 API 实现了对 UIAppearance 的支持
* 导航条采用自定义`SQNavigationBar`，隐藏系统的 UINavigationBar，更好的兼容不同 OS 版本
* `SQNavigationBar`的设计完全遵循系统 UINavigationBar 的 API 设计，使用更加方便
* `SQNavigationController `会为二级页面自动创建返回按钮
* 采用 KVC 替换 UIViewController 的 navigationItem 为 `SQNavigationItem`，实现外部系统方式对导航条的设置
* 对外接口全文档覆盖

### 使用方法

* 直接创建`SQNavigationController`作为自己的导航
* 导航条的基础操作，比如设置 title、barbutton，可以直接按照系统的方式使用`self.navigationItem.leftBarButtonItem = your item`
* 返回按钮可以通过全局属性`globalBackBarButtonItem`进行设置

