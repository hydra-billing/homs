import React, { useContext } from 'react';
import compose from 'shared/utils/compose';
import {
  withCallbacks
} from 'shared/hoc';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';
import Select, { MultiValue } from 'react-select';
import { Column } from './services_table';

type Props = {
  name: string,
  label?: string,
  search: {
    hidden: boolean,
    onSearchQueryChange: React.ChangeEventHandler<HTMLInputElement>
  },
  columnsControl: {
    visibleColumns: Column[],
    columns: Column[],
    onChange: ((newValue: MultiValue<Column>) => void)
  },
  task: {
    key: string,
    process_key: string
  }
}

const HBWServicesTableTitle: React.FC<Props> = (props) => {
  const { translateBP, translate } = useContext(TranslationContext) as TranslationContextType;

  return (
    <div className="table-title">
      <div className="left">
        <span className="services-table-label">
          { translateBP(`${props.task.process_key}.${props.task.key}.${props.name}.label`, {}, props.label) }
        </span>
        <div className="input-wrapper">
          <input
            placeholder={translate('components.services_table.table.title.search.placeholder')}
            type="search"
            className="form-control"
            onChange={props.search.onSearchQueryChange}
          />
        </div>
      </div>
      <div className="right">
        <div className="columns-setting">
          <Select
            name={props.name}
            className="react-select-container"
            classNamePrefix="react-select"
            isMulti
            closeMenuOnSelect={false}
            hideSelectedOptions={false}
            controlShouldRenderValue={false}
            isClearable={false}
            isSearchable={false}
            placeholder={translate('components.services_table.table.title.columns_setting.placeholder')}
            getOptionValue={option => option.name }
            defaultValue={props.columnsControl.visibleColumns}
            onChange={props.columnsControl.onChange}
            options={props.columnsControl.columns}
          />
        </div>
      </div>
    </div>);
};

export default compose(withCallbacks)(HBWServicesTableTitle);
