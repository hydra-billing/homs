modulejs.define 'HBWUIDMixin', [], ->
  setGuid: ->
    @guid = 'hbw-' + Math.floor(Math.random() * 0xFFFF)

  getComponentId: ->
    @guid

  componentWillMount: ->
    @setGuid() unless @guid

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
    @setGuid()

    subscription: @createSubscription()
    pollInterval: 5000
    syncing: false
    error: null

  componentDidMount: ->
    @state.subscription.start(@props.pollInterval)

  componentWillUnmount: ->
    @state.subscription.close()

  createSubscription: ->
    @props.env.connection.subscribe(
      client: @getComponentId()
      path: 'tasks'
      data:
        entity_class: @props.env.entity_class)
      .syncing(=> @setState(syncing: true))
      .progress(=> @setState(error: null))
      .fail((response) => @setState(error: response))
      .always(=> @setState(syncing: false))

modulejs.define 'HBWTranslationsMixin', ['HBWTranslator'], (Translator) ->
  t: (key, vars) -> Translator.translate(key, vars)

modulejs.define 'HBWDeleteIfMixin', [], ->
  variables: ->
    @props.params.variables || @props.params.task.definition.variables

  variableByName: (name) ->
    for variable in @variables()
      return variable.value if variable.name == name

  deleteIf: ->
    conditions = @getConditions()

    if (jQuery.isArray(conditions) && conditions.length == 0) || jQuery.isEmptyObject(conditions)
      false
    else
      conditionType = @conditionType(conditions[0])

      result = for condition in conditions
        if conditionType == 'or'
          @evaluateOrCondition(condition)
        else
          @evaluateAndCondition(condition)

      if conditionType == 'or'
        @some(result)
      else
        @every(result)

  getConditions: ->
    @props.params.delete_if || []

  conditionType: (condition) ->
    if condition.constructor == Array
      'or'
    else
      'and'

  evaluateAndCondition: (data) ->
    eval(data.condition.replace('$var', @variableByName(data.variable)))

  evaluateOrCondition: (data) ->
    result = for inner_condition in data
      @evaluateAndCondition(inner_condition)

    @every(result)

  componentWillMount: ->
    @hidden = @deleteIf()

  every: (results) ->
    for result in results
      return result if result == false

    true

  some: (results) ->
    for result in results
      return result if result == true

    false
