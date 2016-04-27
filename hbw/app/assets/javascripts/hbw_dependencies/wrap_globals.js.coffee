for name, value of window._globalsBeforeHBW
  modulejs.define(name, ((v)->->v)(window[name]))

  if value
    window[name] = value
  else
    delete window[name]

delete window._globalsBeforeHBW
