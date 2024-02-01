import React, { useContext, useState } from 'react';
import TranslationContext, { ContextType as TranslationContextType } from 'shared/context/translation';
import compose from 'shared/utils/compose';
import Select, { SingleValue } from 'react-select';
import DatePickerWrapper from 'shared/element/date_picker_wrapper';
import convertToDateFNSDateFormat from 'shared/utils/to_fns_date_format';
import { format } from 'date-fns';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { AvailableService, SERVICE_ROW_STATES, Service } from './services_table';
import HBWModalWrapper from './modal_wrapper';

const ISODateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx";

type Props = {
  show: boolean,
  individualPricing: boolean,
  currencyCode: string,
  services: Array<AvailableService>,
  dateFormat: string,
  onSubmit: (service: Service) => void,
  onClose: () => void,
}

const HBWServiceAddModal = (props: Props) => {
  const { locale, translate } = useContext(TranslationContext) as TranslationContextType;

  const [selectedService, setSelectedService] = useState<AvailableService | null>(null);
  const [price, setPrice] = useState<number>(0);
  const [quantity, setQuantity] = useState<number>(1);
  const [totalPrice, setTotalPrice] = useState<number>(0);
  const [beginDate, setBeginDate] = useState<Date | null>(null);
  const [endDate, setEndDate] = useState<Date | null>(null);
  const [allowProvisioning, setAllowProvisioning] = useState<boolean>(false);

  const handleServiceChange = (newValue: SingleValue<AvailableService>) => {
    if (newValue) {
      setSelectedService(newValue);
      setPrice(newValue.servicePrice);
      setQuantity(1);
      setTotalPrice(newValue.servicePrice);
    } else {
      setSelectedService(null);
      setPrice(0);
      setQuantity(1);
      setTotalPrice(0);
    }
  };

  const handlePriceChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseFloat(event.target.value);
    setPrice(Number.isNaN(value) ? 0 : value);
    setTotalPrice(Number.isNaN(value) ? 0 : value * (quantity || 1));
  };

  const handleQuantityChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newQuantity = parseInt(event.target.value);
    setQuantity(newQuantity);
    setTotalPrice(+(price * (newQuantity || 1)).toFixed(2));
  };

  const handleTotalPriceChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseFloat(event.target.value);
    setTotalPrice(Number.isNaN(value) ? 0 : value);
  };

  const handleStartDateChange = (date: Date) => {
    setBeginDate(date);
  };

  const handleEndDateChange = (date: Date) => {
    setEndDate(date);
  };

  const handleAllowProvisioningChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setAllowProvisioning(event.target.checked);
  };

  const resetModal = () => {
    setSelectedService(null);
    setPrice(0);
    setQuantity(1);
    setTotalPrice(0);
    setBeginDate(null);
    setEndDate(null);
    setAllowProvisioning(false);
  };

  const handleSubmit = () => {
    if (selectedService) {
      const serviceToAdd: Service = {
        serviceId:             selectedService.serviceId,
        serviceName:           selectedService.serviceName,
        servicePrice:          price,
        serviceUnit:           selectedService.serviceUnit,
        serviceQuantity:       quantity || undefined,
        serviceTotalPrice:     totalPrice,
        subscriptionBeginDate: beginDate ? format(beginDate, ISODateFormat) : '',
        subscriptionEndDate:   endDate ? format(endDate, ISODateFormat) : '',
        allowProvisioning,
        rowState:              SERVICE_ROW_STATES.NEW,
        childServices:         [],
      };

      resetModal();
      props.onSubmit(serviceToAdd);
    }
  };

  const handleClose = () => {
    resetModal();
    props.onClose();
  };

  const dateFormat = props.dateFormat ? convertToDateFNSDateFormat(props.dateFormat) : 'MM/dd/yyyy';
  const checkboxIcon = (checkboxValue: boolean) => {
    const checkedIcon = ['far', 'check-square'];
    const uncheckedIcon = ['far', 'square'];
    return checkboxValue ? checkedIcon : uncheckedIcon;
  };

  const renderModalContent = () => (<div className='container-fluid'>
    <div className='row'>
      <div className='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
        <div className='form-group'>
          <span className='select-label'>
            {translate('components.services_table.modals.service_add.service_select')}
          </span>
          <Select
            name='service-select'
            className='react-select-container'
            classNamePrefix="react-select"
            required
            isClearable={false}
            isSearchable={true}
            placeholder={
              translate('components.services_table.modals.service_add.service_select_placeholder')
            }
            value={selectedService}
            getOptionLabel={(option: AvailableService) => option.serviceName}
            getOptionValue={(option: AvailableService) => option.serviceId.toString()}
            options={props.services}
            onChange={handleServiceChange}
          />
        </div>
      </div>
    </div>
    <div className='row'>
      <div className='col-xs-4 col-sm-4 col-md-4 col-lg-4'>
        <div className='form-group'>
          <span className='hbw-string-label'>
            {`${translate('components.services_table.modals.service_add.price')}, ${props.currencyCode}`}
          </span>
          <input
            name='price'
            type='text'
            pattern="^\d+\.?\d*$"
            className='form-control'
            id='service-price'
            inputMode='decimal'
            value={price.toString().replace(',', '.')}
            disabled={!props.individualPricing}
            onChange={handlePriceChange}
          />
        </div>
      </div>
      <div className='col-xs-4 col-sm-4 col-md-4 col-lg-4'>
        <div className='form-group'>
          <span className='hbw-string-label'>
            {`${translate(
              'components.services_table.modals.service_add.quantity'
            )}${selectedService && selectedService?.serviceUnit !== '-'
              ? `, ${selectedService?.serviceUnit}` : ''}`}
          </span>
          <input
            name='quantity'
            type='number'
            className='form-control'
            id='service-quantity'
            value={quantity}
            required
            disabled={selectedService?.serviceUnit === '-'}
            onChange={handleQuantityChange}
          />
        </div>
      </div>
      <div className='col-xs-4 col-sm-4 col-md-4 col-lg-4'>
        <div className='form-group'>
          <span className='hbw-string-label'>
            {`${translate(
              'components.services_table.modals.service_add.total_price'
            )
            }, ${props.currencyCode}`}
          </span>
          <input
            name='total-price'
            type='text'
            pattern="^\d+\.?\d*$"
            className='form-control'
            id='service-total-cost'
            value={totalPrice}
            disabled
            onChange={handleTotalPriceChange}
          />
        </div>
      </div>
    </div>
    <div className='row'>
      <div className='col-xs-6 col-sm-6 col-md-6 col-lg-6'>
        <div className='form-group'>
          <span className='hbw-datetime-label'>
            {translate('components.services_table.modals.service_add.start_date')}
          </span>
          <DatePickerWrapper
            aria-label='start-date'
            name='start-date-visible-input'
            className='form-control'
            onChange={handleStartDateChange}
            selected={beginDate}
            dateFormat={dateFormat}
            required
            locale={locale.code}
            fixedHeight
            disabledKeyboardNavigation
            disabled={false}
            popperPlacement='bottom-start'
            autoComplete='off'
            showTimeInput={false}

          />
        </div>
      </div>
      <div className='col-xs-6 col-sm-6 col-md-6 col-lg-6'>
        <div className='form-group'>
          <span className='hbw-datetime-label'>
            {translate('components.services_table.modals.service_add.end_date')}
          </span>
          <DatePickerWrapper
            aria-label='end-date'
            name='end-date-visible-input'
            className='form-control'
            onChange={handleEndDateChange}
            selected={endDate}
            dateFormat={dateFormat}
            locale={locale.code}
            fixedHeight
            disabledKeyboardNavigation
            disabled={false}
            popperPlacement='bottom-start'
            autoComplete='off'
            showTimeInput={false}
          />
        </div>
      </div>
    </div>
    <div className='row'>
      <div className='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
        <div className='form-group'>
          <label className='hbw-checkbox-label'>
            <input
              name='allow-provisioning'
              type='checkbox'
              className='hbw-checkbox'
              id='allow-provisioning'
              checked={allowProvisioning}
              onChange={handleAllowProvisioningChange}
            />
            <FontAwesomeIcon
              className='hbw-checkbox'
              icon={checkboxIcon(allowProvisioning) as IconProp}
            />
            <span>
              {` ${translate('components.services_table.modals.service_add.allow_provisioning')}`}
            </span>
          </label>
        </div>
      </div>
    </div>
  </div>);

  const renderModalFooter = () => (<div className='footer-buttons'>
    <button
      type='button'
      className='btn btn-primary close-add-service-button'
      data-dismiss='modal'
      onClick={handleClose}>
      {translate('components.services_table.modals.service_add.cancel')}
    </button>
    <button
      type='submit'
      className='btn btn-info submit-add-service-button'
      data-dismiss='modal'>
      {translate('components.services_table.modals.service_add.submit')}
    </button>
  </div>);

  return <HBWModalWrapper
    show={props.show}
    id='service-modal'
    title={translate('components.services_table.modals.service_add.title')}
    onSubmit={handleSubmit}
    onClose={handleClose}
    body={renderModalContent()}
    footer={renderModalFooter()}>
  </HBWModalWrapper>;
};

export default compose()(HBWServiceAddModal);
