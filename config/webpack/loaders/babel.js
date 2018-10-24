module.exports = {
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader',
      options: {
      presets: ['env', 'react']
    }
  }
};
