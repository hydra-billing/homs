modulejs.define('HBWFormCheckbox', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) => React.createClass({
  mixins: [DeleteIfMixin],

  displayName: 'HBWFormCheckbox',

  render () {
    const opts = {
      name:           this.props.name,
      disabled:       this.props.params.editable === false,
      defaultChecked: this.props.value
    };

    let inputCSS = this.props.params.css_class;

    if (this.hidden) {
      inputCSS += ' hidden';
    }

    const { tooltip } = this.props.params;
    const { label } = this.props.params;
    const labelCSS = `hbw-checkbox-label ${this.props.params.label_css || ''}`;

    return <div className={inputCSS} title={tooltip}>
      <div className="form-group">
        <label className={labelCSS}>
          <input type='checkbox' {...opts} />
          <span>{` ${label}`}</span>
        </label>
      </div>
    </div>;
  }
}));
