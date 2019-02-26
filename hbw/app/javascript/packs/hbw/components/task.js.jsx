import { withCallbacks } from './helpers';

modulejs.define('HBWTask', ['React'], (React) => {
  const HBWTask = (props) => {
    const label = `${props.task.entity_code} – ${props.task.name}`;

    const onClick = () => {
      props.trigger('hbw:task-clicked', props.task);
    };

    if (props.active) {
      return <li className="hbw-active-task" onClick={onClick}>
        {label} {props.form_loading ? <span className="fas fa-spinner fa-pulse" /> : '' }
      </li>;
    } else {
      return <li className="hbw-inactive-task" onClick={onClick}>{label}</li>;
    }
  };

  return withCallbacks(HBWTask);
});
