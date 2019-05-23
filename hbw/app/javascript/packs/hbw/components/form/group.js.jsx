/* eslint react/jsx-no-undef: "off" */

import { withConditions } from '../helpers';

modulejs.define('HBWFormGroup', ['React', 'HBWFormDatetime',
  'HBWFormSubmitSelect', 'HBWFormUser', 'HBWFormSelect',
  'HBWFormString', 'HBWFormText', 'HBWFormCheckbox', 'HBWFormStatic',
  'HBWFormSelectTable', 'HBWFormFileList', 'HBWFormFileUpload'],
(React, Datetime, SubmitSelect, User, Select, String, Text, Checkbox, Static, SelectTable, FileList, FileUpload) => {
  class HBWFormGroup extends React.Component {
    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    render () {
      let inputCSS = `tab-panel form-group ${this.props.params.css_class}`;
      if (this.props.hidden) {
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
    }

    iterateControls = (fields) => {
      this.controls = fields.map((field) => {
        if (field.delimiter) {
          return <div key={field.name}>{this.formControl(field.name, field)}<div className='clearfix'></div></div>;
        } else {
          return <div key={field.name}>{this.formControl(field.name, field)}</div>;
        }
      });

      return this.controls;
    };

    formControl = (name, params) => {
      const opts = {
        name,
        params,
        formValues:     this.props.formValues,
        value:          this.props.variables[name],
        formSubmitting: this.props.formSubmitting,
        env:            this.props.env
      };

      const onRef = { onRef: (i) => { this[`${name}`] = i; } };

      switch (params.type) {
        case 'group':
          return <Group
            {...opts}
            variables={this.props.variables}
            {...onRef} />;
        case 'datetime':
          return <Datetime
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
          return <Static
            {...opts}/>;
        case 'file_list':
          return <FileList
            {...opts}
            {...onRef} />;
        case 'file_upload':
          return <FileUpload
            {...opts}
            fileListPresent={this.props.fileListPresent}
            {...onRef} />;
        default: return <p>{name}: Unknown control type {params.type}</p>;
      }
    };

    notSerializableFields = () => ['static'];

    serialize = () => {
      if (this.props.hidden) {
        return null;
      }

      let variables = {};

      this.props.params.fields.forEach((field) => {
        if (!this.notSerializableFields().includes(field.type)) {
          variables = { ...variables, ...this[`${field.name}`].serialize() };
        }
      });

      return variables;
    };
  }

  return withConditions(HBWFormGroup);
});
