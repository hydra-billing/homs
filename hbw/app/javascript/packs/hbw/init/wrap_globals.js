import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';

Object.assign(window, {$, jQuery, React, ReactDOM, moment});

for (let name in window._globalsBeforeHBW) {
  const value = window._globalsBeforeHBW[name];

  modulejs.define(name, (v => () => v)(window[name]));

  if (value) {
    window[name] = value;
  } else {
    delete window[name];
  }
};
