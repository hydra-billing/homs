import { withConditions } from '../helpers';

modulejs.define('HBWFormCheckbox', ['React'], (React) => {
  const FormCheckbox = React.createClass({

    displayName: 'HBWFormCheckbox',

    componentDidMount () {
      this.props.onRef(this);
    },

    componentWillUnmount () {
      this.props.onRef(undefined);
    },

    getInitialState () {
      return {
        value: this.props.value
      };
    },

    handleChange (event) {
      this.setState({ value: event.target.value });
    },

    render () {
      const opts = {
        name:           this.props.name,
        disabled:       this.props.params.editable === false || this.props.disabled,
      };

      let inputCSS = this.props.params.css_class;

      if (this.props.hidden) {
        inputCSS += ' hidden';
      }

      const { tooltip } = this.props.params;
      const { label } = this.props.params;
      const labelCSS = `hbw-checkbox-label ${this.props.params.label_css || ''}`;

      return <div className={inputCSS} title={tooltip}>
        <div className="form-group">
          <label className={labelCSS}>
            <input type='checkbox' {...opts} onChange={this.handleChange} checked={this.state.value} />
            <span>{` ${label}`}</span>
          </label>
        </div>
      </div>;
    },

    serialize () {
      if (this.props.params.editable === false  || this.props.disabled) {
        return null;
      } else {
        return { [this.props.name]: this.state.value ? 'on' : 'off' };
      }
    }
  });

  return withConditions(FormCheckbox);
});
