import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import CancelProcessButton from './cancel_process_button.js';

modulejs.define('HBWFormSubmit', ['React'], (React) => {
  class HBWFormSubmit extends React.Component {
    static contextType = TranslationContext;

    state = {
      error: false,
    }

    componentDidMount () {
      this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
    }

    renderCancelButton = () => {
      const { processInstanceId } = this.props;

      return <CancelProcessButton processInstanceId={processInstanceId} />;
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
          <i className="fas fa-check" />
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

  return compose(withCallbacks, withErrorBoundary)(HBWFormSubmit);
});
