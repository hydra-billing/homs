import { parseISO, format } from 'date-fns';
import en from 'date-fns/locale/en-US';
import ru from 'date-fns/locale/ru';

export const localize = (str, locale) => {
  if (str) {
    return format(parseISO(str), 'dd.MM.yyyy HH:mm', { locale });
  }

  return null;
};

export const localizeForLocale = locale => (
  str => localize(str, { en, ru }[locale])
);
