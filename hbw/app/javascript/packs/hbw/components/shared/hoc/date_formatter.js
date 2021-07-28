/* eslint-disable implicit-arrow-linebreak */
import React, { useContext } from 'react';
import {
  differenceInHours, differenceInDays, differenceInWeeks, differenceInYears
} from 'date-fns';
import TranslationContext from '../context/translation';

const withDateFormatter = (WrappedComponent) => {
  const WithDateFormatter = (props) => {
    const { translate: t, Localizer } = useContext(TranslationContext);

    const MINUTES_IN_DAY = 1440;
    const MINUTES_IN_WEEK = 10080;
    const MINUTES_IN_MONTH = 43200;
    const MINUTES_IN_YEAR = 525600;

    const lessThanMinute = () =>
      `<1${t('components.claiming.created.periodUnits.minute')}`;

    const inMinutes = minutes =>
      `${minutes}${t('components.claiming.created.periodUnits.minute')}`;

    const inHours = (dateLeft, dateRight) =>
      `${differenceInHours(dateLeft, dateRight)}${t('components.claiming.created.periodUnits.hour')}`;

    const inDays = (dateLeft, dateRight) =>
      `${differenceInDays(dateLeft, dateRight)}${t('components.claiming.created.periodUnits.day')}`;

    const inWeeks = (dateLeft, dateRight) =>
      `${differenceInWeeks(dateLeft, dateRight)}${t('components.claiming.created.periodUnits.week')}`;

    const inYears = (dateLeft, dateRight) =>
      `${differenceInYears(dateLeft, dateRight)}${t('components.claiming.created.periodUnits.year')}`;

    const inDayMonth = date => Localizer.localizeDayMonth(date.toISOString());

    const inDayMonthYear = date => Localizer.localizeDayMonthYear(date.toISOString());

    return (
      <WrappedComponent
        dateFormatter={{
          MINUTES_IN_DAY,
          MINUTES_IN_MONTH,
          MINUTES_IN_WEEK,
          MINUTES_IN_YEAR,
          lessThanMinute,
          inMinutes,
          inHours,
          inDays,
          inWeeks,
          inYears,
          inDayMonth,
          inDayMonthYear,
        }}
        {...props}
      />
    );
  };

  return WithDateFormatter;
};

export default withDateFormatter;
