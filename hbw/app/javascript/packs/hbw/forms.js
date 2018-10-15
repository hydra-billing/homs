/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
modulejs.define('HBWForms', ['jQuery'], (jQuery) => {
  class Forms {
    onStart () {}
    onFinish () {}

    constructor (connection, entityClass) {
      this.start = this.start.bind(this);
      this.finish = this.finish.bind(this);
      this.fetch = this.fetch.bind(this);
      this.save = this.save.bind(this);
      this.formURL = this.formURL.bind(this);
      this.currentRequestsList = this.currentRequestsList.bind(this);
      this.trackRequest = this.trackRequest.bind(this);
      this._registerRequest = this._registerRequest.bind(this);
      this._pushRequest = this._pushRequest.bind(this);
      this._popRequest = this._popRequest.bind(this);
      this._wrapWithDeferred = this._wrapWithDeferred.bind(this);

      this.whenFinished = null;

      this.connection = connection;
      this.entityClass = entityClass;
      this.forms = {};
      this.currentRequests = {};
    }

    start (clbk) {
      this.onStart = clbk;
    }

    finish (clbk) {
      this.onFinish = clbk;
    }

    fetch (taskId, options = {}) {
      const existing = this.forms[taskId];

      if (existing && !options.force) {
        return this._wrapWithDeferred(existing);
      } else {
        return this.trackRequest(
          taskId,
          this.connection
            .request({
              url:  this.formURL(taskId),
              data: {
                entity_class: this.entityClass
              }
            })
            .done(form => this.forms[taskId] = form));
      }
    }

    save (params = {}) {
      return this.connection.request({
        url:         this.formURL(params.taskId),
        method:      'PUT',
        contentType: 'application/json',
        data:        JSON.stringify({
          form_data:    params.variables,
          entity_class: this.entityClass
        }),
        headers: {
          'X-CSRF-Token': params.token
        }
      });
    }

    formURL (taskId) {
      return `${this.connection.serverURL}/tasks/${taskId}/form`;
    }

    currentRequestsList () {
      return jQuery.map(this.currentRequests, (val, _) => val);
    }

    trackRequest (taskId, request) {
      if (jQuery.isEmptyObject(this.currentRequests)) {
        this.onStart();
      }

      this._registerRequest(taskId, request);

      this.whenFinished = jQuery.when.apply(this.currentRequestsList());

      (deferred => deferred.then(() => {
        if (deferred === this.whenFinished) {
          return this.onFinish();
        }
      }))(this.whenFinished);

      return request;
    }

    _registerRequest (taskId, request) {
      this._pushRequest(taskId, request);
      return request.done(() => this._popRequest(taskId));
    }

    _pushRequest (taskId, request) {
      return this.currentRequests[taskId] = request;
    }

    _popRequest (taskId) {
      const request = this.currentRequests[taskId];
      delete this.currentRequests[taskId];
      return request;
    }

    _wrapWithDeferred (value) {
      return (new jQuery.Deferred()).resolve(value);
    }
  }

  return Forms;
});
