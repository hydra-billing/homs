/* eslint no-console: "off" */
/* eslint no-restricted-syntax: "off" */

import compose from 'shared/utils/compose';
import { withCallbacks, withErrorBoundary } from 'shared/hoc';
import ConnectionContext from 'shared/context/connection';
import FileList from './form/file_list';
import ServicesTable from './form/services_table/services_table';
import ClaimButton from './form/claim_button';
import Error from './error';

modulejs.define(
  'HBWForm',
  ['React', 'jQuery', 'HBWFormDatetime',
    'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect',
    'HBWFormUser', 'HBWFormString', 'HBWFormText', 'HBWFormCheckbox',
    'HBWFormStatic', 'HBWFormSelectTable', 'HBWFormFileUpload', 'HBWFormRadioButton'],
  (
    React,
    jQuery,
    DateTime,
    Group,
    Select,
    Submit,
    SubmitSelect,
    User,
    String,
    Text,
    Checkbox,
    Static,
    SelectTable,
    FileUpload,
    RadioButton
  ) => {
    class HBWForm extends React.Component {
      static contextType = ConnectionContext;

      state = {
        error:         null,
        submitting:    false,
        claiming:      false,
        fileUploading: false,
        formValues:    {}
      };

      componentDidMount () {
        this.setInitialFormValues();
        jQuery('.hbw-form :input:enabled:visible:first').focus();
        this.props.bind(`hbw:submit-form-${this.props.id}`, () => this.setState({ submitting: true }));
        this.props.bind('hbw:form-submitting-failed', () => this.setState({ submitting: false }));
        this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
        this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
        this.props.bind(`hbw:update-value-${this.props.id}`, data => this.updateFormValues(data));
      }

      render () {
        const { form, assignee } = this.props.task;

        return <div className="hbw-form">
          <Error error={this.state.error || this.props.error} />
          <form method="POST"
                ref={(f) => { this.form = f; }}
                onSubmit={this.submit}>
            {this.iterateControls(form.fields)}
            {!!assignee && this.submitControl(form.fields)}
          </form>
          {!assignee && this.renderClaimButton()}
        </div>;
      }

      renderClaimButton = () => <ClaimButton disabled={this.state.claiming} onClick={this.claimTask}/>;

      claimTask = async () => {
        this.setState({ claiming: true });

        const { request, serverURL } = this.context;

        await request({
          url:    `${serverURL}/tasks/${this.props.task.id}/claim`,
          method: 'POST'
        });

        this.setState({ claiming: false });
      };

      iterateControls = fields => [...fields].map(field => (
      <div key={field.name} className="row">{this.formControl(field.name, field)}</div>
      ));

      formControl = (name, params) => {
        const { submitting, fileUploading, formValues } = this.state;
        const { id, variables, task } = this.props;

        const { form, assignee } = task;

        const opts = {
          name,
          params,
          id,
          task,
          formValues,
          value:          variables[name],
          formSubmitting: submitting || fileUploading,
          fileListNames:  this.getFileListNames(),
          showSubmit:     !!assignee
        };

        if (!assignee) {
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
          case 'radio_button':
            return <RadioButton
            {...opts}
            {...onRef} />;
          case 'services_table':
            return <ServicesTable
            {...opts}
            {...onRef}
            />;
          default: return <p>{name}: Unknown control type {params.type}</p>;
        }
      };

      submitControl = (fields) => {
        const { submitting, fileUploading } = this.state;
        const { task } = this.props;
        const last = fields[fields.length - 1];

        if (last.type !== 'submit_select') {
          return <Submit formSubmitting={submitting || fileUploading}
                       showCancelButton={!task.form.hide_cancel_button}
                       submitButtonName={task.form.submit_button_name}
                       cancelButtonName={task.form.cancel_button_name}
                       processInstanceId={task.process_instance_id} />;
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

      getFieldsByType = type => this.getFlattenFields().filter(field => field.type === type);

      getFileListNames = () => this.getFieldsByType('file_list').map(f => f.name).sort();

      updateFormValues = ({ name, value }) => {
        this.setState(prevState => ({ formValues: { ...prevState.formValues, [name]: value } }));
      };

      notSerializableFields = () => ['static'];

      setInitialFormValues = () => {
        const selectFieldsWithDefaults = this.getSelectFieldsWithDefaults();
        const isSelect = fieldName => selectFieldsWithDefaults.map(({ selectName }) => selectName).includes(fieldName);

        const variables = this.props.taskVariables.reduce((result, { name, value }) => {
          if (isSelect(name) && this.isEmpty(value)) {
            const { defaultValue } = selectFieldsWithDefaults.find(({ selectName }) => selectName === name);

            result[name] = Array.isArray(defaultValue) ? defaultValue[0] : defaultValue;
          } else {
            result[name] = value;
          }

          return result;
        }, {});

        this.setState({ formValues: variables });
      };

      isEmpty = value => value === null || value === '';

      getSelectFieldsWithDefaults = () => (
        this.getFlattenFields()
          .filter(({
            type, mode, nullable, choices
          }) => (
            type === 'select' && mode === 'select' && nullable === false && choices.length > 0
          ))
          .map(({ name, choices }) => ({ selectName: name, defaultValue: choices[0] }))
      );

      getFlattenFields = () => this.props.task.form.fields.flatMap(
        field => (field.type === 'group' ? field.fields : field)
      );

      serializeForm = () => {
        let variables = {};

        this.props.task.form.fields.forEach((field) => {
          if (!this.notSerializableFields().includes(field.type)) {
            variables = { ...variables, ...this[`${field.name}`].serialize() };
          }
        });

        console.log(`Serialized form: ${JSON.stringify(variables)}`);
        return variables;
      };
    }

    return compose(withCallbacks, withErrorBoundary)(HBWForm);
  }
);
