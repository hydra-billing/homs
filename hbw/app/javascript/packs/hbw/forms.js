modulejs.define('HBWForms', () => {
  class Forms {
    constructor (connection, entityClass) {
      this.save = this.save.bind(this);
      this.formURL = this.formURL.bind(this);

      this.whenFinished = null;

      this.connection = connection;
      this.entityClass = entityClass;
      this.forms = {};
      this.currentRequests = {};
    }

    save (params = {}) {
      return this.connection.request({
        url:    this.formURL(params.taskId),
        method: 'PUT',
        data:   {
          form_data:    params.variables,
          entity_class: this.entityClass
        },
        headers: {
          'X-CSRF-Token': params.token,
          'Content-Type': 'application/json'
        }
      });
    }

    formURL (taskId) {
      return `${this.connection.serverURL}/tasks/${taskId}/form`;
    }
  }

  return Forms;
});
