import React from 'react';

export default WrappedComponent => (props) => {
  const isAvailable = !props.hidden && !props.disabled;

  const isFilled = value => (value !== null && value !== undefined && `${value}`.length > 0);

  const isValid = value => !isAvailable || props.params.nullable || isFilled(value);

  return <WrappedComponent isValid={isValid}
                           isAvailable={isAvailable}
                           {...props} />;
};
