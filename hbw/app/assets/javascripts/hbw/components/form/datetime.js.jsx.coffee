modulejs.define 'HBWFormDatetime', ['React', 'jQuery', 'moment'], (React, jQuery, moment) ->
  React.createClass
    getDefaultProps: ->
      params:
        locale: 'en'
        format: 'MM/DD/YYYY'

    getInitialState: ->
      locale = @props.params.locale or 'en'
      format = @props.params.format or 'MM/DD/YYYY'

      if @props.value
        value = moment(Date.parse(@props.value))
        defaultValue = value.locale(locale).format(format)
      else
        value = null
        defaultValue = ''

      {
        value: value
        defaultValue: defaultValue
        locale: locale
        format: format
      }

    render: ->
      opts = {
        type: 'text'
        defaultValue: this.state.defaultValue
      }
      opts['disabled'] = 'disabled' if this.props.params.editable == false

      if this.state.value
        isoValue = this.state.value.format()
      else
        isoValue = ''

      inputCSS = 'form-group ' + this.props.params.css_class
      `<div className={inputCSS} title={this.props.params.tooltip}>
         <span className={this.props.params.label_css}>{this.props.params.label}</span>
         <div className="input-group date datetime-picker">
           <input {...opts} className="form-control" />
           <input name={this.props.params.name} type="hidden" value={isoValue} />
           <span className="input-group-addon">
             <span className="fa fa-calendar"></span>
           </span>
         </div>
       </div>`

    componentDidMount: ->
      this.setOnChange()

    componentWillUnmount: ->
      jQuery(React.findDOMNode(this)).off()

    updateValue: (event) ->
      date = event.date

      if date
        stringValue = date.format(@state.format)
        value = moment(stringValue, @state.format, true)
      else
        stringValue = ''
        value = null

      @setState(value: value)

    setOnChange: ->
      jQuery(React.findDOMNode(this))
        .find('.datetime-picker')
        .datetimepicker(format: this.state.format, locale: this.state.locale)
        .on('dp.change', (e) => this.updateValue(e))
