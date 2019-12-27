import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import withStoreContext from 'shared/context/store';
import { createPortal } from 'react-dom';

const App = ({
  Button, TaskList, Forms, env
}) => {
  const [buttonContainer, setButtonContainer] = useState(null);
  const [taskListContainer, setTaskListContainer] = useState(null);
  const [formsContainer, setFormsContainer] = useState(null);
  const [taskId, setTaskId] = useState(null);

  useEffect(() => {
    env.dispatcher.bind('hbw:set-button-container', 'widget', setButtonContainer);
    env.dispatcher.bind('hbw:set-task-list-container', 'widget', setTaskListContainer);
    env.dispatcher.bind('hbw:set-forms-container', 'widget', setFormsContainer);
    env.dispatcher.bind('hbw:set-current-task', 'widget', setTaskId);

    return () => {
      env.dispatcher.unbind('hbw:set-button-container', 'widget');
      env.dispatcher.unbind('hbw:set-task-list-container', 'widget');
      env.dispatcher.unbind('hbw:set-forms-container', 'widget');
      env.dispatcher.unbind('hbw:set-current-task', 'widget');
    };
  }, []);

  return (
    <>
        {buttonContainer && createPortal(<Button />, buttonContainer)}
        {taskListContainer && createPortal(<TaskList />, taskListContainer)}
        {formsContainer && createPortal(<Forms taskId={taskId} />, formsContainer)}
    </>
  );
};

App.propTypes = {
  Button:   PropTypes.func,
  TaskList: PropTypes.func,
  Forms:    PropTypes.func,
  env:      PropTypes.shape({
    dispatcher: PropTypes.object,
  }),
};

export default withStoreContext(App);
