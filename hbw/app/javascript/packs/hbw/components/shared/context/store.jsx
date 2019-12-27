import React, { Component, createContext } from 'react';

export const StoreContext = createContext({});
export const { Consumer: StoreConsumer } = StoreContext;

const withStoreContext = (WrappedComponent) => {
  class StoreProvider extends Component {
    state = {
      tasks:    [],
      fetching: true,
      ready:    false,
    };

    // componentDidMount () {
    //   fetch initial state here
    // }

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
