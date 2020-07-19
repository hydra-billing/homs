module.exports = {
  test: require.resolve('i18n-js'),
  use:  [{
    loader:  'expose-loader',
    options: {
      exposes: 'I18n'
    }
  }]
};
