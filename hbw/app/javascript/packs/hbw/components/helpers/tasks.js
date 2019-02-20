/* eslint-disable no-shadow */
import React, { Component } from 'react';


const withTasks = (WrappedComponent) => {
  class WithTasks extends Component {
    constructor (props) {
      super(props);

      this.setGuid();
      this.state = {
        subscription: this.createSubscription(),
        pollInterval: 5000,
        syncing: false,
        error: null
      };
    }

    componentDidMount () {
      this.state.subscription.start(this.props.pollInterval);
    };

    componentWillUnmount () {
      this.state.subscription.close();
    };

    setGuid = () => {
      this.guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;
    };

    getComponentId = () => {
      return this.guid;
    };

    createSubscription = () => {
      return this.props.env.connection.subscribe({
        client: this.getComponentId(),
        path: 'tasks',
        data: {
          entity_class: this.props.env.entity_class
        }
      })
        .syncing(() => this.setState({syncing: true}))
        .progress(() => this.setState({error: null}))
        .fail(response => this.setState({error: response}))
        .always(() => this.setState({syncing: false}));
    };

    render() {
      return <WrappedComponent setGuid={this.setGuid}
                               getComponentId={this.getComponentId}
                               createSubscription={this.createSubscription}
                               {...this.state}
                               {...this.props} />;
    }
  }

  return WithTasks;
};

export default withTasks;