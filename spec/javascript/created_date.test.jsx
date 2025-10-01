import React from 'react';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import { withTranslationContext } from 'hbw/components/shared/context/translation';
import CreatedDate from 'hbw/components/shared/element/created_date';
import { withConnectionContext } from 'hbw/components/shared/context/connection';
import { render, waitFor } from '@testing-library/react';
import compose from 'shared/utils/compose';
import ConnectionMock from './helpers/mock_connection';

describe('CreatedDate should render correctly', () => {
  const CreatedDateWithContext = compose(
    withConnectionContext({ connection: ConnectionMock }),
    withTranslationContext({ locale: { code: 'en' } })
  )(CreatedDate);

  const now = new Date(2019, 11, 2);
  const seconds = addSeconds(now, -30);
  const minutes = addMinutes(seconds, -2);
  const hours = addHours(minutes, -3);
  const days = addDays(hours, -4);
  const weeks = addWeeks(days, -3);
  const years = addYears(weeks, -1);

  const createdDateComponent = date => (
    render(<CreatedDateWithContext dateISO={date.toISOString()} now={now} />)
  );

  const matchSnapshot = testCode => date => (
    it(testCode, async () => {
      await waitFor(() => {
        expect(createdDateComponent(date).container).toMatchSnapshot();
      });
    })
  );

  matchSnapshot('with creation date in last year')(years);
  matchSnapshot('with creation date in last weeks')(weeks);
  matchSnapshot('with creation date in last days')(days);
  matchSnapshot('with creation date in last hours')(hours);
  matchSnapshot('with creation date in last minutes')(minutes);
  matchSnapshot('with creation date in last seconds')(seconds);
});
