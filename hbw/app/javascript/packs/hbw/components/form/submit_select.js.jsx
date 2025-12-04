import React, { Component } from 'react';
import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import CancelProcessButton from './cancel_process_button.js';
import SubmitSelectButton from './submit_select_button.js';

class FormSubmitSelect extends Component {
  static contextType = TranslationContext;

  state = {
    value: this.props.value || '',
    error: false
  };

  componentDidMount () {
    this.props.onRef(this);
    this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
  }

  componentWillUnmount () {
    this.props.onRef(undefined);
  }

  render () {
    const {
      params, name, showSubmit, showCancelButton, hidden
    } = this.props;

    const self = this;
    const buttons = params.options.map(option => self.buildButton(option));

    return showSubmit && !hidden
      && <div className={cx('col-xs-12', params.css_class)}>
        <div className="control-buttons">
          {showCancelButton && this.renderCancelButton()}
          {buttons}
        </div>
        <input type="hidden" name={name} value={this.state.value} />
      </div>;
  }

  buildButton = (option) => {
    const buttonParams = {
      ...option,
      variables: this.props.params.variables
    };
    const {
      formValues,
      id,
      task,
      disabled,
      formSubmitting
    } = this.props;

    return <SubmitSelectButton
      key={buttonParams.name}
      params={buttonParams}
      error={this.state.error}
      onClick={() => this.setState({ value: option.value })}
      formValues={formValues}
      id={id}
      task={task}
      submitSelectDisabled={disabled || formSubmitting}
    />;
  };

  renderCancelButton = () => {
    const { task } = this.props;

    return <CancelProcessButton
      processInstanceId={task.process_instance_id}
      processKey={task.process_key}
    />;
  };

  serialize = () => {
    if (this.props.disabled || this.props.formSubmitting || this.state.error) {
      return null;
    } else {
      return { [this.props.name]: this.state.value };
    }
  };
}

const FormSubmitSelectWrapped = compose(withCallbacks, withConditions, withErrorBoundary)(FormSubmitSelect);

export default FormSubmitSelectWrapped;
