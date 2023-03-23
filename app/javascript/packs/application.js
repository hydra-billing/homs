/* eslint class-methods-use-this: "off" */
/* eslint no-this-before-super: "off" */
/* eslint no-constant-condition: "off" */
/* eslint no-eval: "off" */
/* eslint constructor-super: "off" */

import 'application.sass';
import 'logo.svg';

import '../init/unwrap_jquery';
import '../init/translations';
import 'jquery-ujs';
import 'select2/select2.full';
import 'select2/i18n/ru';
import 'bootstrap-sass/assets/javascripts/bootstrap.js';
import 'fileinput';
import 'bootstrap-datetimepicker';
import 'confirm';
import 'bootstrap-multiselect';
import moment from 'moment';
import React from 'react';
import { createRoot } from 'react-dom/client';
import Messenger from 'messenger';
import OrderList from '../components/order_list';

$(() => $('body').on('dp.change', (evt) => {
  const $target = $(evt.target);

  if ($target.find('.datepicker').is(':visible')) {
    $target.data('DateTimePicker').hide();
  }

  const $hiddenValue = $target.find('input.iso8601[type="hidden"]');

  if ($hiddenValue.length) {
    let value;
    const { date } = evt;

    if (date) {
      const stringValue = date.format($target.data('format'));
      value = moment(stringValue, $target.data('format'), true).format();
    } else {
      value = '';
    }

    $hiddenValue.val(value);
  }
}));

$(() => {
  $('.order_state-picker,.order_archived-picker').select2({
    minimumResultsForSearch: Infinity,
    width:                   '100%',
    allowClear:              true,
    theme:                   'bootstrap'
  });

  const ajaxOptions = {
    dataType: 'json',
    delay:    250,
    data (params) {
      return {
        q:    params.term,
        page: params.page
      };
    },
    processResults (data) {
      return { results: data };
    }
  };

  $.fn.select2.amd.require(['select2/utils', 'select2/data/ajax', 'select2/data/minimumInputLength'],
    (Utils, AJAXAdapter, MinimumInputLength) => {
      const UserNotSet = function (decorated, ...args) {
        decorated.apply(this, args);
      };

      UserNotSet.prototype.query = function (decorated, params, callback) {
        const emptySelected = this.$element.find('[value="empty"]:selected').length > 0;

        decorated.call(this, params, callback);

        if (!params.term && !emptySelected) {
          this.trigger('results:append', {
            data: {
              results: [{
                id:   'empty',
                text: I18n.t('js.select2.not_set')
              }]
            },
            query: params
          });
        }
      };

      const decoratedAdapter = Utils.Decorate(Utils.Decorate(AJAXAdapter, MinimumInputLength), UserNotSet);

      $('.user-picker').select2({
        width:      '100%',
        allowClear: true,
        theme:      'bootstrap',
        ajax:       ajaxOptions,
        formatSelection () {
          return (node)(node.id);
        },
        cache:              true,
        minimumInputLength: 2,
        dataAdapter:        decoratedAdapter,
        language:           I18n.locale
      });
    });

  $.fn.twitter_bootstrap_confirmbox.defaults = {
    fade:          false,
    title:         null, // if title equals null window.top.location.origin is used
    cancel:        I18n.t('js.cancel'),
    cancel_class:  'btn cancel',
    proceed:       I18n.t('js.yes'),
    proceed_class: 'btn proceed btn-danger'
  };
});

$(() => $('.show-hidden-order-data').on('click', 'a', function () {
  $(this).parents('.show-hidden-order-data').hide();
  $($(this).data('toggle')).show('blind');
}));

const defaultExport = {};

class Homs {
  messenger = Messenger;

  enableDateTimePicker = (allowClear = false) => {
    $('.datetime-picker').each(function () {
      const $el = $(this);
      const format = $el.data('format') ? $el.data('format') : false;
      const showClear = $el.data('showclear') ? $el.data('showclear') : false;

      const icons = {
        up:       'fas fa-chevron-up',
        down:     'fas fa-chevron-down',
        date:     'fas fa-calendar',
        time:     'fas fa-clock',
        next:     'fas fa-chevron-right',
        previous: 'fas fa-chevron-left',
        today:    'fas fa-dot-circle-o',
        clear:    'fas fa-trash',
        close:    'fas fa-times'
      };

      return $el.datetimepicker({
        locale:    I18n.locale,
        showClear: showClear || allowClear,
        format,
        icons
      });
    });
  };

  enableOrderTypePicker = (allowClear) => {
    $('.order_type-picker').select2({
      width: '100%',
      allowClear,
      theme: 'bootstrap',
      formatSelection () {
        return (node)(node.id);
      },
      cache:    true,
      language: I18n.locale
    });
  };

  enableOrderAttributePicker = (allowClear) => {
    $('.order_attribute-picker').select2({
      width: '100%',
      allowClear,
      theme: 'bootstrap',
      formatSelection () {
        return (node)(node.id);
      },
      cache:    true,
      language: I18n.locale
    });

    const currentOrderType = $('.order_type-picker option:selected').val();

    if (currentOrderType) {
      this.setAttributePickerOptions(currentOrderType);
    }
  };

  setAttributePickerOptions = (orderType) => {
    $.ajax(`/orders/order_type_attributes/${orderType}`, {
      method:  'GET',
      success: (data) => {
        if (Object.keys(data.options).length > 0) {
          const $orderAttributePicker = $('.order_attribute-picker');
          $orderAttributePicker.empty();

          $.each(data.options, (key, value) => {
            $orderAttributePicker.append(
              $('<option>', { value: key }).text(value.label)
            );
          });

          $orderAttributePicker.prop('disabled', false).trigger('change');
        }
      }
    });
  };

  updateOrderForm = (orderCode) => {
    $.ajax(`/orders/${orderCode}`, { dataType: 'html' })
      .done(response => $('#order-data').html($(response).find('#order-data').html()));
  };

  renderOrderList = (container, props) => {
    createRoot(container).render(
      <OrderList {...props} />
    );
  }
}
defaultExport.Application = new Homs();
window.Application = defaultExport.Application;

$(() => {
  Application.enableDateTimePicker();
  Application.enableOrderAttributePicker(false);
});

export default defaultExport;

$(() => {
  if (!('HBWidget' in window)) {
    return;
  }
  const widget = window.HBWidget;

  widget.dispatcher.bind('hbw:go-to-entity', 'host', (payload) => { window.location = payload.task.entity_url; });

  widget.render();
});
