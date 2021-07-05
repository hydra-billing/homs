import { Growl } from 'jquery.growl';

class PatchedGrowl extends Growl {
  constructor (...args) {
    super(...args);

    this.stopped = false;
  }

  static growl (settings = {}) {
    this.initialize();
    return new PatchedGrowl(settings);
  }

  click = () => {
    this.$growl().stop(true, true);
    this.stopped = true;
  };

  mouseLeave = () => {
    if (!this.stopped) {
      this.waitAndDismiss();
    }
  };
}

jQuery.growl = function (options = {}) {
  return PatchedGrowl.growl(options);
};

class Messenger {
  constructor () {
    this.durations = {
      default: 5,
      success: 5,
      warning: 15,
      error:   20000
    };

    this.typeMap = {
      default: ['info', 'notice'],
      success: ['success'],
      warning: ['warn', 'alert'],
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

  inform = (opts, level) => {
    let options = opts;

    if (typeof opts === 'string') {
      options = { message: opts };
    }

    const o = { ...options };

    if (!options.title) {
      const title = this.titleFor(options, level);
      o.title = (title != null) ? title : '';
    }

    o.style = this.stylesMap[level] || level;
    o.message = jQuery('<div/>').text(options.message).html();
    o.duration = this.durations[level] * 1000;
    o.size = 'large';

    jQuery.growl(o);
  };

  titleFor = (options, level) => {
    if (level === 'error') {
      return I18n.t('js.error');
    }
    return null;
  };

  show = messages => (() => {
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

export default new Messenger();
