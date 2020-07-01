process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const config = require('./shared');
const eslint = require('./loaders/eslint');

config.module.rules.unshift(eslint);

config.devServer.clientLogLevel = 'debug';
config.devServer.writeToDisk = true;

module.exports = config;
