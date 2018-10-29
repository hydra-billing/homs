modulejs.define(
  'HBWMenuButton',
  ['React', 'ReactDOM', 'HBWCallbacksMixin', 'HBWTasksMixin'],
  (React, ReactDOM, CallbacksMixin, TasksMixin) => React.createClass({
    mixins: [CallbacksMixin, TasksMixin],

    displayName: 'HBWMenuButton',

    getInitialState () {
      return { tasksNumber: 0 };
    },

    toggleVisibility () {
      this.setState({ visible: !this.state.visible });
    },

    componentDidMount () {
      this.bind('hbw:hide-widget', this.toggleVisibility);
      this.state.subscription
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
      this.trigger('hbw:toggle-tasks-menu');
    }
  })
);
