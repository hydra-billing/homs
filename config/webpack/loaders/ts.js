module.exports = {
  test:    /\.tsx?$/,
  include: [/app\/javascript/, /hbw\/app\/javascript/],
  use:     {
    loader: 'ts-loader'
  }
};
