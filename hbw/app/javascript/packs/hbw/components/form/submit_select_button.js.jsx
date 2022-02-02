import React from 'react';
import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withCallbacks } from 'shared/hoc';

const HBWSubmitSelectButton = ({
  env,
  params,
  error,
  onClick,
  task,
  disabled,
  hidden,
  submitSelectDisabled
}) => {
  const buttonDisabled = submitSelectDisabled || disabled;

  const cssClass = cx(params.css_class, { buttonDisabled });
  const faClass = cx(params.fa_class, { buttonDisabled });

  const label = env.bpTranslator(`${task.process_key}.${task.key}.${params.name}`, {}, params.label);
  const buildButton = () => (
      <button
        type="submit"
        className={cssClass}
        title={params.title}
        onClick={onClick}
        disabled={error || buttonDisabled}
      >
        <i className={faClass} />
        {label}
      </button>
  );

  return !hidden ? buildButton() : null;
};

export default compose(withCallbacks, withConditions)(HBWSubmitSelectButton);
