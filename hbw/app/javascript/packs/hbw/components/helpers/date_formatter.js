/* eslint-disable implicit-arrow-linebreak */
import React from 'react';
import PropTypes from 'prop-types';
import {
  differenceInHours, differenceInDays, differenceInWeeks, differenceInYears
} from 'date-fns';

const withDateFormatter = (WrappedComponent) => {
  const WithDateFormatter = ({ ...props }) => {
    const { translator: t, localizer } = props.env;

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

    const inDayMonth = date => localizer.localizeDayMonth(date.toISOString());

    const inDayMonthYear = date => localizer.localizeDayMonthYear(date.toISOString());

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

  WithDateFormatter.propTypes = {
    env: PropTypes.shape({
      translator: PropTypes.func.isRequired,
      localizer:  PropTypes.object.isRequired
    }).isRequired,
  };

  return WithDateFormatter;
};

export default withDateFormatter;
