modulejs.define(
  'HBWMenu',
  ['React', 'HBWTaskList', 'HBWCallbacksMixin'],
  (React, TaskList, CallbacksMixin) ->
    React.createClass
      mixins: [CallbacksMixin]

      getInitialState: ->
        visible: false

      toggleVisibility: ->
        @setState(visible: !@state.visible)

      componentDidMount: ->
        @bind('hbw:toggle-tasks-menu', @toggleVisibility)

      render: ->
        `<div>
          { this.props.renderButton &&
          <div className='hbw-launcher' onClick={this.toggleVisibility}>
            <div className='hbw-launcher-button btn-primary'>
            </div>
          </div> }
          { this.state.visible ? <TaskList env={this.props.env}
                                           chosenTaskID={this.props.chosenTaskID} /> : null }
        </div>`
)
