const yaml = require('js-yaml');

module.exports = {
  process (source) {
    const res = yaml.safeLoad(source);
    return `module.exports = ${JSON.stringify(res, undefined, '\t')};`;
  },
};
