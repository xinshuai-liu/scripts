import os
import sys
import time
import subprocess
from getpass import getuser
import common

def install_docker_compose():
    """安装Docker Compose"""
    try:
        # 1. 安装Docker Compose
        common.step("[1/2] 安装 Docker Compose")
        cmd = "curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '\"tag_name\":' | cut -d'\"' -f4"
        compose_version = common.exec(cmd).stdout.replace("\n","")
        uname_s = common.exec("uname -s").stdout.strip()
        uname_m = common.exec("uname -m").stdout.strip()
        compose_url = f"https://github.com/docker/compose/releases/download/{compose_version}/docker-compose-{uname_s}-{uname_m}"
        common.exec(f"curl -L {compose_url} -o /usr/local/bin/docker-compose ")
        common.exec("chmod +x /usr/local/bin/docker-compose")
        
        # 2. 验证Compose安装
        common.step("[2/2] 验证 Docker Compose")
        compose_version = common.exec("docker-compose --version").stdout.strip()
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
    file_name = os.path.basename(__file__)

    # 需要root权限
    if os.geteuid() != 0 :
        print("请使用 sudo 运行此脚本: sudo python3 " + file_name)
        sys.exit(1)
        
    print("\n" + file_name + " 开始")

    install_docker_compose()

    print("\n" + file_name + " 结束")

    