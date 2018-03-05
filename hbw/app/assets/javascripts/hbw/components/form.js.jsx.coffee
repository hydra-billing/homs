modulejs.define 'HBWForm', ['React', 'jQuery', 'HBWError', 'HBWFormDatetime', \
  'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect', \
  'HBWFormUser', 'HBWPending', 'HBWFormString', 'HBWFormText', \
  'HBWFormCheckbox', 'HBWFormStatic', 'HBWCallbacksMixin', 'HBWFormSelectTable', 'HBWFormFileList'],
  (React, jQuery, Error, DateTime, Group, Select, Submit, SubmitSelect, \
   User, Pending, String, Text, Checkbox, Static, CallbacksMixin, SelectTable, FileList) ->

  React.createClass
    mixins: [CallbacksMixin]

    getInitialState: ->
      error: null
      submitting: false

    componentDidMount: ->
      jQuery(':input:enabled:visible:first').focus()
      @bind('hbw:submit-form', => @setState(submitting: true))
      @bind('hbw:form-submitting-failed', => @setState(submitting: false))

    render: ->
      `<div className='hbw-form'>
        <Error error={this.state.error || this.props.error} />
        <span>{this.props.pending}</span>
        <form method="post" ref="form" onSubmit={this.submit}>
          {this.iterateControls(this.props.form.fields)}
          {this.submitControl(this.props.form.fields)}
        </form>
      </div>`

    iterateControls: (fields) ->
      `<div key={field.name} className="row">{this.formControl(field.name, field)}</div>` for field in fields

    formControl: (name, params) ->
      opts =
        name: name
        params: params
        value: @props.variables[name]
        formSubmitting: @state.submitting
        env: @props.env

      switch params.type
        when 'group'           then `<Group        {...opts} variables={this.props.variables}/>`
        when 'datetime'        then `<Datetime     {...opts}/>`
        when 'select'          then `<Select       {...opts}/>`
        when 'select_table'    then `<SelectTable  {...opts}/>`
        when 'submit_select'   then `<SubmitSelect {...opts}/>`
        when 'checkbox'        then `<Checkbox     {...opts}/>`
        when 'user'            then `<User         {...opts}/>`
        when 'string'          then `<String       {...opts}/>`
        when 'text'            then `<Text         {...opts}/>`
        when 'static'          then `<Static       {...opts}/>`
        when 'file_list'       then `<FileList     {...opts}/>`
        else `<p>{name}: Unknown control type {params.type}</p>`

    submitControl: (fields) ->
      last = fields[fields.length - 1]
      if last.type == 'submit_select'
        # TODO draw submit select control
      else
        # Draw default form submit button
        params = {
          title: 'Submit the form'
          css_class: 'btn btn-primary'
          fa_class: 'fa fa-check'
        }

        `<Submit params={params} formSubmitting={this.state.submitting} />`

    submit: (e) ->
      e.preventDefault()
      return if @state.submitting
      @trigger('hbw:validate-form')
      @trigger('hbw:submit-form', @serializeForm()) if @isFormValid()

    getElement: ->
      jQuery(@refs.form)

    isFormValid: ->
      @getElement().find('input[type="text"].invalid').length == 0

    serializeForm: ->
      variables = {}

      jQuery.each(@getElement().serializeArray(), (i, field) ->
        if field.value == 'null'
          field.value = null

        variables[field.name] = field.value
      )

      # get hands dirty with select2 elements,
      # 'cause they are not grabbed with serializeArray()
      selects = jQuery(@getElement()).find('select.select2-hidden-accessible')
      jQuery.each(selects, (i, select) ->
        name = jQuery(select).attr('name')
        value = select.value
        variables[name] = value
      )
      console.log("Serialized form: " + JSON.stringify(variables))

      variables
