/* eslint no-console: "off" */

import { useContext, useState, useEffect } from 'react';
import { withCallbacks } from 'shared/hoc';
import ConnectionContext from 'shared/context/connection';
import TranslationContext from 'shared/context/translation';
import ErrorHandlingContext from 'shared/context/error_handling';
import Pending from './pending';
import Error from './error';

modulejs.define(
  'HBWButtons',
  ['React', 'HBWButton'],
  (React, Button) => {
    const HBWButtons = ({
      entityCode, entityTypeCode, entityClassCode, autorunProcessKey, resetProcess,
      initialVariables, showSpinner, userExists, bind
    }) => {
      const { translate: t } = useContext(TranslationContext);
      const { serverURL } = useContext(ConnectionContext);
      const { safeRequest } = useContext(ErrorHandlingContext);

      const [buttons, setButtons] = useState([]);
      const [fetchError, setFetchError] = useState(null);
      const [submitError, setSubmitError] = useState(null);
      const [errorHeader, setErrorHeader] = useState('');
      const [fetched, setFetched] = useState(false);
      const [submitting, setSubmitting] = useState(false);
      const [BPRunning, setBPRunning] = useState(false);
      const [fileUploading, setFileUploading] = useState(false);
      const [BPStateChecker, setBPStateChecker] = useState(null);

      const buttonsURL = `${serverURL}/buttons`;

      const fetchButtons = async () => {
        const trySetBPStateChecker = () => {
          setBPStateChecker(prevState => prevState || setTimeout(fetchButtons, 5000));
        };

        const data = {
          entity_code:         entityCode,
          entity_type:         entityTypeCode,
          entity_class:        entityClassCode,
          autorun_process_key: autorunProcessKey
        };

        const { bp_running, buttons: fetchedButtons } = await safeRequest({
          url:    buttonsURL,
          method: 'GET',
          data
        }).then(response => response.json())
          .catch((error) => {
            setFetchError(error);
            setErrorHeader(t('errors.cannot_obtain_available_actions'));
          });

        if (bp_running) {
          trySetBPStateChecker();
        } else {
          resetProcess();
        }

        setButtons(fetchedButtons);
        setFetched(true);
        setFetchError(null);
        setBPRunning(bp_running);
      };

      const resetBPStateChecker = () => {
        clearTimeout(BPStateChecker);
      };

      const submitButton = businessProcessCode => safeRequest({
        url:     buttonsURL,
        method:  'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        data: {
          entity_code:       entityCode,
          entity_type:       entityTypeCode,
          entity_class:      entityClassCode,
          bp_code:           businessProcessCode,
          initial_variables: initialVariables
        }
      });

      const onButtonActivation = async (button) => {
        console.log(`Clicked button[${button.title}], submitting`);
        setSubmitting(true);

        const { bp_running, buttons: fetchedButtons } = await submitButton(button.bp_code)
          .then(data => data.json())
          .catch((error) => {
            setSubmitError(error);
            setSubmitting(false);
            setErrorHeader(t('errors.cannot_start_process'));
          });

        setSubmitError(null);
        setButtons(fetchedButtons);
        setBPRunning(bp_running);
      };

      const renderNoBP = () => (
        <div className='hbw-bp-control-buttons'>
          <span>
            {t('no_bp_to_start')}
          </span>
        </div>
      );

      useEffect(() => {
        fetchButtons();
        bind('hbw:button-activated', onButtonActivation);
        bind('hbw:file-upload-started', () => setFileUploading(true));
        bind('hbw:file-upload-finished', () => setFileUploading(false));

        return () => {
          resetBPStateChecker();
        };
      }, []);

      if (userExists) {
        if (showSpinner || !fetched) {
          return <div className="hbw-spinner"><Pending /></div>;
        } else if (BPRunning) {
          return (
              <div className="hbw-spinner">
                <Pending text={t('bp_running')} />
              </div>
          );
        } else {
          const buttonElements = buttons.map((button, index) => (
              <Button key={index}
                      button={button}
                      disabled={submitting || fileUploading}
              />
          ));

          return (
              <div className='hbw-bp-control-buttons btn-group'>
                <Error error={submitError || fetchError}
                       errorHeader={errorHeader}
                />
                {buttons.length === 0 && renderNoBP()}
                {buttonElements}
              </div>
          );
        }
      } else {
        return <div />;
      }
    };

    return withCallbacks(HBWButtons);
  }
);
