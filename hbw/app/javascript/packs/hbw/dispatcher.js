class Dispatcher {
  constructor () {
    this.bind = this.bind.bind(this);
    this.unbind = this.unbind.bind(this);
    this.unbindAll = this.unbindAll.bind(this);
    this.trigger = this.trigger.bind(this);
    this.callbacksFor = this.callbacksFor.bind(this);
    this._addClient = this._addClient.bind(this);
    this._removeClient = this._removeClient.bind(this);

    this.binds = {};
  }

  bind (eventName, clientName, clbk) {
    if (!(eventName in this.binds)) {
      this.binds[eventName] = [];
    }

    this._addClient(this.binds[eventName], clientName, clbk);
  }

  unbind (eventName, clientName) {
    if (eventName in this.binds) {
      this._removeClient(this.binds[eventName], clientName);
    }
  }

  unbindAll (clientName) {
    for (let key in this.binds) {
      this._removeClient(this.binds[key], clientName);
    }
  }

  trigger (eventName, source, payload = null) {
    this.callbacksFor(eventName).forEach(callback => callback(payload, source, eventName));
  }

  callbacksFor (eventName) {
    return (this.binds[eventName] || []).map(c => c.callback);
  }

  _addClient (clients, client, clbk) {
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

  _removeClient (clients, client) {
    [...clients].forEach((c, i) => {
      if (c.client === client) {
        clients.splice(i, 1);
      }
    });
  }
}

modulejs.define('HBWDispatcher', [], () => Dispatcher);
