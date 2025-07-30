const http = require('http');
const httpProxy = require('http-proxy');

// 创建代理实例
const proxy = httpProxy.createProxyServer({});

// 创建HTTP服务器
const server = http.createServer((req, res) => {
  // 设置CORS头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // 处理OPTIONS请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // API请求代理到后端
  if (req.url.startsWith('/api')) {
    proxy.web(req, res, {
      target: 'http://localhost:3001',
      changeOrigin: true
    });
  } 
  // 其他请求代理到前端
  else {
    proxy.web(req, res, {
      target: 'http://localhost:3000',
      changeOrigin: true
    });
  }
});

// 错误处理
proxy.on('error', (err, req, res) => {
  console.error('代理错误:', err);
  if (!res.headersSent) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('代理服务器错误');
  }
});

// 启动服务器
const PORT = 80;
server.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 云归代理服务器启动成功！');
  console.log('📱 前端服务: http://localhost:3000');
  console.log('🔧 后端服务: http://localhost:3001');
  console.log('🌐 代理服务: http://localhost:80');
  console.log('🌍 网站访问: http://ai.guiyunai.fun');
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到SIGTERM信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('收到SIGINT信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});
