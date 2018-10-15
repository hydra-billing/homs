modulejs.define(
  'HBWContainer',
  ['React',
    'HBWButtons',
    'HBWEntityTasks',
    'HBWError',
    'HBWPending',
    'HBWCallbacksMixin',
    'HBWTasksMixin'],
  (React, Buttons, Tasks, Error, Pending, CallbacksMixin, TasksMixin) => React.createClass({
    mixins: [TasksMixin, CallbacksMixin],

    getInitialState () {
      return {
        buttons:        [],
        tasks:          [],
        tasksFetched:   false,
        processStarted: false
      };
    },

    componentDidMount () {
      this.state.subscription
        .fetch(() => this.setState({ tasksFetched: true }))
        .progress((data) => {
          const tasks = data.tasks.filter(t => t.entity_code === this.props.entityCode);
          return this.setState({
            tasks,
            processStarted: this.state.processStarted && (tasks.length === 0)
          });
        });

      this.bind('hbw:form-submitted', this.onFormSubmit);
      this.bind('hbw:process-started', () => this.setState({ processStarted: true }));
    },

    render () {
      if ((this.state.tasks.length > 0) && this.state.tasksFetched) {
        return <div className='hbw-entity-tools'>
          <Tasks tasks={this.state.tasks}
            env={this.props.env}
            chosenTaskID={this.props.chosenTaskID}
            entityCode={this.props.entityCode}
            entityTypeCode={this.props.entityTypeCode}
            entityClassCode={this.props.entityClassCode}
            processInstanceId={this.state.processInstanceId} />
        </div>;
      } else {
        return <div className='hbw-entity-tools'>
          <Error error={this.state.error} />
          <Buttons entityCode={this.props.entityCode}
            entityTypeCode={this.props.entityTypeCode}
            entityClassCode={this.props.entityClassCode}
            tasksFetched={this.state.tasksFetched}
            showSpinner={!this.state.tasksFetched || this.state.processStarted}
            env={this.props.env} />
        </div>;
      }
    },

    onFormSubmit (task) {
      // remember execution id of the last submitted form to open next form if
      // task with the same processInstanceId will be loaded
      this.setState({ processInstanceId: task.processInstanceId });
    }
  }));
