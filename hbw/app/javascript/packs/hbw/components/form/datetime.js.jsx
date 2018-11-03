modulejs.define('HBWFormDatetime',
  ['React', 'ReactDOM', 'jQuery', 'moment', 'HBWDeleteIfMixin'],
  (React, ReactDOM, jQuery, moment, DeleteIfMixin) => React.createClass({
    mixins: [DeleteIfMixin],

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

      if (this.props.params.editable === false) {
        opts.disabled = 'disabled';
      }

      if (this.state.value) {
        isoValue = this.state.value.format();
      } else {
        isoValue = '';
      }

      let inputCSS = this.props.params.css_class;
      if (this.hidden) {
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
    },

    componentWillUnmount () {
      jQuery(this.rootNode).off();
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
      jQuery(this.rootNode)
        .find('.datetime-picker')
        .datetimepicker({
          format: this.state.format,
          locale: this.state.locale
        })
        .on('dp.change', e => this.updateValue(e));
    }
  }));
