/* eslint-disable no-await-in-loop */
/* eslint-disable no-restricted-syntax */

import React, { Component, createContext } from 'react';
import PropTypes from 'prop-types';
import ActionCable from 'actioncable';
import orderBy from 'lodash/orderBy';
import partition from 'lodash/partition';
import Messenger from 'messenger';
import { parseISO } from 'date-fns';

export const StoreContext = createContext({});
export const { Consumer: StoreConsumer } = StoreContext;

const withStoreContext = (WrappedComponent) => {
  class StoreProvider extends Component {
    static propTypes = {
      env: PropTypes.shape({
        connection: PropTypes.shape({
          request:   PropTypes.func.isRequired,
          serverURL: PropTypes.string.isRequired,
        }).isRequired,
        widgetURL:         PropTypes.string.isRequired,
        translator:        PropTypes.func.isRequired,
        userIdentifier:    PropTypes.string.isRequired,
        entity_class:      PropTypes.string.isRequired,
        showNotifications: PropTypes.bool
      }).isRequired,
    };

    state = {
      tasks:      [],
      events:     [],
      versions:   {},
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

      const result = await env.connection.request({
        url:    `${env.connection.serverURL}/tasks/${taskId}`,
        method: 'GET',
        data:   {
          cache_key:    cacheKey,
          entity_class: env.entity_class,
        },
      });

      const incomingTask = await result.json();

      return incomingTask;
    };

    persistTask = async (task, version) => {
      this.setState(prevState => ({
        tasks: this.orderTasks([
          ...prevState.tasks.filter(({ id }) => id !== task.id),
          task,
        ]),
        versions: {
          ...prevState.versions,
          [task.id]: version
        }
      }));
    };

    setTaskVersion = (taskId, version) => {
      this.setState(prevState => ({
        versions: {
          ...prevState.versions,
          [taskId]: version
        }
      }));
    };

    removeTaskFromList = async (taskId) => {
      this.setState(
        prevState => ({
          tasks: prevState.tasks.filter(({ id }) => id !== taskId)
        }),
        () => this.closeTaskOverview(taskId)
      );
    };

    vesionIsOutdated = (taskId, version) => {
      const currentVersion = this.state.versions[taskId];

      return currentVersion && currentVersion > version;
    };

    showNotificaton = (taskName) => {
      const { translator: t, showNotifications } = this.props.env;

      if (showNotifications) {
        Messenger.notice(t('notifications.new_assigned_task', {
          task_name: taskName
        }));
      }
    }

    fetchTask = async (taskId, cacheKey, assignedToMe, version) => {
      const task = await this.getTaskById(taskId, cacheKey);

      if (this.vesionIsOutdated(taskId, version)) return;

      if (task.assignee === null) {
        await this.persistTask(task, version);
      } else if (assignedToMe) {
        await this.persistTask(task, version);
        this.showNotificaton(task.name);
      }
    };

    onReceive = async ({
      task_id: taskId,
      cache_key: cacheKey,
      event_name: eventName,
      assigned_to_me: assignedToMe,
      version
    }) => {
      if (this.vesionIsOutdated(taskId, version)) return;

      this.setState(
        { fetching: true },
        () => this.setTaskVersion(taskId, version)
      );

      if (['create', 'assignment'].includes(eventName)) {
        await this.fetchTask(taskId, cacheKey, assignedToMe, version);
      }

      if (['complete', 'delete'].includes(eventName)) {
        await this.removeTaskFromList(taskId);
      }

      this.setState({ fetching: false });
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
        received: async (data) => {
          const callback = async () => {
            await this.onReceive(JSON.parse(data));
          };

          if (this.state.ready) {
            await callback();
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
