import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';
import TranslationContext from 'shared/context/translation';
import FileList from './file_list';
import ServicesTable from './services_table/services_table';

modulejs.define(
  'HBWFormGroup',
  ['React', 'HBWFormDatetime',
    'HBWFormSubmitSelect', 'HBWFormUser', 'HBWFormSelect',
    'HBWFormString', 'HBWFormText', 'HBWFormCheckbox', 'HBWFormStatic',
    'HBWFormSelectTable', 'HBWFormFileUpload', 'HBWFormRadioButton'],
  (
    React,
    Datetime,
    SubmitSelect,
    User,
    Select,
    String,
    Text,
    Checkbox,
    Static,
    SelectTable,
    FileUpload,
    RadioButton
  ) => {
    class HBWFormGroup extends React.Component {
      static contextType = TranslationContext;

      componentDidMount () {
        this.props.onRef(this);
      }

      componentWillUnmount () {
        this.props.onRef(undefined);
      }

      render () {
        const {
          name, params, hidden, task
        } = this.props;
        const inputCSS = cx('tab-panel', 'form-group', params.css_class, { hidden });
        const label = this.context.translateBP(`${task.process_key}.${task.key}.${name}`, {}, params.label);

        return <div className={inputCSS}>
        <ul className='nav nav-tabs' role='tablist'>
          <li className='active' role='presentation' title={params.tooltip}>
            <a role='tab'>{label}</a>
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
          task:           this.props.task,
          value:          this.props.variables[name],
          formSubmitting: this.props.formSubmitting,
          showSubmit:     this.props.showSubmit,
          formValues:     this.props.formValues
        };

        if (this.props.disabled) {
          opts.disabled = true;
        }

        const onRef = { onRef: (i) => { this[`${name}`] = i; } };

        const Group = compose(withConditions, withErrorBoundary)(HBWFormGroup);

        switch (params.type) {
          case 'group':
            return <Group
            {...opts}
            fileListNames={this.props.fileListNames}
            variables={this.props.variables}
            {...onRef} />;
          case 'radio_button':
            return <RadioButton
            {...opts}
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
            fileListNames={this.props.fileListNames}
            {...onRef} />;
          case 'services_table':
            return <ServicesTable
            {...opts}
            />;
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
  }
);
