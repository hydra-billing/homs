import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import CancelProcessButton from './cancel_process_button.js';

modulejs.define('HBWFormSubmitSelect', ['React'], (React) => {
  class HBWFormSubmitSelect extends React.Component {
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

      const cssClass = `col-xs-12 ${params.css_class}`;
      const self = this;

      const buttons = params.options.map(option => self.buildButton(option));

      return showSubmit
      && <div className={cssClass}>
          <div className="control-buttons">
            { showCancelButton && this.renderCancelButton() }
            { buttons }
          </div>
          <input type="hidden" name={name} value={this.state.value} />
        </div>;
    }

    buildButton = (option) => {
      const onClick = () => this.setState({ value: option.value });
      let cssClass = option.css_class;
      let faClass = option.fa_class;
      let disabled = false || this.state.error;

      if (this.props.disabled || this.props.formSubmitting) {
        cssClass += ' disabled';
        faClass += ' disabled';
        disabled = true;
      }

      return <button key={option.name}
        type="submit"
        className={cssClass}
        title={option.title}
        onClick={onClick}
        href="#"
        disabled={disabled}>
        <i className={faClass} />
        {` ${option.name}`}
      </button>;
    };

    renderCancelButton = () => {
      const { env, processInstanceId } = this.props;

      return <CancelProcessButton processInstanceId={processInstanceId}
                                  env={env} />;
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
