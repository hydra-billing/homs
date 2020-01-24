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
      socket:   null,
      error:    null,
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
        tasks: this.orderTasks([...tasks, incomingTask])
      });

      return incomingTask;
    };

    onCreate = (taskId, cacheKey) => {
      this.getTaskById(taskId, cacheKey);
    };

    onAssignment = async (taskId, cacheKey) => {
      const { translator: t } = this.props.env;
      const { name, assignee } = await this.getTaskById(taskId, cacheKey);

      if (assignee !== null) {
        Application.messenger.notice(t('notifications.new_assigned_task', {
          task_name: name
        }));
      }
    };

    onComplete = (taskId) => {
      const tasks = this.state.tasks.filter(task => task.id !== taskId);
      this.setState({ tasks });
    };

    onReceive = ({ task_id: taskId, cache_key: cacheKey, event_name: eventName }) => {
      this.setState({ fetching: true });

      if (eventName === 'create') {
        this.onCreate(taskId, cacheKey);
      }

      if (eventName === 'assignment') {
        this.onAssignment(taskId, cacheKey);
      }

      if (['complete', 'delete'].includes(eventName)) {
        this.onComplete(taskId);
      }

      this.setState({ fetching: false });
    };

    initSocket = () => {
      const { host, protocol } = new URL(this.props.env.connection.serverURL);
      const socketUrl = protocol === 'https:'
        ? `wss://${host}/widget/cable`
        : `ws://${host}/widget/cable`;

      const ws = ActionCable.createConsumer(socketUrl);

      ws.subscriptions.create({ channel: 'TaskChannel' }, {
        received: (data) => {
          this.onReceive(JSON.parse(data));
        }
      });

      this.setState({ socket: ws });
    };

    initStore = async () => {
      const { env } = this.props;

      try {
        const { tasks } = await env.connection.request({
          url:  `${env.connection.serverURL}/tasks`,
          data: {
            entity_class: env.entity_class,
          },
        });

        this.setState({ tasks: this.orderTasks(tasks) });
      } catch (error) {
        this.setState({ error });
      } finally {
        this.setState({
          fetching: false,
          ready:    true
        });
      }
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
