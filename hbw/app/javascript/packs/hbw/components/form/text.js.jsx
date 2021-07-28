import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';

modulejs.define('HBWFormText', ['React'], (React) => {
  class HBWFormText extends React.Component {
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

    handleChange = (event) => {
      this.setState({ value: event.target.value });
    };

    render () {
      const {
        name, params, disabled, hidden, task
      } = this.props;

      const { value } = this.state;

      const opts = {
        name,
        className:   'textarea',
        rows:        params.rows,
        readOnly:    params.editable === false || disabled,
        placeholder: params.placeholder
      };

      const cssClass = cx(params.css_class, { hidden });
      const labelCss = cx(params.label_css, 'hbw-text-label');
      const label = this.context.translateBP(`${task.process_key}.${task.key}.${name}`, {}, params.label);

      return <div className={cssClass} title={params.tooltip}>
        <div className='form-group'>
          <span className={labelCss}>{label}</span>
          {params.description?.placement === 'top' && this.renderDescription()}
          <textarea {...opts} value={value || ''} onChange={this.handleChange}/>
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
        return { [this.props.name]: this.state.value };
      }
    };
  }

  return compose(withConditions, withErrorBoundary)(HBWFormText);
});
