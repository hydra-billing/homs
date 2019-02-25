import { withConditions } from '../helpers';

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
      this.setState(prevState => ({ value: !prevState.value }));
    };

    render () {
      const opts = {
        name:     this.props.name,
        disabled: this.props.params.editable === false || this.props.disabled,
      };

      let inputCSS = this.props.params.css_class;

      if (this.props.hidden) {
        inputCSS += ' hidden';
      }

      const { tooltip, label } = this.props.params;
      const labelCSS = `hbw-checkbox-label ${this.props.params.label_css || ''}`;

      return <div className={inputCSS} title={tooltip}>
        <div className="form-group">
          <label className={labelCSS}>
            <input
              type='checkbox'
              {...opts}
              onChange={this.handleChange}
              checked={this.state.value}
              className='hbw-checkbox'
            />
            <span>{` ${label}`}</span>
          </label>
        </div>
      </div>;
    }

    serialize = () => {
      if (this.props.params.editable === false || this.props.disabled) {
        return null;
      } else {
        return { [this.props.name]: this.state.value ? 'on' : 'off' };
      }
    };
  }

  return withConditions(HBWFormCheckbox);
});
