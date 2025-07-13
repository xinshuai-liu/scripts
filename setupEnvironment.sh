#!/bin/bash
set -euo pipefail

change_apt_source() {
    # 更换APT源为南大源（Ubuntu 22.04）
    echo "正在更换APT源..."
    
    # 备份原有sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if [ $? -ne 0 ]; then
        echo "错误：备份sources.list失败"
        exit 1
    fi
    
    # 写入南大源
    cat <<EOF | sudo tee /etc/apt/sources.list >/dev/null
# 默认注释了源码仓库，如有需要可自行取消注释
deb https://mirrors.nju.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.nju.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.nju.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF

    if [ $? -ne 0 ]; then
        echo "错误：写入新源失败"
        exit 1
    fi
    
    echo "APT源已成功更换为南大源"
}

# 执行函数
change_apt_source

# 更新软件列表
echo "正在更新软件列表..."
sudo apt update

echo "正在更新..."
sudo apt upgrade -y

# 关闭防火墙
echo "关闭防火墙..."
sudo ufw disable

# 安装必要工具
echo ""$'\n'"=== 安装build-essential ==="$'\n'"----------------------------------------"
sudo apt install build-essential -y    # build-essential packages, include binary utilities, gcc, make, and so on

echo ""$'\n'"=== 安装 man ==="$'\n'"----------------------------------------"
sudo apt install man -y                # on-line reference manual

echo ""$'\n'"=== 安装 gcc-doc ==="$'\n'"----------------------------------------"
sudo apt install gcc-doc -y            # on-line reference manual for gcc

echo ""$'\n'"=== 安装 gdb ==="$'\n'"----------------------------------------"
sudo apt install gdb -y                # GNU debugger

echo ""$'\n'"=== 安装 git ==="$'\n'"----------------------------------------"
sudo apt install git -y                # revision control system

echo ""$'\n'"=== 安装 libreadline-dev ==="$'\n'"----------------------------------------"
sudo apt install libreadline-dev -y    # a library used later

echo ""$'\n'"=== 安装 libsdl2-dev ==="$'\n'"----------------------------------------"
sudo apt install libsdl2-dev -y        # a library used later

echo ""$'\n'"=== 安装 vim ==="$'\n'"----------------------------------------"
sudo apt install vim -y

echo ""$'\n'"=== 安装 cmake ==="$'\n'"----------------------------------------"
sudo apt install cmake -y

echo ""$'\n'"=== 安装 python3 ==="$'\n'"----------------------------------------"
sudo apt install python3 -y

echo ""$'\n'"=== 安装 net-tools ==="$'\n'"----------------------------------------"
sudo apt install net-tools

# echo ""$'\n'"=== 安装 docker and docker-compose ==="$'\n'"----------------------------------------"
# chmod +x ./docker-install.py
# sudo python3 docker-install.py


