/* eslint react/no-render-return-value: "off" */

import React from 'react';
import ReactDOM from 'react-dom';
import { localizer } from './init/date_localizer';
import App from './components/app';
import AvailableTasksButton from './components/claiming/menu_button';
import AvailableTaskList from './components/claiming/task_list';
import Translator from './translator';

modulejs.define(
  'HBW',
  ['HBWContainer', 'HBWConnection',
    'HBWDispatcher', 'HBWForms', 'jQuery'],
  (Container, Connection, Dispatcher, HBWForms, jQuery) => {
    class HBW {
      constructor (options) {
        this.widget = null;

        this.options = options;

        const payload = { variables: {}, ...this.options.payload };

        const connection = new Connection({
          path: this.options.widgetPath,
          host: this.options.widgetHost,
          payload
        });

        this.env = {
          connection,
          dispatcher:       new Dispatcher(),
          translator:       Translator.getTranslatorForLocale(this.options.locale.code),
          localizer:        localizer(this.options.locale),
          forms:            new HBWForms(connection, this.options.entity_class),
          locale:           this.options.locale,
          userExist:        true,
          entity_class:     this.options.entity_class,
          entity_code:      this.options.entity_code,
          initialVariables: payload.variables,
          poll_interval:    this.options.poll_interval,
          taskListPath:     this.options.taskListPath,
        };

        this.$widgetContainer = jQuery(this.options.widgetContainer);

        this.availableTasksButtonContainer = document.querySelector(this.options.availableTasksButtonContainer);
        this.availableTaskListContainer = document.querySelector(this.options.availableTaskListContainer);

        this.env.dispatcher.bind('hbw:task-clicked', 'widget', this.changeTask);

        this.renderApp();
        this.checkBpmUser();
      }

      Forms = ({ taskId }) => <Container entityCode={this.options.entity_code}
                                         entityTypeCode={this.options.entity_type}
                                         entityClassCode={this.options.entity_class}
                                         chosenTaskID={taskId}
                                         env={this.env} />;

      Button = () => <AvailableTasksButton env={this.env} />;

      TaskList = () => <AvailableTaskList env={this.env} />;

      changeTask = (task) => {
        if (task.entity_code === this.options.entity_code) {
          this.env.dispatcher.trigger('hbw:set-current-task', 'widget', task.id);
        } else {
          this.env.dispatcher.trigger('hbw:go-to-entity', 'widget', {
            code: task.entity_code,
            task
          });
        }
      };

      render = () => {
        const formsContainer = this.options.entity_code ? this.$widgetContainer[0] : null;
        const taskId = this.options.entity_code ? this.options.task_id : null;

        this.renderClaimingMenuButton(this.availableTasksButtonContainer);
        this.renderClaimingTaskList(this.availableTaskListContainer);
        this.renderWidget(formsContainer, taskId);
      };

      renderApp = () => {
        ReactDOM.render(
          <App env={this.env}
               Forms={this.Forms}
               Button={this.Button}
               TaskList={this.TaskList} />,
          document.createElement('div')
        );
      };

      renderWidget = (container, taskId) => {
        this.env.dispatcher.trigger('hbw:set-forms-container', 'widget', container);
        this.env.dispatcher.trigger('hbw:set-current-task', 'widget', taskId);
      };

      renderClaimingMenuButton = (container) => {
        this.env.dispatcher.trigger('hbw:set-button-container', 'widget', container);
      };

      renderClaimingTaskList = (container) => {
        this.env.dispatcher.trigger('hbw:set-task-list-container', 'widget', container);
      };

      unmountWidget = () => {
        this.env.connection.unsubscribe();
        this.env.dispatcher.trigger('hbw:set-forms-container', 'widget', null);
        this.env.dispatcher.trigger('hbw:set-current-task', 'widget', null);
      };

      checkBpmUser = () => {
        this.env.connection.request({
          url:    `${this.env.connection.serverURL}/users/check`,
          method: 'GET',
          async:  false
        }).done((data) => {
          if (!data.user_exist) {
            this.env.dispatcher.trigger('hbw:bpm-user-not-found');
            this.env.userExist = false;
          }
        });
      };

      setEntityCode = (code) => {
        this.options.entity_code = code;
        this.env.entity_code = code;
      };

      setEntityType = (type) => {
        this.options.entity_type = type;
        this.env.entity_type = type;
      };

      setWidgetContainer = (container) => {
        this.$widgetContainer = [container];
      }
    }

    return HBW;
  }
);
