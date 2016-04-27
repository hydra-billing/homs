modulejs.define 'HBWFormSubmitSelect', ['React'], (React) ->
  React.createClass
    getInitialState: ->
      value: @props.value

    render: ->
      css_class = 'col-xs-12 ' + this.props.params.css_class
      props = this.props
      self = this

      buttons = this.props.params.options.map (option) ->
        self.buildButton(option)

      `<div className={css_class}>
        <span className="btn-group">{ buttons }</span>
        <input type="hidden" name={this.props.name} value={this.state.value} />
       </div>`

    buildButton: (option) ->
      onClick = => @setState(value: option.value)
      css_class = option.css_class
      fa_class = option.fa_class

      if @props.disabled or @props.formSubmitting
        css_class += ' disabled'
        fa_class  += ' disabled'

      `<button key={option.name}
               type="submit"
               className={css_class}
               title={option.title}
               onClick={onClick}
               href="#">
          <i className={fa_class} />
          {' ' + option.name}
        </button>`
