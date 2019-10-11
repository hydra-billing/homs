import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default WrappedComponent => class WithTasksCount extends Component {
  static propTypes = {
    env: PropTypes.shape({
      poll_interval: PropTypes.number,
      connection:    PropTypes.object.isRequired,
      entity_class:  PropTypes.string.isRequired
    }).isRequired
  };

  guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;

  createSubscription = () => {
    const { env } = this.props;

    const data = {
      entity_class: env.entity_class
    };

    return env.connection.subscribe({
      client: this.guid,
      path:   'tasks/count',
      data
    })
      .syncing(() => this.setState({ syncing: true }))
      .progress(() => this.setState({ error: null }))
      .fail(response => this.setState({ error: response }))
      .always(() => this.setState({ syncing: false }));
  };

  state = {
    subscription: this.createSubscription(),
    syncing:      false,
    error:        null
  };

  componentDidMount () {
    this.state.subscription.start(this.props.env.poll_interval);
  }

  componentWillUnmount () {
    this.state.subscription.close();
  }

  render () {
    return <WrappedComponent {...this.state} {...this.props} />;
  }
};
