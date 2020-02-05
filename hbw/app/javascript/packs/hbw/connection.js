import qs from 'qs';

export default class Connection {
  constructor (options) {
    this.options = options;

    if (!this.options.path) {
      this.options.path = '';
    }

    if (!this.options.host) {
      this.options.host = `${document.location.protocol}//${document.location.host}`;
    }

    this.serverURL = this.options.host + this.options.path;
  }

  request = (opts) => {
    if (opts.method.toLowerCase() === 'get') {
      const url = new URL(opts.url, window.location);

      const searchParams = [...url.searchParams]
        .reduce((obj, [key, value]) => ({ ...obj, [key]: value }), {});

      url.search = qs.stringify({
        ...searchParams,
        ...(opts.data || {}),
        payload: this.options.payload
      });

      return fetch(url.href);
    } else {
      return fetch(opts.url, {
        ...opts,
        body: JSON.stringify({
          ...opts.data,
          payload: this.options.payload
        })
      });
    }
  };
}
