module.exports = {
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader',
      options: {
      presets: ['babel-preset-env']
    }
  }
};
