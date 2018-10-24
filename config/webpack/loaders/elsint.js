module.exports = {
  enforce: 'pre',
  test: /\.(js|jsx)$/i,
  include: [/app\/javascript/, /hbw\/app\/javascript/],
  use: {
    loader: 'eslint-loader',
    options: {
      fix: true
    }
  }
};
