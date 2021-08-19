import { useContext } from 'react';
import compose from 'shared/utils/compose';
import cx from 'classnames';
import { withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';

modulejs.define('HBWFormStatic', ['React'], (React) => {
  const HBWFormStatic = ({
    params, hidden, task, name
  }) => {
    const { translateBP } = useContext(TranslationContext);
    const className = cx({
      [params.css_class]: true,
      hidden
    }, 'hbw-static');

    const variableValue = variableName => (
      task.form.variables.find(variable => `$${variable.name}` === variableName)?.value
    );

    const substituteVariables = rawHTML => (
      rawHTML.replace(/\$\w*\b/g, variableName => variableValue(variableName) || variableName)
    );

    const html = translateBP(`${task.process_key}.${task.key}.${name}`, {}, params.html);

    return <div className={className}
                dangerouslySetInnerHTML={{ __html: substituteVariables(html) }} />;
  };

  return compose(withConditions, withErrorBoundary)(HBWFormStatic);
});
