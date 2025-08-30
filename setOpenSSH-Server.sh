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
echo -e "\n${GREEN}"$0" 开始${NC}"


# [1/4] 安装 OpenSSH-Server 并设置开机自启和重启
echo -ne "\n${CYAN}[1/4] 安装 OpenSSH-Server 并设置开机自启和重启    ${NC}"

apt-get remove -y openssh-server > /dev/null
apt-get install -y openssh-server > /dev/null 
systemctl enable ssh 2> /dev/null
systemctl restart ssh

if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [2/4] 备份 /etc/ssh/sshd_config
echo -ne "${CYAN}\n[2/4] 备份 /etc/ssh/sshd_config    ${NC}"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d) 

if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

# [3/4] 向 /etc/ssh/sshd_config 写入配置
echo -ne "${CYAN}\n[3/4] 向 /etc/ssh/sshd_config 写入配置    ${NC}"

tee /etc/ssh/sshd_config > /dev/null <<'EOF'
Port 22
UsePrivilegeSeparation no
PasswordAuthentication yes
PermitRootLogin yes
AllowUsers xsl  # "xsl" 登陆用户名

# ----------------- 以下提前留出公钥配置（可选）-----------------------
RSAAuthentication yes
PubKeyAUthentication yes
EOF

if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi


# [4/4] 重启 ssh 服务
echo -ne "${CYAN}\n[4/4] 重启 ssh 服务    ${NC}"

systemctl restart ssh

if [ $? -ne 0 ]; then
    echo -e "${RED}错误${NC}"
    exit 1
else
    echo -e "${GREEN}完成${NC}"
fi

echo -e "${GREEN}\n"$0" 结束\n${NC}"

# ------------------------------------------------------------ end
# 删除连接者本地的key  （ssh-keygen -R 192.168.10.10）