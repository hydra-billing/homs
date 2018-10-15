modulejs.define(
  'HBWMenuButton',
  ['React', 'ReactDOM', 'HBWCallbacksMixin', 'HBWTasksMixin'],
  (React, ReactDOM, CallbacksMixin, TasksMixin) => React.createClass({
    mixins: [CallbacksMixin, TasksMixin],

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
      return <a href="javascript:;" onClick={this.toggleMenu} className="hbw-menu-button fa fa-reorder">
        {this.state.tasksNumber && <span className="counter">{this.state.tasksNumber}</span> || ''}
      </a>;
    },

    toggleMenu () {
      ReactDOM.findDOMNode(this).blur();
      this.trigger('hbw:toggle-tasks-menu');
    }
  }));
