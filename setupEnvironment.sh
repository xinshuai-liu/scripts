#!/bin/bash

# 设置参数
set -euo pipefail

source ./common.sh

if [[ $EUID -ne 0 ]]; then
    echo "错误: 此脚本必须以 root 权限运行" >&2
    echo "请使用 sudo 运行此脚本: sudo $0" >&2
    exit 1
fi

# -------------------------------------------------------------------
# -------------------------------------------------------- start ----
# -------------------------------------------------------------------
echo -e "${GREEN}\n"$0" 开始${NC}"

# [1/3] 更换APT源为南大源（Ubuntu 22.04）
echo -e "${CYAN}[1/3] 更换APT源为南大源\n${NC}"

# [1/2] 备份 /etc/apt/sources.list
echo -ne "${MAGENTA}[1/2] 备份 /etc/apt/sources.list    ${NC}"

cp -i /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d-%H%M%S) 
if [ $? -ne 0 ]; then
    echo "错误：备份sources.list失败"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi


# [2/2] 填写资源地址
echo -ne "${MAGENTA}[2/2] 填写资源地址    ${NC}"
# exit 1

tee /etc/apt/sources.list > /dev/null << 'EOF'
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
    echo -e "${RED}错误：写入新源失败${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [2/3] 更新软件列表
echo -e "${CYAN}\n[2/3] 更新软件列表${NC}"

apt-get update

if [ $? -ne 0 ]; then
    echo "${RED}错误：更新软件列表失败${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [3/3] 更新软件
echo -e "${CYAN}\n[3/3] 更新软件${NC}"

apt-get upgrade -y

if [ $? -ne 0 ]; then
    echo "${RED}错误：更新软件失败${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

echo -e "\n${GREEN}"$0" 结束${NC}\n"