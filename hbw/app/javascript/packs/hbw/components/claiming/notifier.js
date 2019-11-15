import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withClaimingTasks } from '../helpers';

class HBWClaimingNotifier extends Component {
  static propTypes = {
    claimingTasks: PropTypes.shape({
      subscription: PropTypes.object.isRequired,
    }).isRequired,
    env: PropTypes.shape({
      translator: PropTypes.func.isRequired
    }).isRequired,
  };

  state = {
    tasks:   [],
    fetched: false,
  };

  componentDidMount () {
    const { subscription } = this.props.claimingTasks;

    subscription.progress(({ tasks }) => {
      if (this.state.fetched) {
        this.notify(tasks);
      }

      this.setState({ tasks, fetched: true });
    });
  }

  notify = (tasks) => {
    const { translator: t } = this.props.env;
    const diff = this.calcDiff(tasks);

    if (diff.length === 1) {
      Application.messenger.notice(t('notifications.new_assigned_task'));
    } else if (diff.length > 1) {
      Application.messenger.notice(t('notifications.new_assigned_task_plural', { count: diff.length }));
    }
  };

  calcDiff = (newTasks) => {
    const prevTaskIds = this.state.tasks.map(({ id }) => id);

    return newTasks.filter(({ id }) => !prevTaskIds.includes(id));
  };

  render = () => <></>
}

export default withClaimingTasks(HBWClaimingNotifier);
