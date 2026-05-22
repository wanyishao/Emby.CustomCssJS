#!/bin/bash

read -p "请输入 Emby 容器名称:" name

echo "Emby-css安装中...
1.先检查插件
2.再修改首页html"

# 1. 检查并安装 dll 插件 (去除了 -it 参数以保证兼容性)
if docker exec "$name" test -f "/config/plugins/Emby.CustomCssJS.dll"; then  
    echo "插件已安装过，无需重复安装！"  
else  
    wget -q --no-check-certificate https://raw.githubusercontent.com/Shurelol/Emby.CustomCssJS/main/src/Emby.CustomCssJS.dll -O /tmp/Emby.CustomCssJS.dll
    docker cp /tmp/Emby.CustomCssJS.dll "$name":/config/plugins/
    docker exec "$name" chmod 755 /config/plugins/Emby.CustomCssJS.dll
    echo "插件首次安装！"  
fi

# 2. 检查并安装 JS 核心模块
wget -q --no-check-certificate https://raw.githubusercontent.com/Shurelol/Emby.CustomCssJS/main/src/CustomCssJS.js -O /tmp/CustomCssJS.js  
docker exec "$name" mkdir -p /system/dashboard-ui/modules/
docker cp /tmp/CustomCssJS.js "$name":/system/dashboard-ui/modules/

# 3. 处理 app.js (使用独立工作目录防止本地文件污染)
WORK_DIR="/tmp/emby_css_workspace"
mkdir -p "$WORK_DIR"
APP_JS="$WORK_DIR/app.js"

# 提取当前容器内的 app.js
docker cp "$name":/system/dashboard-ui/app.js "$APP_JS"

# 核心注入逻辑：使用 sed 替代繁琐的 Bash 替换，专门针对单行大文件，安全稳定
function Installing() {  
    # 注入的目标代码：将 Promise.all 替换为带有 list.push 的版本
    sed -i 's|Promise.all(list.map(loadPlugin))|list.push("./modules/CustomCssJS.js"),Promise.all(list.map(loadPlugin))|g' "$APP_JS"
    docker cp "$APP_JS" "$name":/system/dashboard-ui/
}

# 逻辑判断
count=$(grep -c "CustomCssJS.js" "$APP_JS")

if [ "$count" -eq 0 ]; then
    echo "检测到纯净版 app.js，正在进行首次注入..."
    # 首次注入前，在容器内创建备份
    docker exec "$name" mkdir -p /system/dashboard-ui/bak/
    docker cp "$APP_JS" "$name":/system/dashboard-ui/bak/app.js
    Installing
    echo "成功！app.js 首次安装并修改完成！"
else
    echo "检测到 app.js 已经被注入过代码。"
    # 防御性判断：检查容器内到底有没有备份文件
    if docker exec "$name" test -f "/system/dashboard-ui/bak/app.js"; then
        echo "找到原版备份文件，正在从备份恢复并重新注入..."
        docker cp "$name":/system/dashboard-ui/bak/app.js "$APP_JS"
        Installing
        echo "成功！app.js 已基于备份重新修改！"
    else
        # 核心修复点：如果没有备份，说明之前由于意外丢失了备份文件。
        # 既然现在已经是修改好的状态，直接跳过即可，绝不能去 cp 不存在的文件。
        echo "警告：app.js 已是修改状态，但容器内未找到原版备份文件。"
        echo "为了防止文件损坏，本次直接跳过 app.js 的修改。"
        echo "成功！前端模块已确认加载。"
    fi
fi 

# 清理所有运行产生的临时文件
rm -rf "$WORK_DIR" /tmp/Emby.CustomCssJS.dll /tmp/CustomCssJS.js
