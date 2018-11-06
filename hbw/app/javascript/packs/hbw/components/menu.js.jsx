import { withCallbacks } from './helpers';

modulejs.define('HBWMenu', ['React', 'HBWTaskList'], (React, TaskList) => {
  const Menu = React.createClass({
    displayName: 'HBWMenu',

    getInitialState () {
      return { visible: false };
    },

    toggleVisibility () {
      this.setState({ visible: !this.state.visible });
    },

    componentDidMount () {
      this.props.bind('hbw:toggle-tasks-menu', this.toggleVisibility);
    },

    render () {
      return <div>
        { this.props.renderButton &&
        <div className='hbw-launcher' onClick={this.toggleVisibility}>
          <div className='hbw-launcher-button btn-primary'>
          </div>
        </div> }
        { this.state.visible ? <TaskList env={this.props.env}
                                         chosenTaskID={this.props.chosenTaskID} /> : null }
      </div>;
    }
  });

  return withCallbacks(Menu);
});
