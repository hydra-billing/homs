import React from 'react';

type Props = {
  text?: string
}

const HBWPending: React.FC<Props> = ({ text = '' }) => (
  <div className="pending">
    <i className="fas fa-spinner fa-spin fa-2x" />
    {` ${text}`}
  </div>
);

export default HBWPending;
