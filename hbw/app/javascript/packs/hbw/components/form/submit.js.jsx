import React, { Component } from 'react';
import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import TranslationContext from 'shared/context/translation';
import CancelProcessButton from './cancel_process_button.js';

class FormSubmit extends Component {
  static contextType = TranslationContext;

  state = {
    error: false,
  };

  componentDidMount () {
    this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
  }

  renderCancelButton = () => {
    const { processInstanceId, processKey, cancelButtonName } = this.props;

    return <CancelProcessButton
      processInstanceId={processInstanceId}
      processKey={processKey}
      cancelButtonName={cancelButtonName}
    />;
  };

  renderSubmitButton = () => {
    const { formSubmitting, submitButtonName } = this.props;

    const buttonCN = cx({
      btn:           true,
      'btn-primary': true,
      disabled:      formSubmitting,
    });

    return (
      <button type="submit"
        className={buttonCN}
        disabled={formSubmitting || this.state.error}>
        <FontAwesomeIcon icon="check" />
        {` ${submitButtonName || this.context.translate('submit')}`}
      </button>
    );
  };

  render () {
    const { showCancelButton } = this.props;

    return (
      <div className="control-buttons">
        {showCancelButton && this.renderCancelButton()}
        {this.renderSubmitButton()}
      </div>
    );
  }
}

const FormSubmitWrapped = compose(withCallbacks, withErrorBoundary)(FormSubmit);

export default FormSubmitWrapped;
