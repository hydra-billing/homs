import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormSubmit', ['React'], (React) => {
  class HBWFormSubmit extends React.Component {
    state = {
      error: false,
    }

    componentDidMount () {
      this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
    }

    render () {
      const { formSubmitting, env, showSubmit } = this.props;

      let className = 'btn btn-primary';

      if (formSubmitting) {
        className += ' disabled';
      }

      return showSubmit
      && <div className="form-group">
          <button type="submit"
            className={className}
            disabled={formSubmitting || this.state.error}>
            <i className="fas fa-check" />
            {` ${env.translator('submit')}`}
          </button>
        </div>;
    }
  }

  return compose(withCallbacks, withErrorBoundary)(HBWFormSubmit);
});
