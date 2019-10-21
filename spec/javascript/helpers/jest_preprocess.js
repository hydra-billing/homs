const babelOptions = {
  presets: ['@babel/preset-env', '@babel/preset-react'],
  plugins: [
    '@babel/transform-runtime',
    '@babel/proposal-object-rest-spread',
    '@babel/proposal-class-properties'
  ]
};

module.exports = require('babel-jest').createTransformer(babelOptions);
