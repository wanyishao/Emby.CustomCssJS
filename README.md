# Emby自定义JavaScript及Css

[English](README_EN.md)
- **注意XSS风险，出现任何问题后果自负**
- **此插件基于 mediabrowser.server.core 4.8.0.24-beta**
- 服务端脚本启用信息储存在`localStorage`，键值为`customcssServerConfig_${sercerID}`和`customjsServerConfig_${sercerID}`
- 本地脚本启用信息储存在`localStorage`，键值为`customcssLocalConfig`和`customjsLocalConfig`
- 如启用脚本后，无法进入emby，删除`localStorage`中相应数据即可
- 脚本（粘贴代码到自定义JavaScript或Css）
  - [Telegram频道](https://t.me/embycustomcssjs)
  - 弹幕相关插件暂时无法通过JavaScript及Css添加

## **使用说明**
  ### EMBY（Docker服务器端）安装方法
- 本方案仅`emby/embyserver:beta`镜像测试有效，其他镜像请自行测试
- root账户登录ssh，输入以下指令一键安装
```
wget -O script.sh --no-check-certificate https://raw.githubusercontent.com/Shurelol/Emby.CustomCssJS/main/src/script.sh && bash script.sh
```
- 服务器端安装完成，重启容器，网页端的控制台会多出一个自定义JS和CSS的插件，插件内输入自定义js和css代码即可实现对应功能
- 如果不显示插件，请检查映射的`config`文件夹权限是否正确！

### 修改后端（服务端）
- 复制`src\Emby.CustomCssJS.dll`到`programdata\plugins`

### 修改前端（服务端和客户端）
- 服务端
  - 复制`src\CustomCssJS.js`到`system\dashboard-ui\modules`
  - 修改`system\dashboard-ui\app.js`
    - 函数`start()`中`Promise.all(list.map(loadPlugin))`前新增`list.push("./modules/CustomCssJS.js"),`  

      ```
      list.push("./modules/CustomCssJS.js"),
      Promise.all(list.map(loadPlugin))
      ```
- 桌面客户端
  - 复制`src\CustomCssJS.js`到`electronapp\plugins`


- 移动应用（安卓）
  - 复制`src\CustomCssJS.js`到`assets\www\modules`
  - 修改`assets\www\app.js`
    - 函数`start()`中`Promise.all(list.map(loadPlugin))`前新增`list.push("./modules/CustomCssJS.js"),`  

      ```
      list.push("./modules/CustomCssJS.js"),
      Promise.all(list.map(loadPlugin))
      ```
  - 修改`assets\www\native\android\apphost.js`
    - `features.restrictedplugins`设为`false`  

      ```
      features.restrictedplugins = false;
      ```
***

## 管理员页面：
  - 为所有用户提供脚本，用户可以选择使用（强制开启的强制使用）

  ![photo_2023-05-14_21-45-18](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/b3890993-e5e7-497f-915c-8df75c53f64a)
  

## 用户页面：
  - 管理员提供的脚本可以选择使用
  - 用户可自行添加脚本（储存在localStorage）
  
  ![photo_2023-05-14_21-45-22](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/25309616-bfa1-464c-94a8-e29e500d5278)

## 控制台中可查看脚本加载情况

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/7874ebc0-806a-4d08-b3f3-d4b46809c5d7)
  
# 编辑界面提供代码编辑器

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/b6e486f9-7a08-428d-b8e4-4660d98685d7)
  
  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/868d176d-366a-4f8f-b2cd-7571fe1f9b86)
