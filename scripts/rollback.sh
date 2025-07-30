#!/bin/bash

# 云归.中国 - Postiz回滚脚本
# 作者: heweijie1
# 版本: 1.0.0

set -e

# 配置变量
PROJECT_DIR="/www/wwwroot/ai.guiyunai.fun"
BACKUP_DIR="/www/backups/postiz"
LOG_FILE="/var/log/postiz-deploy.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理
error_exit() {
    log "❌ 错误: $1"
    exit 1
}

log "🔄 开始回滚 Postiz 应用..."

# 1. 找到最新的备份文件
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    error_exit "未找到备份文件，无法回滚"
fi

log "📋 找到备份文件: $(basename "$LATEST_BACKUP")"

# 2. 停止当前服务
log "🛑 停止当前服务..."
pm2 delete all 2>/dev/null || true
pkill -f "node.*postiz" 2>/dev/null || true
pkill -f "proxy-server" 2>/dev/null || true

# 3. 备份当前状态（以防回滚失败）
ROLLBACK_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
if [ -d "$PROJECT_DIR" ] && [ "$(ls -A $PROJECT_DIR)" ]; then
    log "📦 备份当前状态..."
    tar -czf "$BACKUP_DIR/rollback_backup_$ROLLBACK_TIMESTAMP.tar.gz" -C "$PROJECT_DIR" . || log "⚠️ 当前状态备份失败"
fi

# 4. 清空项目目录
log "🗑️ 清空项目目录..."
rm -rf "$PROJECT_DIR"/*

# 5. 恢复备份
log "📥 恢复备份文件..."
cd "$PROJECT_DIR"
tar -xzf "$LATEST_BACKUP" || error_exit "备份恢复失败"

# 6. 启动服务
log "🚀 启动服务..."
pm2 start ecosystem.config.js || error_exit "服务启动失败"

# 7. 启动代理服务器
log "🌐 启动代理服务器..."
pm2 start proxy-server.js --name "proxy-server" || error_exit "代理服务器启动失败"

# 8. 健康检查
log "🔍 执行健康检查..."
sleep 10

if curl -f http://localhost:3000 >/dev/null 2>&1 && curl -f http://localhost:3001 >/dev/null 2>&1; then
    log "✅ 回滚成功！服务运行正常"
    log "🎉 已回滚到版本: $(basename "$LATEST_BACKUP")"
else
    error_exit "回滚后健康检查失败"
fi
