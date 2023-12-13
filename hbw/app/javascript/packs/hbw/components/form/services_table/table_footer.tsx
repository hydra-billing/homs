import React, { useContext } from 'react';
import compose from 'shared/utils/compose';
import {
  withCallbacks
} from 'shared/hoc';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';

type Props = {
  handleAddServiceClick: React.MouseEventHandler<HTMLButtonElement>,
};

const HBWServicesTableFooter: React.FC<Props> = (props) => {
  const { translate } = useContext(TranslationContext) as TranslationContextType;

  return (
    <div className="table-footer">
      <button
        type="button"
        className="btn btn-info add-service-button"
        onClick={props.handleAddServiceClick}
      >
        {translate('components.services_table.table.title.add_service')}
      </button>
    </div>);
};

export default compose(withCallbacks)(HBWServicesTableFooter);
