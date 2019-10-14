import { withCallbacks } from './helpers';

modulejs.define('HBWEntityTasks', ['React', 'HBWEntityTask'], (React, Task) => {
  class HBWEntityTasks extends React.Component {
    PANEL_CLASS = 'hbw-entity-task-list-panel';

    componentWillReceiveProps (nextProps) {
      this.setState({ chosenTaskID: nextProps.chosenTaskID });
    }

    selectFirstTaskId = () => {
      if (this.props.tasks.length > 0) {
        this.props.trigger('hbw:task-clicked', this.props.tasks[0]);
        return this.props.tasks[0].id;
      } else {
        this.props.trigger('hbw:task-clicked', null);
        return null;
      }
    };

    state = {
      error:        null,
      chosenTaskID: this.props.chosenTaskID || this.selectFirstTaskId()
    };

    getProcessName = () => {
      if (this.props.tasks.length > 0) {
        return this.props.tasks[0].process_name;
      } else {
        return null;
      }
    };

    render () {
      const classes = 'hbw-entity-task-list';
      const processName = this.getProcessName();

      return <div className={classes}>
        <div className={`panel panel-group ${this.PANEL_CLASS}`}>
          {processName && <div className='process-name'>{processName}</div>}
          {this.iterateTasks(this.props.tasks, this.state.chosenTaskID)}
        </div>
      </div>;
    }

    iterateTasks = (tasks) => {
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
                     collapsed={collapsed}
                     pollTasks={this.props.pollTasks} />;
      });
    };
  }

  return withCallbacks(HBWEntityTasks);
});
