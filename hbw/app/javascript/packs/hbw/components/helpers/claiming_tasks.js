import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default WrappedComponent => class WithClaimingTasks extends Component {
  static propTypes = {
    env: PropTypes.shape({
      poll_interval: PropTypes.number,
      connection:    PropTypes.object.isRequired,
      entity_class:  PropTypes.string.isRequired
    }).isRequired,
    perPage: PropTypes.number.isRequired,
  };

  guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;

  createSubscription = () => {
    const { env, perPage } = this.props;

    const data = {
      entity_class: env.entity_class,
      max_results:  perPage,
      assigned:     true
    };

    return env.connection.subscribe({
      client: this.guid,
      path:   'tasks/claiming',
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

  updateSubscription = ({ page, searchQuery, assigned }) => {
    const { subscription } = this.state;
    const { env, perPage } = this.props;

    const data = {
      entity_class: env.entity_class,
      max_results:  page * perPage,
      search_query: searchQuery,
      assigned
    };

    subscription.update(data);
    subscription.poll();
  };


  claimAndPollTasks = async (task) => {
    const { subscription } = this.state;
    const { connection } = this.props.env;

    await connection.request({
      url:    `${connection.serverURL}/tasks/${task.id}/claim`,
      method: 'POST'
    });

    await subscription.poll();
  };

  render () {
    const claimingTasks = {
      ...this.state,
      updateSubscription: this.updateSubscription,
      claimAndPollTasks:  this.claimAndPollTasks
    };

    return <WrappedComponent claimingTasks={claimingTasks}
                             {...this.props} />;
  }
};
