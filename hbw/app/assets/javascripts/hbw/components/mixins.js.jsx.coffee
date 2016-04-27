modulejs.define 'HBWUIDMixin', [], ->
  getDefaultProps: ->
    guid: 'hbw-' + Math.floor(Math.random() * 0xFFFF)

  getComponentId: ->
    @props.guid

modulejs.define 'HBWCallbacksMixin', ['HBWUIDMixin'], (UIDMixin) ->
  mixins: [UIDMixin]

  bind: (event, clbk) ->
    @props.env.dispatcher.bind(event, @getComponentId(), clbk)

  unbind: (event) ->
    @props.env.dispatcher.unbind(event, @getComponentId())

  componentWillUnmount: ->
    @props.env.dispatcher.unbindAll(@getComponentId())

  trigger: (event, payload = null) ->
    @props.env.dispatcher.trigger(event, @, payload)

modulejs.define 'HBWTasksMixin', [], ->
  getInitialState: ->
    subscription: @createSubscription()
    pollInterval: 5000
    syncing: false
    error: null

  componentDidMount: ->
    @state.subscription.start(@props.pollInterval)

  componentWillUnmount: ->
    @state.subscription.close()

  createSubscription: ->
    @props.env.connection.subscribe(client: @getComponentId(), path: 'tasks')
      .syncing(=> @setState(syncing: true))
      .progress(=> @setState(error: null))
      .fail((response) => @setState(error: response))
      .always(=> @setState(syncing: false))

modulejs.define 'HBWTranslationsMixin', ['HBWTranslator'], (Translator) ->
  t: (key) -> Translator.translate(key)
