import { withConditions } from '../helpers';

modulejs.define('HBWFormDatetime', ['React', 'ReactDOM', 'jQuery', 'moment'], (React, ReactDOM, jQuery, moment) => {
  const FormDateTime = React.createClass({

    displayName: 'HBWFormDatetime',

    getDefaultProps () {
      return {
        params: {
          locale: 'en',
          format: 'MM/DD/YYYY'
        }
      };
    },

    getInitialState () {
      let defaultValue;
      let value;

      const locale = this.props.params.locale || 'en';
      const format = this.props.params.format || 'MM/DD/YYYY';

      if (this.props.value) {
        value = moment(Date.parse(this.props.value));
        defaultValue = value.locale(locale).format(format);
      } else {
        value = null;
        defaultValue = '';
      }

      return {
        value,
        defaultValue,
        locale,
        format
      };
    },

    render () {
      let isoValue;

      const opts = {
        type:         'text',
        defaultValue: this.state.defaultValue,
        name:         this.props.params.name
      };

      if (this.props.params.editable === false || this.props.disabled) {
        opts.disabled = 'disabled';
      }

      if (this.state.value) {
        isoValue = this.state.value.format();
      } else {
        isoValue = '';
      }

      let inputCSS = this.props.params.css_class;
      if (this.props.hidden) {
        inputCSS += ' hidden';
      }

      return <div className={inputCSS} title={this.props.params.tooltip} ref={(node) => { this.rootNode = node; }}>
        <div className="form-group">
          <span className={this.props.params.label_css}>{this.props.params.label}</span>
          <div className="input-group date datetime-picker">
            <input {...opts} className="form-control" />
            <input name={this.props.params.name} type="hidden" value={isoValue} />
            <span className="input-group-addon">
            <span className="fa fa-calendar"></span>
          </span>
          </div>
        </div>
      </div>;
    },

    componentDidMount () {
      this.setOnChange();
      this.props.onRef(this);
    },

    componentWillUnmount () {
      jQuery(this.rootNode).off();
      this.props.onRef(undefined);
    },

    updateValue (event) {
      let stringValue;
      let value;
      const { date } = event;

      if (date) {
        stringValue = date.format(this.state.format);
        value = moment(stringValue, this.state.format, true);
      } else {
        stringValue = '';
        value = null;
      }

      this.setState({ value });
    },

    setOnChange () {
      const icons = {
        up:       'fa fa-chevron-up',
        down:     'fa fa-chevron-down',
        date:     'fa fa-calendar',
        time:     'fa fa-clock-o',
        next:     'fa fa-chevron-right',
        previous: 'fa fa-chevron-left',
        today:    'fa fa-dot-circle-o',
        clear:    'fa fa-trash',
        close:    'fa fa-times'
      };

      jQuery(this.rootNode)
        .find('.datetime-picker')
        .datetimepicker({
          format: this.state.format,
          locale: this.state.locale,
          icons,
        })
        .on('dp.change', e => this.updateValue(e));
    },

    serialize () {
      if (this.props.params.editable === false || this.props.disabled) {
        return null;
      } else {
        return { [this.props.params.name]: this.state.value ? this.state.value.format() : '' }
      }
    }
  });

  return withConditions(FormDateTime);
});
