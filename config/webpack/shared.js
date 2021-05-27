const path = require('path');
const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const yaml = require('./loaders/yaml');
const I18n = require('./loaders/I18n');
const modulejs = require('./loaders/modulejs');
const tooltip = require('./loaders/tooltip');
const eslint = require('./loaders/eslint');
const ts = require('./loaders/ts');
const SymlinkAssets = require('./plugins/symlink');

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $:      'jquery',
  jQuery: 'jquery',
  jquery: 'jquery'
}));

environment.plugins.prepend('moment', new webpack.ContextReplacementPlugin(/moment[/\\]locale$/, /ru/));

environment.plugins.prepend('clean', new CleanWebpackPlugin());

environment.loaders.append('yaml', yaml);

environment.loaders.append('eslint', eslint);
environment.loaders.append('ts-loader', ts);
// Expose libs called from haml templates
environment.loaders.append('modulejs', modulejs);
environment.loaders.append('i18n-js', I18n);
environment.loaders.append('tooltip', tooltip);

const config = environment.toWebpackConfig();

config.resolve.alias = {
  jquery:                     'jquery/src/jquery',
  modulejs:                   'modulejs/dist/modulejs',
  tooltip:                    'tooltip.js/dist/umd/tooltip.js',
  'bootstrap-datetimepicker': 'eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker',
  shared:                     path.resolve(__dirname, '../../hbw/app/javascript/packs/hbw/components/shared'),
  messenger:                  path.resolve(__dirname, '../../app/javascript/utils/messenger'),
};

config.plugins.push(new SymlinkAssets(['hbw.js']));

module.exports = config;
