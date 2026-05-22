# EmbyCustomJS_Css

[中文](README.md)
- **Note the risk of cross-site scripting attacks**
- **This plugin is based on mediabrowser.server.core 4.8.0.24-beta**
- Scripts (Copy code to custom JavaScript or Css)
  - [Telegram Channel](https://t.me/embycustomcssjs)
  - OSD related code cannot be added by JavaScript and Css for the time being

## How to use
### modify back-end (Server)
- Copy `src\Emby.CustomCssJS.dll` to `programdata\plugins`

### modify front-end (Server and Client)
- Server
  - Copy `src\CustomCssJS.js` to `system\dashboard-ui\modules`
  - modify `\system\dashboard-ui\app.js`
    - Add `list.push("./modules/CustomCssJS.js"),` before `Promise.all(list.map(loadPlugin))` in `start()`
  
      ```
      list.push("./modules/CustomCssJS.js"),
      Promise.all(list.map(loadPlugin))
      ```
- Desktop Client
  - Copy `src\CustomCssJS.js` to `electronapp\plugins`


- App (Android)
  - Copy `src\CustomCssJS.js` to `assets\www\modules`
  - modify `assets\www\app.js`
    - Add `list.push("./modules/CustomCssJS.js"),` before `Promise.all(list.map(loadPlugin))` in `start()`
  
      ```
      list.push("./modules/CustomCssJS.js"),
      Promise.all(list.map(loadPlugin))
      ```
  - modify `assets\www\native\android\apphost.js`
    - Set `features.restrictedplugins` to `false`
  
      ```
      features.restrictedplugins = false;
      ```
***
- State config of Server Scripts stored in `localStorage`, key: `customcssServerConfig_${sercerID}` and `customjsServerConfig_${sercerID}`
- State config of Local Scripts stored in `localStorage`, key: `customcssLocalConfig` and `customjsLocalConfig`
- If error occurred, del these data in `localStorage`


## Admin page：
  - Provide scripts for All users, User can choose to use it or not unless the script is forced on

  ![photo_2023-05-14_21-45-18](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/274dc810-0fff-4d0c-9fe0-33cbba5fbf4f)

  

## User page：
  - Choose to use scripts provided by the admin or not
  - Add your own scripts which are stored in localStorage

  ![photo_2023-05-14_21-45-22](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/1d89c3d4-a393-448e-8c4a-78c9d63bde65)

- The script loading situation showed in the console

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/0582e5a7-8539-4d4d-a360-7affe836f133)
  
## Code editor is provided

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/b044e5e0-0bb9-4bc6-bdcc-ad764d1cb607)
  
  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/666c385c-457b-4949-ae32-25c8bf6621ae)
