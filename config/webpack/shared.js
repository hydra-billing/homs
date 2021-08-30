const path = require('path');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { WebpackManifestPlugin } = require('webpack-manifest-plugin');
const yaml = require('./loaders/yaml');
const I18n = require('./loaders/I18n');
const modulejs = require('./loaders/modulejs');
const tooltip = require('./loaders/tooltip');
const eslint = require('./loaders/eslint');
const ts = require('./loaders/ts');
const file = require('./loaders/file');
const babel = require('./loaders/babel');
const css = require('./loaders/css');
const SymlinkAssets = require('./plugins/symlink');

module.exports = (_, { mode }) => ({
  mode,
  output: {
    filename:   '[name]-[hash].js',
    path:       path.resolve(__dirname, '../../public/assets/packs'),
    publicPath: '/assets/packs/'
  },
  resolve: {
    extensions: ['.jsx', '.js', '.tsx', '.ts', '.sass', '.css'],
    modules:    [
      'app/javascript',
      'app/assets/stylesheets',
      'app/assets/images',
      'app/assets/fonts',
      'hbw/app/javascript/packs',
      'hbw/app/assets/stylesheets',
      'hbw/app/assets/fonts',
      'hbw/app/assets/images',
      'vendor/assets/javascripts',
      'vendor/assets/stylesheets',
      'node_modules'
    ],
    alias: {
      jquery:                     'jquery/src/jquery',
      modulejs:                   'modulejs/dist/modulejs',
      tooltip:                    'tooltip.js/dist/umd/tooltip.js',
      'bootstrap-datetimepicker': 'eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min',
      'bootstrap-multiselect':    'bootstrap-multiselect/dist/js/bootstrap-multiselect',
      shared:                     path.resolve(__dirname, '../../hbw/app/javascript/packs/hbw/components/shared'),
      messenger:                  path.resolve(__dirname, '../../app/javascript/utils/messenger'),
    }
  },
  devtool: 'cheap-module-source-map',
  entry:   {
    application: './app/javascript/packs/application.js',
    hbw:         './app/javascript/packs/hbw.js'
  },
  module: {
    strictExportPresence: true,
    rules:
      [
        {
          test: /\.(css)$/i,
          use:  [
            { loader: MiniCssExtractPlugin.loader },
            css,
          ],
          sideEffects: true,
        },
        {
          test: /\.(scss|sass)$/i,
          use:  [
            { loader: MiniCssExtractPlugin.loader },
            css,
            {
              loader:  'sass-loader',
              options: {
                sourceMap: true,
              }
            }
          ],
          sideEffects: true,
        },
        file,
        babel,
        yaml,
        eslint,
        ts,
        modulejs,
        I18n,
        tooltip
      ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    new WebpackManifestPlugin(),
    new webpack.ContextReplacementPlugin(/moment[/\\]locale$/, /ru/),
    new webpack.ProvidePlugin({
      $:      'jquery',
      jQuery: 'jquery',
      jquery: 'jquery'
    }),
    new MiniCssExtractPlugin({
      filename: '[name]-[chunkhash].css',
    }),
    new SymlinkAssets(['hbw.js', 'hbw.css']),
  ]
});
