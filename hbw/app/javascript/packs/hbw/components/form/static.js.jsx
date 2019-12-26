import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

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
