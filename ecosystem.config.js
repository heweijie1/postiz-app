module.exports = {
  apps: [
    {
      name: 'postiz-frontend',
      script: 'node_modules/.bin/next',
      args: 'start',
      cwd: '/www/wwwroot/ai.guiyunai.fun/apps/frontend',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOSTNAME: '0.0.0.0'
      },
      env_file: '/www/wwwroot/ai.guiyunai.fun/.env',
      error_file: '/var/log/pm2/postiz-frontend-error.log',
      out_file: '/var/log/pm2/postiz-frontend-out.log',
      log_file: '/var/log/pm2/postiz-frontend.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      node_args: '--max-old-space-size=1024'
    },
    {
      name: 'postiz-backend',
      script: 'dist/apps/backend/src/main.js',
      cwd: '/www/wwwroot/ai.guiyunai.fun/apps/backend',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      env_file: '/www/wwwroot/ai.guiyunai.fun/.env',
      error_file: '/var/log/pm2/postiz-backend-error.log',
      out_file: '/var/log/pm2/postiz-backend-out.log',
      log_file: '/var/log/pm2/postiz-backend.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      node_args: '--max-old-space-size=1024'
    },
    {
      name: 'postiz-workers',
      script: 'dist/apps/workers/src/main.js',
      cwd: '/www/wwwroot/ai.guiyunai.fun/apps/workers',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production'
      },
      env_file: '/www/wwwroot/ai.guiyunai.fun/.env',
      error_file: '/var/log/pm2/postiz-workers-error.log',
      out_file: '/var/log/pm2/postiz-workers-out.log',
      log_file: '/var/log/pm2/postiz-workers.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      node_args: '--max-old-space-size=512'
    },
    {
      name: 'postiz-cron',
      script: 'dist/apps/cron/src/main.js',
      cwd: '/www/wwwroot/ai.guiyunai.fun/apps/cron',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production'
      },
      env_file: '/www/wwwroot/ai.guiyunai.fun/.env',
      error_file: '/var/log/pm2/postiz-cron-error.log',
      out_file: '/var/log/pm2/postiz-cron-out.log',
      log_file: '/var/log/pm2/postiz-cron.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      node_args: '--max-old-space-size=256'
    }
  ]
};
