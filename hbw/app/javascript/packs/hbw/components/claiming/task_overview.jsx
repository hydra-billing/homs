import React from 'react';
import PropTypes from 'prop-types';
import Priority from './shared/priority';

const HBWClaimingTaskOverview = ({
  env, assigned, entityUrl, task, claimAndPollTasks, closeTask
}) => {
  const { translator: t, localizer } = env;

  const goToTask = () => { window.location.href = entityUrl; };

  const claimAndClose = async () => {
    await claimAndPollTasks(task);
    closeTask();
  };

  const claimAndGo = async () => {
    await claimAndPollTasks(task);
    goToTask();
  };

  return (
    <div className="task-overview">
      <div className="bold header">
        {t('components.claiming.overview.header')}
      </div>
      {task.icon && (
        <div className="title">
          <span className={task.icon} />
          {task.name}
        </div>
      )}
      <table className="two-cols">
        <tbody>
          {task.due && (
            <tr>
              <td>{t('components.claiming.overview.due')}</td>
              <td>{localizer.localizeDatetime(task.due)}</td>
            </tr>
          )}
          <tr>
            <td>{t('components.claiming.overview.created')}</td>
            <td>{localizer.localizeDatetime(task.created)}</td>
          </tr>
          <tr>
            <td>{t('components.claiming.overview.priority')}</td>
            <td><Priority env={env} priority={task.priority} /></td>
          </tr>
        </tbody>
      </table>
      <div className="bold">{t('components.claiming.overview.description')}</div>
      <div className="description">{task.description}</div>
      <div className="buttons">
        {assigned && (
          <button onClick={goToTask}
                  className='claim-button-secondary'>{t('components.claiming.overview.go_to_task')}
          </button>
        )}
        {!assigned && (
          <>
            <button onClick={claimAndClose}
                    className='claim-button-primary'>{t('components.claiming.overview.claim_task')}
            </button>
            <button onClick={claimAndGo}
                    className='claim-button-secondary'>{t('components.claiming.overview.claim_and_open')}
            </button>
          </>
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
    created:     PropTypes.string.isRequired,
    icon:        PropTypes.string,
    due:         PropTypes.string,
    description: PropTypes.string,
  }).isRequired,
  claimAndPollTasks: PropTypes.func.isRequired,
  closeTask:         PropTypes.func.isRequired,
};

export default HBWClaimingTaskOverview;
