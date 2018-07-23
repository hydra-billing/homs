#= require ./unwrap_jquery
#= require ./unwrap_moment
#= require ./unwrap_react
#= require jquery_ujs
#= require jquery-ui
#= require jquery.growl
#= require bootstrap-sprockets
#= require fileinput
#= require i18n
#= require i18n/translations
#= require bootstrap-datetimepicker
#= require twitter/bootstrap/rails/confirm
#= require bootstrap-multiselect
#= require react_ujs
#= require components
#= require_self

'use strict'

$ ->
  $('body').on('dp.change', (evt) ->
    $target = $(evt.target)

    if $target.find('.datepicker').is(':visible')
      $target.data('DateTimePicker').hide()

    $hiddenValue = $target.find('input.iso8601[type="hidden"]')

    if $hiddenValue.length
      date = evt.date

      if date
        stringValue = date.format($target.data('format'))
        value = moment(stringValue, $target.data('format'), true).format()
      else
        value = ''

      $hiddenValue.val(value)
  )

$ ->
  $('.order_state-picker,.order_archived-picker').select2(
    minimumResultsForSearch: Infinity
    width: '100%'
    allowClear: true
    theme: 'bootstrap'
  )

  ajaxOptions = {
    dataType: 'json'
    delay: 250,
    data: (params) -> { q: params.term, page: params.page }
    processResults: (data, page) -> { results: data }
  }


  $.fn.select2.amd.require ['select2/utils', 'select2/data/ajax', 'select2/data/minimumInputLength'],
    (Utils, AJAXAdapter, MinimumInputLength) ->
      UserNotSet = (decorated, args...) ->
        decorated.apply(this, args)

      UserNotSet.prototype.query = (decorated, params, callback) ->
        emptySelected = this.$element.find('[value="empty"]:selected').length > 0

        decorated.call(this, params, callback)

        if not params.term and not emptySelected
          this.trigger('results:append', {
            data:
              results: [{
                id: 'empty',
                text: I18n.t('js.select2.not_set')
              }]
            query: params
          })

      decoratedAdapter = Utils.Decorate(Utils.Decorate(AJAXAdapter, MinimumInputLength), UserNotSet)

      $('.user-picker').select2(
        width: '100%'
        allowClear: true
        theme: 'bootstrap'
        ajax: ajaxOptions
        formatSelection: -> (node) node.id
        cache: true
        minimumInputLength: 2
        dataAdapter: decoratedAdapter
        language: I18n.locale
      )

  $.fn.twitter_bootstrap_confirmbox.defaults = {
    fade: false,
    title: null, # if title equals null window.top.location.origin is used
    cancel: I18n.t('js.cancel'),
    cancel_class: "btn cancel",
    proceed: I18n.t('js.yes'),
    proceed_class: "btn proceed btn-danger"
  }

$ ->
  $('.show-hidden-order-data').on('click', 'a', ->
    $(@).parents('.show-hidden-order-data').hide()
    $($(@).data('toggle')).show('blind')
  )

class @Messenger
  durations:
    default: 5
    success: 5
    warning: 15
    error: 20000

  typeMap:
    default: ['info', 'notice']
    success: ['success']
    warning: ['warn']
    error: ['error']

  stylesMap:
    success: 'notice'

  constructor: ->
    for key, aliases of @typeMap
      @[key] = ((key) => (options) => @inform(options, key))(key)

      for alias in aliases
        @[alias] = @[key]

  inform: (options, level) =>
    options = {message: options} if $.type(options) == 'string'
    o = $.extend({}, options)

    unless options.title
      title = @titleFor(options, level)
      o.title = if title? then title else ''

    o.style = @stylesMap[level] || level
    o.message = $('<div/>').text(options.message).html()
    o.duration = @durations[level] * 1000
    o.size = 'large'

    $.growl(o)

  titleFor: (options, level) =>
    I18n.t('js.error') if level == 'error'

  show: (messages) =>
    for message in messages
      messageType = message[0]

      if @[messageType]
        if $.type(message[1]) == 'array'
          for msg in message[1]
            @[message[0]](msg)
        else
          @[message[0]](message[1])


class Homs
  constructor: ->
    @messenger = new Messenger()

  enableDateTimePicker: (allowClear = false) =>
    $('.datetime-picker').each ->
      $el = $(@)
      format = if $el.data('format') then $el.data('format') else false
      showClear = if $el.data('showclear') then $el.data('showclear') else false
      $el.datetimepicker(locale: I18n.locale, format: format, showClear: showClear or allowClear)

  enableOrderTypePicker: (allowClear) =>
    $('.order_type-picker').select2(
      width: '100%'
      allowClear: allowClear
      theme: 'bootstrap'
      formatSelection: -> (node) node.id
      cache: true
      language: I18n.locale)

  enableOrderAttributePicker: (allowClear) =>
    $('.order_attribute-picker').select2(
      width: '100%'
      allowClear: allowClear
      theme: 'bootstrap'
      formatSelection: -> (node) node.id
      cache: true
      language: I18n.locale)

    currentOrderType = $('.order_type-picker option:selected').val()
    if currentOrderType
      @setAttributePickerOptions(currentOrderType)

  setAttributePickerOptions: (orderType) =>
    $.ajax '/orders/order_type_attributes/' + orderType,
      method: 'GET'
      success: (data) =>
        if Object.keys(data.options).length > 0
          $orderAttributePicker = $('.order_attribute-picker')
          $orderAttributePicker.empty()

          $.each(data.options, (key, value) =>
            $orderAttributePicker
              .append(
                $('<option>', {value: key}).text(value.label)
            ))

          $orderAttributePicker.prop('disabled', false).trigger('change')

  updateOrderForm: (orderCode) =>
    $.ajax('/orders/' + orderCode, dataType: 'html')
    .done((response) -> $('#order-data').html($(response).find('#order-data').html()))

@Application = new Homs()

$ ->
  Application.enableDateTimePicker()
  Application.enableOrderTypePicker(true)
  Application.enableOrderAttributePicker(false)

class PatchedGrowl extends @Growl
  @growl: (settings = {}) ->
    @initialize()
    new PatchedGrowl(settings)

  stopped: false

  click: (event) =>
    @$growl().stop(true, true)
    @stopped = true

  mouseLeave: (event) =>
    @waitAndDismiss() unless @stopped


$.growl = (options = {}) ->
  PatchedGrowl.growl(options)

$ ->
  return unless 'HBWidget' of window
  widget = window.HBWidget

  widget.env.dispatcher.bind 'hbw:go-to-entity', 'host', (payload) ->
    window.location = payload.task.entity_url

  widget.env.dispatcher.bind 'hbw:form-loaded', 'widget', (payload) ->
    Application.updateOrderForm(payload.entityCode)

  widget.env.dispatcher.bind 'hbw:activiti-user-not-found', 'widget', ->
    Application.messenger.warn(I18n.t('js.user_not_found'))

  widget.render()
