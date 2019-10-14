import React, { Component } from 'react';
import PropTypes from 'prop-types';
import withTaskListContext, { TaskListContext } from './shared/task_list_context';
import Tabs from './shared/task_tabs';
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
      query, onSearch, reset, tasks, fetching, addPage, lastPage,
      tabs, tab, switchTabTo, myTasksCount, unassignedTasksCount,
      activeTask, openTask,
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
                    fetching={fetching}
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
            />
          </Tabs>
        </div>
        <div className="overview">
          {activeTask && (
            <Overview env={env}
                      entityUrl="http://"
                      assigned={tab === tabs.my}
                      task={activeTask}
            />
          )}
        </div>
      </div>
    );
  }
}

export default withTaskListContext(HBWClaimingTaskList);
