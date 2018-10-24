module.exports = {
  test: require.resolve('i18n-js'),
  use: [{
    loader: 'expose-loader',
    options: 'I18n'
  }]
};
