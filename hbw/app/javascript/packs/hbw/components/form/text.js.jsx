import { withConditions } from '../helpers';

modulejs.define('HBWFormText', ['React'], (React) => {
  const FormText = React.createClass({
    displayName: 'HBWFormText',

    render () {
      const opts = {
        name:         this.props.name,
        className:    'form-control',
        rows:         this.props.params.rows,
        defaultValue: this.props.value,
        readOnly:     this.props.params.editable === false || this.props.disabled
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
          <textarea {...opts}/>
        </div>
      </div>;
    }
  });

  return withConditions(FormText);
});
