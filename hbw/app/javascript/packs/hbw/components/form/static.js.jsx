import { withDeleteIf } from '../helpers';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  const FormStatic = React.createClass({
    displayName: 'HBWFormStatic',

    render () {
      let cssClass = this.props.params.css_class;

      if (this.props.hidden) {
        cssClass += ' hidden';
      }

      return <div className={cssClass} dangerouslySetInnerHTML={{ __html: this.props.params.html }} />;
    }
  });

  return withDeleteIf(FormStatic);
});
