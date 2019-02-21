modulejs.define('HBWFormSubmitSelect', ['React'], React => React.createClass({
  displayName: 'HBWFormSubmitSelect',

  componentDidMount () {
    this.props.onRef(this);
  },

  componentWillUnmount () {
    this.props.onRef(undefined);
  },

  getInitialState () {
    return {
      value: this.props.value || ''
    };
  },

  render () {
    const cssClass = `col-xs-12 ${this.props.params.css_class}`;
    const self = this;

    const buttons = this.props.params.options.map(option => self.buildButton(option));

    return <div className={cssClass}>
      <span className="btn-group">{ buttons }</span>
      <input type="hidden" name={this.props.name} value={this.state.value} />
    </div>;
  },

  buildButton (option) {
    const onClick = () => this.setState({ value: option.value });
    let cssClass = option.css_class;
    let faClass = option.fa_class;
    let disabled = false;

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
  },

  serialize () {
    if (this.props.disabled || this.props.formSubmitting) {
      return null;
    } else {
      return { [this.props.name]: this.state.value };
    }
  }
}));
