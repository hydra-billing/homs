process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const config = require('./shared');
const eslint = require('./loaders/eslint');

config.module.rules.unshift(eslint);

module.exports = config;
