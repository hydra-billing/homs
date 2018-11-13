import allTranslations from './init/translations'

modulejs.define('HBWTranslator', ['jQuery'], (jQuery) => {
  const Translator = {
    getTranslatorForLocale (locale) {
      return (key, vars) => this.translate(key, locale, vars);
    },

    translate (key, locale = 'en', vars = {}) {
      let current = allTranslations[locale].hbw.js;

      for (const part of key.split('.')) {
        if (jQuery.isPlainObject(current) && part in current) {
          current = this.interpolateString(current[part], vars);
        } else {
          throw new Error(`Cannot find ${key} in translations`);
        }
      }

      return current;
    },

    interpolateString (str, vars) {
      if (typeof str === 'string') {
        return str.replace(/%{([^{}]*)}/g, (full_match, var_name) => {
          const subst = vars[var_name];
          if ((typeof subst !== 'string') && (typeof subst !== 'number')) {
            throw new Error(`Undefined variable ${var_name}`);
          }

          return subst;
        });
      } else {
        return str;
      }
    }
  };

  return Translator;
});
