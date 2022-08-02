import { parseISO, format } from 'date-fns';
import en from 'date-fns/locale/en-US';
import ru from 'date-fns/locale/ru';
import es from 'date-fns/locale/es';
import { registerLocale } from 'react-datepicker';

const locales = { en, ru, es };

export const initDatePickerLocale = () => {
  Object.keys(locales).forEach((locale) => {
    registerLocale(locale.toString(), locales[locale]);
  });
};

export const localize = (str, locale, dateTimeFormat) => {
  if (str) {
    return format(parseISO(str), dateTimeFormat, { locale });
  }

  return null;
};

const localizeDatetime = (locale, dateTimeFormat) => (
  str => localize(str, locales[locale], dateTimeFormat)
);

const localizeDayMonth = locale => (
  str => format(parseISO(str), 'dd MMM', locales[locale])
);

const localizeDayMonthYear = locale => (
  str => format(parseISO(str), 'dd MMM yyyy', locales[locale])
);

export const localizer = ({ code: locale, dateTimeFormat }) => (
  {
    localizeDatetime:     localizeDatetime(locale, dateTimeFormat),
    localizeDayMonth:     localizeDayMonth(locale),
    localizeDayMonthYear: localizeDayMonthYear(locale)
  }
);
