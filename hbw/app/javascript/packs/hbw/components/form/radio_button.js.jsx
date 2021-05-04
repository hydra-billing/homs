import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormRadioButton', ['React'], (React) => {
  class HBWFormRadioButton extends React.Component {
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
        params, hidden
      } = this.props;

      const inputCSS = cx(params.css_class, { hidden });

      return <div className={inputCSS} title={params.tooltip}>
        <div className="form-group">
          {params.description?.placement === 'top' && this.renderDescription()}
          {this.renderInputs()}
        </div>
      </div>;
    }

    renderDescription = () => {
      const { placement, text } = this.props.params.description;

      return <div className="description" data-test={`description-${placement}`}>{text}</div>;
    }

    renderInputs = () => {
      const {
        name, params, disabled, task, env
      } = this.props;
      const { value } = this.state;
      const { variants } = params;
      const labelCSS = cx('hbw-radio-label', this.props.params.label_css);
      const opts = {
        name,
        disabled: params.editable === false || disabled,
      };

      return variants.map(field => <div key={field.name}>
                                     <label className={labelCSS}>
                                       <input type='radio' {...opts}
                                              onChange={this.handleChange}
                                              value={field.value}
                                              checked={value === field.value}
                                              className='hbw-radiobutton'/>
                                       <span>
                                         { ` ${env.bpTranslator(`${task.process_key}.${task.key}.${name}.${field.name}`,
                                           {},
                                           field.label)}` }
                                       </span>
                                     </label>
                                   </div>);
    }

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.name]: this.state.value };
      }
    };
  }

  return compose(withConditions, withErrorBoundary)(HBWFormRadioButton);
});
