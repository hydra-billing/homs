import React, { ChangeEvent, useContext, useState } from 'react';
import cn from 'classnames';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';
import compose from 'shared/utils/compose';
import {
  withConditions, withSelect, withErrorBoundary, withValidations, withCallbacks
} from 'shared/hoc';
import convertToDateFNSDateFormat from 'shared/utils/to_fns_date_format';
import { localizer } from '../../../init/date_localizer';
import HBWServicesTableTitle from './table_title';

type Entry = {
  id: number,
  name: string
}

type Props = {
  value?: string,
  name: string,
  hidden: boolean,
  disabled: boolean,
  editable: boolean,
  params: {
    name: string,
    value: Service[],
    current_value: string,
    label: string,
    editable: boolean,
    css_class?: string,
    label_css?: string,
    customer_id: number,
    account_id: number,
    contract_id: number,
    equipment_types: Entry[],
    individual_pricing: boolean,
    hidden_columns: string[],
    date_format: string,
    currency_code: string,
    disable_search: boolean,
    variables: object[]
  },
  task: {
    key: string,
    process_key: string
  }
}

type TableRow = {
  serviceId: number,
  serviceName: string
  equipmentId: number,
  equipmentName: string,
  servicePrice: number,
  serviceQuantity?: number,
  serviceUnit: string,
  serviceTotalPrice: number,
  subscriptionId: number,
  parSubscriptionId?: number,
  subscriptionBeginDate: string,
  subscriptionEndDate?: string,
  allowProvisioning: boolean,
  serviceAddress?: string,
  macAddress?: string,
  ipAddress?: string,
  vlan?: number,
  phone?: string
  rowState: number
}

type Service = TableRow & {
  childServices: TableRow[]
}

export type Column = {
  name: string,
  label: string,
  isVisible: boolean
}

const getColumnsToShow = (tableColumns: Column[], hiddenColumns: string[]) => [...tableColumns].map(column => ({
  ...column,
  isVisible: !hiddenColumns.includes(column.name)
}));

