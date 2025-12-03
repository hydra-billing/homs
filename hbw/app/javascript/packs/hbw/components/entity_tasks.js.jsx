import React, { Component } from 'react';
import { withCallbacks } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import Task from './entity_task.js';

class EntityTasks extends Component {
  PANEL_CLASS = 'hbw-entity-task-list-panel';

  static contextType = TranslationContext;

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
    error: null
  };

  getProcessName = () => {
    const { tasks } = this.props;

    if (tasks.length > 0) {
      return this.context.translateBP(`${tasks[0].process_key}.label`, {}, tasks[0].process_name);
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
        {this.iterateTasks(this.props.tasks)}
      </div>
    </div>;
  }

  iterateTasks (tasks) {
    const {
      entityCode, entityTypeCode, entityClassCode
    } = this.props;

    return tasks.map(task => <Task id={`task_id_${task.id}`}
                                   key={`task_id_${task.id}`}
                                   task={task}
                                   parentClass={this.PANEL_CLASS}
                                   taskId={task.id}
                                   entityCode={entityCode}
                                   entityTypeCode={entityTypeCode}
                                   entityClassCode={entityClassCode} />);
  }
}

const EntityTasksWrapped = withCallbacks(EntityTasks);

export default EntityTasksWrapped;
