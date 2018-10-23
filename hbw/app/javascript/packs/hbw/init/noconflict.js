const HBWDependencies = ['$', 'jQuery', 'moment', 'React', 'ReactDOM', 'define', 'require'];

window._globalsBeforeHBW = {};

HBWDependencies.forEach((name) => {
  window._globalsBeforeHBW[name] = window[name];

  if (name in window) {
    window[name] = undefined;
  }
});
