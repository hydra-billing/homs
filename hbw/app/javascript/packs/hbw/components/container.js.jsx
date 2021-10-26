import { withCallbacks } from 'shared/hoc';
import { StoreContext } from 'shared/context/store';

modulejs.define(
  'HBWContainer',
  ['React', 'HBWButtons', 'HBWEntityTasks', 'HBWError'],
  (React, Buttons, Tasks, Error) => {
    class Container extends React.Component {
      static contextType = StoreContext;

      state = {
        error:             null,
        processInstanceId: null
      };

      componentDidMount () {
        this.props.bind('hbw:form-submitted', this.onFormSubmit);
      }

      tasks = () => {
        const { entityCode, entityTypeCode } = this.props;
        const { tasks } = this.context;

        return tasks.filter(task => task.entity_code === entityCode
                                    && task.entity_types.includes(entityTypeCode)).reverse();
      };

      resetProcess = () => {
        this.setState({ processInstanceId: null });
      };

      render () {
        const {
          env, chosenTaskID, entityCode, entityTypeCode, entityClassCode, autorunProcessKey
        } = this.props;

        const { fetching, error, getFormsForTasks } = this.context;
        const { processInstanceId } = this.state;

        if (this.tasks().length > 0) {
          getFormsForTasks(this.tasks());

          return <div className='hbw-body'>
              <Tasks tasks={this.tasks()}
                     env={env}
                     chosenTaskID={chosenTaskID}
                     entityCode={entityCode}
                     entityTypeCode={entityTypeCode}
                     entityClassCode={entityClassCode}
                     processInstanceId={processInstanceId}
              />
            </div>;
        } else {
          return <div className='hbw-body'>
              <Error error={error} env={env} />
              <Buttons entityCode={entityCode}
                       entityTypeCode={entityTypeCode}
                       entityClassCode={entityClassCode}
                       autorunProcessKey={autorunProcessKey}
                       showSpinner={fetching}
                       env={env}
                       resetProcess={this.resetProcess}/>
            </div>;
        }
      }

      onFormSubmit = (task) => {
        // remember execution id of the last submitted form to open next form if
        // task with the same processInstanceId will be loaded
        this.setState({ processInstanceId: task.process_instance_id });
      };
    }

    return withCallbacks(Container);
  }
);
