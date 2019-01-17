/* eslint no-console: "off" */
/* eslint no-restricted-syntax: "off" */

import { withCallbacks } from './helpers';


modulejs.define('HBWForm', ['React', 'jQuery', 'HBWError', 'HBWFormDatetime',
  'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect',
  'HBWFormUser', 'HBWPending', 'HBWFormString', 'HBWFormText',
  'HBWFormCheckbox', 'HBWFormStatic', 'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
(React, jQuery, Error, DateTime, Group, Select, Submit, SubmitSelect,
  User, Pending, String, Text, Checkbox, Static, SelectTable, FileList, FileUpload) => {
  const Form = React.createClass({
    displayName: 'HBWForm',

    getInitialState () {
      return {
        error:         null,
        submitting:    false,
        fileUploading: false
      };
    },

    componentDidMount () {
      jQuery(':input:enabled:visible:first').focus();
      this.props.bind('hbw:submit-form', () => this.setState({ submitting: true }));
      this.props.bind('hbw:form-submitting-failed', () => this.setState({ submitting: false }));
      this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
      this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
    },

    render () {
      return <div className='hbw-form'>
          <Error error={this.state.error || this.props.error} env={this.props.env} />
          <span>{this.props.pending}</span>
          <form method="POST" ref={(form) => { this.form = form; }} onSubmit={this.submit}>
            {this.iterateControls(this.props.form.fields)}
            {this.submitControl(this.props.form.fields)}
          </form>
        </div>;
    },

    iterateControls (fields) {
      return [...fields].map(field => (
          <div key={field.name} className="row">{this.formControl(field.name, field)}</div>
      ));
    },

    formControl (name, params) {
      const opts = {
        name,
        params,
        value:           this.props.variables[name],
        formSubmitting:  this.state.submitting || this.state.fileUploading,
        env:             this.props.env,
        fileListPresent: this.fileListPresent(this.props.form.fields)
      };

      switch (params.type) {
        case 'group': return <Group {...opts} variables={this.props.variables}/>;
        case 'datetime': return <DateTime {...opts}/>;
        case 'select': return <Select {...opts}/>;
        case 'select_table': return <SelectTable {...opts}/>;
        case 'submit_select': return <SubmitSelect {...opts}/>;
        case 'checkbox': return <Checkbox {...opts}/>;
        case 'user': return <User {...opts}/>;
        case 'string': return <String {...opts}/>;
        case 'text': return <Text {...opts}/>;
        case 'static': return <Static {...opts}/>;
        case 'file_list': return <FileList {...opts}/>;
        case 'file_upload': return <FileUpload {...opts}/>;
        default: return <p>{name}: Unknown control type {params.type}</p>;
      }
    },

    submitControl (fields) {
      const last = fields[fields.length - 1];
      if (last.type !== 'submit_select') {
        // Draw default form submit button
        const params = {
          title:     'Submit the form',
          css_class: 'btn btn-primary',
          fa_class:  'fa fa-check'
        };

        return <Submit params={params} formSubmitting={this.state.submitting || this.state.fileUploading}
                       env={this.props.env} />;
      }

      return null;
    },

    submit (e) {
      e.preventDefault();
      if (this.state.submitting) {
        return null;
      }

      this.props.trigger('hbw:validate-form');

      if (this.isFormValid()) {
        return this.props.trigger('hbw:submit-form', this.serializeForm());
      }

      return null;
    },

    getElement () {
      return jQuery(this.form);
    },

    isFormValid () {
      return this.getElement().find('.invalid').length === 0;
    },

    fileListPresent (fields) {
      if (fields.map(f => [f.name, f.type]).includes(['homsOrderDataFileList', 'file_list'])) {
        return true;
      }

      for (const f of fields) {
        if ({}.hasOwnProperty.call(f, 'fields') && this.fileListPresent(f.fields)) {
          return true;
        }
      }

      return false;
    },

    serializeForm () {
      const variables = {};

      jQuery.each(this.getElement().serializeArray(), (i, field) => {
        const value = field.value === 'null' ? null : field.value;

        variables[field.name] = value;

        return value;
      });

      console.log(`Serialized form: ${JSON.stringify(variables)}`);

      return variables;
    }
  });

  return withCallbacks(Form);
});
