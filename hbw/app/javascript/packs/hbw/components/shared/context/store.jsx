/* eslint-disable no-console */
import React, { Component, createContext } from 'react';
import ActionCable from 'actioncable';

export const StoreContext = createContext({});
export const { Consumer: StoreConsumer } = StoreContext;

const withStoreContext = (WrappedComponent) => {
  class StoreProvider extends Component {
    state = {
      tasks:    [],
      fetching: true,
      ready:    false,
      socket:   null
    };

    componentDidMount () {
      const ws = ActionCable.createConsumer('ws://127.0.0.1:3000/cable');
      ws.subscriptions.create({ channel: 'TaskChannel' }, {
        connected: () => {
          console.log('Connected!');
        },
        received: (data) => {
          console.log(data);
        }
      });

      this.setState({ socket: ws });
    }

    updateContext = (...state) => {
      this.setState(...state);
    };

    render () {
      const contextValue = {
        ...this.state,
        update: this.updateContext,
      };

      return (
        <StoreContext.Provider value={contextValue}>
          <WrappedComponent {...this.props} />
        </StoreContext.Provider>
      );
    }
  }

  return StoreProvider;
};

export default withStoreContext;
