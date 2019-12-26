import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withTasksCount } from 'shared/hoc';
import HydraIcon from 'shared/element/icon';
import PopUp from './pop_up';
import ClaimingNotifier from './notifier';

class HBWClaimingMenuButton extends Component {
  static propTypes = {
    taskCount: PropTypes.shape({
      subscription: PropTypes.object.isRequired,
    }).isRequired,
    env: PropTypes.object.isRequired,
  };

  state = {
    myTasksCount:         0,
    unassignedTasksCount: 0,
    isOpen:               false
  };

  rootDiv = React.createRef();

  componentDidMount () {
    const { subscription } = this.props.taskCount;

    window.addEventListener('mousedown', this.handleClickOutside);

    subscription.progress(({ task_count: myTasksCount, task_count_unassigned: unassignedTasksCount }) => {
      this.setState({ myTasksCount, unassignedTasksCount });
    });
  }

  componentWillUnmount () {
    window.removeEventListener('mousedown', this.handleClickOutside);
  }

  handleClickOutside = ({ target }) => {
    if (!this.rootDiv.current.contains(target)) {
      this.setState({ isOpen: false });
    }
  };

  handlePopUp = () => {
    this.setState(prevState => ({ isOpen: !prevState.isOpen }));
  };

  render () {
    const { env } = this.props;
    const { myTasksCount, unassignedTasksCount, isOpen } = this.state;

    const count = {
      my:         myTasksCount,
      unassigned: unassignedTasksCount,
    };

    return (
      <>
        <div className="claiming-menu-button-container" ref={this.rootDiv}>
          <div className="claiming-menu-button" onClick={this.handlePopUp}>
            <HydraIcon />
            <span className="claiming-count">
              {myTasksCount}/{unassignedTasksCount}
            </span>
          </div>
          {isOpen && <PopUp perPage={10} env={this.props.env} count={count} />}
        </div>
        <ClaimingNotifier perPage={400} env={env} />
      </>
    );
  }
}

export default withTasksCount(HBWClaimingMenuButton);
