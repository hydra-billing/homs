import { withConditions, withErrorBoundary, compose } from '../helpers';

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
      const opts = {
        name:      this.props.name,
        className: 'form-control',
        rows:      this.props.params.rows,
        readOnly:  this.props.params.editable === false || this.props.disabled
      };

      const title = this.props.params.tooltip;
      const { label } = this.props.params;
      const labelCss = this.props.params.label_css;
      let cssClass = this.props.params.css_class;

      if (this.props.hidden) {
        cssClass += ' hidden';
      }

      return <div className={cssClass} title={title}>
        <div className='form-group'>
          <span className={labelCss}>{label}</span>
          <textarea {...opts} value={this.state.value} onChange={this.handleChange} />
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
