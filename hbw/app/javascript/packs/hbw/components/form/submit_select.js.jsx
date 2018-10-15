modulejs.define('HBWFormSubmitSelect', ['React'], React => React.createClass({
  getInitialState () {
    return {
      value: this.props.value || ''
    };
  },

  render () {
    const css_class = `col-xs-12 ${this.props.params.css_class}`;
    const { props } = this;
    const self = this;

    const buttons = this.props.params.options.map(option => self.buildButton(option));

    return <div className={css_class}>
      <span className="btn-group">{ buttons }</span>
      <input type="hidden" name={this.props.name} value={this.state.value} />
    </div>;
  },

  buildButton (option) {
    const onClick = () => this.setState({ value: option.value });
    let { css_class } = option;
    let { fa_class } = option;

    if (this.props.disabled || this.props.formSubmitting) {
      css_class += ' disabled';
      fa_class += ' disabled';
    }

    return <button key={option.name}
      type="submit"
      className={css_class}
      title={option.title}
      onClick={onClick}
      href="#">
      <i className={fa_class} />
      {` ${option.name}`}
    </button>;
  }
}));
