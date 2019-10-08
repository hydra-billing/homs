import React from 'react';

const HBWPriority = ({ env, priority }) => {
  const { translator: t } = env;

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
