import React from 'react';
import { shallow } from 'enzyme';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import DueDate from 'hbw/components/claiming/shared/due_date';
import Translator from 'hbw/translator';
import { localizer } from 'hbw/init/date_localizer';

describe('DueDate should render correctly', () => {
  const fakeEnv = {
    translator: Translator.getTranslatorForLocale('en'),
    localizer:  localizer('en')
  };

  const now = new Date();

  const sec = addSeconds(now, 30);
  const minutes = addMinutes(sec, 2);
  const hours = addHours(minutes, 3);
  const days = addDays(hours, 4);
  const weeks = addWeeks(days, 5);
  const years = addYears(weeks, 6);

  const expired = addMinutes(now, -1234);

  const shallowComponent = date => (
    shallow(<DueDate env={fakeEnv} dateISO={date.toISOString()} now={now} />)
  );

  it('with years to deadline', () => {
    expect(shallowComponent(years).html()).toEqual('6y to deadline');
  });

  it('with weeks to deadline', () => {
    expect(shallowComponent(weeks).html()).toEqual('5w to deadline');
  });

  it('with days to deadline', () => {
    expect(shallowComponent(days).html()).toEqual('4d to deadline');
  });

  it('with hours to deadline', () => {
    expect(shallowComponent(hours).html()).toEqual('3h to deadline');
  });

  it('with minutes to deadline', () => {
    expect(shallowComponent(minutes).html()).toEqual('2m to deadline');
  });

  it('with seconds to deadline', () => {
    expect(shallowComponent(sec).html()).toEqual('&lt;1m to deadline');
  });

  it('with expired', () => {
    expect(shallowComponent(expired).html()).toEqual('expired');
  });
});
