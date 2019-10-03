import React from 'react';
import Tabs from './shared/task_tabs';

const HBWClaimingTaskList = ({ env }) => {
  // stub data
  const count = {
    my:         4,
    unassigned: 12,
  };

  const tasks = [
    <div key="myTasksTable">My tasks table</div>,
    <div key="unassignedTasksTable">Unassigned tasks table</div>
  ];

  return (
    <Tabs count={count} env={env}>
      {tasks}
    </Tabs>
  );
};

export default HBWClaimingTaskList;
