#!/bin/bash

# 设置参数
set -euo pipefail


# ------------------------------------------------------------------------------
# ---- log function ------------------------------------------------------------
# ------------------------------------------------------------------------------
log_error() {
    echo -e "\033[0;31m[$(date '+%H:%M:%S')] 错误: $1\033[0m" >&2;
}
log_success() {
    echo -e "\033[0;32m[$(date '+%H:%M:%S')] 成功: $1\033[0m";
}
log_warn() {
    echo -e "\033[0;33m[$(date '+%H:%M:%S')] 警告: $1\033[0m";
}
log_info() {
    echo -e "\033[0;34m[$(date '+%H:%M:%S')] 信息: $1\033[0m";
}

backup_config_file() {
    log_info "正在备份 $1"
    filename=$(basename "$1")
    cp -i "$1" "./${filename}.bak.$(date +%Y%m%d-%H%M%S)" 
    if [ $? -ne 0 ]; then
        log_error "错误：备份 ${filename} 失败"
        return 1
    fi
}

set_mirrors_nju() {
    tee /etc/apt/sources.list > /dev/null << 'EOF'
    deb https://mirrors.nju.edu.cn/ubuntu/ jammy main restricted universe multiverse
    deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy main restricted universe multiverse

    deb https://mirrors.nju.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
    deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

    deb https://mirrors.nju.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
    deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

    deb https://mirrors.nju.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
    deb-src https://mirrors.nju.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
EOF
}

set_sshd_config() {
    tee /etc/ssh/sshd_config > /dev/null <<'EOF'
Port 22
UsePrivilegeSeparation no
PasswordAuthentication yes
PermitRootLogin yes
AllowUsers lxs  #  登陆用户名

# ----------------- 以下提前留出公钥配置（可选）-----------------------
RSAAuthentication yes
PubKeyAUthentication yes
EOF
}

# ------------------------------------------------------------------------------
# ---- start -------------------------------------------------------------------
# ------------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    log_error "请使用 sudo 运行此脚本: sudo $0"
    exit 1
fi

ping -c 1 -W 3 www.baidu.com > /dev/null 2>&1 || {
    log_error "网络异常"
    exit 1
}

# 更换APT源
log_info "更换APT源为南大源（Ubuntu 22.04）"
backup_config_file "/etc/apt/sources.list"
set_mirrors_nju
log_success "完成"

log_info "更新软件列表"
apt-get update
apt-get upgrade -y
log_success "完成"

# 下载软件
packages=(
    "vim"
    "git"
    "python3"
    "build-essential" 
    "man" 
    "gdb"
    "cmake"
    "libreadline-dev"
    "openssh-server"
)
log_info "下载软件 ${packages}"
for pkg in "${packages[@]}"; do
    log_info "    安装 ${pkg}    "
    apt-get install -y "${pkg}" > /dev/null
    if [ $? -ne 0 ]; then
        log_error "    失败"
        continue
    else
        log_success "    完成"
    fi
done
log_success "完成"

# OpenSSH-Server 开机自启、修改配置文件、重启
log_info "OpenSSH-Server 开机自启、修改配置文件、重启"

systemctl enable ssh 2> /dev/null
systemctl restart ssh
backup_config_file "/etc/ssh/sshd_config"
set_sshd_config
systemctl restart ssh

if [ $? -ne 0 ]; then
    log_error "失败"
    exit 1
else
    log_success "完成"
fi
log_info "注：删除连接者本地的key  （ssh-keygen -R 192.168.10.10）"
# -----------------------------------------------------------------
# -------------------------------------------------------- end ----
# -----------------------------------------------------------------
