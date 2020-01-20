/* eslint-disable no-console */
import React, { Component, createContext } from 'react';
import ActionCable from 'actioncable';
import orderBy from 'lodash-es/orderBy';
import partition from 'lodash-es/partition';
import { parseISO } from 'date-fns';

export const StoreContext = createContext({});
export const { Consumer: StoreConsumer } = StoreContext;

const withStoreContext = (WrappedComponent) => {
  class StoreProvider extends Component {
    state = {
      tasks:    [],
      fetching: true,
      ready:    false,
      socket:   null
    };

    componentDidMount () {
      this.initSocket();
      this.initStore();
    }

    getTaskById = async (taskId, cacheKey) => {
      const { env } = this.props;
      const incomingTask = await env.connection.request({
        url:  `${env.connection.serverURL}/tasks/${taskId}`,
        data: {
          cache_key:    cacheKey,
          entity_class: env.entity_class,
        },
      });

      const tasks = this.state.tasks.filter(task => task.id !== incomingTask.id);
      this.setState({
        tasks: (this.orderTasks([...tasks, incomingTask]))
      });

      return incomingTask;
    };

    onCreated = (taskId, cacheKey) => {
      this.getTaskById(taskId, cacheKey);
    };

    onAssigned = async (taskId, cacheKey) => {
      const { translator: t } = this.props.env;
      const { name } = await this.getTaskById(taskId, cacheKey);

      Application.messenger.notice(t('notifications.new_assigned_task', {
        task_name: name
      }));
    };

    onComplete = (taskId) => {
      const tasks = this.state.tasks.filter(task => task.id !== taskId);
      this.setState({ tasks });
    };

    onReceived = (data) => {
      const { task_id: taskId, cache_key: cacheKey } = data;

      if (data.event_name === 'create') {
        this.onCreated(taskId, cacheKey);
      }

      if (data.event_name === 'assignment') {
        this.onAssigned(taskId, cacheKey);
      }

      if (['complete', 'delete'].includes(data.event_name)) {
        this.onComplete(taskId);
      }
    };

    initSocket = () => {
      const ws = ActionCable.createConsumer('ws://127.0.0.1:3000/widget/cable');
      ws.subscriptions.create({ channel: 'TaskChannel' }, {
        connected: () => {
          console.log('Connected!');
        },
        received: (data) => {
          this.onReceived(JSON.parse(data));
        }
      });

      this.setState({ socket: ws });
    };

    initStore = async () => {
      const { env } = this.props;

      const { tasks } = await env.connection.request({
        url:  `${env.connection.serverURL}/tasks/list`,
        data: {
          entity_class: env.entity_class,
        },
      });

      this.setState({
        tasks:    (this.orderTasks(tasks)),
        fetching: false,
        ready:    true
      });
    };

    orderTasks = tasks => orderBy(
      tasks,
      [
        ({ due }) => (due ? parseISO(due) : null),
        'priority',
        'process_name',
        ({ created }) => (created ? parseISO(created) : null)
      ],
      ['asc', 'desc', 'asc', 'asc']
    );

    updateContext = (...state) => {
      this.setState(...state);
    };

    render () {
      const [unassignedTasks, myTasks] = partition(this.state.tasks, { assignee: null });
      const count = {
        my:         myTasks.length,
        unassigned: unassignedTasks.length,
      };

      const contextValue = {
        ...this.state,
        myTasks,
        unassignedTasks,
        count,
        update: this.updateContext,
      };

      return (
        <StoreContext.Provider value={contextValue}>
          <WrappedComponent {...this.props} />
        </StoreContext.Provider>
      );
    }
  }

  return StoreProvider;
};

export default withStoreContext;
