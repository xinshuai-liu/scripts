import os
import sys
import subprocess
import time
from getpass import getuser

def exec(cmd, check=True, shell=True):
    """执行 shell 命令并处理输出"""
    print(f"$ {cmd}")
    result = subprocess.run(cmd, shell=shell, check=check, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result

def step(title):
    """打印步骤标题"""
    print(f"\n=== {title} ===")
    print("-" * 40)

def upd_environment():
    """更新系统"""
    try:
        step("更新系统")
        exec("sudo apt update")
        exec("sudo apt upgrade -y")
    except subprocess.CalledProcessError as e:
        print(f"\n错误：命令执行失败 [{e.returncode}]")
        print(f"命令: {e.cmd}")
        print(f"错误输出: {e.stderr}")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生未知错误: {str(e)}")
        sys.exit(1)

def install_docker():
    try:
        # 安装依赖
        step("安装必要依赖")
        exec("sudo apt install apt-transport-https ca-certificates curl software-properties-common -y")
              
        # 添加GPG密钥（带重试机制）
        step("添加Docker GPG密钥")
        max_retries = 10
        exec("sudo install -m 0755 -d /etc/apt/keyrings")
        for i in range(max_retries):
            try:
                time.sleep(1)
                exec("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg")
                break
            except subprocess.CalledProcessError:
                if i < max_retries - 1:
                    print(f"密钥添加失败，正在重试 ({i+1}/{max_retries})...")
                    time.sleep(2)
                else:
                    raise RuntimeError("无法添加GPG密钥，请检查网络连接")

        # 添加APT源
        #step("添加Docker APT源")
        #release = exec("lsb_release -cs").stdout.strip()
        #repo_cmd = f"echo deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu {release} stable | sudo tee /etc/apt/sources.list.d/docker.list"
        exec("echo \"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null")
        exec("sudo apt update")

        # 安装Docker引擎
        step("安装Docker引擎")
        exec("sudo apt install -y docker-ce docker-ce-cli containerd.io")

        # 启动服务
        step("启动Docker服务")
        exec("sudo systemctl start docker")
        exec("sudo systemctl enable docker")

        # 配置镜像加速
        step("配置镜像加速")
        daemon_config = """{
            "registry-mirrors": [
                "https://docker.1ms.run",
                "https://docker.xuanyuan.me",
                "https://docker.mirrors.ustc.edu.cn",
                "https://rjiom0q7.mirror.aliyuncs.com"
            ]
        }"""
        exec("sudo mkdir -p /etc/docker")
        with open("/tmp/daemon.json", "w") as f:
            f.write(daemon_config)
        exec("sudo mv /tmp/daemon.json /etc/docker/")
        exec("sudo systemctl daemon-reload")
        exec("sudo systemctl restart docker")

        # 验证安装
        step("验证Docker安装")
        output = exec("sudo docker run --rm hello-world").stdout
        if "Hello from Docker!" in output:
            print("Docker安装验证成功！")
        else:
            print("警告：Docker安装验证失败！")

        # 完成信息
        step("docker安装完成")

    except subprocess.CalledProcessError as e:
        print(f"\n错误：命令执行失败 [{e.returncode}]")
        print(f"命令: {e.cmd}")
        print(f"错误输出: {e.stderr}")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生未知错误: {str(e)}")
        sys.exit(1)

def set_non_root():
    """配置非root权限"""
    try:
         # 配置非root权限
        step("配置非root用户权限")
        current_user = getuser()
        
        # 检查/创建docker组
        if "docker" not in exec("grep ^docker /etc/group", check=False).stdout:
            exec("sudo groupadd docker")
        
        # 添加用户到组
        exec(f"sudo usermod -aG docker {current_user}")
        print(f"用户 {current_user} 已添加到docker组")

    except subprocess.CalledProcessError as e:
        print(f"\n错误：命令执行失败 [{e.returncode}]")
        print(f"命令: {e.cmd}")
        print(f"错误输出: {e.stderr}")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生未知错误: {str(e)}")
        sys.exit(1)

def install_docker_compose():
    """安装Docker Compose"""
    try:
        # 1. 安装Docker Compose
        step("安装Docker Compose")
        compose_version = "1.29.2"
        uname_s = exec("uname -s").stdout.strip()
        uname_m = exec("uname -m").stdout.strip()
        compose_url = f"https://github.com/docker/compose/releases/download/{compose_version}/docker-compose-{uname_s}-{uname_m}"
        exec(f"sudo curl -L {compose_url} -o /usr/local/bin/docker-compose")
        exec("sudo chmod +x /usr/local/bin/docker-compose")
        
        # 2. 验证Compose安装
        compose_version = exec("docker-compose --version").stdout.strip()
        print(f"Docker Compose 安装成功: {compose_version}")
    except subprocess.CalledProcessError as e:
        print(f"\n错误：命令执行失败 [{e.returncode}]")
        print(f"命令: {e.cmd}")
        print(f"错误输出: {e.stderr}")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生未知错误: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    print("=== Docker 自动安装配置脚本 开始 ===")
    upd_environment()
    install_docker()
    install_docker_compose()
    set_non_root()
    print("=== Docker 自动安装配置脚本 完成 ===")