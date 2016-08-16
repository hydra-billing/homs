modulejs.define(
  'HBWEntityTask',
  ['React',
   'jQuery',
   'HBWForm',
   'HBWTestForm',
   'HBWError',
   'HBWPending',
   'HBWCallbacksMixin',
   'HBWTranslationsMixin',
   'HBWFormDefinition'],
  (React,
   jQuery,
   Form,
   TestForm,
   Error,
   Pending,
   CallbacksMixin,
   TranslationsMixin,
   FormDefinition) ->
    React.createClass
      mixins: [CallbacksMixin, TranslationsMixin]

      getInitialState: ->
        error: null
        loading: true
        pending: null
        form: null

      componentDidMount: ->
        @loadForm(@props.task.id)
        @bind('hbw:submit-form', @submitForm)

        e = jQuery(React.findDOMNode(this))
        e.on('hidden.bs.collapse', @choose)
        e.on('shown.bs.collapse',  @choose)

      componentWillUnmount: ->
        jQuery(React.findDOMNode(this)).off('hidden.bs.collapse').off('shown.bs.collapse')

      render: ->
        collapseClass = 'panel-collapse collapse'
        collapseClass += ' in' unless this.props.collapsed
        iconClass = 'indicator pull-right glyphicon'

        if @props.collapsed
          iconClass += ' glyphicon-chevron-down'
        else
          iconClass += ' glyphicon-chevron-up'

        task = @props.task
        `<div className="panel panel-default">
          <div className="panel-heading">
            <h4 className="panel-title collapsable">
              <a data-toggle="collapse"
                 data-target={"#collapse" + task.id}
                 data-parent={'.' + this.props.parentClass}>
                {task.name}
              </a>
              <i className={iconClass}></i>
            </h4>
          </div>
          <div id={"collapse" + task.id} className={collapseClass}>
            <div className="panel-body">
              {this.renderForm()}
            </div>
          </div>
        </div>`

      renderForm: ->
        if @state.form
          opts =
            form: @state.form
            env: @props.env
            error: @state.error
            pending: @state.pending
            variables: @formVariablesFromTask(@props.task)

          `<Form {...opts}/>`
        else if @state.error
          `<Error error={this.state.error} />`
        else
          `<Pending active={this.state.loading} />`

      formVariablesFromTask: ->
        form = @state.form
        formVariables = {}
        formDef = new FormDefinition(@state.form)

        for varHash in @props.task.variables
          if formDef.fieldExist(varHash.name)
            formVariables[varHash.name] = varHash.value

        formVariables

      loadForm: (taskId) ->
        @setState(loading: true)
        @props.env.forms.fetch(taskId)
          .done((form) => @setState(error: null, form: form))
          .done(=> @trigger('hbw:form-loaded', entityCode: @props.entityCode))
          .fail((response) => @setState(error: response))
          .always(=> @setState(loading: false))

      submitForm: (variables) ->
        @setState(pending: true)
        @props.env.forms.save(taskId: @props.taskId, variables: variables, token: @state.form.csrf_token)
          .done((form) => @setState(error: null))
          .done(=> @trigger('hbw:form-submitted', @props.task))
          .fail((response) =>
            @setState(error: response)
            @trigger('hbw:form-submitting-failed', response: response, task: @props.task)
          )
          .always(=> @setState(pending: false))

      choose: (e) ->
        @trigger('hbw:task-clicked', @props.task)
)
