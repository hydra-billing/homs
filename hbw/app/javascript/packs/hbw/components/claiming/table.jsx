import React, { Component, createRef } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { parseISO, isBefore } from 'date-fns';
import { withErrorBoundary } from 'shared/hoc';
import Priority from 'shared/element/priority';
import DueDate from 'shared/element/due_date';
import CreatedDate from 'shared/element/created_date';
import TranslationContext from 'shared/context/translation';
import Pending from '../pending';

class HBWTasksTable extends Component {
  static contextType = TranslationContext;

  static propTypes = {
    tasks:           PropTypes.array.isRequired,
    showClaimButton: PropTypes.bool.isRequired,
    fetching:        PropTypes.bool.isRequired,
    lastPage:        PropTypes.bool.isRequired,
    addPage:         PropTypes.func.isRequired,
    openTask:        PropTypes.func.isRequired,
    claim:           PropTypes.func.isRequired,
    claimingTask:    PropTypes.object,
    activeTask:      PropTypes.object,
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

      openTask(tasks[cursor]);
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
    const now = new Date();

    if (due) {
      return <span className="deadline"><DueDate dateISO={due} now={now} /></span>;
    } else {
      return <span><CreatedDate dateISO={created} now={now} /></span>;
    }
  };

  onClaimClick = async (e, task) => {
    e.stopPropagation();

    await this.props.claim(task);
  };

  renderRow = (row, index) => {
    const { cursor } = this.state;
    const {
      tasks, showClaimButton, openTask, claimingTask, activeTask
    } = this.props;

    const { translate: t, translateBP } = this.context;

    const claiming = claimingTask && claimingTask.id === row.id;
    const opened = activeTask && activeTask.id === row.id;

    const chosenCN = cx({
      chosen:  cursor === index,
      expired: row.due ? isBefore(parseISO(row.due), new Date()) : false,
      opened,
      claiming
    });

    const buttonCN = cx({
      btn:           true,
      'btn-primary': opened,
      'btn-default': !opened,
    });

    const taskLabel = translateBP(`${row.process_key}.${row.key}.label`, {}, row.name);
    const processLabel = translateBP(`${row.process_key}.label`, {}, row.process_name);

    return (
      <tr className={chosenCN} key={row.id} onClick={() => openTask(row)}>
        <td className='priority'>
          <Priority priority={row.priority} />
        </td>
        <td>{taskLabel}</td>
        <td><i className={row.icon}/>&nbsp;{processLabel}</td>
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
    const { translate: t } = this.context;

    return (
      <div className='no-tasks'>
        <span>
          {t('components.claiming.table.empty_tasks')}
        </span>
      </div>
    );
  };

  render () {
    const {
      showClaimButton, tasks, fetching
    } = this.props;

    const { translate: t } = this.context;

    return (
      <div className='claiming-table'>
        <table className='table'>
          <thead>
            <tr>
              <th className="priority-header">{t('components.claiming.table.priority')}</th>
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
        {fetching && <Pending />}
        {!fetching && tasks.length === 0 && this.renderNoTasks()}
      </div>
    );
  }
}

export default withErrorBoundary(HBWTasksTable);
