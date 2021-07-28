import React, { createContext, ComponentType, FC } from 'react';
import Connection from '../../../connection';

export type ContextType = {
  options: {
    host: string,
    path: string
  },
  request: Function,
  serverURL: string
}

const ConnectionContext = createContext<ContextType | null>(null);

type InitParams = {
  connection: Connection
}

export const withConnectionContext = (
  { connection }: InitParams
) => (WrappedComponent: ComponentType) => {
  const ConnectionProvider: FC = props => (
      <ConnectionContext.Provider value={connection} >
        <WrappedComponent {...props} />
      </ConnectionContext.Provider >
  );

  return ConnectionProvider;
};

export default ConnectionContext;
