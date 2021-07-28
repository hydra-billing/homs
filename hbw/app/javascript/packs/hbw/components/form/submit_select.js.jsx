import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import CancelProcessButton from './cancel_process_button.js';

modulejs.define('HBWFormSubmitSelect', ['React'], (React) => {
  class HBWFormSubmitSelect extends React.Component {
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
        params, name, showSubmit, showCancelButton
      } = this.props;

      const self = this;
      const buttons = params.options.map(option => self.buildButton(option));

      return showSubmit
      && <div className={cx('col-xs-12', params.css_class)}>
          <div className="control-buttons">
            { showCancelButton && this.renderCancelButton() }
            { buttons }
          </div>
          <input type="hidden" name={name} value={this.state.value} />
        </div>;
    }

    buildButton = (option) => {
      const disabled = this.props.disabled || this.props.formSubmitting;
      const { task } = this.props;
      const { error } = this.state;

      const onClick = () => this.setState({ value: option.value });

      const cssClass = cx(option.css_class, { disabled });
      const faClass = cx(option.fa_class, { disabled });

      const label = this.context.translateBP(`${task.process_key}.${task.key}.${option.name}`, {}, option.label);

      return (
        <button key={option.name}
                type="submit"
                className={cssClass}
                title={option.title}
                onClick={onClick}
                disabled={error || disabled}>
          <i className={faClass} />
          {` ${label}`}
        </button>
      );
    };

    renderCancelButton = () => {
      const { task } = this.props;

      return <CancelProcessButton processInstanceId={task.process_instance_id} />;
    };

    serialize = () => {
      if (this.props.disabled || this.props.formSubmitting || this.state.error) {
        return null;
      } else {
        return { [this.props.name]: this.state.value };
      }
    };
  }

  return compose(withCallbacks, withErrorBoundary)(HBWFormSubmitSelect);
});
