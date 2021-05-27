module.exports = {
  enforce: 'pre',
  test:    /\.(j|t)sx?$/i,
  include: [/app\/javascript/, /hbw\/app\/javascript/],
  use:     {
    loader:  'eslint-loader',
    options: {
      fix: false
    }
  }
};
