import React, { createContext, ComponentType, FC } from 'react';
import Dispatcher from '../../../dispatcher';

export type ContextType = Dispatcher;

const DispatcherContext = createContext<Dispatcher | null>(null);

type InitParams = { dispatcher: Dispatcher };

export const withDispatcherContext = (
  { dispatcher }: InitParams
) => (WrappedComponent: ComponentType) => {
  const DispatcherProvider: FC = props => (
    <DispatcherContext.Provider value={dispatcher} >
      <WrappedComponent {...props} />
    </DispatcherContext.Provider >
  );

  return DispatcherProvider;
};

export default DispatcherContext;
