import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormDatetime', ['React', 'ReactDOM', 'jQuery', 'moment'], (React, ReactDOM, jQuery, moment) => {
  class HBWFormDatetime extends React.Component {
    constructor (props) {
      super(props);
      let defaultValue;
      let value;

      const locale = props.params.locale || props.env.locale.code || 'en';
      const format = props.params.format || 'MM/DD/YYYY';

      if (props.value) {
        value = moment(Date.parse(props.value));
        defaultValue = value.locale(locale).format(format);
      } else {
        value = null;
        defaultValue = '';
      }

      this.state = {
        value,
        defaultValue,
        locale,
        format
      };
    }

    render () {
      const {
        name, params, disabled, hidden, task, env
      } = this.props;
      const { defaultValue, value } = this.state;

      const opts = {
        name,
        defaultValue,
        type: 'text'
      };

      if (params.editable === false || disabled) {
        opts.disabled = 'disabled';
      }

      const isoValue = value ? value.format() : '';
      const inputCSS = cx(params.css_class, { hidden });
      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);

      return <div className={inputCSS} title={params.tooltip} ref={(node) => { this.rootNode = node; }}>
        <div className="form-group">
          <span className={params.label_css}>{label}</span>
          <div className="input-group date datetime-picker">
            <input {...opts} className="form-control" />
            <input name={name} type="hidden" value={isoValue} />
            <span className="input-group-addon">
              <span className="fas fa-calendar" />
            </span>
          </div>
        </div>
      </div>;
    }

    componentDidMount () {
      this.setOnChange();
      this.props.onRef(this);
    }

    componentWillUnmount () {
      jQuery(this.rootNode).off();
      this.props.onRef(undefined);
    }

    updateValue = ({ date }) => {
      let stringValue;
      let value;

      if (date) {
        stringValue = date.format(this.state.format);
        value = moment(stringValue, this.state.format, true);
      } else {
        stringValue = '';
        value = null;
      }

      this.setState({ value });
    };

    setOnChange = () => {
      const icons = {
        up:       'fas fa-chevron-up',
        down:     'fas fa-chevron-down',
        date:     'fas fa-calendar',
        time:     'fas fa-clock-o',
        next:     'fas fa-chevron-right',
        previous: 'fas fa-chevron-left',
        today:    'fas fa-dot-circle-o',
        clear:    'fas fa-trash',
        close:    'fas fa-times'
      };

      jQuery(this.rootNode)
        .find('.datetime-picker')
        .datetimepicker({
          format: this.state.format,
          locale: this.state.locale,
          icons,
        })
        .on('dp.change', e => this.updateValue(e));
    };

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.params.name]: this.state.value ? this.state.value.format() : '' };
      }
    };
  }

  return compose(withConditions, withErrorBoundary)(HBWFormDatetime);
});
