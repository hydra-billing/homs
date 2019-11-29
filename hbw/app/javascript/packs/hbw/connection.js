/* eslint no-console: "off" */
/* eslint class-methods-use-this: ["error", { "exceptMethods": ["request"] }] */

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

    update = (data) => {
      this.channel.updateOptions(data);
    }

    poll = () => this.channel.poll();
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
      return this.options.client;
    }

    eachSubscriptions (update) {
      Object.keys(this.subscriptions).forEach((key) => {
        update(this.subscriptions[key]);
      });
    }

    subscribe (options) {
      const { client } = options;

      if (client in this.subscriptions) {
        if (options.returnExisting) {
          return this.subscriptions[client];
        }
        throw new Error('Error!');
      } else {
        this.subscriptions[client] = new Subscription(this, {
          client,
          fetched:  this.fetched,
          lastPoll: this.lastPoll
        });

        return this.subscriptions[client];
      }
    }

    unsubscribe (client) {
      delete this.subscriptions[client];

      if (jQuery.isEmptyObject(this.subscriptions)) {
        this.stop();
      }
    }

    start (interval = this.defaultInterval) {
      if (interval < 0) {
        this.poll();
        return;
      }

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
        return null;
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

    updateOptions = (data) => {
      this.options.data = data;
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

      window.onblur = this.stopPolling;
      window.onfocus = this.startPolling;
    }

    stopPolling = () => Object.values(this.channels).forEach(c => c.stop());

    startPolling = () => Object.values(this.channels).forEach(c => c.start())

    request (opts) {
      return jQuery.ajax({
        ...opts,
        data: {
          ...opts.data,
          payload: this.options.payload
        }
      });
    }

    createChannel (options) {
      const channel = new Channel(this, {
        path:   options.path,
        data:   options.data || {},
        method: options.method || 'GET',
        client: options.client
      });
      const { id } = channel;

      if (id in this.channels) {
        if (options.raiseOnExisting) {
          throw new Error('Error!');
        } else {
          return this.channels[id];
        }
      } else {
        this.channels[id] = channel;

        return channel;
      }
    }

    subscribe (options) {
      return this.createChannel(options).subscribe(options);
    }

    unsubscribe () {
      Object.keys(this.channels).forEach((ch) => {
        Object.values(this.channels[ch].subscriptions).forEach((s) => {
          s.close();
        });

        delete this.channels[ch];
      });
    }
  }

  return Connection;
});
