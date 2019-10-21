import { parseISO, format } from 'date-fns';
import en from 'date-fns/locale/en-US';
import ru from 'date-fns/locale/ru';

const locales = { en, ru };

export const localize = (str, locale) => {
  if (str) {
    return format(parseISO(str), 'dd.MM.yyyy HH:mm', { locale });
  }

  return null;
};

const localizeDatetime = locale => (
  str => localize(str, locales[locale])
);

const localizeDayMonth = locale => (
  str => format(parseISO(str), 'dd MMM', locales[locale])
);

const localizeDayMonthYear = locale => (
  str => format(parseISO(str), 'dd MMM yyyy', locales[locale])
);

export const localizer = locale => (
  {
    localizeDatetime:     localizeDatetime(locale),
    localizeDayMonth:     localizeDayMonth(locale),
    localizeDayMonthYear: localizeDayMonthYear(locale)
  }
);
