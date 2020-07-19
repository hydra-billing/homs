module.exports = {
  test: require.resolve('tooltip.js'),
  use:  [{
    loader:  'expose-loader',
    options: {
      exposes: 'Tooltip'
    }
  }]
};
