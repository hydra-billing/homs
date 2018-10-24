process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const config = require('./shared');
const SymlinkAssets = require('./plugins/symlink');

config.plugins.push(new SymlinkAssets(['hbw.js']));

module.exports = config;
