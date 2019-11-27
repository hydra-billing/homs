/* eslint react/no-render-return-value: "off" */

import { localizer } from './init/date_localizer';
import AvailableTasksButton from './components/claiming/menu_button';
import AvailableTaskList from './components/claiming/task_list';
import Translator from './translator';

modulejs.define(
  'HBW',
  ['React', 'ReactDOM', 'HBWContainer', 'HBWConnection',
    'HBWDispatcher', 'HBWForms', 'jQuery'],
  (React, ReactDOM, Container, Connection, Dispatcher, Forms, jQuery) => {
    class HBW {
      constructor (options) {
        this.changeTask = this.changeTask.bind(this);
        this.render = this.render.bind(this);
        this.renderWidget = this.renderWidget.bind(this);
        this.checkBpmUser = this.checkBpmUser.bind(this);

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
          forms:            new Forms(connection, this.options.entity_class),
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
        this.checkBpmUser();
      }

      changeTask (task) {
        if (task.entity_code === this.options.entity_code) {
          this.widget = this.renderWidget(this.$widgetContainer[0], task.id);
        } else {
          this.env.dispatcher.trigger('hbw:go-to-entity', 'widget', {
            code: task.entity_code,
            task
          });
        }
      }

      render () {
        if (this.options.entity_code) {
          this.widget = this.renderWidget(this.$widgetContainer[0], this.options.task_id);
        } else {
          this.widget = null;
        }

        if (this.availableTasksButtonContainer) {
          this.renderClaimingMenuButton(this.availableTasksButtonContainer);
        }

        if (this.availableTaskListContainer) {
          this.renderClaimingTaskList(this.availableTaskListContainer);
        }
      }

      renderWidget (container, taskId) {
        return ReactDOM.render(
          <Container entityCode={this.options.entity_code}
            entityTypeCode={this.options.entity_type}
            entityClassCode={this.options.entity_class}
            chosenTaskID={taskId}
            env={this.env} />,
          container
        );
      }

      renderClaimingMenuButton (container) {
        return ReactDOM.render(
          <AvailableTasksButton env={this.env} />,
          container
        );
      }

      renderClaimingTaskList (container) {
        return ReactDOM.render(
          <AvailableTaskList env={this.env} perPage={50} />,
          container
        );
      }

      unmountWidget () {
        this.env.connection.unsubscribe();
        ReactDOM.unmountComponentAtNode(this.$widgetContainer[0]);
      }

      checkBpmUser () {
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
      }

      setEntityCode = (code) => {
        this.options.entity_code = code;
        this.env.entity_code = code;
      }

      setEntityType = (type) => {
        this.options.entity_type = type;
        this.env.entity_type = type;
      }

      setWidgetContainer = (container) => {
        this.$widgetContainer = [container];
      }
    }

    return HBW;
  }
);
