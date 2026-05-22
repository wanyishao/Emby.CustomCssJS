#!/bin/bash

read -p "请输入 Emby 容器名称:" name

echo "Emby-css安装中...
1.先检查插件
2.再修改首页html"

# 【核心修复 1】开始前彻底清理宿主机本地可能残留的临时文件，防止缓存污染
rm -f ./app.js ./app.js.bak ./CustomCssJS.js ./Emby.CustomCssJS.dll

# 使用 docker exec 检查插件是否存在  
if docker exec "$name" test -f "/config/plugins/Emby.CustomCssJS.dll"; then  
    echo "插件已安装过，无需重复安装！"  
else  
    # 安装插件
    wget -q --no-check-certificate https://raw.githubusercontent.com/Shurelol/Emby.CustomCssJS/main/src/Emby.CustomCssJS.dll -O Emby.CustomCssJS.dll
    docker cp ./Emby.CustomCssJS.dll $name:/config/plugins/
    docker exec $name chmod 755 /config/plugins/Emby.CustomCssJS.dll
    echo "插件首次安装！"  
fi

# 下载所需 JS 文件到系统
wget -q --no-check-certificate https://raw.githubusercontent.com/Shurelol/Emby.CustomCssJS/main/src/CustomCssJS.js -O CustomCssJS.js  

# 从系统复制文件到容器内
docker cp ./CustomCssJS.js $name:/system/dashboard-ui/modules/

# 主安装程序
function Installing() {  
    # 读取单行文件内容
    content=$(cat ./app.js)    
    
    # 注入的代码和特征码
    code1='list.push("./modules/CustomCssJS.js")'    
    code2='Promise.all(list.map(loadPlugin))'      
    
    # 防重复检查
    if [[ "$content" == *"$code1"* ]]; then
        echo "app.js 中已存在注入代码，跳过修改。"
        return
    fi

    echo "正在向单行 app.js 精准注入代码..."
    
    # 核心修改：利用 Bash 内置替换，直接在单行中完成插入，绝对不产生任何换行符
    new_content="${content/$code2/$code1,$code2}"  
    
    # 使用 printf 确保写入文件时不会在末尾自动添加换行符，严格保持纯单行
    printf "%s" "$new_content" > ./app.js
    
    # 覆盖容器内的 app.js 文件
    docker cp ./app.js $name:/system/dashboard-ui/app.js
    echo "成功！app.js 修改并应用成功！"
}

# 【核心修复 2】明确指定本地相对路径 ./app.js，确保从容器拉取的文件100%覆盖本地
docker cp $name:/system/dashboard-ui/app.js ./app.js

if ! grep -q "CustomCssJS.js" ./app.js; then
    echo "检测到原版 app.js，正在备份并注入..."
    cp ./app.js ./app.js.bak
    docker exec $name mkdir -p /system/dashboard-ui/bak/
    docker cp ./app.js $name:/system/dashboard-ui/bak/app.js
    Installing
else
    echo "检测到当前 app.js 已经是修改版，尝试寻找原版备份..."
    if docker exec "$name" test -f "/system/dashboard-ui/bak/app.js"; then
        docker cp $name:/system/dashboard-ui/bak/app.js ./app.js
        Installing
    else
        echo "警告：容器内未找到原版备份！"
        echo "由于原文件是单行压缩文件，为了安全，放弃强行修改，防止损坏文件。"
        echo "提示：请先在当前目录下手动执行 [rm -f app.js]，然后重启 Emby 容器再运行此脚本。"
    fi
fi

# 清理本次运行产生的本地临时文件
rm -f ./app.js ./app.js.bak ./CustomCssJS.js ./Emby.CustomCssJS.dll
