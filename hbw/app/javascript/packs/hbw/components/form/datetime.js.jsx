import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import DatePickerWrapper from 'shared/element/date_picker_wrapper';
import convertToDateFNSDateFormat from 'shared/utils/to_fns_date_format';
import { format } from 'date-fns';
import { initDatePickerLocale } from '../../init/date_localizer';

initDatePickerLocale();

modulejs.define('HBWFormDatetime', ['React'], (React) => {
  class HBWFormDatetime extends React.Component {
    static contextType = TranslationContext;

    constructor (props, context) {
      super(props, context);

      const locale = props.params.locale || context.locale.code || 'en';
      const dateFormat = props.params.format ? convertToDateFNSDateFormat(props.params.format) : 'MM/dd/yyyy';

      const value = props.value ? new Date(props.value) : null;

      this.state = {
        value,
        locale,
        dateFormat
      };
    }

    ISODateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx";

    popperOptions = [{ name: 'offset', options: { offset: [0, -8] } },
      { name: 'flip', options: { fallbackPlacements: ['bottom-start'] } }];

    render () {
      const {
        name, params, disabled, hidden, task
      } = this.props;

      const { value, locale } = this.state;

      const isoValue = value ? format(value, this.ISODateFormat) : '';
      const inputCSS = cx(params.css_class, { hidden });
      const labelCSS = cx(params.label_css, 'hbw-datetime-label');
      const label = this.context.translateBP(`${task.process_key}.${task.key}.${name}.label`, {}, params.label);

      return <div className={inputCSS} title={params.tooltip} ref={(node) => { this.rootNode = node; }}>
        <div className="form-group">
          <span className={labelCSS}>{label}</span>
          {params.description?.placement === 'top' && this.renderDescription()}
          <DatePickerWrapper
            name={`${name}-visible-input`}
            className="form-control"
            onChange={date => this.setValue(date)}
            selected={value}
            dateFormat={this.state.dateFormat}
            locale={locale}
            fixedHeight
            disabledKeyboardNavigation
            disabled={params.editable === false || disabled}
            popperPlacement="bottom-start"
            popperModifiers={this.popperOptions}
            autoComplete='off'
            showTimeInput={params.set_time}
            timeInputLabel=""
          />
          <input name={name} type="hidden" value={isoValue} />
          {params.description?.placement === 'bottom' && this.renderDescription()}
        </div>
      </div>;
    }

    componentDidMount () {
      this.props.onRef(this);
    }

    renderDescription = () => {
      const { placement, text } = this.props.params.description;

      return <div className="description" data-test={`description-${placement}`}>{text}</div>;
    };

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    setValue = (date) => {
      this.setState({ value: date });
      this.props.fireFieldValueUpdate(this.props.name, format(date, this.ISODateFormat));
    };

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.params.name]: this.state.value ? format(this.state.value, this.ISODateFormat) : '' };
      }
    };
  }

  return compose(withCallbacks, withConditions, withErrorBoundary)(HBWFormDatetime);
});
