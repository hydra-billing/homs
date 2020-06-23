/* eslint no-console: "off" */
/* eslint no-restricted-syntax: "off" */

import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWForm', ['React', 'jQuery', 'HBWError', 'HBWFormDatetime',
  'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect',
  'HBWFormUser', 'HBWFormString', 'HBWFormText', 'HBWFormCheckbox',
  'HBWFormStatic', 'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
(React, jQuery, Error, DateTime, Group, Select, Submit, SubmitSelect,
  User, String, Text, Checkbox, Static, SelectTable, FileList, FileUpload) => {
  class HBWForm extends React.Component {
    state = {
      error:         null,
      submitting:    false,
      claiming:      false,
      fileUploading: false
    };

    componentDidMount () {
      jQuery(':input:enabled:visible:first').focus();
      this.props.bind(`hbw:submit-form-${this.props.id}`, () => this.setState({ submitting: true }));
      this.props.bind('hbw:form-submitting-failed', () => this.setState({ submitting: false }));
      this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
      this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
    }

    render () {
      const { env, form, assignee } = this.props;

      return <div className="hbw-form">
          <Error error={this.state.error || this.props.error}
                 env={env} />
          <form method="POST"
                ref={(f) => { this.form = f; }}
                onSubmit={this.submit}>
            {this.iterateControls(form.fields)}
            {!!assignee && this.submitControl(form.fields)}
          </form>
          {!assignee && this.renderClaimButton()}
        </div>;
    }

    renderClaimButton = () => {
      const { claiming } = this.state;
      const { translator: t } = this.props.env;

      return (
        <button
          disabled={claiming}
          className="btn btn-primary"
          onClick={this.claimTask}
        >
          {t('components.claiming.claim')}
        </button>
      );
    };

    claimTask = async () => {
      this.setState({ claiming: true });

      await this.props.env.connection.request({
        url:    `${this.props.env.connection.serverURL}/tasks/${this.props.taskId}/claim`,
        method: 'POST'
      });

      this.setState({ claiming: false });
    };

    iterateControls = fields => [...fields].map(field => (
      <div key={field.name} className="row">{this.formControl(field.name, field)}</div>
    ));

    formControl = (name, params) => {
      const { submitting, fileUploading } = this.state;
      const {
        id, variables, env, form, assignee, processInstanceId
      } = this.props;

      const opts = {
        name,
        params,
        id,
        env,
        value:           variables[name],
        formSubmitting:  submitting || fileUploading,
        fileListPresent: this.fileListPresent(form.fields),
        showSubmit:      !!assignee
      };

      if (!this.props.assignee) {
        opts.disabled = true;
      }

      const onRef = { onRef: (i) => { this[`${name}`] = i; } };

      switch (params.type) {
        case 'group':
          return <Group
            {...opts}
            variables={variables}
            {...onRef} />;
        case 'datetime':
          return <DateTime
            {...opts}
            {...onRef} />;
        case 'select':
          return <Select
            {...opts}
            {...onRef} />;
        case 'select_table':
          return <SelectTable
            {...opts}
            {...onRef} />;
        case 'submit_select':
          return <SubmitSelect
            {...opts}
            showCancelButton={!form.hide_cancel_button}
            processInstanceId={processInstanceId}
            {...onRef} />;
        case 'checkbox':
          return <Checkbox
            {...opts}
            {...onRef} />;
        case 'user':
          return <User
            {...opts}
            {...onRef} />;
        case 'string':
          return <String
            {...opts}
            {...onRef} />;
        case 'text':
          return <Text
            {...opts}
            {...onRef} />;
        case 'static':
          return <Static {...opts}/>;
        case 'file_list':
          return <FileList
            {...opts}
            {...onRef} />;
        case 'file_upload':
          return <FileUpload
            {...opts}
            {...onRef} />;
        default: return <p>{name}: Unknown control type {params.type}</p>;
      }
    };

    submitControl = (fields) => {
      const { submitting, fileUploading } = this.state;
      const { form, env, processInstanceId } = this.props;
      const last = fields[fields.length - 1];

      if (last.type !== 'submit_select') {
        return <Submit formSubmitting={submitting || fileUploading}
                       showCancelButton={!form.hide_cancel_button}
                       submitButtonName={form.submit_button_name}
                       processInstanceId={processInstanceId}
                       env={env} />;
      }

      return null;
    };

    submit = (e) => {
      e.preventDefault();
      if (this.state.submitting) {
        return null;
      }

      this.props.trigger(`hbw:validate-form-${this.props.id}`);

      if (this.isFormValid()) {
        return this.props.trigger(`hbw:submit-form-${this.props.id}`, this.serializeForm());
      }

      return null;
    };

    getElement = () => jQuery(this.form);

    isFormValid = () => this.getElement().find('.invalid').length === 0;

    fileListPresent = (fields) => {
      if (fields.map(f => [f.name, f.type])
        .some(pair => pair.every(el => ['homsOrderDataFileList', 'file_list']
          .includes(el)))) {
        return true;
      }

      for (const f of fields) {
        if ({}.hasOwnProperty.call(f, 'fields') && this.fileListPresent(f.fields)) {
          return true;
        }
      }

      return false;
    };

    notSerializableFields = () => ['static'];

    serializeForm = () => {
      let variables = {};

      this.props.form.fields.forEach((field) => {
        if (!this.notSerializableFields().includes(field.type)) {
          variables = { ...variables, ...this[`${field.name}`].serialize() };
        }
      });

      console.log(`Serialized form: ${JSON.stringify(variables)}`);

      return variables;
    };
  }

  return compose(withCallbacks, withErrorBoundary)(HBWForm);
});
