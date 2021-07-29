import React from 'react';
import ReactDOM from 'react-dom';
import { withStoreContext } from 'shared/context/store';
import { withTranslationContext } from 'shared/context/translation';
import { withConnectionContext } from 'shared/context/connection';
import { withDispatcherContext } from 'shared/context/dispatcher';
import { withErrorHandlingContext } from 'shared/context/error_handling';
import compose from 'shared/utils/compose';
import App from './components/app';
import AvailableTasksButton from './components/claiming/menu_button';
import AvailableTaskList from './components/claiming/task_list';
import Dispatcher from './dispatcher';
import Connection from './connection';

modulejs.define(
  'HBW',
  ['HBWContainer', 'jQuery'],
  (Container, jQuery) => {
    class HBW {
      constructor (options) {
        this.options = options;

        this.payload = { variables: {}, ...this.options.payload };

        this.dispatcher = new Dispatcher();
        this.connection = new Connection({
          host:    this.options.widgetHost,
          path:    this.options.widgetPath,
          payload: this.payload
        });

        this.$widgetContainer = jQuery(this.options.widgetContainer);

        this.availableTasksButtonContainer = document.querySelector(this.options.availableTasksButtonContainer);
        this.availableTaskListContainer = document.querySelector(this.options.availableTaskListContainer);

        this.dispatcher.bind('hbw:task-clicked', 'widget', this.changeTask);

        this.renderApp();
      }

      Forms = ({ taskId }) => <Container entityCode={this.options.entity_code}
                                         entityTypeCode={this.options.entity_type}
                                         entityClassCode={this.options.entity_class}
                                         autorunProcessKey={this.options.autorunProcessKey}
                                         initialVariables={this.payload.variables}
                                         chosenTaskID={taskId} />;

      Button = () => <AvailableTasksButton taskListPath={this.options.taskListPath} />;

      TaskList = () => <AvailableTaskList />;

      changeTask = (task) => {
        if (task.entity_code === this.options.entity_code) {
          this.dispatcher.trigger('hbw:set-current-task', 'widget', task.id);
        } else {
          this.dispatcher.trigger('hbw:go-to-entity', 'widget', {
            code: task.entity_code,
            task
          });
        }
      };

      render = () => {
        this.renderPortals();
      }

      renderPortals = async () => {
        const formsContainer = this.options.entity_code ? this.$widgetContainer[0] : null;
        const taskId = this.options.entity_code ? this.options.task_id : null;

        await this.renderClaimingMenuButton(this.availableTasksButtonContainer);
        await this.renderClaimingTaskList(this.availableTaskListContainer);
        await this.renderWidget(formsContainer, taskId);
      };

      renderApp = () => {
        const {
          widgetURL,
          userIdentifier,
          showNotification,
          locale,
          entity_class: entityClassCode
        } = this.options;

        const withContext = compose(
          withDispatcherContext({ dispatcher: this.dispatcher }),
          withConnectionContext({ connection: this.connection }),
          withTranslationContext({ locale }),
          withErrorHandlingContext(),
          withStoreContext({
            widgetURL,
            userIdentifier,
            showNotification,
            entityClassCode,
            dispatcher: this.dispatcher,
            connection: this.connection
          })
        );

        const AppWithContext = withContext(App);

        ReactDOM.render(
          <AppWithContext Forms={this.Forms}
                          Button={this.Button}
                          TaskList={this.TaskList} />,
          document.createElement('div')
        );
      };

      renderWidget = async (container, taskId) => {
        this.dispatcher.trigger('hbw:set-forms-container', 'widget', container);
        this.dispatcher.trigger('hbw:set-current-task', 'widget', taskId);
      };

      renderClaimingMenuButton = async (container) => {
        this.dispatcher.trigger('hbw:set-button-container', 'widget', container);
      };

      renderClaimingTaskList = async (container) => {
        this.dispatcher.trigger('hbw:set-task-list-container', 'widget', container);
      };

      unmountWidget = () => {
        this.dispatcher.trigger('hbw:set-forms-container', 'widget', null);
        this.dispatcher.trigger('hbw:set-current-task', 'widget', null);
      };

      setEntityCode = (code) => {
        this.options.entity_code = code;
      };

      setEntityType = (type) => {
        this.options.entity_type = type;
      };

      setWidgetContainer = (container) => {
        this.$widgetContainer = [container];
      }
    }

    return HBW;
  }
);
