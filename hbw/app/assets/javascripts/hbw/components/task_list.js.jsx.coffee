modulejs.define 'HBWTaskList',\
  ['React', 'HBWTaskGroup', 'HBWError', 'HBWPending', 'HBWTasksMixin',
   'HBWCallbacksMixin', 'HBWTranslationsMixin'],\
  (React, TaskGroup, Error, Pending, TasksMixin, CallbacksMixin, TranslationsMixin) ->
    React.createClass(
      mixins: [TasksMixin, CallbacksMixin, TranslationsMixin]

      getInitialState: ->
        tasks: []
        groupByVar: 'id'
        fetched: false

      componentDidMount: ->
        @state.subscription
          .fetch(=> @setState(fetched: true))
          .progress((data) =>
            tasks = data.tasks.filter (t) => t.entity_code == @props.entity_code
            @setState(tasks: data.tasks, groupByVar: data.group_by_var)
          )

      hideWidget: (e) ->
        e.preventDefault()
        @trigger('hbw:toggle-tasks-menu')

      render: ->
        a_class = 'hbw-sheet-header-button hbw-sheet-header-close-button'
        `<div className='hbw-sheet hbw-enabled col-xs-12 col-sm-4 col-md-3 col-lg-2'>
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
        </div>`

      createGroupsChildren: ->
        props = @props
        @groupsFromTasks(@state.tasks).map (group) =>
          group.key = group.group
          group.env = @props.env
          group.chosenTaskID = @props.chosenTaskID

          React.createElement(TaskGroup, group)

      groupsFromTasks: (tasks) ->
        groups = {}
        for task in tasks
          group = task[@state.groupByVar]
          groups[group] ||= []
          groups[group].push task

        groups = do (groups) ->
          keys = Object.keys(groups).sort (a, b) -> (a < b ? -1 : (a > b ? 1 : 0))
          { group, tasks: groups[group]} for group in keys
    )
