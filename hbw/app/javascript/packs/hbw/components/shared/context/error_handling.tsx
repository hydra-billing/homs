import Messenger from 'messenger';
import React, {
  createContext, ComponentType, FC, useState, useCallback, useContext
} from 'react';
import HBWError from '../../error';
import TranslationContext, { ContextType as TranslationContextType } from './translation';
import ConnectionContext, { ContextType as ConnectionContextType } from './connection';
import { CamundaError, WidgetErrorType } from '../utils/errors';

export type ContextType = {
  addError: Function,
  formError: React.JSX.Element,
  safeRequest: Function
}

const ErrorHandlingContext = createContext<ContextType | null>(null);

export const withErrorHandlingContext = () => (WrappedComponent: ComponentType) => {
  const ErrorHandlingProvider: FC = (props) => {
    const { translate: t } = useContext(TranslationContext) as TranslationContextType;
    const { request } = useContext(ConnectionContext) as ConnectionContextType;

    const [formError, setFormError] = useState<React.JSX.Element>(() => <HBWError/>);

    const notify = useCallback((error: WidgetErrorType) => {
      // @ts-ignore
      Messenger[error.level](t(error.notificationText, {}, error.notificationText));
    }, [t]);

    const setupFormError = useCallback((error: WidgetErrorType) => {
      setFormError(
        <HBWError
          errorHeader={t(error.header, {}, error.header)}
          errorBody={error.body}
        />,
      );
    }, [t]);

    const addError = useCallback((error: WidgetErrorType) => {
      if (error.level === 'error') {
        setupFormError(error);
      }
      if (error.notificationText) {
        notify(error);
      }
    }, [notify, setupFormError]);

    const safeRequest = (opts: {}) => (
      request(opts)
        .then((response: Response) => {
          if (response.status === 504) {
            addError(CamundaError);
          }
          return response;
        }));

    return (
      <ErrorHandlingContext.Provider value={{
        addError,
        formError,
        safeRequest,
      }}>
        <WrappedComponent {...props} />
      </ErrorHandlingContext.Provider>
    );
  };

  return ErrorHandlingProvider;
};

export default ErrorHandlingContext;
