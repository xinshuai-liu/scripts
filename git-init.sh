#!/bin/bash

get_git_version() {
    echo -e "\n\033[36m[1/4] 验证Git存在\033[0m"

    git_version="$(git --version 2>/dev/null)"
    if [ -n "${git_version}" ]; then
        echo ${git_version}
    else
        echo "Git is not installed."
    fi
}

set_user_name(){
    echo -e "\n\033[36m[2/4] 设置用户名\033[0m"

    git config --global user.name ${user_name}

    if [ 0 != $? ]; then
        echo $?
    else
        echo "用户名：$(git config user.name)"
    fi
}

set_email() {
    echo -e "\n\033[36m[3/4] 设置邮箱\033[0m"

    git config --global user.email ${user_email}

    if [ 0 != $? ]; then
        echo $?
    else
        echo "邮箱：$(git config user.email)"
    fi
}

gen_ssh_key_rsa() {
    echo -e "\n\033[36m[4/4] 生成SSH密钥\033[0m"
    
    ssh-keygen -t rsa -C "${user_email}" -f "${KEY_FILE_NAME}" -N ""

    if [ ! -f $HOME/.ssh/config ]; then
        touch $HOME/.ssh/config
        chmod 600 $HOME/.ssh/config
    fi

cat >> $HOME/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_github
EOF

}

add_ssh_key_github() {
    PUBLIC_KEY=$(cat "${KEY_FILE_NAME}.pub" 2>/dev/null)
    if [ -z "${PUBLIC_KEY}" ]; then
        echo -e "\033[31mssh_key: ${KEY_FILE_NAME}.pub 不存在\033[0m"
        exit 1
    fi

    echo -e "\n\033[36m[5/5] Github添加SSH密钥\033[0m"
    echo -e "\n\033[35m[1/3] 访问 https://github.com/settings/ssh/new\033[0m"
    echo -e "\n\033[35m[2/3] 复制一下内容\033[0m"
    echo -e "\033[30mTitle\033[0m"
    echo -e "\033[33m"ubuntu-$(whoami)"\033[0m"
    echo -e "\033[30mKey\033[0m"
    echo -e "\033[33m${PUBLIC_KEY}\033[0m"

    echo -e "\n\033[35m[3/3]测试 ssh -T -i ~/.ssh/id_rsa_github git@github.com\033[0m"
    echo -e "\033[35m[3/3]测试 ssh -T git@github.com\033[0m"
}

# ----------------    main    ----------------

read -p "请输入用户名：" user_name
read -p "请输入邮箱：" user_email

KEY_FILE_NAME="$HOME/.ssh/id_rsa_github"

get_git_version
set_user_name
set_email
gen_ssh_key_rsa
add_ssh_key_github

