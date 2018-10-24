modulejs.define(
  'HBWEntityTasks',
  ['React', 'HBWEntityTask', 'HBWCallbacksMixin'],
  (React, Task, CallbacksMixin) => React.createClass({
    PANEL_CLASS: 'hbw-entity-task-list-panel',

    mixins: [CallbacksMixin],

    getInitialState () {
      return {
        error:        null,
        chosenTaskID: this.props.chosenTaskID || this.selectFirstTaskId()
      };
    },

    componentWillReceiveProps (nextProps) {
      this.setState({ chosenTaskID: nextProps.chosenTaskID });
    },

    selectFirstTaskId () {
      if (this.props.tasks.length > 0) {
        this.trigger('hbw:task-clicked', this.props.tasks[0]);
        return this.props.tasks[0].id;
      } else {
        this.trigger('hbw:task-clicked', null);
        return null;
      }
    },

    render () {
      const classes = 'hbw-entity-task-list';
      const processName = this.getProcessName();

      return <div className={classes}>
        <div className={`panel panel-group ${this.PANEL_CLASS}`}>
          {processName && <div className='process-name'>{processName}</div>}
          {this.iterateTasks(this.props.tasks, this.state.chosenTaskID)}
        </div>
      </div>;
    },

    iterateTasks (tasks, chosenTaskID) {
      let taskAlreadyExpanded = false; // only one task should show its form - to be expanded
      const { props } = this;

      return tasks.map((task) => {
        let collapsed;
        if (taskAlreadyExpanded) {
          collapsed = true;
        } else {
          collapsed = ((task.id !== this.props.chosenTaskID) && (task.processInstanceId !== props.processInstanceId));
          taskAlreadyExpanded = !collapsed;
        }

        return <Task id={`task_id_${task.id}`}
          key={`task_id_${task.id}`}
          task={task}
          parentClass={this.PANEL_CLASS}
          env={props.env}
          taskId={task.id}
          entityCode={props.entityCode}
          entityTypeCode={props.entityTypeCode}
          entityClassCode={props.entityClassCode}
          collapsed={collapsed} />;
      });
    },

    getProcessName () {
      if (this.props.tasks.length > 0) {
        return this.props.tasks[0].process_name;
      } else {
        return null;
      }
    }
  }));
