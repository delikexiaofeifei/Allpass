# Allpass

## 介绍
Allpass是一款简单的私密数据管理软件，包括支持密码存储与卡片信息存储。采用Flutter构建，目前完成了针对安卓9与10的适配。

- 密码与卡片信息管理
- 支持指纹解锁软件
- AES256位加密
- 支持从csv文件中导入或导出为csv文件
- 支持从Chrome中导入密码
- 支持从剪贴板中导入密码
- 标签功能
- 文件夹功能
- 收藏功能
- 备注功能


## 文件结构

- dao/ 与数据库交互层
- model/ 密码或卡片实体类
- pages/ 页面
- params/ 软件相关参数
- provider/ 状态管理
- route/ 路由管理
- services/ 服务管理，包括生物识别授权及路由服务
- utils/ 工具
- widgets/ 自定义组件

## 命名规范

### Dart文件
1. dart文件采用下划线命名方式；
2. 类采取大驼峰命名法，变量、常量、函数名采用小驼峰命名法；
3. 导包as后的名称使用小写+下划线；
4. 导包顺序为：
    Dart SDK; flutter内的库; 第三方库; 自己的库; 相对路径引用;

### 数据库相关
1. 数据库表名使用下划线命名方式，且表名开头的第一个单词为`allpass`；
2. 表的列名与model相同，采用小写驼峰命名方式；

# LICENSE
[![License](https://img.shields.io/badge/license-Apache%202-green.svg)](https://www.apache.org/licenses/LICENSE-2.0)