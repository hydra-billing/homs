import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { withErrorBoundary, withUnassignedTasks, compose } from '../helpers';
import Priority from './priority';

class HBWTasksTable extends Component {
  static propTypes = {
    showClaimButton:              PropTypes.bool.isRequired,
    env:                          PropTypes.object.isRequired,
    url:                          PropTypes.string.isRequired,
    createUnassignedSubscription: PropTypes.func.isRequired,
    startUnassignedSubscription:  PropTypes.func.isRequired,
    closeUnassignedSubscription:  PropTypes.func.isRequired,
    updateUnassignedSubscription: PropTypes.func.isRequired,
  };

  state = {
    tasks:        [],
    subscription: null,
    cursor:       -1,
    page:         1,
    lastPage:     false,
    openOverview: false,
    fetching:     true
  };

  perPage = 50;

  componentDidMount () {
    window.addEventListener('keydown', this.handleKeyDown);
    window.addEventListener('scroll', this.trackScrolling);
    this.tableBody.addEventListener('mouseenter', this.removeCursor);

    const subscription = this.props.createUnassignedSubscription(0, this.perPage);

    this.setState({
      fetching: true,
      subscription
    });

    this.props.startUnassignedSubscription(subscription);

    subscription
      .always(() => this.setState({ fetching: false }))
      .progress(({ tasks }) => this.updateTasks(tasks));
  }

  componentWillUnmount () {
    window.removeEventListener('keydown', this.handleKeyDown);
    window.removeEventListener('scroll', this.trackScrolling);
    this.tableBody.removeEventListener('mouseenter', this.removeCursor);
    this.props.closeUnassignedSubscription(this.state.subscription);
  }

  updateTasks = (tasks) => {
    const { page } = this.state;

    this.setState({
      tasks,
      lastPage: tasks.length < page * this.perPage
    });
  }

  removeCursor = () => this.setState({ cursor: -1 });

  moveCursorUp = () => {
    this.setState(prevState => ({ cursor: prevState.cursor - 1 }));
  };

  moveCursorDown = () => {
    this.setState(prevState => ({ cursor: prevState.cursor + 1 }));
  };

  moveCursorToFirst = () => {
    this.setState({ cursor: 0 });
  };

  moveCursorToLast = () => {
    this.setState({ cursor: this.state.tasks.length - 1 });
  };

  handleKeyDown = (e) => {
    const { cursor, tasks } = this.state;

    if (e.keyCode === 38) {
      e.preventDefault();

      if (cursor > 0) {
        this.moveCursorUp();
      } else {
        this.moveCursorToLast();
      }
    } else if (e.keyCode === 40) {
      e.preventDefault();

      if (cursor < tasks.length - 1) {
        this.moveCursorDown();
      } else {
        this.moveCursorToFirst();
      }
    } else if (e.keyCode === 13 && cursor >= 0 && cursor <= tasks.length - 1) {
      e.preventDefault();

      this.setState(prevState => ({ openOverview: !prevState.openOverview }));
    }
  };

  isBottom = el => (el.getBoundingClientRect().bottom <= window.innerHeight);

  showMore = () => {
    const { page, subscription } = this.state;
    this.setState(prevState => ({ page: prevState.page + 1, fetching: true }));

    this.props.updateUnassignedSubscription(subscription, 0, (page + 1) * this.perPage);
  };

  trackScrolling = () => {
    const { lastPage, fetching } = this.state;

    if (this.isBottom(this.tableBody) && !lastPage && !fetching) {
      this.showMore();
    }
  };

  renderRow = (row, index) => {
    const { cursor } = this.state;
    const { showClaimButton, env } = this.props;
    const { translator } = env;

    const chosenCN = cx({ chosen: cursor === index });

    return (
      <tr className={chosenCN} key={row.id}>
        <td className='priority'><Priority env={env} priority={row.priority}/></td>
        <td>{row.name}</td>
        <td><i className={row.icon}/>&nbsp;{row.process_name}</td>
        <td>{row.description || translator('components.claiming.table.empty_description') }</td>
        <td>{'1h ago'}</td>
        {showClaimButton
          && <td><button className='claim-button'>{translator('components.claiming.claim')}</button></td>}
      </tr>
    );
  };

  renderLoader = () => {
    const { fetching } = this.state;

    return (
      fetching && <div className='loader'><i className="fas fa-spinner fa-spin fa-2x"></i></div>
    );
  };

  renderNoTasks = () => {
    const { tasks, fetching } = this.state;
    const { translator } = this.props.env;

    return (
      !fetching && tasks.length === 0
        && <div className='no-tasks'><span>{translator('components.claiming.table.empty_tasks')}</span></div>
    );
  };

  render () {
    const { tasks } = this.state;
    const { showClaimButton } = this.props;
    const { translator } = this.props.env;

    return (
      <div className='claiming-table'>
        <table className='table'>
          <thead>
          <tr>
            <th>{translator('components.claiming.table.priority')}</th>
            <th>{translator('components.claiming.table.title')}</th>
            <th>{translator('components.claiming.table.type')} </th>
            <th>{translator('components.claiming.table.description')}</th>
            <th>{translator('components.claiming.table.sla')}</th>
            {showClaimButton && <th></th>}
          </tr>
          </thead>
          <tbody ref={(t) => { this.tableBody = t; }}>
            {tasks.map((row, index) => this.renderRow(row, index))}
          </tbody>
        </table>
        {this.renderLoader()}
        {this.renderNoTasks()}
      </div>
    );
  }
}

export default compose(withErrorBoundary, withUnassignedTasks)(HBWTasksTable);
