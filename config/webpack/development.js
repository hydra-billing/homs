process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const config = require('./shared');

config.devServer = {
  ...config.devServer,
  clientLogLevel: 'debug',
  writeToDisk:    true
};

module.exports = config;
