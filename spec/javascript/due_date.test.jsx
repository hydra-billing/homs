import React from 'react';
import { shallow } from 'enzyme';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import DueDate from 'hbw/components/shared/element/due_date';
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

  const expiredSec = addSeconds(now, -30);
  const expiredMinutes = addMinutes(now, -2);
  const expiredHours = addHours(now, -3);
  const expiredDays = addDays(now, -4);
  const expiredWeeks = addWeeks(now, -5);
  const expiredYears = addYears(now, -6);

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

  it('with expired (years past due)', () => {
    expect(shallowComponent(expiredYears).html()).toEqual('expired (6y past due)');
  });

  it('with expired (weeks past due)', () => {
    expect(shallowComponent(expiredWeeks).html()).toEqual('expired (5w past due)');
  });

  it('with expired (days past due)', () => {
    expect(shallowComponent(expiredDays).html()).toEqual('expired (4d past due)');
  });

  it('with expired (hours past due)', () => {
    expect(shallowComponent(expiredHours).html()).toEqual('expired (3h past due)');
  });

  it('with expired (minutes past due)', () => {
    expect(shallowComponent(expiredMinutes).html()).toEqual('expired (2m past due)');
  });

  it('with expired (seconds past due)', () => {
    expect(shallowComponent(expiredSec).html()).toEqual('expired (&lt;1m past due)');
  });
});
