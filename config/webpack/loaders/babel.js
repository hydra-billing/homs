module.exports = {
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader',
    options: {
      presets: ['@babel/preset-env', '@babel/preset-react'],
      plugins: [
        '@babel/transform-runtime',
        '@babel/proposal-object-rest-spread',
        '@babel/proposal-class-properties'
      ]
    }
  }
};
