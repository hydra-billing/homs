import React, { useContext } from 'react';
import TranslationContext from '../context/translation';

const HBWPriority = ({ priority }) => {
  const { translate: t } = useContext(TranslationContext);

  const priorityName = (p) => {
    if (p < 50) {
      return 'medium';
    } else if (p >= 50 && p < 75) {
      return 'high';
    } else {
      return 'urgent';
    }
  };

  return (
    <span className={`badge priority ${priorityName(priority)}`}>
      {t(`components.claiming.table.priorities.${priorityName(priority)}`)}
    </span>
  );
};

export default HBWPriority;
