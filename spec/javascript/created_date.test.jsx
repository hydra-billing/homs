import React from 'react';
import { shallow } from 'enzyme';
import {
  addSeconds, addMinutes, addHours, addDays, addWeeks, addYears,
} from 'date-fns';
import CreatedDate from 'hbw/components/shared/element/created_date';
import Translator from 'hbw/translator';
import { localizer } from 'hbw/init/date_localizer';

describe('CreatedDate should render correctly', () => {
  const fakeEnv = {
    translator: Translator.getTranslatorForLocale('en'),
    localizer:  localizer('en')
  };

  const now = new Date(2019, 11, 2);
  const sec = addSeconds(now, -30);
  const minutes = addMinutes(sec, -2);
  const hours = addHours(minutes, -3);
  const days = addDays(hours, -4);
  const weeks = addWeeks(days, -3);
  const years = addYears(weeks, -1);

  const shallowComponent = date => (
    shallow(<CreatedDate env={fakeEnv} dateISO={date.toISOString()} now={now} />)
  );

  it('with creation date in last year', () => {
    expect(shallowComponent(years).html()).toEqual('06 Nov 2018');
  });

  it('with creation date in last weeks', () => {
    expect(shallowComponent(weeks).html()).toEqual('06 Nov');
  });

  it('with creation date in last days', () => {
    expect(shallowComponent(days).html()).toEqual('4d ago');
  });

  it('with creation date in last hours', () => {
    expect(shallowComponent(hours).html()).toEqual('3h ago');
  });

  it('with creation date in last minutes', () => {
    expect(shallowComponent(minutes).html()).toEqual('2m ago');
  });

  it('with creation date in last seconds', () => {
    expect(shallowComponent(sec).html()).toEqual('&lt;1m ago');
  });
});
