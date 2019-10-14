import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { withTasksCount } from '../../helpers';

class HBWClaimingTaskTabs extends Component {
  static propTypes = {
    env:          PropTypes.object.isRequired,
    children:     PropTypes.element.isRequired,
    subscription: PropTypes.object.isRequired,
    tabs:         PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired,
    }).isRequired,
    activeTab:   PropTypes.number.isRequired,
    onTabChange: PropTypes.func.isRequired,
  };

  state = {
    count: {
      my:         0,
      unassigned: 0,
    }
  };

  componentDidMount () {
    const { subscription } = this.props;

    subscription.progress(({ task_count: my, task_count_unassigned: unassigned }) => {
      this.setState({ count: { my, unassigned } });
    });
  }

  renderTabs = () => {
    const {
      env, tabs, activeTab, onTabChange
    } = this.props;

    const { count } = this.state;

    const tabCN = tab => cx({
      'is-active': activeTab === tab,
    });

    const tabsList = Object.entries(tabs)
      .map(tab => (
        <li className={tabCN(tab[1])} key={`${tab[0]}${tab[1]}`}>
          <a
            role="button"
            tabIndex={0}
            className="tab"
            onClick={() => onTabChange(tab[1])}
          >
            {env.translator(`components.claiming.tabs.${tab[0]}`, { count: count[tab[0]] })}
          </a>
        </li>
      ));

    return (
      <div className="tabs">
        <ul>
          {tabsList}
        </ul>
      </div>
    );
  };

  render () {
    const { children } = this.props;

    return (
      <div>
        {this.renderTabs()}
        {children}
      </div>
    );
  }
}

export default withTasksCount(HBWClaimingTaskTabs);
