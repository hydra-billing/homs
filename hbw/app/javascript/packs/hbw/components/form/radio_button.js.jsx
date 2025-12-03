import React, { Component } from 'react';
import cx from 'classnames';
import Tooltip from 'tooltip';
import compose from 'shared/utils/compose';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';

class FormRadioButton extends Component {
  static contextType = TranslationContext;

  state = {
    value: this.props.value
  };

  containerRef = React.createRef();

  getEl = () => this.containerRef.current;

  isRequired = this.props.params.required;

  componentDidMount () {
    this.tooltip = new Tooltip(this.getEl(), {
      title:     this.context.translate('errors.field_is_required'),
      container: this.tooltipContainer,
      trigger:   'manual',
      placement: 'top',
    });

    if (this.isRequired) {
      this.validateOnSubmit();
    }

    this.props.onRef(this);
  }

  componentDidUpdate () {
    const hideTooltip = !this.isAvailable() || !this.isRequired || this.isValid();

    this.controlErrorTooltip(hideTooltip);
  }

  componentWillUnmount () {
    this.props.onRef(undefined);
  }

  handleChange = (event) => {
    const newValue = event.target.value;

    this.setState({ value: newValue });
    this.props.fireFieldValueUpdate(this.props.name, newValue);
  };

  render () {
    const {
      params, hidden
    } = this.props;

    const inputCSS = cx(params.css_class, { hidden, invalid: this.isRequired && !this.isValid() });

    const errorTooltip = <div ref={(t) => { this.tooltipContainer = t; }}
      className='tooltip-red' />;

    return <div ref={this.containerRef} className={inputCSS} title={params.tooltip}>
      <div className="form-group">
        {params.description?.placement === 'top' && this.renderDescription()}
        {this.renderInputs()}
        {errorTooltip}
      </div>
    </div>;
  }

  renderDescription = () => {
    const { name, params, task } = this.props;

    const { placement, text } = params.description;

    const translated = this.context.translateBP(`${task.process_key}.${task.key}.${name}.description`, {}, text);

    return <div className="description" data-test={`description-${placement}`}>{translated}</div>;
  };

  renderInputs = () => {
    const { translateBP } = this.context;
    const {
      name, params, disabled, task
    } = this.props;
    const { value } = this.state;
    const { variants } = params;
    const labelCSS = cx('hbw-radio-label', this.props.params.label_css, { disabled });
    const checkedIcon = params.icon?.checked || ['far', 'check-circle'];
    const uncheckedIcon = params.icon?.unchecked || ['far', 'circle'];

    const opts = {
      name,
      disabled: params.editable === false || disabled,
    };

    return variants.map(field => <div key={field.name}>
      <label className={labelCSS}>
        <input type='radio' {...opts}
          onChange={this.handleChange}
          value={field.value}
          checked={value === field.value}
          className='hbw-radiobutton' />
        <FontAwesomeIcon
          className='hbw-radiobutton'
          icon={value === field.value ? checkedIcon : uncheckedIcon} />
        <span>
          {` ${translateBP(
            `${task.process_key}.${task.key}.${name}.${field.name}`,
            {},
            field.label
          )}`}
        </span>
      </label>
    </div>);
  };

  validateOnSubmit = () => {
    this.props.bind(`hbw:validate-form-${this.props.id}`, this.onFormSubmit);
  };

  onFormSubmit = () => {
    if (this.isValid()) {
      this.getEl().classList.remove('invalid');
    } else {
      this.getEl().classList.add('invalid');

      this.props.trigger('hbw:form-submitting-failed');
    }
  };

  isValid = () => {
    if (!this.isAvailable()) {
      return true;
    }

    return this.isFilled();
  };

  isAvailable = () => !this.props.hidden && !this.props.disabled;

  isFilled = () => {
    const { value } = this.state;

    return value !== null && value !== undefined;
  };

  controlErrorTooltip = (toHide) => {
    if (toHide) {
      this.tooltip.hide();
    } else {
      this.tooltip.show();
    }
  };

  serialize = () => {
    if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
      return null;
    } else {
      return { [this.props.name]: this.state.value };
    }
  };
}

const FormRadioButtonWrapped = compose(withCallbacks, withConditions, withErrorBoundary)(FormRadioButton);

export default FormRadioButtonWrapped;
