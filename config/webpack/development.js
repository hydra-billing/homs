process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const config = require('./shared');
const eslint = require('./loaders/eslint');
const SymlinkAssets = require('./plugins/symlink');

config.plugins.push(new SymlinkAssets(['hbw.js']));

config.module.rules.unshift(eslint);

config.devServer.clientLogLevel = 'debug';

module.exports = config;
