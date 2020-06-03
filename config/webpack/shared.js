const path = require('path');
const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const babel = require('./loaders/babel');
const yaml = require('./loaders/yaml');
const I18n = require('./loaders/I18n');
const modulejs = require('./loaders/modulejs');
const tooltip = require('./loaders/tooltip');

const assetsPath = path.resolve(__dirname, '../../public/assets/');

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $:      'jquery',
  jQuery: 'jquery',
  jquery: 'jquery'
}));

environment.plugins.prepend('moment', new webpack.ContextReplacementPlugin(/moment[/\\]locale$/, /ru/));

environment.plugins.prepend('clean', new CleanWebpackPlugin({
  cleanOnceBeforeBuildPatterns: [assetsPath]
}));

environment.loaders.append('yaml', yaml);
environment.loaders.append('babel', babel);

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

module.exports = config;
