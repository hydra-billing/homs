const fs = require('fs');
const path = require('path');

const CHUNKHASH_REGEX = /(-[a-z0-9]{20}\.{1}){1}/;
const assetsPath = path.resolve(__dirname, '../../../public/assets');

class SymlinkAssets {
  constructor (filenames) {
    this.filenames = filenames;
  }

  apply (compiler) {
    const emit = (compilation) => {
      Object.entries(compilation.assets).forEach(([filename]) => {
        if (!CHUNKHASH_REGEX.test(filename)) return;

        const nonDigestFilename = filename.replace(CHUNKHASH_REGEX, '.');
        const relativeFileName = nonDigestFilename.replace(/^(js|css)\//, '');

        const fileName = path.join('./packs', filename);
        const symlinkName = path.join(assetsPath, relativeFileName);

        if (this.filenames.includes(relativeFileName)) {
          try {
            fs.readlinkSync(symlinkName);

            fs.unlinkSync(symlinkName);

            fs.symlinkSync(
              fileName,
              symlinkName
            );
          } catch {
            fs.symlinkSync(
              fileName,
              symlinkName
            );
          }
        }
      });
    };

    compiler.hooks.afterEmit.tap('SymlinkAssets', emit);
  }
}

module.exports = SymlinkAssets;
