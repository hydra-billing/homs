import cx from 'classnames';
import { withCallbacks } from 'shared/hoc';
import Pending from './pending';

modulejs.define(
  'HBWEntityTask',
  ['React', 'jQuery', 'HBWForm', 'HBWError', 'HBWFormDefinition'],
  (React, jQuery, Form, Error, FormDefinition) => {
    class HBWEntityTask extends React.Component {
      state = {
        error:     null,
        collapsed: this.props.collapsed || false
      };

      componentDidMount () {
        this.props.bind(`hbw:submit-form-${this.props.guid}`, this.submitForm);

        const e = jQuery(this.rootNode);
        e.on('hidden.bs.collapse', this.choose);
        e.on('shown.bs.collapse', this.choose);
      }

      componentWillUnmount () {
        jQuery(this.rootNode).off('hidden.bs.collapse').off('shown.bs.collapse');
      }

      render () {
        const { task, env } = this.props;
        const { collapsed } = this.state;

        const iconClass = cx('indicator', 'pull-right', 'fa', {
          'fa-chevron-down': collapsed,
          'fa-chevron-up':   !collapsed,
        });

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
          {!collapsed && (
            <div className="panel-body">
              {this.renderForm()}
            </div>
          )}
        </div>;
      }

      renderForm = () => {
        const { guid, task, env } = this.props;
        const { error } = this.state;

        if (task.form !== undefined) {
          if (error) {
            return <Error error={error} env={env}/>;
          } else {
            const opts = {
              task,
              env,
              error,
              id:            guid,
              variables:     this.formVariablesFromTask(task),
              taskVariables: task.form.variables
            };

            return <Form {...opts}/>;
          }
        } else {
          return <div className="hbw-spinner"><Pending /></div>;
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
          .then(() => {
            this.setState({ error: null });
            this.props.trigger('hbw:form-submitted', this.props.task);
          })
          .catch((response) => {
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
