import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import CancelProcessButton from './cancel_process_button.js';

modulejs.define('HBWFormSubmit', ['React'], (React) => {
  class HBWFormSubmit extends React.Component {
    state = {
      error: false,
    }

    componentDidMount () {
      this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
    }

    renderCancelButton = () => {
      const { env, processInstanceId } = this.props;

      return <CancelProcessButton processInstanceId={processInstanceId}
                                  env={env} />;
    };

    renderSubmitButton = () => {
      const { formSubmitting, env } = this.props;

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
          {` ${env.translator('submit')}`}
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
