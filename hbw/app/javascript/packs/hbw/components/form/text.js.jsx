import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormText', ['React'], (React) => {
  class HBWFormText extends React.Component {
    state = {
      value: this.props.value
    };

    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    handleChange = (event) => {
      this.setState({ value: event.target.value });
    };

    render () {
      const {
        name, params, disabled, hidden, task, env
      } = this.props;

      const { value } = this.state;

      const opts = {
        name,
        className: 'textarea',
        rows:      params.rows,
        readOnly:  params.editable === false || disabled
      };

      const cssClass = cx(params.css_class, { hidden });
      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);

      return <div className={cssClass} title={params.tooltip}>
        <div className='form-group'>
          <span className={params.label_css}>{label}</span>
          <textarea {...opts} value={value || ''} onChange={this.handleChange} />
        </div>
      </div>;
    }

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.name]: this.state.value };
      }
    };
  }

  return compose(withConditions, withErrorBoundary)(HBWFormText);
});
