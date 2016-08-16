modulejs.define(
  'HBWContainer',
  ['React',
   'HBWButtons',
   'HBWEntityTasks',
   'HBWError',
   'HBWPending',
   'HBWCallbacksMixin',
   'HBWTasksMixin'],
  (React, Buttons, Tasks, Error, Pending, CallbacksMixin, TasksMixin) ->
    React.createClass
      mixins: [TasksMixin, CallbacksMixin]

      getInitialState: ->
        buttons: []
        tasks: []
        tasksFetched: false
        processStarted: false

      componentDidMount: ->
        @state.subscription
          .fetch(=> @setState(tasksFetched: true))
          .progress((data) =>
            tasks = data.tasks.filter (t) => t.entity_code == @props.entityCode
            @setState(tasks: tasks, processStarted: @state.processStarted and tasks.length == 0))

        @bind('hbw:form-submitted', @onFormSubmit)
        @bind('hbw:process-started', => @setState(processStarted: true))

      render: ->
        if @state.tasks.length > 0 and @state.tasksFetched
          `<div className='hbw-entity-tools'>
            <Tasks tasks={this.state.tasks}
                   env={this.props.env}
                   chosenTaskID={this.props.chosenTaskID}
                   entityCode={this.props.entityCode}
                   entityTypeCode={this.props.entityTypeCode}
                   processInstanceId={this.state.processInstanceId} />
          </div>`
        else
          `<div className='hbw-entity-tools'>
             <Error error={this.state.error} />
             <Buttons entityCode={this.props.entityCode}
                      entityTypeCode={this.props.entityTypeCode}
                      tasksFetched={this.state.tasksFetched}
                      showSpinner={!this.state.tasksFetched || this.state.processStarted}
                      env={this.props.env} />
          </div>`

      onFormSubmit: (task) ->
        # remeber execution id of the last submitted form to open next form if
        # task with the same processInstanceId will be loaded
        @setState(processInstanceId: task.processInstanceId)
)
