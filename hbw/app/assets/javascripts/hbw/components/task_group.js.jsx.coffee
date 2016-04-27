modulejs.define(
  'HBWTaskGroup',
  ['React',
   'HBWTask',
   'HBWCallbacksMixin'],
  (React,
   Task,
   CallbacksMixin) ->
    React.createClass
      mixins: [CallbacksMixin]

      getDefaultProps: ->
        group: ''
        tasks: []
        form_loading: false

      renderTask: (task) ->
        `<Task key={task.id}
               task={task}
               env={this.props.env}
               active={task.id == this.props.chosenTaskID}
               form_loading={this.props.form_loading}
          />`

      render: ->
        tasks = do (tasks = @props.tasks) ->
          # sort by task.id
          keys = tasks.sort (a, b) -> (a.id - b.id)
          task for task in keys

        children = tasks.map (task) => @renderTask(task)

        `<div>
          <p className="hbw-task-group-item"><b>{this.props.key}</b></p>
          <ul className="hbw-task-item">{children}</ul>
        </div>`
)
