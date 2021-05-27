import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormCheckbox', ['React'], (React) => {
  class HBWFormCheckbox extends React.Component {
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
        name, params, disabled, hidden, task, env
      } = this.props;

      const { value } = this.state;

      const opts = {
        name,
        disabled: params.editable === false || disabled,
      };

      const inputCSS = cx(params.css_class, { hidden });
      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);

      const labelCSS = cx('hbw-checkbox-label', this.props.params.label_css);

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
            <span>{` ${label}`}</span>
          </label>
          {params.description?.placement === 'bottom' && this.renderDescription()}
        </div>
      </div>;
    }

    renderDescription = () => {
      const { placement, text } = this.props.params.description;

      return <div className="description" data-test={`description-${placement}`}>{text}</div>;
    }

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.name]: this.state.value ? 'on' : 'off' };
      }
    };
  }

  return compose(withCallbacks, withConditions, withErrorBoundary)(HBWFormCheckbox);
});
