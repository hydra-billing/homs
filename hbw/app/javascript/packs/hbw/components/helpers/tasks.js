import React from 'react';

import { getDisplayName } from './utils';

export default WrappedComponent => React.createClass({
  displayName: `WithTasks(${getDisplayName(WrappedComponent)})`,

  setGuid () {
    this.guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;
  },

  getComponentId () {
    return this.guid;
  },

  componentWillMount () {
    if (!this.guid) {
      this.setGuid();
    }
  },

  getInitialState () {
    this.setGuid();
    return {
      subscription: this.createSubscription(),
      pollInterval: 5000,
      syncing:      false,
      error:        null
    };
  },

  componentDidMount () {
    this.state.subscription.start(this.props.pollInterval);
  },

  componentWillUnmount () {
    this.state.subscription.close();
  },

  createSubscription () {
    return this.props.env.connection.subscribe({
        client: this.getComponentId(),
        path:   'tasks',
        data: {
          entity_class: this.props.env.entity_class
        }
      })
      .syncing(() => this.setState({ syncing: true }))
      .progress(() => this.setState({ error: null }))
      .fail(response => this.setState({ error: response }))
      .always(() => this.setState({ syncing: false }));
  },

  render () {
    return <WrappedComponent setGuid={this.setGuid}
                             getComponentId={this.getComponentId}
                             createSubscription={this.createSubscription}
                             {...this.state}
                             {...this.props} />
  }
});
