#!/bin/bash

# 从ip_list文件读取ip
IP_FILE="ip_list"
SSH_KEY="TShard"

# 获取当前系统的CPU核数
CPU_CORES=$(nproc)

# 读取每行IP地址
while IFS= read -r ip; do
    # 提取IP地址后缀部分，例如 10.0.0.162 中的 162
    suffix=$(echo $ip | awk -F. '{print $NF}')
    session_name="config$suffix"
    
    # 创建tmux session
    tmux new-session -d -s "$session_name"
    
    # 在tmux session中运行scp和ssh命令
    tmux send-keys -t "$session_name" "ssh -i $SSH_KEY -o StrictHostKeyChecking=no $ip 'cd damysus_updated && git checkout flexi'" C-m
    tmux send-keys -t "$session_name" "scp -i $SSH_KEY -o StrictHostKeyChecking=no App/params.h $ip:damysus_updated/App/" C-m
    tmux send-keys -t "$session_name" "scp -i $SSH_KEY -o StrictHostKeyChecking=no -r servers $ip:damysus_updated/" C-m
    tmux send-keys -t "$session_name" "scp -i $SSH_KEY -o StrictHostKeyChecking=no -r clients $ip:damysus_updated/" C-m
    tmux send-keys -t "$session_name" "ssh -i $SSH_KEY -o StrictHostKeyChecking=no $ip 'cd damysus_updated && make clean && make -j $CPU_CORES SGX_MODE=SIM '" C-m
done < "$IP_FILE"


