const yaml = require('js-yaml');

module.exports = {
  process (source) {
    const res = yaml.load(source);
    return {
      code: `module.exports = ${JSON.stringify(res, undefined, '\t')};`
    };
  },
};
