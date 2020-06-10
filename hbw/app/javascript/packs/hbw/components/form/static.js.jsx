import compose from 'shared/utils/compose';
import cx from 'classnames';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  const HBWFormStatic = ({ params, hidden }) => {
    const className = cx({
      [params.css_class]: true,
      hidden
    });

    return <div className={className}
                dangerouslySetInnerHTML={{ __html: params.html }} />;
  };

  return compose(withConditions, withErrorBoundary)(HBWFormStatic);
});
