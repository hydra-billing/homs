import compose from 'shared/utils/compose';
import cx from 'classnames';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  const HBWFormStatic = ({
    params, hidden, task, name, env
  }) => {
    const className = cx({
      [params.css_class]: true,
      hidden
    }, 'hbw-static');

    const html = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.html);

    return <div className={className}
                dangerouslySetInnerHTML={{ __html: html }} />;
  };

  return compose(withConditions, withErrorBoundary)(HBWFormStatic);
});
