import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withTasksCount } from '../helpers';

class HBWClaimingMenuButton extends Component {
  static propTypes = {
    subscription: PropTypes.object.isRequired
  };

  state = {
    myTasksCount: 0,
    unassignedTasksCount: 0
   };

  componentDidMount () {
    const { subscription } = this.props;

    subscription
      .progress(({ task_count, task_count_unassigned }) => this.setState({ myTasksCount: task_count, unassignedTasksCount: task_count_unassigned }));
  }

  render () {
    const { myTasksCount, unassignedTasksCount } = this.state;

    return (
      <div className="claiming-menu-button">
        <span>
          {myTasksCount}/{unassignedTasksCount}
        </span>
      </div>
    );
  }
};

export default withTasksCount(HBWClaimingMenuButton);
