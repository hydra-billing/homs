modulejs.define(
  'HBW',
  ['React', 'HBWTaskList', 'HBWMenu', 'HBWMenuButton', 'HBWContainer', 'HBWConnection',
   'HBWDispatcher', 'HBWForms', 'HBWTranslator', 'jQuery'],
  (React, TaskList, Menu, MenuButton, Container, Connection, Dispatcher, Forms, Translator, jQuery) ->
    class HBW
      widget: null
      tasksMenu: null

      constructor: (@options) ->
        connection = new Connection(path: @options.widgetPath, host: @options.widgetHost)
        @env =
          connection: connection
          dispatcher: new Dispatcher()
          translator: Translator
          forms: new Forms(connection, @options.entity_class)
          locale: @options.locale
          userExist: true
          entity_class: @options.entity_class

        @$widgetContainer = jQuery(@options.widgetContainer)
        @$tasksMenuContainer = jQuery(@options.tasksMenuContainer)
        @$tasksMenuButtonContainer = jQuery(@options.tasksMenuButtonContainer)

        @env.dispatcher.bind('hbw:task-clicked', 'widget', @changeTask)
        @checkActivitiUser()

      changeTask: (task) =>
        if task.entity_code == @options.entity_code
          if @tasksMenu
            @tasksMenu = @renderTasksMenu(@$tasksMenuContainer[0],
                                          {renderButton: @tasksMenuButton is null},
                                          task.id)
          @widget = @renderWidget(@$widgetContainer[0], task.id)
        else
          @env.dispatcher.trigger('hbw:go-to-entity', 'widget', code: task.entity_code, task: task)

      render: =>
        if @options.entity_code
          @widget = @renderWidget(@$widgetContainer[0], this.options.task_id)
        else
          @widget = null

        if @$tasksMenuButtonContainer.length or @$tasksMenuContainer.length
          if @$tasksMenuButtonContainer.length
            @tasksMenuButton = @renderTasksMenuButton(@$tasksMenuButtonContainer[0])

          else
            @tasksMenuButton = null

          @tasksMenu = @renderTasksMenu(@$tasksMenuContainer[0],
                                        {renderButton: @tasksMenuButton is null},
                                        this.options.task_id)
        else
          @tasksMenuButton = null
          @tasksMenu = null

        if @widget or @tasksMenu
          @subscribeOnTasks()

      renderWidget: (container, task_id) =>
        ReactDOM.render(
          `<Container entityCode={this.options.entity_code}
                      entityTypeCode={this.options.entity_type}
                      entityClassCode={this.options.entity_class}
                      chosenTaskID={task_id}
                      env={this.env} />`
          container
        )

      renderTasksMenu: (container, options, task_id) =>
        ReactDOM.render(
          `<Menu env={this.env}
                 chosenTaskID={task_id}
                 renderButton={options.renderButton}  />`
          container
        )

      renderTasksMenuButton: (container) =>
        ReactDOM.render(
          `<MenuButton env={this.env} />`
          container
        )

      subscribeOnTasks: =>
        @tasksSubscription = @env.connection.subscribe(
          client: 'root'
          path: 'tasks'
          data:
            entity_class: this.options.entity_class
        )

      checkActivitiUser: =>
        @env.connection.request(
          url: @env.connection.serverURL + '/users/check'
          method: 'GET'
          contentType: 'application/json').done((data) =>
            unless data.user_exist
              @env.dispatcher.trigger('hbw:activiti-user-not-found')
              @env.userExist = false
            )
)
