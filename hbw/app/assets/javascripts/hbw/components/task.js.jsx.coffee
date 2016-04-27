modulejs.define 'HBWTask', ['React', 'HBWCallbacksMixin'], (React, CallbacksMixin) ->
  React.createClass(
    mixins: [CallbacksMixin]

    onClick: ->
      @trigger('hbw:task-clicked', @props.task)

    render: ->
      label = @props.task.entity_code + ' – ' + @props.task.name
      if @props.active
        `<li className="hbw-active-task" onClick={this.onClick}>{label} {this.props.form_loading ? <span className="fa fa-spinner fa-pulse"></span> : '' }</li>`
      else
        `<li className="hbw-inactive-task" onClick={this.onClick}>{label}</li>`
  )
