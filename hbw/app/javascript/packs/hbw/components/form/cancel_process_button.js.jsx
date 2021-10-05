import { withErrorBoundary } from 'shared/hoc';
import React, { useContext, useEffect, useState } from 'react';
import TranslationContext from 'shared/context/translation';
import ConnectionContext from 'shared/context/connection';

const HBWFormCancelProcess = ({ processInstanceId, cancelButtonName, bind }) => {
  const { translate: t } = useContext(TranslationContext);
  const { request, serverURL } = useContext(ConnectionContext);

  const [error, setError] = useState(false);

  useEffect(() => {
    bind('hbw:have-errors', () => setError(true));
  }, []);

  const onClick = () => {
    const result = window.confirm(t('confirm_cancel'));

    if (result) {
      request({
        url:    `${serverURL}/tasks/${processInstanceId}`,
        method: 'DELETE',
        async:  false
      });
    }
  };

  return (
      <button className="btn-primary btn-cancel-process btn"
              type="button"
              onClick={onClick}
              disabled={error}>
        {` ${cancelButtonName || t('cancel')}`}
      </button>
  );
};

export default withErrorBoundary(HBWFormCancelProcess);
