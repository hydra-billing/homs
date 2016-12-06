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
          forms: new Forms(connection)
          locale: @options.locale
          userExist: true

        @$widgetContainer = jQuery(@options.widgetContainer)
        @$tasksMenuContainer = jQuery(@options.tasksMenuContainer)
        @$tasksMenuButtonContainer = jQuery(@options.tasksMenuButtonContainer)

        @env.dispatcher.bind('hbw:task-clicked', 'widget', @changeTask)
        @checkActivitiUser()

      changeTask: (task) =>
        if task.entity_code == @options.entity_code
          if @tasksMenu
            @tasksMenu.setProps(chosenTaskID: task.id)
          @widget.setProps(chosenTaskID: task.id)
        else
          @env.dispatcher.trigger('hbw:go-to-entity', 'widget', code: task.entity_code, task: task)

      render: =>
        if @options.entity_code
          @widget = @renderWidget(@$widgetContainer[0])
        else
          @widget = null

        if @$tasksMenuButtonContainer.length or @$tasksMenuContainer.length
          if @$tasksMenuButtonContainer.length
            @tasksMenuButton = @renderTasksMenuButton(@$tasksMenuButtonContainer[0])

          else
            @tasksMenuButton = null

          @tasksMenu = @renderTasksMenu(@$tasksMenuContainer[0],
                                        renderButton: @tasksMenuButton is null)
        else
          @tasksMenuButton = null
          @tasksMenu = null

        if @widget or @tasksMenu
          @subscribeOnTasks()

      renderWidget: (container) =>
        React.render(
          `<Container entityCode={this.options.entity_code}
                      entityTypeCode={this.options.entity_type}
                      chosenTaskID={this.options.task_id}
                      env={this.env} />`
          container
        )

      renderTasksMenu: (container, options) =>
        React.render(
          `<Menu env={this.env}
                 chosenTaskID={this.options.task_id}
                 renderButton={options.renderButton}  />`
          container
        )

      renderTasksMenuButton: (container) =>
        React.render(
          `<MenuButton env={this.env} />`
          container
        )

      subscribeOnTasks: =>
        @tasksSubscription = @env.connection.subscribe(client: 'root', path: 'tasks')

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
