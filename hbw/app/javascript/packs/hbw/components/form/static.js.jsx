import { withConditions, withErrorBoundary, compose } from '../helpers';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  const HBWFormStatic = ({ params, hidden }) => {
    let cssClass = params.css_class;

    if (hidden) {
      cssClass += ' hidden';
    }

    return <div className={cssClass} dangerouslySetInnerHTML={{ __html: params.html }} />;
  };

  return compose(withConditions, withErrorBoundary)(HBWFormStatic);
});
