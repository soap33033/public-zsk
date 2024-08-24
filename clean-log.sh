#!/bin/bash

# 设置日志文件所在目录
LOG_DIR="/var/log"   # 修改为你的日志目录路径

# 设置文件大小
MAX_SIZE=500

# 查找大于阈值的日志文件
find "$LOG_DIR" -type f -name "*.log" -size +"${MAX_SIZE}M" | while read logfile; do
    echo "正在处理日志文件：$logfile"
    
    # 获取文件大小
    filesize=$(du -m "$logfile" | cut -f1)
    
    if (( filesize > MAX_SIZE )); then
        # 压缩并保存旧日志
        timestamp=$(date +"%Y%m%d-%H%M%S")
        gzip -c "$logfile" > "${logfile}-${timestamp}.gz"
        echo "日志文件已压缩并保存为：${logfile}-${timestamp}.gz"
        
        # 清理原日志内容（只保留最新日志）
        > "$logfile"
        echo "已清理日志内容，保留最新日志记录"
    fi
done

echo "日志文件处理完成！"


0 3 * * * /path/to/clean_logs.sh
