import jQuery from 'jquery';

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

  request = opts => (
    jQuery.ajax({
      ...opts,
      data: {
        ...opts.data,
        payload: this.options.payload
      }
    })
  );
}
