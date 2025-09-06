import os
import sys
import time
import subprocess
from getpass import getuser
import common

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
        common.exec(f"sudo usermod -aG docker {current_user}")
        print(f"用户 {current_user} 已添加到docker组")

        # 重启docker服务
        common.exec("sudo systemctl restart docker")

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

    print("\n" + file_name + " 开始")

    set_non_root()

    print("\n" + file_name + " 结束\n")
