const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const babel = require('./loaders/babel');
const yaml = require('./loaders/yaml');
const I18n = require('./loaders/I18n');
const modulejs = require('./loaders/modulejs');

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
    $:      'jquery',
    jQuery: 'jquery',
    jquery: 'jquery'
  })
);

environment.loaders.append('yaml', yaml);
environment.loaders.append('babel', babel);

// Expose libs called from haml templates
environment.loaders.append('modulejs', modulejs);
environment.loaders.append('i18n-js', I18n);

const config = environment.toWebpackConfig();

config.resolve.alias = {
  jquery: 'jquery/src/jquery',
  modulejs: 'modulejs/dist/modulejs',
  'jquery-ui': 'jquery-ui-dist/jquery-ui',
  'bootstrap-datetimepicker': 'eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker'
};

module.exports = config;
