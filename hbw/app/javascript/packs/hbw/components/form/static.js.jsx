import { Component } from 'react';
import { withConditions } from '../helpers';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  class HBWFormStatic extends Component {
    render () {
      let cssClass = this.props.params.css_class;

      if (this.props.hidden) {
        cssClass += ' hidden';
      }

      return <div className={cssClass} dangerouslySetInnerHTML={{ __html: this.props.params.html }} />;
    }
  };

  return withConditions(HBWFormStatic);
});
