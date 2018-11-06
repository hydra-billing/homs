import { withCallbacks, withTasks, compose } from './helpers';

modulejs.define('HBWMenuButton', ['React'], (React) => {
  const MenuButton = React.createClass({
    displayName: 'HBWMenuButton',

    getInitialState () {
      return { tasksNumber: 0 };
    },

    toggleVisibility () {
      this.setState({ visible: !this.state.visible });
    },

    componentDidMount () {
      this.props.bind('hbw:hide-widget', this.toggleVisibility);
      this.props.subscription
        .progress(data => this.setState({ tasksNumber: data.tasks.length }));
    },

    render () {
      const counter = this.state.tasksNumber ? <span className="counter">{this.state.tasksNumber}</span> : '';

      return <a ref={(node) => { this.rootNode = node; }}
                onClick={this.toggleMenu}
                className="hbw-menu-button fa fa-reorder">
        {counter}
      </a>;
    },

    toggleMenu (e) {
      e.preventDefault();

      this.rootNode.blur();
      this.props.trigger('hbw:toggle-tasks-menu');
    }
  });

  return compose(withTasks, withCallbacks)(MenuButton);
});
