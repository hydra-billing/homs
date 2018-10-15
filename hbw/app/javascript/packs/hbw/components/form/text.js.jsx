modulejs.define('HBWFormText', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) => React.createClass({
  mixins: [DeleteIfMixin],

  render () {
    const opts = {
      name:      this.props.name,
      className: 'form-control'
    };
    opts.rows = this.props.params.rows;
    opts.defaultValue = this.props.value;

    if (this.props.params.editable === false) {
      opts.readOnly = true;
    }

    const title = this.props.params.tooltip;
    const { label } = this.props.params;
    const labelCss = this.props.params.label_css;
    let cssClass = this.props.params.css_class;

    if (this.hidden) {
      cssClass += ' hidden';
    }

    return <div className={cssClass} title={title}>
      <div className='form-group'>
        <span className={labelCss}>{label}</span>
        <textarea {...opts}/>
      </div>
    </div>;
  }
}));
