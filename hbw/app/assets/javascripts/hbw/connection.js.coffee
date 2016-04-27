'use strict'

modulejs.define 'HBWConnection', ['jQuery'], (jQuery) ->
  class Subscription
    constructor: (@channel, @options) ->
      @callbacks =
        fetch: []
        progress: []
        fail: []
        syncing: []
        always: []

    addCallback: (kind, clbk) =>
      @callbacks[kind].push(clbk)

    runCallbacks: (kind, args) =>
      for clbk in @callbacks[kind]
        clbk(args...)

    fetch: (clbk) =>
      @addCallback('fetch', clbk)
      if @channel.fetched
        setTimeout(clbk, 0)
      @

    progress: (clbk) =>
      @addCallback('progress', clbk)
      if @channel.lastPoll != null
        setTimeout((=> clbk(@channel.lastPoll...)), 0)
      @

    fail: (clbk) =>
      @addCallback('fail', clbk)
      @

    syncing: (clbk) =>
      @addCallback('syncing', clbk)
      @

    always: (clbk) =>
      @addCallback('always', clbk)
      @

    start: (args...) =>
      @channel.start(args...)

    close: => @channel.unsubscribe(@options.client)

    markAsFetched: =>
      @runCallbacks('fetch')

  class Channel
    defaultInterval: 5000
    started: false
    fetched: false
    intervalId: null
    lastPoll: null
    polling: false
    _currentXHR: null

    constructor: (@connection, @options) ->
      @id = @buildId()
      @subscriptions = {}

    buildId: =>
      @options.method + ' '  + @options.path

    eachSubscriptions: (update) =>
      for _, subscription of @subscriptions
        update(subscription)

    subscribe: (options) =>
      client = options.client

      if client of @subscriptions
        if options.returnExisting
          @subscriptions[client]
        else
          throw new Error('Error!')
      else
        @subscriptions[client] = new Subscription(@,
                                                  client: options.client,
                                                  fetched: @fetched,
                                                  lastPoll: @lastPoll)

    unsubscribe: (client) =>
      delete @subscriptions[client]

      if jQuery.isEmptyObject(@subscriptions)
        @stop()

    start: (interval = @defaultInterval) =>
      if @started
        newInterval = interval or @defaultInterval

        if newInterval != @interval
          console.warn('Channel to', @options.path, 'already started with interval', @interval)
      else
        @started = true
        @interval = interval or @defaultInterval
        @poll()
        @intervalId = setInterval(@poll, @interval)

    stop: =>
      @abort()
      clearInterval(@intervalId)
      @intervalId = null
      @started = false
      @polling = false
      @lastPoll = null

    poll: =>
      return if @polling
      @polling = true

      @runCallbacks('syncing')
      @_currentXHR = @connection.request(
        url: @connection.serverURL + '/' + @options.path.replace(/^\//, '')
        method: @options.method
        data: @options.data)
      @_currentXHR
        .always(=>
          @polling = false
          @_currentXHR = null)
        .done((args...) =>
          @lastPoll = args
          unless @fetched
            @fetched = true
            @runCallbacks('fetch')
          @runCallbacks('progress', args))
        .fail((args...) => @runCallbacks('fail', args))
        .always((args...) => @runCallbacks('always', args))

    abort: =>
      if @_currentXHR
        @_currentXHR.abort()
        @_currentXHR = null

    runCallbacks: (kind, args = []) =>
      @eachSubscriptions((s) -> s.runCallbacks(kind, args))

  class Connection
    constructor: (@options) ->
      @options.path ||= ''
      @options.host ||= document.location.protocol + '//' + document.location.host
      @serverURL = @options.host + @options.path
      @channels = {}

    request: (args...) =>
      jQuery.ajax(args...)

    createChannel: (options) =>
      channel = new Channel(@,
                            path: options.path
                            data: options.data or {}
                            method: options.method or 'GET')
      id = channel.id

      if id of @channels
        if options.raiseOnExisting
          throw new Error('Error!')
        else
          @channels[id]
      else
        @channels[id] = channel

    subscribe: (options) =>
      @createChannel(options).subscribe(options)

  Connection
