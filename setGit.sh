#!/bin/bash

# 设置参数
set -euo pipefail

source ./common.sh

KEY_FILE_NAME="$HOME/.ssh/id_rsa_github"

# -----------------------------------------------------------------
# ------------------------------------------------------ start ----
# -----------------------------------------------------------------
echo -e "${GREEN}\n"$0" 开始\n${NC}"

read -p "请输入用户名：" user_name
read -p "请输入邮箱名：" user_email

# [1/6] 验证Git存在
echo -ne "${CYAN}\n[1/6] 验证Git存在    ${NC}"

git_version="$(git --version 2>/dev/null)"
if [ ! -z "${git_version}" ]; then
    echo -e "${GREEN}${git_version}${NC}"
else
    echo -e "${RED}Git is not installed.${NC}"
    exit 1
fi

# [2/6] 设置用户名
echo -ne "${CYAN}\n[2/6] 设置用户名    ${NC}"

if ! git config --global user.name "${user_name}"; then
    echo -e "${RED}$?${NC}"
else
    echo -e "${GREEN}$(git config user.name)${NC}"
fi

# [3/6] 设置邮箱名
echo -ne "${CYAN}\n[3/6] 设置邮箱名    ${NC}"

if ! git config --global user.email "${user_email}"; then
    echo -e "${RED}$?${NC}"
else
    echo -e "${GREEN}$(git config user.email)${NC}"
fi

# [4/6] 生成SSH密钥
echo -ne "${CYAN}\n[4/6] 生成SSH密钥    ${NC}"

ssh-keygen -t rsa -C "${user_email}" -f "${KEY_FILE_NAME}" -N "" > /dev/null <<< y
if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [5/6] 配置ssh的config文件
echo -ne "${CYAN}\n[5/6] 配置ssh的config文件    ${NC}"

mkdir -p "$HOME/.ssh"

if [ ! -f $HOME/.ssh/config ]; then
    touch $HOME/.ssh/config
    chmod 600 $HOME/.ssh/config
fi

if ! grep -q "^Host github.com" "$HOME/.ssh/config"; then
tee -a $HOME/.ssh/config > /dev/null << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github
EOF
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [6/6] Github添加SSH密钥
echo -e "${CYAN}\n[6/6] Github添加SSH密钥${NC}"

PUBLIC_KEY=$(cat "${KEY_FILE_NAME}.pub" 2>/dev/null)
if [ -z "${PUBLIC_KEY}" ]; then
    echo -e "${RED}ssh_key: ${KEY_FILE_NAME}.pub 不存在${NC}"
    exit 1
fi

echo -e "${MAGENTA}\n[1/3] 访问 https://github.com/settings/ssh/new${NC}"
echo -e "${MAGENTA}[2/3] 复制以下内容到GitHub中${NC}"
echo -e "${BLACK}Title${NC}"
echo -e "${YELLOW}"ubuntu-$(whoami)"${NC}"
echo -e "${BLACK}Key${NC}"
echo -e "${YELLOW}${PUBLIC_KEY}${NC}"
echo -e "${MAGENTA}[3/3] 测试 ssh -T -i ~/.ssh/id_rsa_github git@github.com${NC}"
# echo -e "${MAGENTA}[3/3] 测试 ssh -T git@github.com${NC}"

echo -e "${GREEN}\n"$0" 结束\n${NC}"
# -----------------------------------------------------------------
# -------------------------------------------------------- end ----
# -----------------------------------------------------------------