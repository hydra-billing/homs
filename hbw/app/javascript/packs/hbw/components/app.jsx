import React, { useState, useEffect, useContext } from 'react';
import PropTypes from 'prop-types';
import { createPortal } from 'react-dom';
import DispatcherContext from './shared/context/dispatcher';

const App = ({ Button, TaskList, Forms }) => {
  const dispatcher = useContext(DispatcherContext);

  const [buttonContainer, setButtonContainer] = useState(null);
  const [taskListContainer, setTaskListContainer] = useState(null);
  const [formsContainer, setFormsContainer] = useState(null);
  const [taskId, setTaskId] = useState(null);

  useEffect(() => {
    dispatcher.bind('hbw:set-button-container', 'widget', setButtonContainer);
    dispatcher.bind('hbw:set-task-list-container', 'widget', setTaskListContainer);
    dispatcher.bind('hbw:set-forms-container', 'widget', setFormsContainer);
    dispatcher.bind('hbw:set-current-task', 'widget', setTaskId);

    dispatcher.trigger('hbw:app-rendered', 'widget');

    return () => {
      dispatcher.unbind('hbw:set-button-container', 'widget');
      dispatcher.unbind('hbw:set-task-list-container', 'widget');
      dispatcher.unbind('hbw:set-forms-container', 'widget');
      dispatcher.unbind('hbw:set-current-task', 'widget');
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
};

export default App;
