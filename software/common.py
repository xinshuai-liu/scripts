
import subprocess

def exec(cmd, check=True, shell=True):
    """执行 shell 命令并处理输出"""
    print(f"$ {cmd}")
    result = subprocess.run(cmd, shell=shell, check=check, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result

def step(title):
    """打印步骤标题"""
    print(f"\n{title}")
    print("-" * 40)
