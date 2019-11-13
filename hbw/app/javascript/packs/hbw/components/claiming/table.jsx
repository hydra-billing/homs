import React, { Component, createRef } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { parseISO, isBefore } from 'date-fns';
import { withErrorBoundary } from '../helpers';
import Priority from './shared/priority';
import DueDate from './shared/due_date';
import CreatedDate from './shared/created_date';

class HBWTasksTable extends Component {
  static propTypes = {
    env:               PropTypes.object.isRequired,
    tasks:             PropTypes.array.isRequired,
    showClaimButton:   PropTypes.bool.isRequired,
    fetching:          PropTypes.bool.isRequired,
    lastPage:          PropTypes.bool.isRequired,
    addPage:           PropTypes.func.isRequired,
    openTask:          PropTypes.func.isRequired,
    claimAndPollTasks: PropTypes.func.isRequired,
    claimingTask:      PropTypes.object,
    fetched:           PropTypes.bool.isRequired,
    activeTask:        PropTypes.object,
  };

  state = {
    cursor: -1,
  };

  tableBody = createRef();

  componentDidMount () {
    window.addEventListener('keydown', this.handleKeyDown);
    window.addEventListener('scroll', this.trackScrolling);

    this.tableBody.current.addEventListener('mouseenter', this.removeCursor);
  }

  componentWillUnmount () {
    window.removeEventListener('keydown', this.handleKeyDown);
    window.removeEventListener('scroll', this.trackScrolling);

    this.tableBody.current.removeEventListener('mouseenter', this.removeCursor);
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
    this.setState({ cursor: this.props.tasks.length - 1 });
  };

  handleKeyDown = (e) => {
    const { tasks, openTask } = this.props;
    const { cursor } = this.state;

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

      openTask(cursor);
    }
  };

  isBottom = el => (el.getBoundingClientRect().bottom <= window.innerHeight);

  showMore = () => {
    this.props.addPage();
  };

  trackScrolling = () => {
    const { fetching, lastPage } = this.props;

    if (this.isBottom(this.tableBody.current) && !lastPage && !fetching) {
      this.showMore();
    }
  };

  renderDate = (created, due) => {
    const { env } = this.props;
    const now = new Date();

    if (due) {
      return <span className="deadline"><DueDate env={env} dateISO={due} now={now} /></span>;
    } else {
      return <span><CreatedDate env={env} dateISO={created} now={now} /></span>;
    }
  };

  onClaimClick = async (e, task) => {
    e.stopPropagation();

    await this.props.claimAndPollTasks(task);
  };

  renderRow = (row, index) => {
    const { cursor } = this.state;
    const {
      tasks, showClaimButton, env, openTask, claimingTask, activeTask
    } = this.props;
    const { translator: t } = env;

    const claiming = claimingTask && claimingTask.id === row.id;
    const opened = activeTask && activeTask.id === row.id;

    const chosenCN = cx({
      chosen:  cursor === index,
      expired: isBefore(parseISO(row.due), new Date()),
      opened,
      claiming
    });

    const buttonCN = cx({
      btn:           true,
      'btn-primary': opened,
      'btn-default': !opened,
    });

    return (
      <tr className={chosenCN} key={row.id} onClick={() => openTask(index)}>
        <td className='priority'>
          <Priority env={env} priority={row.priority} />
        </td>
        <td>{row.name}</td>
        <td><i className={row.icon}/>&nbsp;{row.process_name}</td>
        <td className='description'>{row.description || t('components.claiming.table.empty_description') }</td>
        <td>{this.renderDate(row.created, row.due)}</td>
        {showClaimButton && (
          <td>
            <button className={buttonCN} onClick={e => !claiming && this.onClaimClick(e, tasks[index])}>
              {t('components.claiming.claim')}
            </button>
          </td>
        )}
      </tr>
    );
  };

  renderNoTasks = () => {
    const { translator: t } = this.props.env;

    return (
      <div className='no-tasks'>
        <span>
          {t('components.claiming.table.empty_tasks')}
        </span>
      </div>
    );
  };

  render () {
    const { showClaimButton, tasks, fetched } = this.props;
    const { translator: t } = this.props.env;

    return (
      <div className='claiming-table'>
        <table className='table'>
          <thead>
            <tr>
              <th>{t('components.claiming.table.priority')}</th>
              <th>{t('components.claiming.table.title')}</th>
              <th>{t('components.claiming.table.type')} </th>
              <th>{t('components.claiming.table.description')}</th>
              <th>{t('components.claiming.table.sla')}</th>
              {showClaimButton && <th />}
            </tr>
          </thead>
          <tbody ref={this.tableBody}>
            {tasks.map((row, index) => this.renderRow(row, index))}
          </tbody>
        </table>
        {fetched && tasks.length === 0 && this.renderNoTasks()}
      </div>
    );
  }
}

export default withErrorBoundary(HBWTasksTable);
