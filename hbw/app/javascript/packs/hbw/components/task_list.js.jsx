/* eslint no-return-assign: "off" */
/* eslint no-cond-assign: "off" */

import { withCallbacks, withTasks, compose } from './helpers';

modulejs.define('HBWTaskList',
  ['React', 'HBWTaskGroup', 'HBWError', 'HBWPending'],
  (React, TaskGroup, Error, Pending) => {
    const TaskList = React.createClass({
      displayName: 'HBWTaskList',

      getInitialState () {
        return {
          tasks:      [],
          groupByVar: 'id',
          fetched:    false
        };
      },

      componentDidMount () {
        this.props.subscription
          .fetch(() => this.setState({ fetched: true }))
          .progress(data => this.setState({
            tasks:      data.tasks,
            groupByVar: data.group_by_var
          }));
      },

      hideWidget (e) {
        e.preventDefault();
        this.props.trigger('hbw:toggle-tasks-menu');
      },

      render () {
        const aClass = 'hbw-sheet-header-button hbw-sheet-header-close-button';

        return <div className='hbw-sheet hbw-enabled col-xs-12 col-sm-4 col-md-3 col-lg-2'>
          <div className='hbw-sheet-header'>
            <div className='hbw-sheet-header-container'>
              <div className='hbw-sheet-header-title-container'>
                <em className='hbw-sheet-header-title'>{this.props.env.translator('tasks')}</em>
              </div>
              <a className={aClass} href="#" onClick={this.hideWidget}
                 title={this.props.env.translator('hide_widget')}>
                <div className="hbw-sheet-header-button-icon hbw-sheet-header-close-button-icon"></div>
              </a>
            </div>
          </div>
          <div className='hbw-sheet-body'>
            { !this.state.fetched && <Pending text={this.props.env.translator('loading')} /> }
            { this.state.tasks.length === 0 && this.state.fetched
            && <p>{this.props.env.translator('no_tasks')}</p> }
            { this.createGroupsChildren() }
          </div>
          <div className='hbw-sheet-content'></div>
        </div>;
      },

      createGroupsChildren () {
        return this.groupsFromTasks(this.state.tasks).map((group) => {
          const newGroup = group;

          newGroup.key = group.group;
          newGroup.env = this.props.env;
          newGroup.chosenTaskID = this.props.chosenTaskID;

          return React.createElement(TaskGroup, newGroup);
        });
      },

      groupsFromTasks (tasks) {
        let group;
        const groups = {};

        [...tasks].forEach((task) => {
          group = task[this.state.groupByVar];

          if (!groups[group]) {
            groups[group] = [];
          }

          groups[group].push(task);
        });

        const keys = Object.keys(groups).sort((a, b) => {
          if (a < b) {
            return 1;
          }

          if (a > b) {
            return -1;
          }

          return 0;
        });

        return keys.map(_group => ({
          _group,
          tasks: groups[_group]
        }));
      }
    });

    return compose(withTasks, withCallbacks)(TaskList);
  });
