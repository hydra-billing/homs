import React from 'react';
import PropTypes from 'prop-types';
import Priority from './priority';

const HBWClaimingTaskOverview = ({
  env, assigned, entityUrl, task
}) => {
  const { translator: t, localizeDate: l } = env;

  const goToTask = () => { window.location.href = entityUrl; };

  const claimTask = async () => (
    env.connection.request({
      url:    `${env.connection.serverURL}/tasks/${task.id}/claim`,
      method: 'POST'
    })
    // Fire event (or call callback) here to change task state in the list
  );

  const claimAndGo = async () => {
    await claimTask();
    goToTask();
  };

  return (
    <div className="task-overview">
      <div className="bold header">
        {t('components.claiming.overview.header')}
      </div>
      <div className="title">
        <span className={task.icon} />
        {task.name}
      </div>
      <div className='two-cols'>
        <div className="name">
          <p>{task.due && t('components.claiming.overview.due')}</p>
          <p>{t('components.claiming.overview.created')}</p>
          <p>{assigned && t('components.claiming.overview.claimed')}</p>
          <p>{t('components.claiming.overview.priority')}</p>
        </div>
        <div className="value">
          <p>{task.due && l(task.due)}</p>
          <p>{l(task.created)}</p>
          <p>{assigned && l(task.claimed)}</p>
          <p><Priority env={env} priority={task.priority} /></p>
        </div>
      </div>
      <div className="bold">{t('components.claiming.overview.description')}</div>
      <div className="description">{task.description}</div>
      <div className="buttons">
        {assigned && (
          <button onClick={goToTask}
                  className='claim-button'>{t('components.claiming.overview.go_to_task')}
          </button>
        )}
        {!assigned && (
          <button onClick={claimTask}
                  className='claim-button'>{t('components.claiming.overview.claim_task')}
          </button>
        )}
        {!assigned && (
          <button onClick={claimAndGo}
                  className='claim-button'>{t('components.claiming.overview.claim_and_open')}
          </button>
        )}
      </div>
    </div>
  );
};

HBWClaimingTaskOverview.propTypes = {
  env:       PropTypes.object.isRequired,
  assigned:  PropTypes.bool.isRequired,
  entityUrl: PropTypes.string.isRequired,
  task:      PropTypes.shape({
    id:          PropTypes.string.isRequired,
    priority:    PropTypes.number.isRequired,
    name:        PropTypes.string.isRequired,
    icon:        PropTypes.string.isRequired,
    processName: PropTypes.string.isRequired,
    created:     PropTypes.string.isRequired,
    claimed:     PropTypes.string,
    due:         PropTypes.string,
    description: PropTypes.string,
  }).isRequired,
};

export default HBWClaimingTaskOverview;
