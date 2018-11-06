import React from 'react';
import { getDisplayName } from './utils';

export default WrappedComponent => React.createClass({
  displayName: `WithCallbacks(${getDisplayName(WrappedComponent)})`,

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

  bind (event, clbk) {
    this.props.env.dispatcher.bind(event, this.getComponentId(), clbk);
  },

  unbind (event) {
    this.props.env.dispatcher.unbind(event, this.getComponentId());
  },

  componentWillUnmount () {
    this.props.env.dispatcher.unbindAll(this.getComponentId());
  },

  trigger (event, payload = null) {
    this.props.env.dispatcher.trigger(event, this, payload);
  },

  render () {
    return <WrappedComponent setGuid={this.setGuid}
                             getComponentId={this.getComponentId}
                             bind={this.bind}
                             unbind={this.unbind}
                             trigger={this.trigger}
                             {...this.state}
                             {...this.props} />;
  }
});
