#!/bin/bash

# 设置参数
set -euo pipefail

source ./common.sh

if [[ $EUID -ne 0 ]]; then
    echo "错误: 此脚本必须以 root 权限运行" >&2
    echo "请使用 sudo 运行此脚本: sudo $0" >&2
    exit 1
fi

# -----------------------------------------------------------------
# ------------------------------------------------------ start ----
# -----------------------------------------------------------------
echo -e "${GREEN}\n"$0" 开始\n${NC}"

packages=(
    "build-essential" 
    "man" 
    "gcc-doc"
    "gdb"
    "git"
    "libreadline-dev" 
    "libsdl2-dev"
    "vim"
    "cmake"
    "python3"
)

for pkg in "${packages[@]}"; do
    
    apt-get install -y "${pkg}" > /dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误：安装 ${pkg}    失败${NC}"
        exit 1
    else
        echo -e "安装 ${pkg}    ${GREEN}完成${NC}"
    fi
done

echo -e "${GREEN}\n"$0" 结束\n${NC}"
# -----------------------------------------------------------------
# -------------------------------------------------------- end ----
# -----------------------------------------------------------------