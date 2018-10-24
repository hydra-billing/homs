modulejs.define('HBWFormGroup', ['React', 'HBWFormDatetime',
  'HBWFormSubmitSelect', 'HBWFormUser', 'HBWFormSelect',
  'HBWFormString', 'HBWFormText', 'HBWFormCheckbox', 'HBWFormStatic',
  'HBWDeleteIfMixin', 'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
  (React, Datetime, SubmitSelect, User, Select, String, Text, Checkbox, Static, DeleteIfMixin, SelectTable, FileList,
    FileUpload) => React.createClass({
    mixins: [DeleteIfMixin],

    render () {
      let inputCSS = `tab-panel form-group ${this.props.params.css_class}`;
      if (this.hidden) {
        inputCSS += ' hidden';
      }

      return <div className={inputCSS}>
        <ul className='nav nav-tabs' role='tablist'>
          <li className='active' role='presentation' title={this.props.params.tooltip}>
            <a role='tab'>{this.props.params.label}</a>
          </li>
        </ul>
        <div className='tab-content' title={this.props.params.tooltip}>
          <div className='row'>
            {this.iterateControls(this.props.params.fields)}
          </div>
        </div>
      </div>;
    },

    iterateControls (fields) {
      return this.controls = fields.map((field) => {
        if (field.delimiter) {
          return <div key={field.name}>{this.formControl(field.name, field)}<div className='clearfix'></div></div>;
        } else {
          return <div key={field.name}>{this.formControl(field.name, field)}</div>;
        }
      });
    },

    formControl (name, params) {
      const opts = {
        name,
        params,
        value:          this.props.variables[name],
        formSubmitting: this.props.formSubmitting,
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
    }
  }));
