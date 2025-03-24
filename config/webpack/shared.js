const path = require('path');
const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { WebpackManifestPlugin } = require('webpack-manifest-plugin');
const ESLintPlugin = require('eslint-webpack-plugin');
const sass = require('sass-embedded');
const yaml = require('./loaders/yaml');
const modulejs = require('./loaders/modulejs');
const tooltip = require('./loaders/tooltip');
const ts = require('./loaders/ts');
const file = require('./loaders/file');
const babel = require('./loaders/babel');
const css = require('./loaders/css');
const SymlinkAssets = require('./plugins/symlink');

module.exports = (_, { mode }) => ({
  mode,
  output: {
    filename:   '[name]-[fullhash].js',
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
                api:            'legacy',
                sourceMap:      true,
                implementation: sass,
                sassOptions:    {
                  loadPaths: [
                    path.resolve(__dirname, '../../app/javascript'),
                    path.resolve(__dirname, '../../app/assets/stylesheets'),
                    path.resolve(__dirname, '../../hbw/app/assets/stylesheets'),
                    path.resolve(__dirname, '../../vendor/assets/stylesheets'),
                    path.resolve(__dirname, '../../node_modules')
                  ],
                  quietDeps: true,
                }
              }
            }
          ],
          sideEffects: true,
        },
        file,
        babel,
        yaml,
        ts,
        modulejs,
        tooltip
      ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    new ESLintPlugin({
      extensions: ['js', 'jsx'],
      exclude:    ['node_modules', 'vendor'],
      fix:        false
    }),
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
