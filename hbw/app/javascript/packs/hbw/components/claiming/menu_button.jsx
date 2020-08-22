import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { StoreContext } from 'shared/context/store';
import HydraIcon from 'shared/element/icon';
import PopUp from './pop_up';

class HBWClaimingMenuButton extends Component {
  static contextType = StoreContext;

  static propTypes = {
    env: PropTypes.object.isRequired,
  };

  state = {
    isOpen: false
  };

  rootDiv = React.createRef();

  componentDidMount () {
    window.addEventListener('mousedown', this.handleClickOutside);
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
    const { count } = this.context;
    const { isOpen } = this.state;

    return (
      <div className="claiming-menu-button-container hbw-body" ref={this.rootDiv}>
        <div className="claiming-menu-button" onClick={this.handlePopUp}>
          <HydraIcon />
          <span className="claiming-count">
            {count.my}/{count.unassigned}
          </span>
        </div>
        {isOpen && <PopUp env={env}/>}
      </div>
    );
  }
}

export default HBWClaimingMenuButton;
