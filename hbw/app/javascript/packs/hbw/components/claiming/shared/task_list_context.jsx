import React, { Component, createContext } from 'react';
import PropTypes from 'prop-types';
import { debounce } from 'lodash-es';
import { withTasksCount, withClaimingTasks } from '../../helpers';

export const TaskListContext = createContext({});
export const TaskListConsumer = TaskListContext.Consumer;

const withTaskListContext = (WrappedComponent) => {
  class TaskListProvider extends Component {
    static propTypes = {
      claimingTasks: PropTypes.shape({
        subscription:       PropTypes.object.isRequired,
        updateSubscription: PropTypes.func.isRequired,
        claimAndPollTasks:  PropTypes.func.isRequired,
      }).isRequired,
      taskCount: PropTypes.shape({
        subscription: PropTypes.object.isRequired,
      }).isRequired,
      perPage: PropTypes.number.isRequired,
    };

    tabs = {
      my:         0,
      unassigned: 1,
    };

    stateForReset = {
      tasks:        [],
      query:        '',
      searchQuery:  '',
      activeTask:   null,
      claimingTask: null,
      page:         1,
      lastPage:     false,
      fetched:      false,
      fetching:     false,
    };

    state = {
      ...this.stateForReset,
      myTasksCount:         0, // should be filled by separate subscription
      unassignedTasksCount: 0, // and passed to tabs component
      tab:                  this.tabs.my,
    };

    componentDidMount () {
      const { taskCount, claimingTasks, perPage } = this.props;

      claimingTasks.subscription.progress(({ tasks }) => this.setState(prevState => ({
        tasks,
        lastPage: tasks.length < prevState.page * perPage,
        fetching: false,
      })));

      taskCount.subscription.progress(({ task_count: myTasksCount, task_count_unassigned: unassignedTasksCount }) => {
        this.setState({ myTasksCount, unassignedTasksCount, fetched: true });
      });
    }

    updateSubscription = () => {
      const { page, searchQuery, tab } = this.state;

      this.props.claimingTasks.updateSubscription({
        assigned: tab === this.tabs.my,
        page,
        searchQuery,
      });
    };

    updateContext = (...state) => {
      this.setState(...state, this.updateSubscription);
    };

    resetContext = () => {
      this.setState(this.stateForReset, this.updateSubscription);
    };

    search = () => {
      this.setState({ fetching: true });

      return debounce(this.updateSubscription, 350);
    };

    onSearch = ({ target }) => {
      const { value: query } = target;
      const searchQuery = query.trim();

      if (this.state.searchQuery.length < 3 && searchQuery.length < 3) {
        this.setState({ query });
      } else {
        this.setState({
          searchQuery: searchQuery.length > 2 ? searchQuery : '',
          query,
        }, this.search());
      }
    };

    addPage = () => {
      this.setState(
        prevState => ({ page: prevState.page + 1 }),
        this.updateSubscription
      );
    };

    switchTabTo = (tab) => {
      if (tab !== this.state.tab) {
        this.setState(
          { ...this.stateForReset, tab },
          this.updateSubscription
        );
      }
    };

    openTask = (index) => {
      this.setState(prevState => ({ activeTask: prevState.tasks[index] }));
    };

    closeTask = () => {
      this.setState({ activeTask: null });
    };

    claimAndPollTasks = async (task) => {
      const { activeTask } = this.state;
      const { claimAndPollTasks } = this.props.claimingTasks;

      this.setState({ claimingTask: task });

      await claimAndPollTasks(task);

      if (activeTask && task.id === activeTask.id) {
        this.closeTask();
      }

      this.setState({ claimingTask: null });
    }

    render () {
      const contextValue = {
        ...this.state,
        tabs:              this.tabs,
        fetching:          this.state.fetching,
        update:            this.updateContext,
        reset:             this.resetContext,
        onSearch:          this.onSearch,
        addPage:           this.addPage,
        switchTabTo:       this.switchTabTo,
        openTask:          this.openTask,
        claimAndPollTasks: this.claimAndPollTasks,
        closeTask:         this.closeTask,
      };

      return (
        <TaskListContext.Provider value={contextValue}>
          <WrappedComponent {...this.props} />
        </TaskListContext.Provider>
      );
    }
  }

  return withTasksCount(withClaimingTasks(TaskListProvider));
};

export default withTaskListContext;
