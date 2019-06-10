/* eslint no-console: "off" */
/* eslint no-restricted-syntax: "off" */

import { withCallbacks, withErrorBoundary, compose } from './helpers';

modulejs.define('HBWForm', ['React', 'jQuery', 'HBWError', 'HBWFormDatetime',
  'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect',
  'HBWFormUser', 'HBWPending', 'HBWFormString', 'HBWFormText',
  'HBWFormCheckbox', 'HBWFormStatic', 'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
(React, jQuery, Error, DateTime, Group, Select, Submit, SubmitSelect,
  User, Pending, String, Text, Checkbox, Static, SelectTable, FileList, FileUpload) => {
  class HBWForm extends React.Component {
    state = {
      error:         null,
      submitting:    false,
      fileUploading: false,
      formValues:    {}
    };

    componentDidMount () {
      this.setInitialValuesForm();
      jQuery(':input:enabled:visible:first').focus();
      this.props.bind('hbw:submit-form', () => this.setState({ submitting: true }));
      this.props.bind('hbw:form-submitting-failed', () => this.setState({ submitting: false }));
      this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
      this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
      this.props.bind('hbw:update-value', data => this.updateFormValues(data));
    }

    render () {
      return <div className='hbw-form'>
          <Error error={this.state.error || this.props.error} env={this.props.env} />
          <span>{this.props.pending}</span>
          <form method="POST" ref={(form) => { this.form = form; }} onSubmit={this.submit}>
            {this.iterateControls(this.props.form.fields)}
            {this.submitControl(this.props.form.fields)}
          </form>
        </div>;
    }

    iterateControls = fields => [...fields].map(field => (
      <div key={field.name} className="row">{this.formControl(field.name, field)}</div>
    ));

    formControl = (name, params) => {
      const opts = {
        name,
        params,
        formValues:      this.state.formValues,
        value:           this.props.variables[name],
        formSubmitting:  this.state.submitting || this.state.fileUploading,
        env:             this.props.env,
        fileListPresent: this.fileListPresent(this.props.form.fields)
      };

      const onRef = { onRef: (i) => { this[`${name}`] = i; } };

      switch (params.type) {
        case 'group':
          return <Group
            {...opts}
            variables={this.props.variables}
            {...onRef}
             />;
        case 'datetime':
          return <DateTime
            {...opts}
            {...onRef}
             />;
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
            {...onRef}/>;
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
      const last = fields[fields.length - 1];
      if (last.type !== 'submit_select') {
        // Draw default form submit button
        const params = {
          title:     'Submit the form',
          css_class: 'btn btn-primary',
          fa_class:  'fas fa-check-square'
        };

        return <Submit params={params} formSubmitting={this.state.submitting || this.state.fileUploading}
                       env={this.props.env} />;
      }

      return null;
    };

    submit = (e) => {
      e.preventDefault();
      if (this.state.submitting) {
        return null;
      }

      this.props.trigger('hbw:validate-form');

      if (this.isFormValid()) {
        return this.props.trigger('hbw:submit-form', this.serializeForm());
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

    updateFormValues = ({ name, value }) => {
      this.setState(prevState => ({ formValues: { ...prevState.formValues, [name]: value } }));
    };

    notSerializableFields = () => ['static'];

    setInitialValuesForm = () => {
      const variables = {};

      this.props.taskVariables.forEach((variable) => {
        variables[variable.name] = variable.value;
      });

      this.setState({ formValues: variables });
    };

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
