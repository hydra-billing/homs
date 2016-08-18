modulejs.define(
  'HBWEntityTasks',
  ['React', 'HBWEntityTask', 'HBWCallbacksMixin'],
  (React, Task, CallbacksMixin) ->
    React.createClass
      PANEL_CLASS: 'hbw-entity-task-list-panel'

      mixins: [CallbacksMixin]

      getInitialState: ->
        error: null
        chosenTaskID: @props.chosenTaskID or @selectFirstTaskId()

      componentWillReceiveProps: (nextProps) ->
        @setState(chosenTaskID: nextProps.chosenTaskID)

      selectFirstTaskId: ->
        if @props.tasks.length > 0
          @trigger('hbw:task-clicked', @props.tasks[0])
          @props.tasks[0].id
        else
          @trigger('hbw:task-clicked', null)
          null

      render: ->
        classes = 'hbw-entity-task-list'
        # classes += ' ' + this.props.form.css_class
        processName = @getProcessName()

        `<div className={classes}>
          <div className={'panel panel-group ' + this.PANEL_CLASS}>
            {processName && <div className='process-name'>{processName}</div>}
            {this.iterateTasks(this.props.tasks, this.state.chosenTaskID)}
          </div>
        </div>`

      iterateTasks: (tasks, chosenTaskID) ->
        taskAlreadyExpanded = false # only one task should show its form - to be expanded
        props = @props

        tasks.map((task) =>
          if taskAlreadyExpanded
            collapsed = true
          else
            collapsed = (task.id != @props.chosenTaskID and task.processInstanceId != props.processInstanceId)
            taskAlreadyExpanded = !collapsed

          `<Task id={'task_id_' + task.id}
                 key={'task_id_' + task.id}
                 task={task}
                 parentClass={this.PANEL_CLASS}
                 env={props.env}
                 taskId={task.id}
                 entityCode={props.entityCode}
                 entityTypeCode={props.entityTypeCode}
                 collapsed={collapsed} />`
        )

      getProcessName: ->
        if @props.tasks.length > 0
          @props.tasks[0].process_name
        else
          null
)
