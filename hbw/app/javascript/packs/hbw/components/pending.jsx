import React from 'react';

const HBWPending = ({ text = '' }) => (<div className="pending">
    <i className="fas fa-spinner fa-spin fa-2x" />
    {` ${text}`}
  </div>);

export default HBWPending;
