import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';

class HBWClaimingTaskTabs extends Component {
  static propTypes = {
    env:      PropTypes.object.isRequired,
    children: PropTypes.arrayOf(PropTypes.element).isRequired,
    count:    PropTypes.shape({
      my:         PropTypes.number.isRequired,
      unassigned: PropTypes.number.isRequired
    }).isRequired,
  };

  tabs = { my: 0, unassigned: 1 };

  state = {
    tab: this.tabs.my,
  };

  handleTabChange = (tab) => {
    if (tab !== this.state.tab) {
      this.setState({ tab });
    }
  };

  renderTabs = () => {
    const { env, count } = this.props;

    const tabCN = tab => cx({
      'is-active': this.state.tab === tab,
    });

    const tabs = Object.entries(this.tabs)
      .map(tab => (
        <li className={tabCN(tab[1])} key={`${tab[0]}${tab[1]}`}>
          <a
            role="button"
            tabIndex={0}
            className="tab"
            onClick={() => this.handleTabChange(tab[1])}
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
    const { tab } = this.state;

    return (
      <div>
        {this.renderTabs()}
        {children[tab]}
      </div>
    );
  }
}

export default HBWClaimingTaskTabs;
