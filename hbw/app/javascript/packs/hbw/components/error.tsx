/* eslint no-script-url: "off" */
import React, { FC, useContext, useState } from 'react';
import cn from 'classnames';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';

type Props = {
  errorHeader?: string,
  error?: {
    responseText?: string
  }
}

const HBWError: FC<Props> = ({ errorHeader = '', error }) => {
  const { translate: t } = useContext(TranslationContext) as TranslationContextType;
  const [showFull, setShowFull] = useState(false);

  const toggleBacktrace = () => {
    setShowFull(!showFull);
  };

  const iconClass = cn('fas', {
    'fa-chevron-down':  showFull,
    'fa-chevron-right': !showFull
  });

  if (error) {
    const errorText = error.responseText || error;

    const header = errorHeader
      ? ` ${t('error')} — ${errorHeader}`
      : ` ${t('error')}`;

    return (
      <div className="alert alert-danger hbw-error">
        <i className="fas fa-exclamation-triangle"></i>
        <strong>{header}</strong>
        <br />
        <a href="javascript:;"
           onClick={toggleBacktrace}
           className="show-more"
           style={{ display: errorText ? 'block' : 'none' }}>
           <i className={iconClass}></i>
           {t('more')}
        </a>
        <pre style={{ display: showFull ? 'block' : 'none' }}>{errorText}</pre>
      </div>
    );
  } else {
    return <></>;
  }
};

export default HBWError;
