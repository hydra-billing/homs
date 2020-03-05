import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Messenger from 'messenger';
import { StoreContext } from 'shared/context/store';
import Tabs from 'shared/element/task_tabs';
import Search from './search';
import Table from './table';
import Overview from './task_overview';

class HBWClaimingTaskList extends Component {
  static contextType = StoreContext;

  static propTypes = {
    env: PropTypes.object.isRequired,
  };

  perPage = 50;

  tabs = {
    my:         0,
    unassigned: 1,
  };

  state = {
    tab:          this.tabs.my,
    page:         1,
    lastPage:     false,
    claimingTask: null,
    query:        '',
    searchQuery:  null,
    searching:    false,
  };

  addPage = () => {
    this.setState(prevState => ({
      page:     prevState.page + 1,
      lastPage: this.tasksForCurrentTab().length <= (prevState.page + 1) * this.perPage,
    }));
  };

  claim = async (task) => {
    const { connection, translator: t } = this.props.env;
    const { closeTask } = this.context;

    this.setState({ claimingTask: task });

    const { ok } = await connection.request({
      url:    `${connection.serverURL}/tasks/${task.id}/claim`,
      method: 'POST'
    });

    if (!ok) {
      Messenger.error(t('errors.task_already_claimed', {
        task_name: task.name
      }));
    }

    closeTask(task.id);

    this.setState({ claimingTask: null });
  };

  onSearch = ({ target }) => {
    const { value: query } = target;

    this.setState({ query });

    if (query.length > 2) {
      this.setState({ searchQuery: query.trim() });
    } else {
      this.setState({ searchQuery: null });
    }
  };

  clearSearch = () => {
    this.setState({ query: '', searchQuery: null });
  };

  switchTabTo = (tab) => {
    const { closeTask } = this.context;

    if (tab !== this.state.tab) {
      this.setState({ tab });
      closeTask();
      this.clearSearch();
    }
  };

  isMyTab = () => this.state.tab === this.tabs.my;

  tasksForCurrentTab = () => {
    const { myTasks, unassignedTasks } = this.context;

    return this.isMyTab() ? myTasks : unassignedTasks;
  };

  filterTasks = () => this.tasksForCurrentTab().filter(({ description }) => (
    description && description.toLowerCase().includes(this.state.searchQuery.toLowerCase())
  ));

  tasksForRender = () => {
    const filteredTasks = this.state.searchQuery
      ? this.filterTasks()
      : this.tasksForCurrentTab();

    return filteredTasks.slice(0, this.perPage * this.state.page);
  };

  render () {
    const { env } = this.props;
    const {
      fetching, count, openTask, activeTask
    } = this.context;
    const {
      tab, lastPage, claimingTask, query, searching
    } = this.state;

    return (
      <div id="hbw-claiming-tasks">
        <div className="table">
          <div className="title-row">
            <div className="title">
              {env.translator('components.claiming.open_tasks')}
            </div>
             <Search env={env}
                     query={query}
                     searching={searching}
                     search={this.onSearch}
                     clear={this.clearSearch}
             />
          </div>
          <Tabs env={env}
                count={count}
                tabs={this.tabs}
                activeTab={tab}
                onTabChange={this.switchTabTo}
          >
            <Table env={env}
                   tasks={this.tasksForRender()}
                   fetching={fetching}
                   addPage={this.addPage}
                   openTask={openTask}
                   lastPage={lastPage}
                   showClaimButton={!this.isMyTab()}
                   claimingTask={claimingTask}
                   claim={this.claim}
                   activeTask={activeTask}
            />
          </Tabs>
        </div>
         <div className="overview">
          {activeTask && (
            <Overview env={env}
                      entityUrl={activeTask.entity_url}
                      assigned={this.isMyTab()}
                      task={activeTask}
                      claim={this.claim}
            />
          )}
         </div>
      </div>
    );
  }
}

export default HBWClaimingTaskList;
