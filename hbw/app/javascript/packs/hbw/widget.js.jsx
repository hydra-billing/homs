/* eslint react/no-render-return-value: "off" */

modulejs.define(
  'HBW',
  ['React', 'ReactDOM', 'HBWTaskList', 'HBWMenu', 'HBWMenuButton', 'HBWContainer', 'HBWConnection',
    'HBWDispatcher', 'HBWForms', 'HBWTranslator', 'jQuery'],
  (React, ReactDOM, TaskList, Menu, MenuButton, Container, Connection, Dispatcher, Forms, Translator, jQuery) => {
    class HBW {
      constructor (options) {
        this.changeTask = this.changeTask.bind(this);
        this.render = this.render.bind(this);
        this.renderWidget = this.renderWidget.bind(this);
        this.renderTasksMenu = this.renderTasksMenu.bind(this);
        this.renderTasksMenuButton = this.renderTasksMenuButton.bind(this);
        this.subscribeOnTasks = this.subscribeOnTasks.bind(this);
        this.checkBpmUser = this.checkBpmUser.bind(this);

        this.widget = null;
        this.tasksMenu = null;

        this.options = options;
        const connection = new Connection({
          path: this.options.widgetPath,
          host: this.options.widgetHost
        });

        this.env = {
          connection,
          dispatcher:   new Dispatcher(),
          translator:   Translator,
          forms:        new Forms(connection, this.options.entity_class),
          locale:       this.options.locale,
          userExist:    true,
          entity_class: this.options.entity_class
        };

        this.$widgetContainer = jQuery(this.options.widgetContainer);
        this.$tasksMenuContainer = jQuery(this.options.tasksMenuContainer);
        this.$tasksMenuButtonContainer = jQuery(this.options.tasksMenuButtonContainer);

        this.env.dispatcher.bind('hbw:task-clicked', 'widget', this.changeTask);
        this.checkBpmUser();
      }

      changeTask (task) {
        if (task.entity_code === this.options.entity_code) {
          if (this.tasksMenu) {
            this.tasksMenu = this.renderTasksMenu(
              this.$tasksMenuContainer[0],
              { renderButton: this.tasksMenuButton === null },
              task.id
            );
          }
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

        if (this.$tasksMenuButtonContainer.length || this.$tasksMenuContainer.length) {
          if (this.$tasksMenuButtonContainer.length) {
            this.tasksMenuButton = this.renderTasksMenuButton(this.$tasksMenuButtonContainer[0]);
          } else {
            this.tasksMenuButton = null;
          }

          this.tasksMenu = this.renderTasksMenu(
            this.$tasksMenuContainer[0],
            { renderButton: this.tasksMenuButton === null },
            this.options.task_id
          );
        } else {
          this.tasksMenuButton = null;
          this.tasksMenu = null;
        }

        if (this.widget || this.tasksMenu) {
          this.subscribeOnTasks();
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

      renderTasksMenu (container, options, taskId) {
        return ReactDOM.render(
          <Menu env={this.env}
            chosenTaskID={taskId}
            renderButton={options.renderButton} />,
          container
        );
      }

      renderTasksMenuButton (container) {
        return ReactDOM.render(
          <MenuButton env={this.env} />,
          container
        );
      }

      subscribeOnTasks () {
        this.tasksSubscription = this.env.connection.subscribe({
          client: 'root',
          path:   'tasks',

          data: {
            entity_class: this.options.entity_class
          }
        });
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
    }

    return HBW;
  }
);
