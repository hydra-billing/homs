import React, { useContext } from 'react';
import compose from 'shared/utils/compose';
import {
  withCallbacks
} from 'shared/hoc';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';

type Props = {
  name: string,
  label?: string,
  search: {
    hidden: boolean,
    onSearchQueryChange: React.ChangeEventHandler<HTMLInputElement>
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
    </div>);
};

export default compose(withCallbacks)(HBWServicesTableTitle);
