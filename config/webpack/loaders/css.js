module.exports = {
  loader:  'css-loader',
  options: {
    url: {
      filter: (url) => {
        if (url.includes('glyphicons-halflings-regular')) {
          return false;
        }

        return true;
      },
    },
    sourceMap:     true,
    importLoaders: 2,
    modules:       false
  }
};
