import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import TranslationContext from '../context/translation';

class HBWClaimingTaskTabs extends Component {
  static contextType = TranslationContext;

  static propTypes = {
    children: PropTypes.element.isRequired,
    tabs:     PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired,
    }).isRequired,
    activeTab:   PropTypes.number.isRequired,
    onTabChange: PropTypes.func.isRequired,
    count:       PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired,
    }).isRequired,
  };

  state = {
    count: {
      my:         0,
      unassigned: 0,
    }
  };

  renderTabs = () => {
    const {
      tabs, activeTab, onTabChange, count
    } = this.props;

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
            {this.context.translate(`components.claiming.tabs.${tab[0]}`, { count: count[tab[0]] })}
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

export default HBWClaimingTaskTabs;
