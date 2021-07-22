import React, { FC, MouseEventHandler, useContext } from 'react';
import TranslationContext, { ContextType as TranslationContextType } from '../shared/context/translation';

type Props = {
  disabled: boolean,
  onClick: MouseEventHandler<HTMLButtonElement>
}

const ClaimButton: FC<Props> = ({ disabled, onClick }) => {
  const { translate: t } = useContext(TranslationContext) as TranslationContextType;

  return (
    <button className="btn btn-primary"
            disabled={disabled}
            onClick={onClick}
    >
      {t('components.claiming.claim')}
    </button>
  );
};

export default ClaimButton;
