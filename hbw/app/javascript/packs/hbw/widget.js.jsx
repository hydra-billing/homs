import React from 'react';
import ReactDOM from 'react-dom';
import { localizer } from './init/date_localizer';
import App from './components/app';
import AvailableTasksButton from './components/claiming/menu_button';
import AvailableTaskList from './components/claiming/task_list';
import Translator from './translator';
import Connection from './connection';

modulejs.define(
  'HBW',
  ['HBWContainer', 'HBWDispatcher', 'HBWForms', 'jQuery'],
  (Container, Dispatcher, HBWForms, jQuery) => {
    class HBW {
      constructor (options) {
        this.widget = null;

        this.options = options;

        const payload = { variables: {}, ...this.options.payload };

        const {
          widgetURL, widgetPath, widgetHost, userIdentifier
        } = this.options;

        const connection = new Connection({
          path: widgetPath,
          host: widgetHost,
          payload,
        });

        this.env = {
          connection,
          widgetURL,
          userIdentifier,
          dispatcher:       new Dispatcher(),
          translator:       Translator.getTranslatorForLocale(this.options.locale.code),
          localizer:        localizer(this.options.locale),
          forms:            new HBWForms(connection, this.options.entity_class),
          locale:           this.options.locale,
          userExist:        true,
          entity_class:     this.options.entity_class,
          entity_code:      this.options.entity_code,
          initialVariables: payload.variables,
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
        ReactDOM.render(
          <App env={this.env}
               Forms={this.Forms}
               Button={this.Button}
               TaskList={this.TaskList} />,
          document.createElement('div')
        );
      };

      renderWidget = async (container, taskId) => {
        await this.setBPTranslator();
        this.env.dispatcher.trigger('hbw:set-forms-container', 'widget', container);
        this.env.dispatcher.trigger('hbw:set-current-task', 'widget', taskId);
      };

      renderClaimingMenuButton = async (container) => {
        await this.setBPTranslator();
        this.env.dispatcher.trigger('hbw:set-button-container', 'widget', container);
      };

      renderClaimingTaskList = async (container) => {
        await this.setBPTranslator();
        this.env.dispatcher.trigger('hbw:set-task-list-container', 'widget', container);
      };

      unmountWidget = () => {
        this.env.dispatcher.trigger('hbw:set-forms-container', 'widget', null);
        this.env.dispatcher.trigger('hbw:set-current-task', 'widget', null);
      };

      checkBpmUser = async () => {
        const { user_exist: userExist } = await this.env.connection.request({
          url:    `${this.env.connection.serverURL}/users/check`,
          method: 'GET',
          async:  false
        }).then(data => data.json());

        if (!userExist) {
          this.env.dispatcher.trigger('hbw:bpm-user-not-found');
          this.env.userExist = false;
        }
      };

      fetchBPTranslations = async () => {
        const bpTranslations = await this.env.connection.request({
          url:    `${this.env.connection.serverURL}/translations`,
          method: 'GET'
        }).then(data => data.json());

        return Translator.getTranslatorForLocale(this.options.locale.code, bpTranslations);
      }

      setBPTranslator = async () => {
        this.env.bpTranslator ||= await this.fetchBPTranslations();
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
