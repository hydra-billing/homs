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
      // Mutating requests from a same-origin page (widget embedded into HOMS UI)
      // are subject to Rails CSRF protection; the token comes from the layout's
      // csrf_meta_tags. Pages of proxying integrations have no such meta tag —
      // their backends authenticate with the Authorization header and are
      // exempted from CSRF server-side.
      const csrfMeta = document.querySelector('meta[name="csrf-token"]');

      return fetch(opts.url, {
        ...opts,
        headers: {
          ...(csrfMeta ? { 'X-CSRF-Token': csrfMeta.content } : {}),
          ...opts.headers
        },
        body: JSON.stringify({
          ...opts.data,
          payload: this.options.payload
        })
      });
    }
  };
}
