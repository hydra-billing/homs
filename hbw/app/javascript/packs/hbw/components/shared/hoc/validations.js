import React from 'react';

export default WrappedComponent => (props) => {
  const isFilled = value => (value !== null && value !== undefined && `${value}`.length > 0);

  const isValid = value => props.params.nullable || isFilled(value);

  return <WrappedComponent isValid={isValid}
                           {...props} />;
};
