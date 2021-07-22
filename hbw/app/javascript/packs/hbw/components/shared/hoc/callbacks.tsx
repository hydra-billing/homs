import React, {
  ComponentType, FC, useContext, useEffect, useState
} from 'react';
import { v4 as uuidv4 } from 'uuid';
import DispatcherContext, { ContextType as DispatcherContextType } from '../context/dispatcher';

type WithCallbacksProps = {
  guid: string,
  bind: (event: string, clbk: Function) => void,
  unbind: (event: string) => void,
  trigger: (event: string, payload: object | null) => void,
}

export default <P extends WithCallbacksProps>(WrappedComponent: ComponentType<P>) => {
  const WithCallbacks: FC<WithCallbacksProps> = (props) => {
    const dispatcher = useContext(DispatcherContext) as DispatcherContextType;

    const [guid] = useState(uuidv4);

    useEffect(() => () => {
      dispatcher.unbindAll(guid);
    }, []);

    const bind = (event: string, clbk: Function) => {
      dispatcher.bind(event, guid, clbk);
    };

    const unbind = (event: string) => {
      dispatcher.unbind(event, guid);
    };

    const trigger = (event: string, payload = null) => {
      dispatcher.trigger(event, this, payload);
    };

    return <WrappedComponent {...props as P}
                              guid={guid}
                              bind={bind}
                              unbind={unbind}
                              trigger={trigger} />;
  };

  return WithCallbacks;
};
