modulejs.define(
  'HBWButtons',
  ['React',
   'HBWButton',
   'HBWCallbacksMixin',
   'HBWTranslationsMixin',
   'HBWError',
   'HBWPending'],
  (React,
   Button,
   CallbacksMixin,
   TranslationsMixin,
   Error,
   Pending) ->
    React.createClass(
      mixins: [CallbacksMixin, TranslationsMixin]

      getInitialState: ->
        @setGuid()

        buttons: []
        subscription: @createSubscription()
        pollInterval: 5000
        syncing: false
        syncError: null
        submitError: null
        errorHeader: ''
        disabled: false
        fetched: false
        submitting: false
        bpRunning: false

      createSubscription: ->
        subscription = @props.env.connection.subscribe(
          client: @getComponentId()
          path: '/buttons'
          data:
            entity_code: @props.entityCode
            entity_type: @props.entityTypeCode
            entity_class: @props.entityClassCode
        )

        subscription
          .syncing(=> @setState(syncing: true))
          .fetch(=> @setState(fetched: true))
          .always(=> @setState(syncing: false))
          .fail((response) => @setState(
                                syncError: response,
                                errorHeader: @t('errors.cannot_obtain_available_actions')))
          .progress((data) => @setState(buttons: data.buttons, syncError: null, bpRunning: data.bp_running))

      submitButton: (businessProcessCode) ->
        @props.env.connection.request(
          url: @buttonsURL()
          method: 'POST'
          data:
            entity_code: @props.entityCode
            entity_type: @props.entityTypeCode
            entity_class: @props.entityClassCode
            bp_code: businessProcessCode)

      buttonsURL: ->
        @props.env.connection.serverURL + '/buttons'

      componentDidMount: ->
        @state.subscription.start(@state.pollInterval)
        @bind('hbw:button-activated', @onButtonActivation)

      componentWillUnmount: ->
        @state.subscription.close()

      render: ->
        if @props.env.userExist
          if @props.showSpinner or !@state.fetched
            `<div className="hbw-spinner"><i className="fa fa-spinner fa-spin fa-2x"></i></div>`
          else if @state.bpRunning
            `<div className="hbw-spinner"><i className="fa fa-spinner fa-spin fa-2x"></i><h5 className="hbw-spinner-text">{I18n.t('js.bp_running')}</h5></div>`
          else
            buttons = @state.buttons.map((button, index) =>
              self = @
              `<Button key={index}
                       button={button}
                       disabled={self.state.submitting}
                       env={self.props.env} />`
            )
            `<div className='hbw-bp-control-buttons btn-group'>
              <Error error={this.state.submitError || this.state.syncError} errorHeader={this.state.errorHeader} />
              {buttons}
            </div>`
        else
          ``

      onButtonActivation: (button) ->
        console.log('Clicked button[' + button.title + '], submitting')
        @setState(syncing: true, submitting: true)

        @submitButton(button.bp_code)
          .done((data) => @setState(submitError: null, buttons: data.buttons, bpRunning: data.bp_running))
          .done(=> @triggerBPStart(button))
          .fail((response) =>
            @setState(
              submitError: response,
              submitting: false,
              errorHeader: @t('errors.cannot_start_process')))
          .always(=> @setState(syncing: false))

      triggerBPStart: (button) ->
        @trigger('hbw:process-started', button)
  )
)
