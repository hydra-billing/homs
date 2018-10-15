modulejs.define(
  'HBWTaskGroup',
  ['React',
    'HBWTask',
    'HBWCallbacksMixin'],
  (React,
    Task,
    CallbacksMixin) => React.createClass({
    mixins: [CallbacksMixin],

    getDefaultProps () {
      return {
        group:        '',
        tasks:        [],
        form_loading: false
      };
    },

    renderTask (task) {
      return <Task key={task.id}
        task={task}
        env={this.props.env}
        active={task.id == this.props.chosenTaskID}
        form_loading={this.props.form_loading}
      />;
    },

    render () {
      const tasks = [...this.props.tasks.sort((a, b) => a.id - b.id)];
      const children = tasks.map(task => this.renderTask(task));

      return <div>
        <p className="hbw-task-group-item"><b>{this.props.key}</b></p>
        <ul className="hbw-task-item">{children}</ul>
      </div>;
    }
  }));
