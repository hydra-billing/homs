import React from 'react';
import renderer from 'react-test-renderer';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import { withTranslationContext } from 'hbw/components/shared/context/translation';
import DueDate from 'hbw/components/shared/element/due_date';
import { withConnectionContext } from 'hbw/components/shared/context/connection';
import { waitFor } from '@testing-library/react';
import compose from 'shared/utils/compose';
import ConnectionMock from './helpers/mock_connection';

describe('DueDate should render correctly', () => {
  const DueDateWithContext = compose(
    withConnectionContext({ connection: ConnectionMock }),
    withTranslationContext({ locale: { code: 'en' } })
  )(DueDate);

  const now = new Date();

  const sec = addSeconds(now, 30);
  const minutes = addMinutes(sec, 2);
  const hours = addHours(minutes, 3);
  const days = addDays(hours, 4);
  const weeks = addWeeks(days, 5);
  const years = addYears(weeks, 6);

  const expiredSec = addSeconds(now, -30);
  const expiredMinutes = addMinutes(now, -2);
  const expiredHours = addHours(now, -3);
  const expiredDays = addDays(now, -4);
  const expiredWeeks = addWeeks(now, -5);
  const expiredYears = addYears(now, -6);

  const dueDateComponent = date => (
    renderer
      .create(<DueDateWithContext dateISO={date.toISOString()} now={now} />)
      .toJSON()
  );

  const matchSnapshot = testCode => date => (
    it(testCode, async () => {
      await waitFor(() => {
        expect(dueDateComponent(date)).toMatchSnapshot();
      });
    })
  );

  matchSnapshot('with years to due date')(years);
  matchSnapshot('with weeks to due date')(weeks);
  matchSnapshot('with days to due date')(days);
  matchSnapshot('with hours to due date')(hours);
  matchSnapshot('with minutes to due date')(minutes);
  matchSnapshot('with seconds to due date')(sec);
  matchSnapshot('with expired (years past due date)')(expiredYears);
  matchSnapshot('with expired (weeks past due date)')(expiredWeeks);
  matchSnapshot('with expired (days past due date)')(expiredDays);
  matchSnapshot('with expired (hours past due date)')(expiredHours);
  matchSnapshot('with expired (minutes past due date)')(expiredMinutes);
  matchSnapshot('with expired (seconds past due date)')(expiredSec);
});
