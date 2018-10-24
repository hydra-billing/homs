module.exports = {
  test: require.resolve('modulejs'),
  use: [{
    loader: 'expose-loader',
    options: 'modulejs'
  }]
};
