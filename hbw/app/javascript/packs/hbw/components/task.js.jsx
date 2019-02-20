import { Component } from 'react';
import { withCallbacks } from './helpers';

modulejs.define('HBWTask', ['React'], (React) => {
  class HBWTask extends Component {
    onClick = () => {
      this.props.trigger('hbw:task-clicked', this.props.task);
    };

    render () {
      const label = `${this.props.task.entity_code} – ${this.props.task.name}`;

      if (this.props.active) {
        return <li className="hbw-active-task" onClick={this.onClick}>
          {label} {this.props.form_loading ? <span className="fas fa-spinner fa-pulse"></span> : '' }
        </li>;
      } else {
        return <li className="hbw-inactive-task" onClick={this.onClick}>{label}</li>;
      }
    }
  }

  return withCallbacks(HBWTask);
});
