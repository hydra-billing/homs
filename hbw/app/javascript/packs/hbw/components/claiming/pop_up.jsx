import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { StoreContext } from 'shared/context/store';
import Tabs from 'shared/element/task_tabs';
import ShortList from './short_list';

class HBWPopUp extends Component {
  static contextType = StoreContext;

  static propTypes = {
    env: PropTypes.object.isRequired,
  };

  listSize = 10;

  tabs = {
    my:         0,
    unassigned: 1,
  };

  state = {
    tab: this.tabs.my,
  };

  switchTabTo = (tab) => {
    if (tab !== this.state.tab) {
      this.setState({ tab });
    }
  };

  isMyTab = () => this.state.tab === this.tabs.my;

  tasksForCurrentTab = () => {
    const { myTasks, unassignedTasks } = this.context;

    return (this.isMyTab() ? myTasks : unassignedTasks).slice(0, this.listSize);
  };

  render () {
    const { env } = this.props;
    const { count, fetching, ready } = this.context;
    const { tab } = this.state;

    return (
      <div className="claimimg-popup">
        <Tabs env={env}
              count={count}
              tabs={this.tabs}
              activeTab={tab}
              onTabChange={this.switchTabTo}
        >
          <ShortList env={env}
                     tasks={this.tasksForCurrentTab()}
                     fetched={ready}
                     fetching={fetching}
          />
        </Tabs>
      </div>
    );
  }
}

export default HBWPopUp;
