import React, { Component } from 'react';
import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import TranslationContext from 'shared/context/translation';

class FormCheckbox extends Component {
  static contextType = TranslationContext;

  state = {
    value: this.props.value
  };

  componentDidMount () {
    this.props.onRef(this);
  }

  componentWillUnmount () {
    this.props.onRef(undefined);
  }

  handleChange = () => {
    this.props.fireFieldValueUpdate(this.props.name, !this.state.value);
    this.setState(prevState => ({ value: !prevState.value }));
  };

  render () {
    const {
      name, params, disabled, hidden, task
    } = this.props;

    const { value } = this.state;

    const opts = {
      name,
      disabled: params.editable === false || disabled,
    };

    const inputCSS = cx(params.css_class, { hidden });
    const label = this.context.translateBP(`${task.process_key}.${task.key}.${name}.label`, {}, params.label);

    const labelCSS = cx('hbw-checkbox-label', this.props.params.label_css);

    const checkedIcon = params.icon?.checked || ['far', 'check-square'];
    const uncheckedIcon = params.icon?.unchecked || ['far', 'square'];

    const icon = value ? checkedIcon : uncheckedIcon;

    return <div className={inputCSS} title={params.tooltip}>
      <div className="form-group">
        {params.description?.placement === 'top' && this.renderDescription()}
        <label className={labelCSS}>
          <input
            type='checkbox'
            {...opts}
            onChange={this.handleChange}
            checked={value}
            className='hbw-checkbox'
          />
          <FontAwesomeIcon
            className='hbw-checkbox'
            icon={icon}
          />
          <span>{` ${label}`}</span>
        </label>
        {params.description?.placement === 'bottom' && this.renderDescription()}
      </div>
    </div>;
  }

  renderDescription = () => {
    const { name, params, task } = this.props;

    const { placement, text } = params.description;

    const translated = this.context.translateBP(`${task.process_key}.${task.key}.${name}.description`, {}, text);

    return <div className="description" data-test={`description-${placement}`}>{translated}</div>;
  };

  serialize = () => {
    if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
      return null;
    } else {
      return { [this.props.name]: this.state.value ? 'on' : 'off' };
    }
  };
}

const FormCheckboxWrapped = compose(withCallbacks, withConditions, withErrorBoundary)(FormCheckbox);

export default FormCheckboxWrapped;
