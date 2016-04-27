modulejs.define(
  'HBWMenuButton',
  ['React', 'HBWCallbacksMixin', 'HBWTasksMixin'],
  (React, CallbacksMixin, TasksMixin) ->
    React.createClass
      mixins: [CallbacksMixin, TasksMixin]

      getInitialState: ->
        tasksNumber: 0

      toggleVisibility: ->
        @setState(visible: !@state.visible)

      componentDidMount: ->
        @bind('hbw:hide-widget', @toggleVisibility)
        @state.subscription
          .progress((data) =>
            @setState(tasksNumber: data.tasks.length)
          )

      render: ->
        `<a href="javascript:;" onClick={this.toggleMenu} className="hbw-menu-button fa fa-reorder">
          {this.state.tasksNumber && <span className="counter">{this.state.tasksNumber}</span> || ''}
        </a>`

      toggleMenu: ->
        React.findDOMNode(@).blur()
        @trigger('hbw:toggle-tasks-menu')
)
