import PropTypes from 'prop-types';
import {
  parseISO, isAfter, differenceInMinutes,
} from 'date-fns';
import { withDateFormatter } from '../../helpers';

const HBWDueDate = ({
  dateISO, now, env, dateFormatter,
}) => {
  const { translator: t } = env;
  const {
    MINUTES_IN_DAY, MINUTES_IN_MONTH, MINUTES_IN_YEAR, lessThanMinute, inMinutes, inHours, inDays, inWeeks, inYears
  } = dateFormatter;

  const date = parseISO(dateISO);

  const format = () => {
    const minutes = differenceInMinutes(date, now);

    if (minutes < 1) {
      return lessThanMinute();
    } else if (minutes < 60) {
      return inMinutes(minutes);
    } else if (minutes < MINUTES_IN_DAY) {
      return inHours(date, now);
    } else if (minutes < MINUTES_IN_MONTH) {
      return inDays(date, now);
    } else if (minutes < MINUTES_IN_YEAR) {
      return inWeeks(date, now);
    } else {
      return inYears(date, now);
    }
  };

  if (isAfter(date, now)) {
    return (
      `${format()} ${t('components.claiming.created.to_deadline')}`
    );
  } else {
    return (
      t('components.claiming.created.expired')
    );
  }
};

HBWDueDate.propTypes = {
  dateISO: PropTypes.string.isRequired,
  now:     PropTypes.instanceOf(Date).isRequired,
  env:     PropTypes.shape({
    translator: PropTypes.func.isRequired,
  }).isRequired,
  dateFormatter: PropTypes.shape({
    MINUTES_IN_DAY:   PropTypes.number.isRequired,
    MINUTES_IN_MONTH: PropTypes.number.isRequired,
    MINUTES_IN_YEAR:  PropTypes.number.isRequired,
    lessThanMinute:   PropTypes.func.isRequired,
    inMinutes:        PropTypes.func.isRequired,
    inHours:          PropTypes.func.isRequired,
    inDays:           PropTypes.func.isRequired,
    inWeeks:          PropTypes.func.isRequired,
    inYears:          PropTypes.func.isRequired
  }).isRequired
};

export default withDateFormatter(HBWDueDate);
