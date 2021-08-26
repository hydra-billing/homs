module.exports = {
  test:    /\.(js|jsx|ts|tsx)?$/,
  exclude: /node_modules/,
  use:     [{
    loader:  'babel-loader',
    options: {
      cacheDirectory:   true,
      cacheCompression: false,
      compact:          false
    }
  }]
};
