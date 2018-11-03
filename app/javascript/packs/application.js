/* eslint class-methods-use-this: "off" */
/* eslint no-this-before-super: "off" */
/* eslint no-constant-condition: "off" */
/* eslint no-eval: "off" */
/* eslint constructor-super: "off" */

import '../init/unwrap_jquery';
import '../init/unwrap_moment';
import '../init/unwrap_react';
import '../init/translations';
import 'jquery-ujs';
import 'select2/select2.full';
import 'select2/i18n/ru';
import { Growl } from 'jquery.growl';
import 'bootstrap-sass';
import 'fileinput';
import 'bootstrap-datetimepicker';
import 'confirm';
import 'bootstrap-multiselect';
import '../components/order_list';

const componentRequireContext = require.context('components', true);
const ReactRailsUJS = require('react_ujs');

ReactRailsUJS.useContext(componentRequireContext);

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
class Messenger {
  constructor () {
    this.inform = this.inform.bind(this);
    this.titleFor = this.titleFor.bind(this);
    this.show = this.show.bind(this);

    this.durations = {
      default: 5,
      success: 5,
      warning: 15,
      error:   20000
    };

    this.typeMap = {
      default: ['info', 'notice'],
      success: ['success'],
      warning: ['warn'],
      error:   ['error']
    };

    this.stylesMap = { success: 'notice' };

    Object.keys(this.typeMap).forEach((key) => {
      const aliases = this.typeMap[key];

      this[key] = (_key => options => this.inform(options, _key))(key);

      [...aliases].forEach((alias) => {
        this[alias] = this[key];
      });
    });
  }

  inform (opts, level) {
    let options = opts;

    if ($.type(opts) === 'string') {
      options = { message: opts };
    }

    const o = Object.assign({}, options);

    if (!options.title) {
      const title = this.titleFor(options, level);
      o.title = (title != null) ? title : '';
    }

    o.style = this.stylesMap[level] || level;
    o.message = $('<div/>').text(options.message).html();
    o.duration = this.durations[level] * 1000;
    o.size = 'large';

    $.growl(o);
  }

  titleFor (options, level) {
    if (level === 'error') {
      return I18n.t('js.error');
    }
    return null;
  }

  show (messages) {
    return (() => {
      const result = [];

      [...messages].forEach((message) => {
        const messageType = message[0];

        if (this[messageType]) {
          if ($.type(message[1]) === 'array') {
            result.push([...message[1]].map(msg => this[message[0]](msg)));
          } else {
            result.push(this[message[0]](message[1]));
          }
        } else {
          result.push(undefined);
        }
      });

      return result;
    })();
  }
}
defaultExport.Messenger = Messenger;

class Homs {
  constructor () {
    this.enableDateTimePicker = this.enableDateTimePicker.bind(this);
    this.enableOrderTypePicker = this.enableOrderTypePicker.bind(this);
    this.enableOrderAttributePicker = this.enableOrderAttributePicker.bind(this);
    this.setAttributePickerOptions = this.setAttributePickerOptions.bind(this);
    this.updateOrderForm = this.updateOrderForm.bind(this);

    this.messenger = new Messenger();
  }

  enableDateTimePicker (allowClear = false) {
    $('.datetime-picker').each(function () {
      const $el = $(this);
      const format = $el.data('format') ? $el.data('format') : false;
      const showClear = $el.data('showclear') ? $el.data('showclear') : false;
      return $el.datetimepicker({
        locale:    I18n.locale,
        format,
        showClear: showClear || allowClear
      });
    });
  }

  enableOrderTypePicker (allowClear) {
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
  }

  enableOrderAttributePicker (allowClear) {
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
  }

  setAttributePickerOptions (orderType) {
    return $.ajax(`/orders/order_type_attributes/${orderType}`, {
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
  }

  updateOrderForm (orderCode) {
    $.ajax(`/orders/${orderCode}`, { dataType: 'html' })
      .done(response => $('#order-data').html($(response).find('#order-data').html()));
  }
}
defaultExport.Application = new Homs();
window.Application = defaultExport.Application;

$(() => {
  Application.enableDateTimePicker();
  Application.enableOrderTypePicker(true);
  Application.enableOrderAttributePicker(false);
});

class PatchedGrowl extends Growl {
  constructor (...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) {
        super();
      }
      const thisFn = (() => this).toString();
      const thisName = thisFn.slice(thisFn.indexOf('return') + 6 + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }

    this.click = this.click.bind(this);
    this.mouseLeave = this.mouseLeave.bind(this);

    super(...args);

    this.stopped = false;
  }

  static growl (settings = {}) {
    this.initialize();
    return new PatchedGrowl(settings);
  }

  click () {
    this.$growl().stop(true, true);
    this.stopped = true;
  }

  mouseLeave () {
    if (!this.stopped) {
      this.waitAndDismiss();
    }
  }
}
export default defaultExport;

$.growl = function (options = {}) {
  return PatchedGrowl.growl(options);
};

$(() => {
  if (!('HBWidget' in window)) {
    return;
  }
  const widget = window.HBWidget;

  widget.env.dispatcher.bind('hbw:go-to-entity', 'host', (payload) => { window.location = payload.task.entity_url; });

  widget.env.dispatcher.bind('hbw:form-loaded', 'widget', payload => Application.updateOrderForm(payload.entityCode));

  widget.env.dispatcher.bind('hbw:bpm-user-not-found', 'widget',
    () => Application.messenger.warn(I18n.t('js.user_not_found')));

  widget.render();
});
