import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { parseISO, isPast } from 'date-fns';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import DueDate from 'shared/element/due_date';
import CreatedDate from 'shared/element/created_date';
import TranslationContext from 'shared/context/translation';
import ConnectionContext from 'shared/context/connection';
import Pending from '../pending';

const HBWClaimingShortList = ({
  tasks, fetched, fetching, taskListPath
}) => {
  const { translate, translateBP } = useContext(TranslationContext);
  const connection = useContext(ConnectionContext);

  const viewAll = () => { window.location.href = `${connection.options.host}/${taskListPath}`; };
  const goToTask = (entityUrl) => { window.location.href = entityUrl; };

  const renderDate = (created, due) => {
    const now = new Date();

    if (due) {
      return <span className="deadline"><DueDate dateISO={due} now={now} /></span>;
    } else {
      return <span><CreatedDate dateISO={created} now={now} /></span>;
    }
  };

  const rowCN = due => (
    cx({
      row:     true,
      expired: due !== null ? isPast(parseISO(due)) : false
    })
  );

  const renderNoTasks = () => (
    <div className='no-tasks'>
      <span>
        {translate('components.claiming.table.empty_tasks')}
      </span>
    </div>
  );

  return (
    <div className="short-list">
      {tasks.map(({
        id, key, process_key, icon, name, due, created, entity_url, description
      }) => (
        <div onClick={() => goToTask(entity_url)} key={id} className={rowCN(due)}>
          <div className="left">
            <FontAwesomeIcon icon={icon} />
            <span className="title">{translateBP(`${process_key}.${key}.label`, {}, name)}</span>
            <span title={description} className="description">{description}</span>
          </div>
          <div className="right">
            {renderDate(created, due)}
          </div>
        </div>
      ))}
      {fetching && <Pending />}
      {fetched && tasks.length === 0 && renderNoTasks()}
      <div className="button">
        <button onClick={viewAll} className='btn btn-primary'>
          {translate('components.claiming.short_list.view_all')}
        </button>
      </div>
    </div>
  );
};

HBWClaimingShortList.propTypes = {
  fetched:      PropTypes.bool.isRequired,
  fetching:     PropTypes.bool.isRequired,
  taskListPath: PropTypes.string.isRequired,
  tasks:        PropTypes.arrayOf(PropTypes.shape({
    id:         PropTypes.string.isRequired,
    name:       PropTypes.string.isRequired,
    icon:       PropTypes.array.isRequired,
    entity_url: PropTypes.string.isRequired,
    created:    PropTypes.string.isRequired,
    due:        PropTypes.string,
  })).isRequired,
};

export default HBWClaimingShortList;
