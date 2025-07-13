# 安装 OpenSSH-Server 并配置

set -euo pipefail

# 先卸载
sudo apt-get remove openssh-server

# 安装
sudo apt-get install openssh-server -y

# 重启ssh 服务
sudo service ssh --full-restart

# 自动启动
sudo systemctl enable ssh

# 备份
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 

# 写入配置
cat <<EOF | sudo tee /etc/ssh/sshd_config > /dev/null
Port 22
UsePrivilegeSeparation no
PasswordAuthentication yes
PermitRootLogin yes
AllowUsers xsl # 这里的 "xsl" 改成你自己的登陆用户名
# ----------------- 以下提前留出公钥配置（可选）-----------------------
RSAAuthentication yes
PubKeyAUthentication yes
EOF
    if [ $? -ne 0 ]; then
        echo "错误：写入失败"
        exit 1
    fi

sudo service ssh --full-restart


# 删除连接者本地的key  （ssh-keygen -R 192.168.10.10）
