import React from 'react';
import ReactDOM from 'react-dom';

Object.assign(window, {
  $, jQuery, React, ReactDOM
});

Object.keys(window._globalsBeforeHBW).forEach((name) => {
  const value = window._globalsBeforeHBW[name];

  modulejs.define(name, (v => () => v)(window[name]));

  if (value) {
    window[name] = value;
  } else {
    delete window[name];
  }
});
