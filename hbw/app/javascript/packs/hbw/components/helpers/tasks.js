import React, { Component } from 'react';

export default WrappedComponent => class WithTasks extends Component {
  constructor (props, context) {
    super(props, context);
    this.setGuid();

    this.state = {
      subscription: this.createSubscription(),
      pollInterval: 5000,
      syncing:      false,
      error:        null
    };
  }

  setGuid = () => {
    this.guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;
  };

  getComponentId = () => this.guid;

  componentWillMount () {
    if (!this.guid) {
      this.setGuid();
    }
  }

  componentDidMount () {
    this.state.subscription.start(this.props.pollInterval);
  }

  componentWillUnmount () {
    this.state.subscription.close();
  }

  createSubscription = () => {
    let data;

    if (this.props.env.fetch_all) {
      data = {
        entity_class: this.props.env.entity_class
      };
    } else {
      data = {
        entity_class: this.props.env.entity_class,
        entity_code:  this.props.env.entity_code
      };
    }

    return this.props.env.connection.subscribe({
      client: this.getComponentId(),
      path:   'tasks',
      data
    })
      .syncing(() => this.setState({ syncing: true }))
      .progress(() => this.setState({ error: null }))
      .fail(response => this.setState({ error: response }))
      .always(() => this.setState({ syncing: false }));
  };

  render () {
    return <WrappedComponent setGuid={this.setGuid}
                             getComponentId={this.getComponentId}
                             createSubscription={this.createSubscription}
                             {...this.state}
                             {...this.props} />;
  }
};
