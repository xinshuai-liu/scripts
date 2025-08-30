import os
import sys
import time
import subprocess
from getpass import getuser
import common

def install_docker():
    try:
        # [1/6] 安装依赖
        common.step("[1/6] 安装必要依赖")
        common.exec("apt-get install apt-transport-https ca-certificates curl software-properties-common -y")
              
        # [2/6] 添加GPG密钥（带重试机制）
        common.step("[2/6] 添加Docker GPG密钥")
        max_retries = 10
        common.exec("install -m 0755 -d /etc/apt/keyrings")
        for i in range(max_retries):
            try:
                time.sleep(1)
                common.exec("curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg")
                break
            except subprocess.CalledProcessError:
                if i < max_retries - 1:
                    print(f"密钥添加失败，正在重试 ({i+1}/{max_retries})...")
                    time.sleep(2)
                else:
                    raise RuntimeError("无法添加GPG密钥，请检查网络连接")

        # 添加APT源
        common.exec("echo \"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null")
        common.exec("apt-get update")

        # [3/6] 安装Docker引擎
        common.step("[3/6] 安装Docker引擎")
        common.exec("apt-get install -y docker-ce docker-ce-cli containerd.io")

        # [4/6] 启动服务
        common.step("[4/6] 启动Docker服务")
        common.exec("systemctl start docker")
        common.exec("systemctl enable docker")

        # [5/6] 配置镜像加速
        common.step("[5/6] 配置镜像加速")
        daemon_config = """{
            "registry-mirrors": [
                "https://docker.1ms.run",
                "https://docker.xuanyuan.me",
                "https://docker.mirrors.ustc.edu.cn",
                "https://rjiom0q7.mirror.aliyuncs.com"
            ]
        }"""
        common.exec("mkdir -p /etc/docker")
        with open("/tmp/daemon.json", "w") as f:
            f.write(daemon_config)
        common.exec("mv /tmp/daemon.json /etc/docker/")
        common.exec("systemctl daemon-reload")
        common.exec("systemctl restart docker")

        # [6/6] 验证安装
        common.step("[6/6] 验证Docker安装")
        output = common.exec("docker run --rm hello-world").stdout
        if "Hello from Docker!" in output:
            print("Docker安装验证成功！")
        else:
            print("警告：Docker安装验证失败！")

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
        common.step("[-/-] 配置非root用户权限")
        current_user = getuser()
        
        # 检查/创建docker组
        if "docker" not in common.exec("grep ^docker /etc/group", check=False).stdout:
            common.exec("groupadd docker")
        
        # 添加用户到组
        common.exec(f"usermod -aG docker {current_user}")
        print(f"用户 {current_user} 已添加到docker组")

        # 重启docker服务
        common.exec("systemctl restart docker")

    except subprocess.CalledProcessError as e:
        print(f"\n错误：命令执行失败 [{e.returncode}]")
        print(f"命令: {e.cmd}")
        print(f"错误输出: {e.stderr}")
        sys.exit(1)
    except Exception as e:
        print(f"\n发生未知错误: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    file_name = os.path.basename(__file__)

    # 需要root权限
    if os.geteuid() != 0 :
        print("请使用 sudo 运行此脚本: sudo python3 " + file_name)
        sys.exit(1)

    print("\n" + file_name + " 开始")

    install_docker()
    set_non_root()

    print("\n" + file_name + " 结束\n")
