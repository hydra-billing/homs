import allTranslations from './init/translations';

const HBWTranslator = {
  getTranslatorForLocale (locale) {
    return (key, vars) => this.translate(key, locale, vars);
  },

  translate (key, locale = 'en', vars = {}) {
    let current = allTranslations[locale].hbw.js;

    key.split('.').forEach((part) => {
      if (typeof current === 'object' && part in current) {
        current = this.interpolateString(current[part], vars);
      } else {
        throw new Error(`Cannot find ${key} in translations`);
      }
    });

    return current;
  },

  interpolateString (str, vars) {
    if (typeof str === 'string') {
      return str.replace(/%{([^{}]*)}/g, (fullMatch, varName) => {
        const subst = vars[varName];
        if ((typeof subst !== 'string') && (typeof subst !== 'number')) {
          throw new Error(`Undefined variable ${varName}`);
        }

        return subst;
      });
    }
    return str;
  }
};

export default HBWTranslator;
