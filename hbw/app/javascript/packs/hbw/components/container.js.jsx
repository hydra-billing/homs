import { withCallbacks } from 'shared/hoc';
import StoreContext from 'shared/context/store';
import Messenger from 'messenger';
import { useContext, useEffect, useState } from 'react';
import ConnectionContext from 'shared/context/connection';
import TranslationContext from 'shared/context/translation';
import ErrorHandlingContext from 'shared/context/error_handling';

modulejs.define(
  'HBWContainer',
  ['React', 'HBWButtons', 'HBWEntityTasks'],
  (React, Buttons, Tasks) => {
    const Container = ({
      chosenTaskID, entityCode, entityTypeCode, entityClassCode, autorunProcessKey, bind, unbind, initialVariables
    }) => {
      const {
        tasks, fetching, error, getFormsForTasks
      } = useContext(StoreContext);

      const { serverURL } = useContext(ConnectionContext);
      const { translate } = useContext(TranslationContext);
      const { safeRequest } = useContext(ErrorHandlingContext);

      const [processInstanceId, setProcessInstanceId] = useState(null);
      const [userExists, setUserExists] = useState(false);

      const onFormSubmit = (task) => {
        // remember execution id of the last submitted form to open next form if
        // task with the same processInstanceId will be loaded
        setProcessInstanceId(task.process_instance_id);
      };

      const checkBpmUser = async () => {
        const response = await safeRequest({
          url:    `${serverURL}/users/check`,
          method: 'GET',
          async:  false
        });

        const { user_exists } = await response.json();

        setUserExists(user_exists);

        if (!user_exists) {
          Messenger.warn(translate('errors.user_not_found'));
        }
      };

      useEffect(() => {
        bind('hbw:form-submitted', onFormSubmit);
        checkBpmUser();

        return () => {
          unbind('hbw:form-submitted');
        };
      }, []);

      const activeTasks = () => tasks.filter(task => task.entity_code === entityCode
                                                     && task.entity_types.includes(entityTypeCode)).reverse();

      const resetProcess = () => {
        setProcessInstanceId(null);
      };

      if (activeTasks().length > 0) {
        getFormsForTasks(activeTasks());

        return <div className='hbw-body'>
            {error}
            <Tasks tasks={activeTasks()}
                    chosenTaskID={chosenTaskID}
                    entityCode={entityCode}
                    entityTypeCode={entityTypeCode}
                    entityClassCode={entityClassCode}
                    processInstanceId={processInstanceId}
            />
          </div>;
      } else {
        return <div className='hbw-body'>
            {error}
            <Buttons entityCode={entityCode}
                      entityTypeCode={entityTypeCode}
                      entityClassCode={entityClassCode}
                      autorunProcessKey={autorunProcessKey}
                      initialVariables={initialVariables}
                      showSpinner={fetching}
                      userExists={userExists}
                      resetProcess={resetProcess}/>
          </div>;
      }
    };

    return withCallbacks(Container);
  }
);
