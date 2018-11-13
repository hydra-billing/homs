import allTranslations from './init/translations';

modulejs.define('HBWTranslator', ['jQuery'], (jQuery) => {
  const Translator = {
    getTranslatorForLocale (locale) {
      return (key, vars) => this.translate(key, locale, vars);
    },

    translate (key, locale = 'en', vars = {}) {
      let current = allTranslations[locale].hbw.js;

      key.split('.').forEach((part) => {
        if (jQuery.isPlainObject(current) && part in current) {
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

  return Translator;
});
