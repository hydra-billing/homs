import React, { Component } from 'react';
import PropTypes from 'prop-types';
import withTaskListContext, { TaskListContext } from 'shared/context/task_list_context';
import Tabs from 'shared/element/task_tabs';
import Search from './search';
import Table from './table';
import Overview from './task_overview';

class HBWClaimingTaskList extends Component {
  static contextType = TaskListContext;

  static propTypes = {
    env: PropTypes.object.isRequired,
  };

  render () {
    const { env } = this.props;
    const {
      query, onSearch, reset, tasks, searching, addPage, lastPage,
      tabs, tab, switchTabTo, myTasksCount, unassignedTasksCount,
      activeTask, openTask, claimingTask, claimAndPollTasks, closeTask, fetching
    } = this.context;

    const count = {
      my:         myTasksCount,
      unassigned: unassignedTasksCount,
    };

    return (
      <div id="hbw-claiming-tasks">
        <div className="table">
          <div className="title-row">
            <div className="title">
              {env.translator('components.claiming.open_tasks')}
            </div>
            <Search env={env}
                    query={query}
                    fetching={searching}
                    onChange={onSearch}
                    onClear={reset}
            />
          </div>
          <Tabs env={env}
                count={count}
                tabs={tabs}
                activeTab={tab}
                onTabChange={switchTabTo}
          >
            <Table env={env}
                   tasks={tasks}
                   fetching={fetching}
                   addPage={addPage}
                   openTask={openTask}
                   lastPage={lastPage}
                   showClaimButton={tab === tabs.unassigned}
                   claimingTask={claimingTask}
                   claimAndPollTasks={claimAndPollTasks}
                   activeTask={activeTask}
            />
          </Tabs>
        </div>
        <div className="overview">
          {activeTask && (
            <Overview env={env}
                      entityUrl={activeTask.entity_url}
                      assigned={tab === tabs.my}
                      task={activeTask}
                      claimAndPollTasks={claimAndPollTasks}
                      closeTask={closeTask}
            />
          )}
        </div>
      </div>
    );
  }
}

export default withTaskListContext(HBWClaimingTaskList);
