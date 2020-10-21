import HBWTranslations from './init/translations';

const HBWTranslator = {
  getTranslatorForLocale (locale, translations = HBWTranslations) {
    return (key, vars, fallback) => this.translate(translations, key, locale, vars, fallback);
  },

  translate (translations, key, locale = 'en', vars = {}, fallback) {
    let current = translations[locale];

    try {
      key.split('.').forEach((part) => {
        if (typeof current === 'object' && part in current) {
          current = this.interpolateString(current[part], vars);
        } else {
          throw new Error(`Cannot find ${key} in translations`);
        }
      });
    } catch {
      if (fallback !== undefined) {
        current = fallback;
      } else if (locale === 'en') {
        current = `translation is missing: ${key}`;
      } else {
        current = this.translate(translations, key, 'en', vars);
      }
    }

    return current;
  },

  interpolateString (str, vars) {
    if (typeof str === 'string') {
      return str.replace(/%{([^{}]*)}/g, (_, varName) => {
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