const HBWFormServicesTable: React.FC<Props> = (props) => {
  const { translate, locale } = useContext(TranslationContext) as TranslationContextType;

  const tableColumns: Column[] = [
    {
      name:      'action',
      label:     translate('components.services_table.table.columns.action'),
      isVisible: true
    },
    {
      name:      'equipmentName',
      label:     translate('components.services_table.table.columns.equipmentName'),
      isVisible: true
    },
    {
      name:      'serviceName',
      label:     translate('components.services_table.table.columns.serviceName'),
      isVisible: true
    },
    {
      name:      'servicePrice',
      label:     `${translate('components.services_table.table.columns.servicePrice')}, ${props.params.currency_code}`,
      isVisible: true
    },
    {
      name:      'serviceQuantity',
      label:     translate('components.services_table.table.columns.serviceQuantity'),
      isVisible: true
    },
    {
      name:      'serviceTotalPrice',
      // eslint-disable-next-line max-len
      label:     `${translate('components.services_table.table.columns.serviceTotalPrice')}, ${props.params.currency_code}`,
      isVisible: true
    },
    {
      name:      'subscriptionBeginDate',
      label:     translate('components.services_table.table.columns.subscriptionBeginDate'),
      isVisible: true
    },
    {
      name:      'subscriptionEndDate',
      label:     translate('components.services_table.table.columns.subscriptionEndDate'),
      isVisible: true
    },
    {
      name:      'allowProvisioning',
      label:     translate('components.services_table.table.columns.allowProvisioning'),
      isVisible: true
    },
    {
      name:      'serviceAddress',
      label:     translate('components.services_table.table.columns.serviceAddress'),
      isVisible: true
    },
    {
      name:      'macAddress',
      label:     translate('components.services_table.table.columns.macAddress'),
      isVisible: true
    },
    {
      name:      'ipAddress',
      label:     translate('components.services_table.table.columns.ipAddress'),
      isVisible: true
    },
    {
      name:      'vlan',
      label:     translate('components.services_table.table.columns.vlan'),
      isVisible: true
    },
    {
      name:      'phone',
      label:     translate('components.services_table.table.columns.phone'),
      isVisible: true
    }
  ];
  const defaultHiddenColumns = [
    'serviceAddress', 'macAddress', 'ipAddress', 'vlan', 'phone'
  ];

  const [value] = useState(props.params.value);
  const [searchQuery, setSearchQuery] = useState('');
  const [columns] = useState<readonly Column[]>(
    getColumnsToShow(tableColumns, props.params.hidden_columns || defaultHiddenColumns)
  );

  const dateTimeFormat = convertToDateFNSDateFormat(props.params.date_format);
  const { localizeDatetime } = localizer({ code: locale.code, dateTimeFormat });

  const isColumnVisible = (columnName: String) => (
    columns.some(column => column.name === columnName && column.isVisible)
  );

  const isRowSatisfiesSearchQuery = (entry: TableRow) => columns.map(column => entry[column.name as keyof TableRow]
    ?.toString()
    ?.toLowerCase())
    .join(',')
    .includes(searchQuery.toLowerCase());

  const handleSearchQueryChange = (e: ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };

  const checkboxIcon = (checkboxValue: boolean) => {
    const checkedIcon = ['far', 'check-square'];
    const uncheckedIcon = ['far', 'square'];
    return checkboxValue ? checkedIcon : uncheckedIcon;
  };

  const renderChildRow = (serviceRow: TableRow, index: number) => (
    <tr key={`_${index}_${serviceRow.serviceId}`}>
      { isColumnVisible('action') && <td>
          Child Action
      </td> }
      { isColumnVisible('equipmentName') && <td>
        {serviceRow.equipmentName}
      </td> }
      { isColumnVisible('serviceName') && <td>
          <div className="service-name">
              <div className="prefix-icon">
                  <FontAwesomeIcon
                      icon='chevron-right'
                  />
              </div>
              <div>
                {serviceRow.serviceName}
              </div>
          </div>
      </td> }
      { isColumnVisible('servicePrice') && <td>
        {serviceRow.servicePrice}
      </td> }
      { isColumnVisible('serviceQuantity') && <td>
        {serviceRow.serviceQuantity} {serviceRow.serviceUnit}
      </td> }
      { isColumnVisible('serviceTotalPrice') && <td>
        {serviceRow.serviceTotalPrice}
      </td> }
      { isColumnVisible('subscriptionBeginDate') && <td>
        {localizeDatetime(serviceRow.subscriptionBeginDate)}
      </td> }
      { isColumnVisible('subscriptionEndDate') && <td>
        {serviceRow.subscriptionEndDate ? localizeDatetime(serviceRow.subscriptionEndDate) : '-'}
      </td> }
      { isColumnVisible('allowProvisioning') && <td>
          <div className="form-check checkbox">
              <div>
                  <FontAwesomeIcon
                      className='hbw-checkbox'
                      icon={checkboxIcon(serviceRow.allowProvisioning) as IconProp}
                  />
              </div>
          </div>
      </td> }
      { isColumnVisible('serviceAddress') && <td className="white-space-wrap">
        {serviceRow.serviceAddress}
      </td> }
      { isColumnVisible('macAddress') && <td>
        {serviceRow.macAddress}
      </td> }
      { isColumnVisible('ipAddress') && <td>
        {serviceRow.ipAddress}
      </td> }
      { isColumnVisible('vlan') && <td>
        {serviceRow.vlan}
      </td> }
      { isColumnVisible('phone') && <td>
        {serviceRow.phone}
      </td> }
    </tr>
  );

  const renderParentRow = (serviceRow: Service, index: number) => {
    if (isRowSatisfiesSearchQuery(serviceRow)
      || serviceRow.childServices.some(childServiceRow => isRowSatisfiesSearchQuery(childServiceRow))
    ) {
      const parentRow = (
        <tr key={`${index}_${serviceRow.serviceId}`}>
          { isColumnVisible('action') && <td>
              Action
          </td> }
          { isColumnVisible('equipmentName') && <td>
            {serviceRow.equipmentName}
          </td> }
          { isColumnVisible('serviceName') && <td>
            {serviceRow.serviceName}
          </td> }
          { isColumnVisible('servicePrice') && <td>
            {serviceRow.servicePrice}
          </td> }
          { isColumnVisible('serviceQuantity') && <td>
            {serviceRow.serviceQuantity} {serviceRow.serviceUnit}
          </td> }
          { isColumnVisible('serviceTotalPrice') && <td>
            {serviceRow.serviceTotalPrice}
          </td> }
          { isColumnVisible('subscriptionBeginDate') && <td>
            {localizeDatetime(serviceRow.subscriptionBeginDate)}
          </td> }
          { isColumnVisible('subscriptionEndDate') && <td>
            {serviceRow.subscriptionEndDate ? localizeDatetime(serviceRow.subscriptionEndDate) : '-'}
          </td> }
          { isColumnVisible('allowProvisioning') && <td>
              <div className="form-check checkbox">
                  <div>
                      <FontAwesomeIcon
                          className='hbw-checkbox'
                          icon={checkboxIcon(serviceRow.allowProvisioning) as IconProp}
                      />
                  </div>
              </div>
          </td> }
          { isColumnVisible('serviceAddress') && <td className="white-space-wrap">
            {serviceRow.serviceAddress}
          </td> }
          { isColumnVisible('macAddress') && <td>
            {serviceRow.macAddress}
          </td> }
          { isColumnVisible('ipAddress') && <td>
            {serviceRow.ipAddress}
          </td> }
          { isColumnVisible('vlan') && <td>
            {serviceRow.vlan}
          </td> }
          { isColumnVisible('phone') && <td>
            {serviceRow.phone}
          </td> }
        </tr>
      );

      const childRows = serviceRow?.childServices
        .filter(childServiceRow => isRowSatisfiesSearchQuery(childServiceRow))
        .map((_serviceRow, _index) => renderChildRow(_serviceRow, _index));
      return [parentRow, ...childRows];
    }
    return [];
  };

  const renderTableHeader = () => columns.map(column => (column.isVisible ? <th key={column.name}>
    {column.label}
  </th> : null));

  const renderTableBody = () => value.map((serviceRow, index) => <>
    {renderParentRow(serviceRow, index)}
  </>);

  const cssClass = cn('services-select-table', props.params.css_class, { hidden: props.hidden });
  const tableCss = cn('table', 'table-stripper', 'table-bordered', {
    disabled: !props.params.editable || props.disabled
  });
  const formGroupCss = cn('hbw-table', 'form-group');

  return <div className={cssClass}>
    <HBWServicesTableTitle
      name={props.name}
      label={props.params.label}
      search={{
        hidden:              props.params.disable_search,
        searchQuery,
        onSearchQueryChange: handleSearchQueryChange
      }}
      task={props.task}
    />
    <div className={formGroupCss}>
      <table className={tableCss}>
        <thead className='thead-inverse'>
        <tr key='columns'>
          {renderTableHeader()}
        </tr>
        </thead>
        <tbody>
        {renderTableBody()}
        </tbody>
      </table>
    </div>
  </div>;
};

export default compose(
  withSelect,
  withCallbacks,
  withConditions,
  withValidations,
  withErrorBoundary
)(HBWFormServicesTable);
