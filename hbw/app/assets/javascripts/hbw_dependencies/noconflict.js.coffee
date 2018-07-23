#= require_self
#= require jquery
#= require jquery-ui
#= require moment
#= require moment/ru
#= require bootstrap-datetimepicker
#= require select2/select2.full
#= require select2/i18n/ru
#= require react
#= require formatter
#= require ./wrap_globals

HBWDependencies = ['$', 'jQuery', 'moment', 'React', 'define', 'require']

window._globalsBeforeHBW = {}

for name in HBWDependencies
  window._globalsBeforeHBW[name] = window[name]

  if name of window
    window[name] = undefined
