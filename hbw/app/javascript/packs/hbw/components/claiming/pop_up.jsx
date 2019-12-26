import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withClaimingTasks } from 'shared/hoc';
import Tabs from 'shared/element/task_tabs';
import ShortList from './short_list';

class HBWPopUp extends Component {
  static propTypes = {
    claimingTasks: PropTypes.shape({
      subscription:       PropTypes.object.isRequired,
      updateSubscription: PropTypes.func.isRequired,
    }).isRequired,
    env:   PropTypes.object.isRequired,
    count: PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired,
    }).isRequired,
  };

  tabs = {
    my:         0,
    unassigned: 1,
  };

  state = {
    tasks:    [],
    tab:      this.tabs.my,
    fetched:  false,
    fetching: true,
  };

  componentDidMount () {
    const { subscription } = this.props.claimingTasks;

    subscription.progress(({ tasks }) => this.setState({ tasks, fetched: true, fetching: false }));
  }

  switchTabTo = (tab) => {
    if (tab !== this.state.tab) {
      this.setState({
        tasks:    [],
        fetched:  false,
        fetching: true,
        tab,
      },
      this.updateSubscription);
    }
  };

  updateSubscription = () => {
    const { tab } = this.state;
    const { claimingTasks } = this.props;

    claimingTasks.updateSubscription({
      assigned: tab === this.tabs.my,
      page:     1
    });
  };

  render () {
    const { env, count } = this.props;
    const {
      tasks, tab, fetched, fetching
    } = this.state;

    return (
      <div className="claimimg-popup">
        <Tabs env={env}
              count={count}
              tabs={this.tabs}
              activeTab={tab}
              onTabChange={this.switchTabTo}
        >
          <ShortList env={env}
                     tasks={tasks}
                     fetched={fetched}
                     fetching={fetching}
          />
        </Tabs>
      </div>
    );
  }
}

export default withClaimingTasks(HBWPopUp);
