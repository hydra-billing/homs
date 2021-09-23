import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

type Props = {
  text?: string
}

const HBWPending: React.FC<Props> = ({ text = '' }) => (
  <div className="pending">
    <FontAwesomeIcon icon={['fas', 'spinner']} size="2x" spin />
    {` ${text}`}
  </div>
);

export default HBWPending;
