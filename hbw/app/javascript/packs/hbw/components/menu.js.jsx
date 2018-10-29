modulejs.define(
  'HBWMenu',
  ['React', 'HBWTaskList', 'HBWCallbacksMixin'],
  (React, TaskList, CallbacksMixin) => React.createClass({
    mixins: [CallbacksMixin],

    displayName: 'HBWMenu',

    getInitialState () {
      return { visible: false };
    },

    toggleVisibility () {
      this.setState({ visible: !this.state.visible });
    },

    componentDidMount () {
      this.bind('hbw:toggle-tasks-menu', this.toggleVisibility);
    },

    render () {
      return <div>
        { this.props.renderButton
          && <div className='hbw-launcher' onClick={this.toggleVisibility}>
            <div className='hbw-launcher-button btn-primary'>
            </div>
          </div> }
        { this.state.visible ? <TaskList env={this.props.env}
          chosenTaskID={this.props.chosenTaskID} /> : null }
      </div>;
    }
  })
);
