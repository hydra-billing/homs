import PropTypes from 'prop-types';
import {
  parseISO, isSameYear, differenceInMinutes,
} from 'date-fns';
import { withDateFormatter } from '../helpers';

const HBWCreatedDate = ({ dateISO, env, dateFormatter }) => {
  const { translator: t } = env;
  const {
    MINUTES_IN_DAY, MINUTES_IN_MONTH, lessThanMinute, inMinutes, inHours, inDays, inDayMonth, inDayMonthYear
  } = dateFormatter;

  const now = new Date();
  const date = parseISO(dateISO);

  const minutes = differenceInMinutes(now, date);

  if (minutes < 1) {
    return lessThanMinute();
  } else if (minutes < 60) {
    return `${inMinutes(minutes)} ${t('components.claiming.created.ago')}`;
  } else if (minutes < MINUTES_IN_DAY) {
    return `${inHours(now, date)} ${t('components.claiming.created.ago')}`;
  } else if (minutes < MINUTES_IN_MONTH) {
    return `${inDays(now, date)} ${t('components.claiming.created.ago')}`;
  } else if (isSameYear(now, date)) {
    return inDayMonth(date);
  } else {
    return inDayMonthYear(date);
  }
};

HBWCreatedDate.propTypes = {
  dateISO: PropTypes.string.isRequired,
  env:     PropTypes.shape({
    translator: PropTypes.func.isRequired
  }).isRequired,
  dateFormatter: PropTypes.shape({
    MINUTES_IN_DAY:   PropTypes.number.isRequired,
    MINUTES_IN_MONTH: PropTypes.number.isRequired,
    lessThanMinute:   PropTypes.func.isRequired,
    inMinutes:        PropTypes.func.isRequired,
    inHours:          PropTypes.func.isRequired,
    inDays:           PropTypes.func.isRequired,
    inDayMonth:       PropTypes.func.isRequired,
    inDayMonthYear:   PropTypes.func.isRequired,
  }).isRequired
};

export default withDateFormatter(HBWCreatedDate);
