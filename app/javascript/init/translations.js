import { I18n } from 'i18n-js';

import en from '../../../config/locales/en.yml';
import ru from '../../../config/locales/ru.yml';
import es from '../../../config/locales/es.yml';
import fr from '../../../config/locales/fr.yml';

const i18n = new I18n();

i18n.store({
  ...en, ...ru, ...es, ...fr
});

window.I18n = i18n;
