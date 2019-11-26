import { withCallbacks } from './helpers';

modulejs.define(
  'HBWEntityTask',
  ['React', 'jQuery', 'HBWForm', 'HBWError', 'HBWFormDefinition'],
  (React, jQuery, Form, Error, FormDefinition) => {
    class HBWEntityTask extends React.Component {
      state = {
        error:     null,
        collapsed: this.props.collapsed || false,
        id:        this.props.getComponentId()
      };

      componentDidMount () {
        this.props.bind(`hbw:submit-form-${this.state.id}`, this.submitForm);

        const e = jQuery(this.rootNode);
        e.on('hidden.bs.collapse', this.choose);
        e.on('shown.bs.collapse', this.choose);
      }

      componentWillUnmount () {
        jQuery(this.rootNode).off('hidden.bs.collapse').off('shown.bs.collapse');
      }

      render () {
        let iconClass = 'indicator pull-right fa';

        const { task } = this.props;

        if (this.state.collapsed) {
          iconClass += ' fa-chevron-down';
        } else {
          iconClass += ' fa-chevron-up';
        }

        return <div className="panel panel-default" ref={(node) => { this.rootNode = node; }}>
          <div className="panel-heading">
            <h4 className="panel-title collapsable">
              <a
                onClick={this.toggleCollapse}
              >
                {task.name}
              </a>
              <i
                onClick={this.toggleCollapse}
                className={iconClass}
              />
            </h4>
          </div>
          {!this.state.collapsed
            && (<div className="panel-body">
                {this.renderForm()}
                </div>)
          }
        </div>;
      }

      renderForm = () => {
        const { form } = this.props.task;

        if (this.state.error) {
          return <Error error={this.state.error} env={this.props.env} />;
        } else {
          const opts = {
            id:        this.state.id,
            taskId:    this.props.task.id,
            form,
            env:       this.props.env,
            error:     this.state.error,
            assignee:  this.props.task.assignee,
            variables: this.formVariablesFromTask(this.props.task),
            pollTasks: this.props.pollTasks
          };

          return <Form {...opts}/>;
        }
      };

      formVariablesFromTask = () => {
        const { form } = this.props.task;

        const formVariables = {};
        const formDef = new FormDefinition(form);

        [...form.variables].forEach(({ name, value }) => {
          if (formDef.fieldExist(name)) {
            formVariables[name] = value;
          }
        });

        return formVariables;
      };

      submitForm = (variables) => {
        this.props.env.forms.save({
          taskId: this.props.taskId,
          variables,
          token:  this.props.task.form.csrf_token
        })
          .done(() => this.setState({ error: null }))
          .done(() => this.props.trigger('hbw:form-submitted', this.props.task))
          .fail((response) => {
            this.setState({ error: response });
            return this.props.trigger('hbw:form-submitting-failed', {
              response,
              task: this.props.task
            });
          });
      };

      choose = () => {
        this.props.trigger('hbw:task-clicked', this.props.task);
      };

      toggleCollapse = () => {
        this.setState(prevState => ({ collapsed: !prevState.collapsed }));
      };
    }

    return withCallbacks(HBWEntityTask);
  }
);
