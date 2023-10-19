import React, { useContext, useState } from 'react';
import cn from 'classnames';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';
import compose from 'shared/utils/compose';
import {
  withConditions, withSelect, withErrorBoundary, withValidations, withCallbacks
} from 'shared/hoc';
import convertToDateFNSDateFormat from 'shared/utils/to_fns_date_format';
import { localizer } from '../../init/date_localizer';

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

type Column = {
  name: string,
  nameSuffix?: string,
  id: string
}

function getColumnsToShow (tableColumns: Column[], hiddenColumns: string[]) {
  return [...tableColumns].filter(column => !hiddenColumns.includes(column.id));
}

function isColumnVisible (tableColumns: Column[], columnId: String) {
  return tableColumns.some(column => column.id === columnId);
}

const HBWFormServicesTable: React.FC<Props> = (props) => {
  const { translateBP, translate, locale } = useContext(TranslationContext) as TranslationContextType;
  const tableColumns: Column[] = [
    {
      name: translate('components.services_table.table.columns.action'),
      id:   'action'
    },
    {
      name: translate('components.services_table.table.columns.equipmentName'),
      id:   'equipmentName',
    },
    {
      name: translate('components.services_table.table.columns.serviceName'),
      id:   'serviceName',
    },
    {
      name:       translate('components.services_table.table.columns.servicePrice'),
      nameSuffix: props.params.currency_code,
      id:         'servicePrice',
    },
    {
      name: translate('components.services_table.table.columns.serviceQuantity'),
      id:   'serviceQuantity',
    },
    {
      name:       translate('components.services_table.table.columns.serviceTotalPrice'),
      nameSuffix: props.params.currency_code,
      id:         'serviceTotalPrice',
    },
    {
      name: translate('components.services_table.table.columns.subscriptionBeginDate'),
      id:   'subscriptionBeginDate',
    },
    {
      name: translate('components.services_table.table.columns.subscriptionEndDate'),
      id:   'subscriptionEndDate',
    },
    {
      name: translate('components.services_table.table.columns.allowProvisioning'),
      id:   'allowProvisioning',
    },
    {
      name: translate('components.services_table.table.columns.serviceAddress'),
      id:   'serviceAddress',
    },
    {
      name: translate('components.services_table.table.columns.macAddress'),
      id:   'macAddress',
    },
    {
      name: translate('components.services_table.table.columns.ipAddress'),
      id:   'ipAddress',
    },
    {
      name: translate('components.services_table.table.columns.vlan'),
      id:   'vlan',
    },
    {
      name: translate('components.services_table.table.columns.phone'),
      id:   'phone',
    }
  ];

  const defaultHiddenColumns = [
    'serviceAddress', 'macAddress', 'ipAddress', 'vlan', 'phone'
  ];

  const [value] = useState(props.params.value);
  const [columns] = useState(
    getColumnsToShow(tableColumns, props.params.hidden_columns || defaultHiddenColumns)
  );
  const dateTimeFormat = convertToDateFNSDateFormat(props.params.date_format);

  const { localizeDatetime } = localizer({ code: locale.code, dateTimeFormat });

  const checkboxIcon = (checkboxValue: boolean) => {
    const checkedIcon = ['far', 'check-square'];
    const uncheckedIcon = ['far', 'square'];
    return checkboxValue ? checkedIcon : uncheckedIcon;
  };

  const renderChildRow = (serviceRow: TableRow, index: number) => <tr key={`_${index}_${serviceRow.serviceId}`}>
      <td>Child Action</td>
      { isColumnVisible(columns, 'equipmentName') && <td>
        {serviceRow.equipmentName}
      </td> }
      { isColumnVisible(columns, 'serviceName') && <td>
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
      { isColumnVisible(columns, 'servicePrice') && <td>
        {serviceRow.servicePrice}
      </td> }
      { isColumnVisible(columns, 'serviceQuantity') && <td>
        {serviceRow.serviceQuantity} {serviceRow.serviceUnit}
      </td> }
      { isColumnVisible(columns, 'serviceTotalPrice') && <td>
        {serviceRow.serviceTotalPrice}
      </td> }
      { isColumnVisible(columns, 'subscriptionBeginDate') && <td>
        {localizeDatetime(serviceRow.subscriptionBeginDate)}
      </td> }
      { isColumnVisible(columns, 'subscriptionEndDate') && <td>
        {serviceRow.subscriptionEndDate ? localizeDatetime(serviceRow.subscriptionEndDate) : '-'}
      </td> }
      { isColumnVisible(columns, 'allowProvisioning') && <td className="checkbox">
        <div className="form-check">
          <div>
            <FontAwesomeIcon
              className='hbw-checkbox'
              icon={checkboxIcon(serviceRow.allowProvisioning) as IconProp}
            />
          </div>
        </div>
      </td> }
      { isColumnVisible(columns, 'serviceAddress') && <td className="white-space-wrap">
        {serviceRow.serviceAddress}
      </td> }
      { isColumnVisible(columns, 'macAddress') && <td>
        {serviceRow.macAddress}
      </td> }
      { isColumnVisible(columns, 'ipAddress') && <td>
        {serviceRow.ipAddress}
      </td> }
      { isColumnVisible(columns, 'vlan') && <td>
        {serviceRow.vlan}
      </td> }
      { isColumnVisible(columns, 'phone') && <td>
        {serviceRow.phone}
      </td> }
    </tr>;

  const renderParentRow = (serviceRow: Service, index: number) => {
    const parentRow = <tr key={`${index}_${serviceRow.serviceId}`}>
      <td>Action</td>
      { isColumnVisible(columns, 'equipmentName') && <td>
        {serviceRow.equipmentName}
      </td> }
      { isColumnVisible(columns, 'serviceName') && <td>
        {serviceRow.serviceName}
      </td> }
      { isColumnVisible(columns, 'servicePrice') && <td>
        {serviceRow.servicePrice}
      </td> }
      { isColumnVisible(columns, 'serviceQuantity') && <td>
        {serviceRow.serviceQuantity} {serviceRow.serviceUnit}
      </td> }
      { isColumnVisible(columns, 'serviceTotalPrice') && <td>
        {serviceRow.serviceTotalPrice}
      </td> }
      { isColumnVisible(columns, 'subscriptionBeginDate') && <td>
        {localizeDatetime(serviceRow.subscriptionBeginDate)}
      </td> }
      { isColumnVisible(columns, 'subscriptionEndDate') && <td>
        {serviceRow.subscriptionEndDate ? localizeDatetime(serviceRow.subscriptionEndDate) : '-'}
      </td> }
      { isColumnVisible(columns, 'allowProvisioning') && <td className="checkbox">
        <div className="form-check">
          <div>
            <FontAwesomeIcon
              className='hbw-checkbox'
              icon={checkboxIcon(serviceRow.allowProvisioning) as IconProp}
            />
          </div>
        </div>
      </td> }
      { isColumnVisible(columns, 'serviceAddress') && <td className="white-space-wrap">
        {serviceRow.serviceAddress}
      </td> }
      { isColumnVisible(columns, 'macAddress') && <td>
        {serviceRow.macAddress}
      </td> }
      { isColumnVisible(columns, 'ipAddress') && <td>
        {serviceRow.ipAddress}
      </td> }
      { isColumnVisible(columns, 'vlan') && <td>
        {serviceRow.vlan}
      </td> }
      { isColumnVisible(columns, 'phone') && <td>
        {serviceRow.phone}
      </td> }
    </tr>;

    const childRows = (serviceRow?.childServices || []).map(
      (_serviceRow, _index) => renderChildRow(_serviceRow, _index)
    );
    return [parentRow, ...childRows];
  };

  const renderTableBody = () => value.map((serviceRow, index) => <>
    {renderParentRow(serviceRow, index)}
  </>);

  const renderTableHeader = () => columns.map(column => <th key={column.name} className="white-space-no-wrap">
      {[column.name, column.nameSuffix].filter(el => el).join(', ')}
    </th>);

  const task = { ...props.task };
  const label = translateBP(`${task.process_key}.${task.key}.${props.name}.label`, {}, props.params.label);
  const cssClass = cn(props.params.css_class, { hidden: props.hidden });
  const labelCss = cn(props.params.label_css, 'select-table-label');
  const tableCss = cn('services-select-table', 'table', 'table-stripper', 'table-bordered', {
    disabled: !props.params.editable || props.disabled
  });
  const formGroupCss = cn('hbw-table', 'form-group');

  return <div className={cssClass}>
    <span className={labelCss}>{label}</span>
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
