modulejs.define 'HBWButton', ['React', 'HBWCallbacksMixin'], (React, CallbacksMixin)->
  React.createClass(
    mixins: [CallbacksMixin]

    render: ->
      classes = []
      classes.push(@props.button.class) if @props.button.class
      classes.push('disabled') if @props.disabled

      opts = {
        className: classes.join(' ')
        title: @props.button.title
        disabled: @props.disabled
      }

      `<span className="hbw-button"><a onClick={this.onClick} {...opts} href='#'>
          <i className={this.props.button.fa_class}></i>
          {' ' + this.props.button.name}
        </a></span>`

    onClick: (evt) ->
      evt.preventDefault()

      @trigger('hbw:button-activated', @props.button)
  )
