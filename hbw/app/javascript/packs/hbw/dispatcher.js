class Dispatcher {
  constructor () {
    this.bind = this.bind.bind(this);
    this.unbind = this.unbind.bind(this);
    this.unbindAll = this.unbindAll.bind(this);
    this.trigger = this.trigger.bind(this);
    this.callbacksFor = this.callbacksFor.bind(this);

    this.binds = {};
  }

  bind (eventName, clientName, clbk) {
    if (!(eventName in this.binds)) {
      this.binds[eventName] = [];
    }

    Dispatcher._addClient(this.binds[eventName], clientName, clbk);
  }

  unbind (eventName, clientName) {
    if (eventName in this.binds) {
      Dispatcher._removeClient(this.binds[eventName], clientName);
    }
  }

  unbindAll (clientName) {
    Object.keys(this.binds).forEach((key) => {
      Dispatcher._removeClient(this.binds[key], clientName);
    });
  }

  trigger (eventName, source, payload = null) {
    this.callbacksFor(eventName).forEach(callback => callback(payload, source, eventName));
  }

  callbacksFor (eventName) {
    return (this.binds[eventName] || []).map(c => c.callback);
  }

  static _addClient (clients, client, clbk) {
    [...clients].forEach((c) => {
      if (c.client === client) {
        throw new Error(`Client ${client} already bound!`);
      }
    });

    clients.push({
      client,
      callback: clbk
    });
  }

  static _removeClient (clients, client) {
    [...clients].forEach((c, i) => {
      if (c.client === client) {
        clients.splice(i, 1);
      }
    });
  }
}

modulejs.define('HBWDispatcher', [], () => Dispatcher);
