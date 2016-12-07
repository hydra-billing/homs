modulejs.define 'HBWForms', ['jQuery'], (jQuery) ->
  class Forms
    whenFinished: null
    onStart: ->
    onFinish: ->

    constructor: (@connection, @entityClass) ->
      @forms = {}
      @currentRequests = {}

    start: (clbk) =>
      @onStart = clbk

    finish: (clbk) =>
      @onFinish = clbk

    fetch: (taskId, options = {}) =>
      existing = @forms[taskId]

      if existing and not options.force
        @_wrapWithDeferred(existing)
      else
        @trackRequest(
          taskId,
          @connection.request(
            url: @formURL(taskId)
            data:
              entity_class: @entityClass)
            .done((form) => @forms[taskId] = form))

    save: (params = {}) =>
      @connection.request(
        url: @formURL(params.taskId)
        method: 'PUT'
        contentType: 'application/json'
        data: JSON.stringify(form_data: params.variables, entity_class: @entityClass)
        headers:
          'X-CSRF-Token': params.token
      )

    formURL: (taskId) =>
      @connection.serverURL + '/tasks/' + taskId + '/form'

    currentRequestsList: =>
      jQuery.map(@currentRequests, (val, _) -> val)

    trackRequest: (taskId, request) =>
      if jQuery.isEmptyObject(@currentRequests)
        @onStart()

      @_registerRequest(taskId, request)

      @whenFinished = jQuery.when.apply(@currentRequestsList())
      ((deferred) => deferred.then(=> @onFinish() if deferred == @whenFinished))(@whenFinished)

      request

    _registerRequest: (taskId, request) =>
      @_pushRequest(taskId, request)
      request.done(=> @_popRequest(taskId))

    _pushRequest: (taskId, request) =>
      @currentRequests[taskId] = request

    _popRequest: (taskId) =>
      request = @currentRequests[taskId]
      delete @currentRequests[taskId]
      request

    _wrapWithDeferred: (value) =>
       (new jQuery.Deferred()).resolve(value)

  Forms
