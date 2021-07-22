import PropTypes from 'prop-types';
import {
  parseISO, isSameYear, differenceInMinutes,
} from 'date-fns';
import { withDateFormatter } from 'shared/hoc';
import { useContext } from 'react';
import TranslationContext from '../context/translation';

const HBWCreatedDate = ({
  dateISO, now, dateFormatter,
}) => {
  const { translate: t } = useContext(TranslationContext);
  const {
    MINUTES_IN_DAY, MINUTES_IN_WEEK, lessThanMinute, inMinutes, inHours, inDays, inDayMonth, inDayMonthYear
  } = dateFormatter;

  const date = parseISO(dateISO);

  const minutes = differenceInMinutes(now, date);

  if (minutes < 1) {
    return `${lessThanMinute()} ${t('components.claiming.created.ago')}`;
  } else if (minutes < 60) {
    return `${inMinutes(minutes)} ${t('components.claiming.created.ago')}`;
  } else if (minutes < MINUTES_IN_DAY) {
    return `${inHours(now, date)} ${t('components.claiming.created.ago')}`;
  } else if (minutes < MINUTES_IN_WEEK) {
    return `${inDays(now, date)} ${t('components.claiming.created.ago')}`;
  } else if (isSameYear(now, date)) {
    return inDayMonth(date);
  } else {
    return inDayMonthYear(date);
  }
};

HBWCreatedDate.propTypes = {
  dateISO:       PropTypes.string.isRequired,
  now:           PropTypes.instanceOf(Date).isRequired,
  dateFormatter: PropTypes.shape({
    MINUTES_IN_DAY:  PropTypes.number.isRequired,
    MINUTES_IN_WEEK: PropTypes.number.isRequired,
    lessThanMinute:  PropTypes.func.isRequired,
    inMinutes:       PropTypes.func.isRequired,
    inHours:         PropTypes.func.isRequired,
    inDays:          PropTypes.func.isRequired,
    inDayMonth:      PropTypes.func.isRequired,
    inDayMonthYear:  PropTypes.func.isRequired,
  }).isRequired
};

export default withDateFormatter(HBWCreatedDate);
