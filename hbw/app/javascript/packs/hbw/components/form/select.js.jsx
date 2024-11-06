/* eslint no-console: "off" */

import cx from 'classnames';
import Select from 'react-select';
import Async from 'react-select/async';
import Tooltip from 'tooltip.js';
import compose from 'shared/utils/compose';
import {
  withConditions, withSelect, withCallbacks, withValidations, withErrorBoundary
} from 'shared/hoc';
import {
  useContext, useEffect, useRef, useState
} from 'react';
import TranslationContext from '../shared/context/translation';
import ConnectionContext from '../shared/context/connection';

modulejs.define('HBWFormSelect',
  ['React'],
  (React) => {
    const FormSelect = ({
      id, name, params, task, value: valueFromProps, disabled, hidden, onRef,
      isValid, isAvailable, fireFieldValueUpdate, getChosenValue, hasValueInChoices, missFieldInVariables,
      trigger, bind, unbind,
    }) => {
      const { translate: t, translateBP } = useContext(TranslationContext);
      const { request, serverURL } = useContext(ConnectionContext);

      const chosenValue = getChosenValue() || '';

      const addCurrentValueToChoices = (currentValue) => {
        const newChoices = params.choices.slice();

        if (!hasValueInChoices(currentValue) && valueFromProps !== null) {
          newChoices.push(currentValue);
        }

        return newChoices;
      };

      const getChoices = (currentValue) => {
        if (params.mode === 'select') {
          addCurrentValueToChoices(currentValue);

          return params.choices.slice();
        } else if (params.mode === 'lookup') {
          return params.choices;
        } else {
          return null;
        }
      };

      const [value, setValue] = useState(chosenValue);
      const [choices, setChoices] = useState(getChoices(chosenValue));
      const [error, setError] = useState((!hasValueInChoices(value) && value) || missFieldInVariables());
      const [valid, setValid] = useState(true);
      const [tooltip, setTooltip] = useState(null);

      const select = useRef(null);
      const tooltipContainer = useRef(null);

      const setValidationState = () => {
        setValid(isValid(value));
      };

      const onFormSubmit = () => {
        const el = select.current;

        if (isValid(value)) {
          el.classList.remove('invalid');
        } else {
          el.classList.add('invalid');

          setValidationState();
          trigger('hbw:form-submitting-failed');
        }
      };

      const serialize = () => {
        if (params.editable === false || disabled || hidden) {
          return null;
        } else {
          return { [name]: value };
        }
      };

      const controlValidationTooltip = (toHide) => {
        if (toHide) {
          tooltip.hide();
        } else {
          tooltip.show();
        }
      };

      useEffect(() => {
        setTooltip(new Tooltip(
          select.current,
          {
            title:     t('errors.field_is_required'),
            container: tooltipContainer.current,
            trigger:   'manual',
            placement: 'top'
          }
        ));
      }, []);

      useEffect(() => {
        bind(`hbw:validate-form-${id}`, onFormSubmit);

        return () => {
          unbind(`hbw:validate-form-${id}`);
        };
      }, [value]);

      useEffect(() => {
        onRef({ serialize });

        return () => {
          onRef({ serialize: () => null });
        };
      }, [value, disabled, hidden, params.editable]);

      useEffect(() => {
        if (tooltip) {
          const hideTooltip = !isAvailable || valid;

          controlValidationTooltip(hideTooltip);
        }
      }, [tooltip, valid, isAvailable]);

      const fetchOptionsAsync = async (inputValue, callback) => {
        const url = params.userLookup ? params.url : `${serverURL}${params.url}`;

        const response = await request({
          url,
          method: 'GET',
          data:   {
            q:           inputValue,
            process_key: task.process_key
          }
        }).then(res => res.json())
          .catch((e) => {
            console.error(e);
            callback();
          });

        const res = response.map(({ text, id: optionValue }) => ({
          label: text,
          value: optionValue
        }));

        callback(res);
      };

      const debounce = (f, ms) => {
        let timer;

        return function (...args) {
          const functionCall = () => f.apply(this, args);

          clearTimeout(timer);
          timer = setTimeout(functionCall, ms);
        };
      };

      const fetchOptionsAsyncDebounced = debounce(fetchOptionsAsync, 250);

      const loadOptions = (inputValue, callback) => {
        if (inputValue && inputValue.length >= 2) {
          fetchOptionsAsyncDebounced(inputValue, callback);
        } else {
          callback();
        }
      };

      const selectComponent = (opts) => {
        if (params.mode === 'lookup') {
          return <Async loadOptions={loadOptions} {...opts} />;
        } else {
          return <Select {...opts} />;
        }
      };

      const noOptionsMessage = (options) => {
        const { inputValue } = options;

        if (inputValue && inputValue.length >= 2) {
          return t('components.select.no_results_found');
        } else {
          return t('components.select.enter_more_chars');
        }
      };

      const loadingMessage = () => t('components.select.searching');

      const renderDescription = () => {
        const { placement, text } = params.description;

        const translated = translateBP(`${task.process_key}.${task.key}.${name}.description`, {}, text);

        return <div className="description" data-test={`description-${placement}`}>{translated}</div>;
      };

      const buildOptions = () => choices.map((variant) => {
        const [optionValue, label] = Array.isArray(variant) ? variant : [variant, variant];

        return {
          label,
          value: optionValue || '',
          key:   optionValue || 'null'
        };
      });

      const getDefaultValue = () => {
        const variants = buildOptions();

        if (value) {
          return variants.filter(opt => `${value}` === `${opt.value}`);
        }

        if (params.nullable) {
          return [];
        } else {
          return [variants[0]];
        }
      };

      const applyValue = (option) => {
        const newValue = option ? option.value : null;

        setValue(newValue);
        setChoices(getChoices(newValue));
        setError((!hasValueInChoices(newValue) && newValue) || missFieldInVariables());

        fireFieldValueUpdate(name, newValue);
      };

      const customStyles = () => {
        const bgOptionColor = (state) => {
          if (state.isFocused) {
            return 'var(--hbw-pickled-bluewood, var(--base-hbw-pickled-bluewood))';
          }

          if (state.isSelected) {
            return 'var(--hbw-selected-element, var(--base-hbw-selected-element))';
          }

          return 'var(--hbw-white, var(--base-hbw-white))';
        };

        const borderColor = (isFocused) => {
          if (error) {
            return 'var(--hbw-red, var(--base-hbw-red))';
          }

          if (isFocused) {
            return 'var(--select-border-color-focus-hover, var(--base-select-border-color-focus-hover))';
          }

          return 'var(--hbw-mystic, var(--base-hbw-mystic))';
        };

        const controlBackgroundColor = (isDisabled) => {
          if (isDisabled) {
            return 'var(--hbw-light-gray, var(--base-hbw-light-gray))';
          } else {
            return 'var(--hbw-white, var(--base-hbw-white))';
          }
        };

        const controlCursor = (isDisabled) => {
          if (isDisabled) {
            return 'not-allowed';
          } else {
            return 'pointer';
          }
        };

        const optionColor = (isFocusedOrSelected) => {
          if (isFocusedOrSelected) {
            return 'var(--hbw-focused-text-color, var(--base-hbw-focused-text-color))';
          } else {
            return 'var(--hbw-text-color, var(--base-hbw-text-color))';
          }
        };

        const dropdownIndicatorColor = (isFocused) => {
          if (isFocused) {
            return 'var(--select-dropdown-indicator-color-focus, var(--base-select-dropdown-indicator-color-focus))';
          } else {
            return 'var(--select-dropdown-indicator-color, var(--base-select-dropdown-indicator-color))';
          }
        };

        return {
          control: (base, state) => ({
            ...base,
            minHeight:       'var(--form-control-height, var(--base-form-control-height))',
            height:          'var(--form-control-height, var(--base-form-control-height))',
            borderColor:     borderColor(state.isFocused),
            borderWidth:     'var(--form-control-border-width, var(--base-form-control-border-width))',
            borderRadius:    'var(--form-control-border-radius, var(--base-form-control-border-radius))',
            boxShadow:       'none',
            backgroundColor: controlBackgroundColor(state.isDisabled),

            '&:hover': {
              borderColor: 'var(--select-border-color-focus-hover, var(--base-select-border-color-focus-hover))',
              borderWidth: 'var(--form-control-border-width, var(--base-form-control-border-width))'
            }
          }),
          singleValue: (base, state) => ({
            ...base,
            cursor:        controlCursor(state.isDisabled),
            pointerEvents: 'all',
            color:         'var(--hbw-text-color, var(--base-hbw-text-color))'
          }),

          indicatorsContainer: base => ({
            ...base,
            height: 'var(--form-control-height, var(--base-form-control-height))'
          }),
          dropdownIndicator: (base, state) => ({
            ...base,
            color: dropdownIndicatorColor(state.isFocused),
            width: 'var(--select-dropdown-indicator-width, var(--base-select-dropdown-indicator-width))',

            '&:hover': {
              color: 'var(--select-dropdown-indicator-color-hover, var(--base-select-dropdown-indicator-color-hover))'
            }
          }),
          indicatorSeparator: base => ({
            ...base,
            display: 'var(--select-separator-display, var(--base-select-separator-display))'
          }),
          valueContainer: base => ({
            ...base,
            height: 'var(--form-control-height, var(--base-form-control-height))'
          }),
          option: (base, state) => ({
            ...base,
            color:           optionColor(state.isFocused || state.isSelected),
            backgroundColor: bgOptionColor(state),
            cursor:          'pointer',

            '&:active': {
              color:           'var(--hbw-white, var(--base-hbw-white))',
              backgroundColor: 'var(--hbw-pickled-bluewood, var(--base-hbw-pickled-bluewood))'
            }
          }),
          menu: base => ({
            ...base,
            'z-index': 99,
          })
        };
      };

      const opts = {
        name,
        options:         buildOptions(),
        defaultValue:    getDefaultValue(),
        placeholder:     params.placeholder || '',
        isClearable:     params.nullable,
        isDisabled:      params.editable === false || disabled,
        noOptionsMessage,
        loadingMessage,
        className:       'react-select-container',
        classNamePrefix: 'react-select',
        styles:          customStyles(),
        onChange:        opt => applyValue(opt)
      };

      const label = translateBP(`${task.process_key}.${task.key}.${name}.label`, {}, params.label);
      const labelCss = cx(params.label_css, 'select-label');
      const cssClass = cx(params.css_class, { hidden });

      const selectErrorMessage = t('errors.field_not_defined_in_bp', { field_name: name });
      const selectErrorMessageCss = cx('alert', 'alert-danger', { hidden: !missFieldInVariables() });

      const errorTooltip = <div
        ref={tooltipContainer}
        className='tooltip-red'
      />;

      return <div className={cssClass} title={params.tooltip} data-test={`select-${name}`}>
        <span className={labelCss}>{label}</span>
        <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
        <div className='form-group' ref={select}>
          {params.description?.placement === 'top' && renderDescription()}
          {selectComponent(opts)}
          {params.description?.placement === 'bottom' && renderDescription()}
        </div>
        {errorTooltip}
      </div>;
    };

    return compose(withSelect, withCallbacks, withConditions, withValidations, withErrorBoundary)(FormSelect);
  });
