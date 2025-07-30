#!/bin/bash

# 云归.中国 - Postiz自动部署脚本
# 作者: heweijie1
# 版本: 1.0.0

set -e

# 配置变量
PROJECT_DIR="/www/wwwroot/ai.guiyunai.fun"
BACKUP_DIR="/www/backups/postiz"
LOG_FILE="/var/log/postiz-deploy.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理
error_exit() {
    log "❌ 错误: $1"
    exit 1
}

# 创建必要目录
mkdir -p "$BACKUP_DIR" "$PROJECT_DIR"

log "🚀 开始部署 Postiz 应用..."

# 1. 备份当前版本
if [ -d "$PROJECT_DIR" ] && [ "$(ls -A $PROJECT_DIR)" ]; then
    log "📋 备份当前版本..."
    tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" -C "$PROJECT_DIR" . || error_exit "备份失败"
    log "✅ 备份完成: backup_$TIMESTAMP.tar.gz"
fi

# 2. 停止服务
log "🛑 停止现有服务..."
pm2 delete all 2>/dev/null || true
pkill -f "node.*postiz" 2>/dev/null || true
pkill -f "proxy-server" 2>/dev/null || true

# 3. 拉取最新代码
log "📥 拉取最新代码..."
cd "$PROJECT_DIR"
git fetch origin main || error_exit "拉取代码失败"
git reset --hard origin/main || error_exit "重置代码失败"

# 4. 安装依赖
log "📦 安装依赖..."
pnpm install --frozen-lockfile || error_exit "依赖安装失败"

# 5. 生成Prisma客户端
log "🗄️ 生成数据库客户端..."
pnpm run prisma-generate || error_exit "Prisma生成失败"

# 6. 推送数据库变更
log "🔄 推送数据库变更..."
pnpm run prisma-db-push || error_exit "数据库推送失败"

# 7. 构建项目
log "🔨 构建项目..."
NODE_ENV=production pnpm run build || error_exit "项目构建失败"

# 8. 启动服务
log "🚀 启动服务..."
pm2 start ecosystem.config.js || error_exit "服务启动失败"

# 9. 启动代理服务器
log "🌐 启动代理服务器..."
pm2 start proxy-server.js --name "proxy-server" || error_exit "代理服务器启动失败"

# 10. 健康检查
log "🔍 执行健康检查..."
sleep 10

# 检查服务状态
if curl -f http://localhost:3000 >/dev/null 2>&1 && curl -f http://localhost:3001 >/dev/null 2>&1; then
    log "✅ 部署成功！服务运行正常"
    
    # 清理旧备份（保留最近5个）
    cd "$BACKUP_DIR"
    ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm -f
    log "🧹 清理完成，保留最近5个备份"
else
    log "❌ 健康检查失败，尝试回滚..."
    bash "$PROJECT_DIR/scripts/rollback.sh"
    error_exit "部署失败，已回滚到上一版本"
fi

log "🎉 部署完成！访问地址: https://ai.guiyunai.fun"
