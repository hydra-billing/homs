modulejs.define('HBWForm', ['React', 'jQuery', 'HBWError', 'HBWFormDatetime',
  'HBWFormGroup', 'HBWFormSelect', 'HBWFormSubmit', 'HBWFormSubmitSelect',
  'HBWFormUser', 'HBWPending', 'HBWFormString', 'HBWFormText',
  'HBWFormCheckbox', 'HBWFormStatic', 'HBWCallbacksMixin', 'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
  (React, jQuery, Error, DateTime, Group, Select, Submit, SubmitSelect,
    User, Pending, String, Text, Checkbox, Static, CallbacksMixin, SelectTable, FileList, FileUpload) => React.createClass({
    mixins: [CallbacksMixin],

    getInitialState () {
      return {
        error:         null,
        submitting:    false,
        fileUploading: false
      };
    },

    componentDidMount () {
      jQuery(':input:enabled:visible:first').focus();
      this.bind('hbw:submit-form', () => this.setState({ submitting: true }));
      this.bind('hbw:form-submitting-failed', () => this.setState({ submitting: false }));
      this.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
      this.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
    },

    render () {
      return <div className='hbw-form'>
        <Error error={this.state.error || this.props.error} />
        <span>{this.props.pending}</span>
        <form method="POST" ref="form" onSubmit={this.submit}>
          {this.iterateControls(this.props.form.fields)}
          {this.submitControl(this.props.form.fields)}
        </form>
      </div>;
    },

    iterateControls (fields) {
      return Array.from(fields).map(field => <div key={field.name} className="row">{this.formControl(field.name, field)}</div>);
    },

    formControl (name, params) {
      const opts = {
        name,
        params,
        value:          this.props.variables[name],
        formSubmitting: this.state.submitting || this.state.fileUploading,
        env:            this.props.env
      };

      switch (params.type) {
        case 'group': return <Group {...opts} variables={this.props.variables}/>;
        case 'datetime': return <Datetime {...opts}/>;
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

        return <Submit params={params} formSubmitting={this.state.submitting || this.state.fileUploading} />;
      }
    },

    submit (e) {
      e.preventDefault();
      if (this.state.submitting) {
        return;
      }
      this.trigger('hbw:validate-form');
      if (this.isFormValid()) {
        return this.trigger('hbw:submit-form', this.serializeForm());
      }
    },

    getElement () {
      return jQuery(this.refs.form);
    },

    isFormValid () {
      return this.getElement().find('input[type="text"].invalid').length === 0;
    },

    serializeForm () {
      const variables = {};

      jQuery.each(this.getElement().serializeArray(), (i, field) => {
        if (field.value === 'null') {
          field.value = null;
        }

        return variables[field.name] = field.value;
      });

      // get hands dirty with select2 elements,
      // 'cause they are not grabbed with serializeArray()
      const selects = jQuery(this.getElement()).find('select.select2-hidden-accessible');

      jQuery.each(selects, (i, select) => {
        const name = jQuery(select).attr('name');
        const { value } = select;
        return variables[name] = value;
      });

      console.log(`Serialized form: ${JSON.stringify(variables)}`);

      return variables;
    }
  }));
