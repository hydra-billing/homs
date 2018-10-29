modulejs.define('HBWFormStatic', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) => React.createClass({
  mixins: [DeleteIfMixin],

  displayName: 'HBWFormStatic',

  render () {
    let cssClass = this.props.params.css_class;

    if (this.hidden) {
      cssClass += ' hidden';
    }

    return <div className={cssClass} dangerouslySetInnerHTML={{ __html: this.props.params.html }} />;
  }
}));
