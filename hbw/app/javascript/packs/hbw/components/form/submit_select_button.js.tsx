import React, { useContext, MouseEventHandler } from 'react';
import cx from 'classnames';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';
import compose from 'shared/utils/compose';
import { withConditions, withCallbacks } from 'shared/hoc';

type Props = {
  params: {
    css_class?: string,
    fa_class?: string,
    label: string,
    name: string,
    title?: string,
    button_text?: string
  },
  error: boolean,
  onClick: MouseEventHandler<HTMLButtonElement>,
  task: {
    process_key: string,
    key: string,
  },
  disabled?: boolean,
  hidden?: boolean,
  submitSelectDisabled: boolean
}

const HBWSubmitSelectButton: React.FC<Props> = ({
  params,
  error,
  onClick,
  task,
  disabled,
  hidden,
  submitSelectDisabled
}) => {
  const { translateBP } = useContext(TranslationContext) as TranslationContextType;
  const buttonDisabled = submitSelectDisabled || disabled;

  const cssClass = cx(params.css_class, { buttonDisabled });
  const faClass = cx(params.fa_class, { buttonDisabled });

  const label = translateBP(`${task.process_key}.${task.key}.${params.name}`, {}, params.button_text);
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
