/* eslint react/jsx-no-undef: "off" */

import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

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
      const {
        name, params, hidden, task, env
      } = this.props;

      const inputCSS = cx('tab-panel', 'form-group', params.css_class, { hidden });

      return <div className={inputCSS}>
        <ul className='nav nav-tabs' role='tablist'>
          <li className='active' role='presentation' title={params.tooltip}>
            <a role='tab'>{params.label}</a>
          </li>
        </ul>
        <div className='tab-content' title={params.tooltip}>
          <div className='row'>
            {this.iterateControls(params.fields)}
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
        id:             this.props.id,
        value:          this.props.variables[name],
        formSubmitting: this.props.formSubmitting,
        env:            this.props.env,
        showSubmit:     this.props.showSubmit,
        formValues:     this.props.formValues
      };

      if (this.props.disabled) {
        opts.disabled = true;
      }

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

  return compose(withConditions, withErrorBoundary)(HBWFormGroup);
});
