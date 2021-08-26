module.exports = {
  test: /(.jpg|.jpeg|.png|.gif|.tiff|.ico|.svg|.eot|.otf|.ttf|.woff|.woff2)$/i,
  use:  [{
    loader:  'file-loader',
    options: {
      esModule: false,
    }
  }]
};
