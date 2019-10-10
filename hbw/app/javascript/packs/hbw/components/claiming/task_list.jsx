import React, { Component } from 'react';
import PropTypes from 'prop-types';
import withTaskListContext, { TaskListContext } from './shared/task_list_context';
import Tabs from './shared/task_tabs';
import Search from './search';
import Table from './table';

class HBWClaimingTaskList extends Component {
  static contextType = TaskListContext;

  static propTypes = {
    env: PropTypes.object.isRequired,
  };

  render () {
    const { env } = this.props;
    const {
      query, onSearch, reset, tasks, fetching, addPage, lastPage,
      tab, switchTabTo, myTasksCount, unassignedTasksCount,
    } = this.context;

    const count = {
      my:         myTasksCount,
      unassigned: unassignedTasksCount,
    };

    return (
      <>
        <Search env={env}
                query={query}
                fetching={fetching}
                onChange={onSearch}
                onClear={reset}
        />
        <Tabs env={env}
              count={count}
              tab={tab}
              onTabChange={switchTabTo}
        >
          <Table env={env}
                 tasks={tasks}
                 fetching={fetching}
                 addPage={addPage}
                 lastPage={lastPage}
                 url="http://#"
                 showClaimButton={true} />
        </Tabs>
      </>
    );
  }
}

export default withTaskListContext(HBWClaimingTaskList);
