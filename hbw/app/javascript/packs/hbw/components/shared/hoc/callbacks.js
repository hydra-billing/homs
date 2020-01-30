import React, { Component } from 'react';

export default WrappedComponent => class WithCallbacks extends Component {
  guid = `hbw-${Math.floor(Math.random() * 0xFFFF)}`;

  bind = (event, clbk) => {
    this.props.env.dispatcher.bind(event, this.guid, clbk);
  };

  unbind = (event) => {
    this.props.env.dispatcher.unbind(event, this.guid);
  };

  componentWillUnmount () {
    this.props.env.dispatcher.unbindAll(this.guid);
  }

  trigger = (event, payload = null) => {
    this.props.env.dispatcher.trigger(event, this, payload);
  };

  render () {
    return <WrappedComponent guid={this.guid}
                             bind={this.bind}
                             unbind={this.unbind}
                             trigger={this.trigger}
                             {...this.state}
                             {...this.props} />;
  }
};
