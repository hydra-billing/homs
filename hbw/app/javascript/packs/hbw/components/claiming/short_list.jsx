import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { parseISO, isPast } from 'date-fns';

const HBWClaimingShortList = ({ env, tasks }) => {
  const { translator: t, connection, taskListPath } = env;

  const viewAll = () => { window.location.href = `${connection.options.host}/${taskListPath}`; };
  const goToTask = (entityUrl) => { window.location.href = entityUrl; };
  const rowCN = due => (
    cx({
      row:     true,
      expired: isPast(parseISO(due))
    })
  );

  return (
    <div className="short-list">
      {tasks.map(({
        id, icon, name, due, created, entityUrl
      }) => (
        <div onClick={() => goToTask(entityUrl)} key={id} className={rowCN(due)}>
          <div className="left">
            <i className={icon} />
            <span className="title">{name}</span>
          </div>
          <div className="right">
            <span className="created">{due || created}</span>
          </div>
        </div>
      ))}
      <div className="button">
        <button onClick={viewAll} className='claim-button-primary'>
          {t('components.claiming.short_list.view_all')}
        </button>
      </div>
    </div>
  );
};

HBWClaimingShortList.propTypes = {
  env:   PropTypes.object.isRequired,
  tasks: PropTypes.arrayOf(PropTypes.shape({
    id:        PropTypes.string.isRequired,
    name:      PropTypes.string.isRequired,
    icon:      PropTypes.string.isRequired,
    entityUrl: PropTypes.string.isRequired,
    created:   PropTypes.string.isRequired,
    due:       PropTypes.string,
  })).isRequired,
};

export default HBWClaimingShortList;
