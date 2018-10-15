modulejs.define('HBWConnection', ['jQuery'], (jQuery) => {
  class Subscription {
    constructor (channel, options) {
      this.channel = channel;
      this.options = options;
      this.callbacks = {
        fetch:    [],
        progress: [],
        fail:     [],
        syncing:  [],
        always:   []
      };
    }

    addCallback (kind, clbk) {
      return this.callbacks[kind].push(clbk);
    }

    runCallbacks (kind, args = []) {
      this.callbacks[kind].forEach(clbk => clbk(...args));
    }

    fetch (clbk) {
      this.addCallback('fetch', clbk);

      if (this.channel.fetched) {
        setTimeout(clbk, 0);
      }

      return this;
    }

    progress (clbk) {
      this.addCallback('progress', clbk);

      if (this.channel.lastPoll !== null) {
        setTimeout((() => clbk(...Array.from(this.channel.lastPoll || []))), 0);
      }

      return this;
    }

    fail (clbk) {
      this.addCallback('fail', clbk);
      return this;
    }

    syncing (clbk) {
      this.addCallback('syncing', clbk);
      return this;
    }

    always (clbk) {
      this.addCallback('always', clbk);
      return this;
    }

    start (...args) {
      return this.channel.start(...args);
    }

    close () {
      return this.channel.unsubscribe(this.options.client);
    }

    markAsFetched () {
      return this.runCallbacks('fetch');
    }
  }

  class Channel {
    constructor (connection, options) {
      this.buildId = this.buildId.bind(this);
      this.eachSubscriptions = this.eachSubscriptions.bind(this);
      this.subscribe = this.subscribe.bind(this);
      this.unsubscribe = this.unsubscribe.bind(this);
      this.start = this.start.bind(this);
      this.stop = this.stop.bind(this);
      this.poll = this.poll.bind(this);
      this.abort = this.abort.bind(this);
      this.runCallbacks = this.runCallbacks.bind(this);

      this.defaultInterval = 5000;
      this.started = false;
      this.fetched = false;
      this.intervalId = null;
      this.lastPoll = null;
      this.polling = false;
      this._currentXHR = null;

      this.connection = connection;
      this.options = options;
      this.id = this.buildId();
      this.subscriptions = {};
    }

    buildId () {
      return `${this.options.method} ${this.options.path}`;
    }

    eachSubscriptions (update) {
      for (let key in this.subscriptions) {
        update(this.subscriptions[key]);
      }
    }

    subscribe (options) {
      const { client } = options;

      if (client in this.subscriptions) {
        if (options.returnExisting) {
          return this.subscriptions[client];
        } else {
          throw new Error('Error!');
        }
      } else {
        return this.subscriptions[client] = new Subscription(this, {
          client:   options.client,
          fetched:  this.fetched,
          lastPoll: this.lastPoll
        });
      }
    }

    unsubscribe (client) {
      delete this.subscriptions[client];

      if (jQuery.isEmptyObject(this.subscriptions)) {
        return this.stop();
      }
    }

    start (interval = this.defaultInterval) {
      if (this.started) {
        const newInterval = interval || this.defaultInterval;

        if (newInterval !== this.interval) {
          console.warn('Channel to', this.options.path, 'already started with interval', this.interval);
        }
      } else {
        this.started = true;
        this.interval = interval || this.defaultInterval;
        this.poll();
        this.intervalId = setInterval(this.poll, this.interval);
      }
    }

    stop () {
      this.abort();
      clearInterval(this.intervalId);
      this.intervalId = null;
      this.started = false;
      this.polling = false;
      this.lastPoll = null;
    }

    poll () {
      if (this.polling) {
        return;
      }

      this.polling = true;

      this.runCallbacks('syncing');
      this._currentXHR = this.connection.request({
        url:    `${this.connection.serverURL}/${this.options.path.replace(/^\//, '')}`,
        method: this.options.method,
        data:   this.options.data
      });

      return this._currentXHR
        .always(() => {
          this.polling = false;
          this._currentXHR = null;
        })
        .done((...args) => {
          this.lastPoll = args;
          if (!this.fetched) {
            this.fetched = true;
            this.runCallbacks('fetch');
          }
          return this.runCallbacks('progress', args);
        })
        .fail((...args) => this.runCallbacks('fail', args))
        .always((...args) => this.runCallbacks('always', args));
    }

    abort () {
      if (this._currentXHR) {
        this._currentXHR.abort();
        this._currentXHR = null;
      }
    }

    runCallbacks (kind, args = []) {
      this.eachSubscriptions(s => s.runCallbacks(kind, args));
    }
  }

  class Connection {
    constructor (options) {
      this.request = this.request.bind(this);
      this.createChannel = this.createChannel.bind(this);
      this.subscribe = this.subscribe.bind(this);

      this.options = options;
      if (!this.options.path) {
        this.options.path = '';
      }
      if (!this.options.host) {
        this.options.host = `${document.location.protocol}//${document.location.host}`;
      }

      this.serverURL = this.options.host + this.options.path;
      this.channels = {};
    }

    request (...args) {
      return jQuery.ajax(...args);
    }

    createChannel (options) {
      const channel = new Channel(this, {
        path:   options.path,
        data:   options.data || {},
        method: options.method || 'GET'
      });
      const { id } = channel;

      if (id in this.channels) {
        if (options.raiseOnExisting) {
          throw new Error('Error!');
        } else {
          return this.channels[id];
        }
      } else {
        return this.channels[id] = channel;
      }
    }

    subscribe (options) {
      return this.createChannel(options).subscribe(options);
    }
  }

  return Connection;
});
