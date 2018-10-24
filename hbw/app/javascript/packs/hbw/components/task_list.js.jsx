modulejs.define('HBWTaskList',
  ['React', 'HBWTaskGroup', 'HBWError', 'HBWPending', 'HBWTasksMixin',
    'HBWCallbacksMixin', 'HBWTranslationsMixin'],
  (React, TaskGroup, Error, Pending, TasksMixin, CallbacksMixin, TranslationsMixin) => React.createClass({
    mixins: [TasksMixin, CallbacksMixin, TranslationsMixin],

    getInitialState () {
      return {
        tasks:      [],
        groupByVar: 'id',
        fetched:    false
      };
    },

    componentDidMount () {
      this.state.subscription
        .fetch(() => this.setState({ fetched: true }))
        .progress((data) => {
          const tasks = data.tasks.filter(t => t.entity_code === this.props.entity_code);

          return this.setState({
            tasks:      data.tasks,
            groupByVar: data.group_by_var
          });
        });
    },

    hideWidget (e) {
      e.preventDefault();
      this.trigger('hbw:toggle-tasks-menu');
    },

    render () {
      const a_class = 'hbw-sheet-header-button hbw-sheet-header-close-button';

      return <div className='hbw-sheet hbw-enabled col-xs-12 col-sm-4 col-md-3 col-lg-2'>
        <div className='hbw-sheet-header'>
          <div className='hbw-sheet-header-container'>
            <div className='hbw-sheet-header-title-container'>
              <em className='hbw-sheet-header-title'>{this.t('tasks')}</em>
            </div>
            <a className={a_class} href="#" onClick={this.hideWidget} title={this.t('hide_widget')}>
              <div className="hbw-sheet-header-button-icon hbw-sheet-header-close-button-icon">
              </div>
            </a>
          </div>
        </div>
        <div className='hbw-sheet-body'>
          { !this.state.fetched && <Pending text={this.t('loading')} /> }
          { this.state.tasks.length == 0 && this.state.fetched && <p>{this.t('no_tasks')}</p> }
          { this.createGroupsChildren() }
        </div>
        <div className='hbw-sheet-content'>
        </div>
      </div>;
    },

    createGroupsChildren () {
      const { props } = this;

      return this.groupsFromTasks(this.state.tasks).map((group) => {
        group.key = group.group;
        group.env = this.props.env;
        group.chosenTaskID = this.props.chosenTaskID;

        return React.createElement(TaskGroup, group);
      });
    },

    groupsFromTasks (tasks) {
      let group;
      const groups = {};
      for (const task of Array.from(tasks)) {
        group = task[this.state.groupByVar];
        if (!groups[group]) {
          groups[group] = [];
        }
        groups[group].push(task);
      }

      const keys = Object.keys(groups).sort((a, b) => {
        let left;
        let left1;

        return ((left = a < b) != null ? left : -{ 1: ((left1 = a > b) != null ? left1 : { 1: 0 }) }); // The hell generated from CoffeeScript
      });

      return keys.map(group => ({
        group,
        tasks: groups[group]
      }));
    }
  }));
