import { withCallbacks } from './helpers';

modulejs.define(
  'HBWEntityTask',
  ['React', 'ReactDOM', 'jQuery', 'HBWForm', 'HBWTestForm', 'HBWError', 'HBWPending', 'HBWTranslationsMixin',
    'HBWFormDefinition'],
  (React, ReactDOM, jQuery, Form, TestForm, Error, Pending, TranslationsMixin, FormDefinition) => {
    const EntityTask = React.createClass({
      mixins: [TranslationsMixin],

      displayName: 'HBWEntityTask',

      getInitialState () {
        return {
          error:   null,
          loading: true,
          pending: null,
          form:    null
        };
      },

      componentDidMount () {
        this.loadForm(this.props.task.id);
        this.props.bind('hbw:submit-form', this.submitForm);

        const e = jQuery(this.rootNode);
        e.on('hidden.bs.collapse', this.choose);
        e.on('shown.bs.collapse', this.choose);
      },

      componentWillUnmount () {
        jQuery(this.rootNode).off('hidden.bs.collapse').off('shown.bs.collapse');
      },

      render () {
        let collapseClass = 'panel-collapse collapse';
        if (!this.props.collapsed) {
          collapseClass += ' in';
        }
        let iconClass = 'indicator pull-right glyphicon';

        const { task } = this.props;

        if (jQuery(`#collapse${task.id}`).attr('class') === 'panel-collapse collapse') {
          iconClass += ' glyphicon-chevron-down';
        } else {
          iconClass += ' glyphicon-chevron-up';
        }

        return <div className="panel panel-default" ref={(node) => { this.rootNode = node; }}>
          <div className="panel-heading">
            <h4 className="panel-title collapsable">
              <a data-toggle="collapse"
                data-target={`#collapse${task.id}`}
                data-parent={`.${this.props.parentClass}`}>
                {task.name}
              </a>
              <i className={iconClass}
                data-toggle="collapse"
                data-target={`#collapse${task.id}`}
                data-parent={`.${this.props.parentClass}`}>
              </i>
            </h4>
          </div>
          <div id={`collapse${task.id}`} className={collapseClass}>
            <div className="panel-body">
              {this.renderForm()}
            </div>
          </div>
        </div>;
      },

      renderForm () {
        if (this.state.form) {
          const opts = {
            form:      this.state.form,
            env:       this.props.env,
            error:     this.state.error,
            pending:   this.state.pending,
            variables: this.formVariablesFromTask(this.props.task)
          };

          return <Form {...opts}/>;
        } if (this.state.error) {
          return <Error error={this.state.error} />;
        }
        return <Pending active={this.state.loading} />;
      },

      formVariablesFromTask () {
        const formVariables = {};
        const formDef = new FormDefinition(this.state.form);

        [...this.props.task.variables].forEach((varHash) => {
          if (formDef.fieldExist(varHash.name)) {
            formVariables[varHash.name] = varHash.value;
          }
        });

        return formVariables;
      },

      loadForm (taskId) {
        this.setState({ loading: true });

        this.props.env.forms.fetch(taskId)
          .done(form => this.setState({
            error: null,
            form
          }))
          .done(() => this.props.trigger('hbw:form-loaded', { entityCode: this.props.entityCode }))
          .fail(response => this.setState({ error: response }))
          .always(() => this.setState({ loading: false }));
      },

      submitForm (variables) {
        this.setState({ pending: true });

        this.props.env.forms.save({
          taskId: this.props.taskId,
          variables,
          token:  this.state.form.csrf_token
        })
          .done(() => this.setState({ error: null }))
          .done(() => this.props.trigger('hbw:form-submitted', this.props.task))
          .fail((response) => {
            this.setState({ error: response });
            return this.props.trigger('hbw:form-submitting-failed', {
              response,
              task: this.props.task
            });
          })
          .always(() => this.setState({ pending: false }));
      },

      choose () {
        this.props.trigger('hbw:task-clicked', this.props.task);
      }
    });

    return withCallbacks(EntityTask);
  }
);
