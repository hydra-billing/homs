import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';

class HBWClaimingTaskTabs extends Component {
  static propTypes = {
    env:      PropTypes.object.isRequired,
    children: PropTypes.element.isRequired,
    count:    PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired
    }).isRequired,
    tab:         PropTypes.number.isRequired,
    onTabChange: PropTypes.func.isRequired,
  };

  tabs = { my: 0, unassigned: 1 };

  renderTabs = () => {
    const {
      env, count, tab: activeTab, onTabChange
    } = this.props;

    const tabCN = tab => cx({
      'is-active': activeTab === tab,
    });

    const tabs = Object.entries(this.tabs)
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
          {tabs}
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

export default HBWClaimingTaskTabs;
