import React from 'react';
import { shallow } from 'enzyme';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import { withTranslationContext } from 'hbw/components/shared/context/translation';
import DueDate from 'hbw/components/shared/element/due_date';

describe('DueDate should render correctly', () => {
  const DueDateWithContext = withTranslationContext({ locale: { code: 'en' } })(DueDate);

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
    shallow(<DueDateWithContext dateISO={date.toISOString()} now={now} />)
  );

  it('with years to due date', () => {
    expect(shallowComponent(years).html()).toEqual('6y to due date');
  });

  it('with weeks to due date', () => {
    expect(shallowComponent(weeks).html()).toEqual('5w to due date');
  });

  it('with days to due date', () => {
    expect(shallowComponent(days).html()).toEqual('4d to due date');
  });

  it('with hours to due date', () => {
    expect(shallowComponent(hours).html()).toEqual('3h to due date');
  });

  it('with minutes to due date', () => {
    expect(shallowComponent(minutes).html()).toEqual('2m to due date');
  });

  it('with seconds to due date', () => {
    expect(shallowComponent(sec).html()).toEqual('&lt;1m to due date');
  });

  it('with expired (years past due date)', () => {
    expect(shallowComponent(expiredYears).html()).toEqual('expired (6y past due date)');
  });

  it('with expired (weeks past due date)', () => {
    expect(shallowComponent(expiredWeeks).html()).toEqual('expired (5w past due date)');
  });

  it('with expired (days past due date)', () => {
    expect(shallowComponent(expiredDays).html()).toEqual('expired (4d past due date)');
  });

  it('with expired (hours past due date)', () => {
    expect(shallowComponent(expiredHours).html()).toEqual('expired (3h past due date)');
  });

  it('with expired (minutes past due date)', () => {
    expect(shallowComponent(expiredMinutes).html()).toEqual('expired (2m past due date)');
  });

  it('with expired (seconds past due date)', () => {
    expect(shallowComponent(expiredSec).html()).toEqual('expired (&lt;1m past due date)');
  });
});
