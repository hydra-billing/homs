/* eslint-disable no-await-in-loop */
/* eslint-disable no-restricted-syntax */

import React, { Component, createContext } from 'react';
import ActionCable from 'actioncable';
import orderBy from 'lodash-es/orderBy';
import partition from 'lodash-es/partition';
import Messenger from 'messenger';
import { parseISO } from 'date-fns';

export const StoreContext = createContext({});
export const { Consumer: StoreConsumer } = StoreContext;

const withStoreContext = (WrappedComponent) => {
  class StoreProvider extends Component {
    state = {
      tasks:      [],
      events:     [],
      fetching:   true,
      ready:      false,
      socket:     null,
      error:      null,
      activeTask: null,
    };

    componentDidMount () {
      this.initSocket();
      this.initStore();
    }

    getTaskById = async (taskId, cacheKey = null) => {
      const { env } = this.props;

      const incomingTask = await env.connection.request({
        url:    `${env.connection.serverURL}/tasks/${taskId}`,
        method: 'GET',
        data:   {
          cache_key:    cacheKey,
          entity_class: env.entity_class,
        },
      }).then(response => response.json());

      const tasks = this.state.tasks.filter(task => task.id !== incomingTask.id);

      this.setState({
        tasks: this.orderTasks([...tasks, incomingTask])
      });

      return incomingTask;
    };

    onCreate = async (taskId, cacheKey) => {
      await this.getTaskById(taskId, cacheKey);
    };

    onAssignment = async (taskId, cacheKey, assignedToMe) => {
      const { translator: t } = this.props.env;
      const { name, assignee } = await this.getTaskById(taskId, cacheKey);

      if (assignee !== null) {
        if (assignedToMe) {
          Messenger.notice(t('notifications.new_assigned_task', {
            task_name: name
          }));
        } else {
          this.removeTaskFromList(taskId);
        }
      }
    };

    mergeFormsToTasks = (prevTasks, fetchedForms) => {
      const tasks = prevTasks;
      const forms = fetchedForms;

      Object.entries(tasks).forEach(([, value]) => {
        const fetchedForm = forms.find(form => form.task_id === value.id);

        if (fetchedForm !== undefined) {
          value.form = fetchedForm;
        }
      });

      return tasks;
    };

    getFormsForTasks = async (tasks) => {
      const emptyFormTasks = this.getEmptyFormEntityTasks(tasks);
      const { connection } = this.props.env;

      if (emptyFormTasks.length > 0) {
        const { forms } = await connection.request({
          url:    `${connection.serverURL}/tasks/forms`,
          method: 'GET',
          data:   {
            entity_tasks: JSON.stringify(emptyFormTasks)
          }
        }).then(data => data.json());

        this.addFormsToTasks(forms);
      }
    };

    getEmptyFormEntityTasks = (entityTasks) => {
      const entityClass = this.props.env.entity_class;

      const emptyFormEntityTasks = entityTasks.filter(
        task => (task.form === undefined)
      );

      return Object.entries(emptyFormEntityTasks).map(([, task]) => ({ task_id: task.id, entity_class: entityClass }));
    };

    addFormsToTasks = (fetchedForms) => {
      this.setState(prevState => ({
        tasks: this.mergeFormsToTasks(prevState.tasks, fetchedForms)
      }));
    };

    onComplete = async (taskId) => {
      this.removeTaskFromList(taskId);
    };

    onReceive = async ({
      task_id: taskId, cache_key: cacheKey, event_name: eventName, assigned_to_me: assignedToMe
    }) => {
      this.setState({ fetching: true });

      if (eventName === 'create') {
        await this.onCreate(taskId, cacheKey);
      }

      if (eventName === 'assignment') {
        await this.onAssignment(taskId, cacheKey, assignedToMe);
      }

      if (['complete', 'delete'].includes(eventName)) {
        await this.onComplete(taskId);
      }

      this.setState({ fetching: false });
    };

    defer = (callback) => {
      this.setState(prevState => ({ events: [...prevState.events, callback] }));
    };

    executeDeferred = async () => {
      const { events } = this.state;

      for (const e of events) {
        await e();
      }

      this.setState({ events: [] });
    };

    initSocket = () => {
      const { userIdentifier, widgetURL } = this.props.env;
      const { host, protocol } = new URL(widgetURL);

      const socketUrl = protocol === 'https:'
        ? `wss://${host}/widget/cable`
        : `ws://${host}/widget/cable`;

      const ws = ActionCable.createConsumer(socketUrl);

      ws.subscriptions.create({ channel: 'TaskChannel', user_identifier: userIdentifier }, {
        received: (data) => {
          const callback = async () => {
            await this.onReceive(JSON.parse(data));
          };

          if (this.state.ready) {
            callback();
          } else {
            this.defer(callback);
          }
        }
      });

      this.setState({ socket: ws });
    };

    initStore = async () => {
      const { env } = this.props;
      try {
        const result = await env.connection.request({
          url:    `${env.connection.serverURL}/tasks`,
          method: 'GET',
          data:   {
            entity_class: env.entity_class,
          },
        });

        const { tasks } = await result.json();

        this.setState({ tasks: this.orderTasks(tasks) });
      } catch (error) {
        this.setState({ error });
      } finally {
        this.setState({
          fetching: false,
          ready:    true
        }, this.executeDeferred);
      }
    };

    removeTaskFromList = async (taskId) => {
      const tasks = this.state.tasks.filter(task => task.id !== taskId);
      this.setState({ tasks });

      this.closeTaskOverview(taskId);
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

    openTaskOverview = (task) => {
      const { activeTask } = this.state;

      if (!activeTask || task.id !== activeTask.id) {
        this.setState({ activeTask: task });
      }
    };

    closeTaskOverview = (taskId) => {
      const { activeTask } = this.state;

      if ((activeTask && taskId === activeTask.id) || !taskId) {
        this.setState({ activeTask: null });
      }
    };

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
        update:           this.updateContext,
        openTask:         this.openTaskOverview,
        closeTask:        this.closeTaskOverview,
        getFormsForTasks: this.getFormsForTasks
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
