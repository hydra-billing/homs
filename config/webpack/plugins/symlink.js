const fs = require("fs");
const path = require('path');

const CHUNKHASH_REGEX = /(-[a-z0-9]{20}\.{1}){1}/;
const assetsPath = path.resolve(__dirname, '../../../public/assets');

class SymlinkAssets {
  constructor(filenames) {
    this.filenames = filenames;
  }

  apply (compiler) {
    const emit = (compilation, callback) => {
      Object.entries(compilation.assets).forEach(([filename, _]) => {
        if (!CHUNKHASH_REGEX.test(filename)) return;

        const nonDigestFilename = filename.replace(CHUNKHASH_REGEX, '.');

        if (this.filenames.includes(nonDigestFilename)) {
          fs.symlinkSync(
            path.join('./packs', filename),
            path.join(assetsPath, nonDigestFilename))
        }
      });

      callback();
    };

    compiler.plugin('emit', emit);
  }
}

module.exports = SymlinkAssets;
