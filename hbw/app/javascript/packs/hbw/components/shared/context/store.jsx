/* eslint-disable no-await-in-loop */
/* eslint-disable no-restricted-syntax */

import React, {
  Component, createContext, useContext, useEffect
} from 'react';
import ActionCable from 'actioncable';
import orderBy from 'lodash/orderBy';
import partition from 'lodash/partition';
import Messenger from 'messenger';
import { parseISO } from 'date-fns';
import TranslationContext from 'shared/context/translation';
import DispatcherContext from 'shared/context/dispatcher';
import { CamundaError } from '../utils/errors';
import ErrorHandlingContext from './error_handling';

const StoreContext = createContext({});

const NewTaskNotifier = () => {
  const { translate: t } = useContext(TranslationContext);
  const { bind, unbind } = useContext(DispatcherContext);

  useEffect(() => {
    bind('hbw:notify-new-task', 'widget', (taskName) => {
      Messenger.notice(t('notifications.new_assigned_task', {
        task_name: taskName
      }));
    });

    return () => {
      unbind('hbw:notify-new-task', 'widget');
    };
  });

  return <></>;
};

export const withStoreContext = ({
  widgetURL, userIdentifier, showNotifications, entityClassCode, dispatcher, connection
}) => (WrappedComponent) => {
  class StoreProvider extends Component {
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
      const result = await connection.request({
        url:    `${connection.serverURL}/tasks/${taskId}`,
        method: 'GET',
        data:   {
          cache_key:    cacheKey,
          entity_class: entityClassCode,
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
      if (showNotifications) {
        dispatcher.trigger('hbw:notify-new-task', 'widget', taskName);
      }
    }

    fetchTask = async (taskId, cacheKey, assignedToMe, version) => {
      const task = await this.getTaskById(taskId, cacheKey);

      if (this.vesionIsOutdated(taskId, version)) {
        return;
      }

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
      if (this.vesionIsOutdated(taskId, version)) {
        return;
      }

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
      const emptyFormEntityTasks = entityTasks.filter(
        task => (task.form === undefined)
      );

      return Object.entries(emptyFormEntityTasks).map(([, task]) => ({
        task_id: task.id, entity_class: entityClassCode
      }));
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
      try {
        const result = await connection.request({
          url:    `${connection.serverURL}/tasks`,
          method: 'GET',
          data:   {
            entity_class: entityClassCode,
          },
        });

        if (result.status === 504) {
          this.context.addError(CamundaError);
          this.setState({ error: this.context.formError });
        }

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
        my:         this.state.error ? '-' : myTasks.length,
        unassigned: this.state.error ? '-' : unassignedTasks.length,
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
          <NewTaskNotifier />
          <WrappedComponent {...this.props} />
        </StoreContext.Provider>
      );
    }
  }

  StoreProvider.contextType = ErrorHandlingContext;

  return StoreProvider;
};

export default StoreContext;
