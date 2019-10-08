import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default WrappedComponent => class WithUnssignedTasks extends Component {
  static propTypes = {
    env: PropTypes.shape({
      poll_interval: PropTypes.number,
      connection:    PropTypes.object.isRequired,
      entity_class:  PropTypes.string.isRequired
    }).isRequired,
  };

  generateGuid = () => `hbw-${Math.floor(Math.random() * 0xFFFF)}`;

  state = {
    guid:    this.generateGuid(),
    syncing: false,
    error:   null
  };

  getComponentId = () => this.state.guid;

  componentWillMount () {
    if (!this.state.guid) {
      this.setState({ guid: this.generateGuid() });
    }
  }

  startUnassignedSubscription = (subscription) => {
    subscription.start(this.props.env.poll_interval);
  };

  closeUnassignedSubscription = (subscription) => {
    subscription.close();
  };

  createUnassignedSubscription = (firstResult, maxResults) => {
    const data = {
      entity_class: this.props.env.entity_class,
      first_result: firstResult,
      max_results:  maxResults,
      unassigned:   true
    };

    return this.props.env.connection.subscribe({
      client: this.getComponentId(),
      path:   'tasks/unassigned',
      data
    })
      .syncing(() => this.setState({ syncing: true }))
      .progress(() => this.setState({ error: null }))
      .fail(response => this.setState({ error: response }))
      .always(() => this.setState({ syncing: false }));
  };

  updateUnassignedSubscription = (subscription, firstResult, maxResults) => {
    const data = {
      entity_class: this.props.env.entity_class,
      first_result: firstResult,
      max_results:  maxResults,
      unassigned:   true
    };

    subscription.update(data);
    subscription.poll();
  }

  render () {
    return <WrappedComponent startUnassignedSubscription={this.startUnassignedSubscription}
                             closeUnassignedSubscription={this.closeUnassignedSubscription}
                             createUnassignedSubscription={this.createUnassignedSubscription}
                             updateUnassignedSubscription={this.updateUnassignedSubscription}
                             {...this.state}
                             {...this.props} />;
  }
};
