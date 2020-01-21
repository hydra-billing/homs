import { withCallbacks } from 'shared/hoc';

modulejs.define(
  'HBWContainer',
  ['React', 'HBWButtons', 'HBWEntityTasks', 'HBWError'],
  (React, Buttons, Tasks, Error) => {
    class Container extends React.Component {
      state = {
        tasks:          [],
        tasksFetched:   false,
        processStarted: false,
        error:          null
      };

      componentDidMount () {
        this.fetchInitialState();

        this.props.bind('hbw:form-submitted', this.onFormSubmit);
        this.props.bind('hbw:process-started', () => this.setState({ processStarted: true }));
      }

      fetchInitialState = () => {
        const { env } = this.props;
        const { processStarted } = this.state;

        const data = {
          entity_class: env.entity_class,
          entity_code:  env.entity_code
        };

        return env.connection.request({
          url:    `${env.connection.serverURL}/tasks`,
          method: 'GET',
          data
        })
          .done(({ tasks }) => this.setState({
            tasks,
            processStarted: processStarted && (tasks.length === 0),
            tasksFetched:   true
          }))
          .fail(response => this.setState({ error: response }));
      };

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

    return withCallbacks(Container);
  }
);
