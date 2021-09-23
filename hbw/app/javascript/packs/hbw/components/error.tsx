/* eslint no-script-url: "off" */
import React, { FC, useContext, useState } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';

type Props = {
  errorHeader?: string,
  errorBody?: string
}

const HBWError: FC<Props> = ({ errorHeader, errorBody }) => {
  const { translate: t } = useContext(TranslationContext) as TranslationContextType;

  const [showFull, setShowFull] = useState(() => false);

  const toggleBacktrace = () => {
    setShowFull(!showFull);
  };

  const icon = showFull ? 'chevron-down' : 'chevron-right';

  if (errorHeader) {
    const header = ` ${t('error')} — ${errorHeader}`;

    return (
      <div className="alert alert-danger hbw-error">
        <FontAwesomeIcon icon={['fas', 'exclamation-triangle']} />
        <strong>{header}</strong>
        <br/>
        <a href="javascript:;"
           onClick={toggleBacktrace}
           className="show-more"
           style={{ display: errorBody ? 'block' : 'none' }}>
           <FontAwesomeIcon icon={icon}/>
           {t('more')}
        </a>
        <pre style={{ display: showFull ? 'block' : 'none' }}>{errorBody}</pre>
      </div>
    );
  } else {
    return <></>;
  }
};

export default HBWError;
