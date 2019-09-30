import { withCallbacks, withTasks, compose } from './helpers';

modulejs.define('HBWMenuButton', ['React'], (React) => {
  class HBWMenuButton extends React.Component {
    state = { tasksNumber: 0 };

    toggleVisibility = () => {
      this.setState({ visible: !this.state.visible });
    };

    componentDidMount () {
      this.props.bind('hbw:hide-widget', this.toggleVisibility);
      this.props.subscription
        .progress(data => this.setState({ tasksNumber: data.task_count }));
    }

    render () {
      const counter = this.state.tasksNumber ? <span className="counter">{this.state.tasksNumber}</span> : '';

      return <a ref={(node) => { this.rootNode = node; }}
                onClick={this.toggleMenu}
                className="hbw-menu-button fas fa-bars">
        {counter}
      </a>;
    }

    toggleMenu = (e) => {
      e.preventDefault();

      this.rootNode.blur();
      this.props.trigger('hbw:toggle-tasks-menu');
    };
  }

  return compose(withTasks, withCallbacks)(HBWMenuButton);
});
