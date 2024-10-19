const path = require('path');

module.exports = {
  entry: './src/index.js',  // 指定入口文件
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'development',  // 开发模式
  devServer: {
    static: {
      directory: path.join(__dirname, 'dist'),  // 指定静态文件目录
    },
    compress: true,
    port: 9000,
    open: true,  // 启动服务器后自动打开浏览器
    hot: true,   // 启用热替换 (Hot Module Replacement)
    watchFiles: ['src/**/*', 'dist/**/*'],  // 监控文件变化
  },
};
