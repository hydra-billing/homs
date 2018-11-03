modulejs.define('HBWTask', ['React', 'HBWCallbacksMixin'], (React, CallbacksMixin) => React.createClass({
  mixins: [CallbacksMixin],

  displayName: 'HBWTask',

  onClick () {
    this.trigger('hbw:task-clicked', this.props.task);
  },

  render () {
    const label = `${this.props.task.entity_code} – ${this.props.task.name}`;

    if (this.props.active) {
      return <li className="hbw-active-task" onClick={this.onClick}>
        {label} {this.props.form_loading ? <span className="fa fa-spinner fa-pulse"></span> : '' }
      </li>;
    } else {
      return <li className="hbw-inactive-task" onClick={this.onClick}>{label}</li>;
    }
  }
}));
