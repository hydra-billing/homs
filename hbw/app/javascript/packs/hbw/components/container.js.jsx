import { withCallbacks, withTasks, compose } from './helpers';

modulejs.define(
  'HBWContainer',
  ['React', 'HBWButtons', 'HBWEntityTasks', 'HBWError'],
  (React, Buttons, Tasks, Error) => {
    class Container extends React.Component {
      state = {
        buttons:        [],
        tasks:          [],
        tasksFetched:   false,
        processStarted: false
      };

      componentDidMount () {
        this.props.subscription
          .fetch(() => this.setState({ tasksFetched: true }))
          .progress((data) => {
            const tasks = data.tasks.filter(t => t.entity_code === this.props.entityCode);
            return this.setState({
              tasks,
              processStarted: this.state.processStarted && (tasks.length === 0)
            });
          });

        this.props.bind('hbw:form-submitted', this.onFormSubmit);
        this.props.bind('hbw:process-started', () => this.setState({ processStarted: true }));
      }

      render () {
        if ((this.state.tasks.length > 0) && this.state.tasksFetched) {
          return <div className='hbw-entity-tools'>
            <Tasks tasks={this.state.tasks}
                   env={this.props.env}
                   chosenTaskID={this.props.chosenTaskID}
                   entityCode={this.props.entityCode}
                   entityTypeCode={this.props.entityTypeCode}
                   entityClassCode={this.props.entityClassCode}
                   processInstanceId={this.state.processInstanceId}
                   pollTasks={this.props.pollTasks} />
          </div>;
        } else {
          return <div className='hbw-entity-tools'>
            <Error error={this.props.error} env={this.props.env} />
            <Buttons entityCode={this.props.entityCode}
                     entityTypeCode={this.props.entityTypeCode}
                     entityClassCode={this.props.entityClassCode}
                     tasksFetched={this.state.tasksFetched}
                     showSpinner={!this.state.tasksFetched || this.state.processStarted}
                     env={this.props.env} />
          </div>;
        }
      }

      onFormSubmit = (task) => {
        // remember execution id of the last submitted form to open next form if
        // task with the same processInstanceId will be loaded
        this.setState({ processInstanceId: task.processInstanceId });
      };
    }

    return compose(withTasks, withCallbacks)(Container);
  }
);
