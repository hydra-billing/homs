'use strict'

class Dispatcher
  constructor: ->
    @binds = {}

  bind: (eventName, clientName, clbk) =>
    unless eventName of @binds
      @binds[eventName] = []

    @_addClient(@binds[eventName], clientName, clbk)

  unbind: (eventName, clientName) =>
    if eventName of @binds
      @_removeClient(@binds[eventName], clientName)

  unbindAll: (clientName) =>
    for _, clients of @binds
      @_removeClient(clients, clientName)

  trigger: (eventName, source, payload = null) =>
    for callback in @callbacksFor(eventName)
      callback(payload, source, eventName)

  callbacksFor: (eventName) =>
    (@binds[eventName] or []).map (c) -> c.callback

  _addClient: (clients, client, clbk) =>
    for c in clients when c.client is client
      throw new Error('Client ' + client + ' already bound!')

    clients.push(
      client: client
      callback: clbk
    )

  _removeClient: (clients, client) =>
    for c, i in clients
      if c.client == client
        clients.splice(i, 1)
        return


modulejs.define('HBWDispatcher', [], -> Dispatcher)
