/* eslint no-console: "off" */

import cx from 'classnames';
import Select from 'react-select';
import Async from 'react-select/async';
import Tooltip from 'tooltip.js';
import compose from 'shared/utils/compose';
import {
  withConditions, withSelect, withCallbacks, withValidations, withErrorBoundary
} from 'shared/hoc';

modulejs.define('HBWFormSelect',
  ['React'],
  (React) => {
    class FormSelect extends React.Component {
      constructor (props, context) {
        super(props, context);
        const value = props.getChosenValue() || '';

        this.state = {
          value,
          choices: this.getChoices(value),
          error:   (!props.hasValueInChoices(value) && value) || props.missFieldInVariables(),
          valid:   true
        };
      }

      componentDidMount () {
        this.fetchOptionsAsync = this.debounce(this.fetchOptionsAsync, 250);

        this.tooltip = new Tooltip(this.select, {
          title:     this.props.env.translator('errors.field_is_required'),
          container: this.tooltipContainer,
          trigger:   'manual',
          placement: 'top'
        });

        this.validateOnSubmit();
        this.props.onRef(this);
      }

      componentWillUnmount () {
        this.props.onRef(undefined);
      }

      componentDidUpdate () {
        const hideTooltip = !this.props.isAvailable || this.state.valid;

        this.controlValidationTooltip(hideTooltip);
      }

      render () {
        const {
          name, task, params, disabled, hidden, env, missFieldInVariables
        } = this.props;

        const opts = {
          name,
          options:          this.buildOptions(),
          defaultValue:     this.getDefaultValue(),
          placeholder:      params.placeholder || '',
          isClearable:      params.nullable,
          isDisabled:       params.editable === false || disabled,
          noOptionsMessage: this.noOptionsMessage,
          loadingMessage:   this.loadingMessage,
          className:        'react-select-container',
          classNamePrefix:  'react-select',
          styles:           this.customStyles(),
          onChange:         opt => this.setValue(opt)
        };

        const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);
        const labelCss = params.label_css;
        const cssClass = cx(params.css_class, { hidden });

        const selectErrorMessage = env.translator('errors.field_not_defined_in_bp', { field_name: name });
        const selectErrorMessageCss = cx('alert', 'alert-danger', { hidden: !missFieldInVariables() });

        const errorTooltip = <div
          ref={(t) => { this.tooltipContainer = t; }}
          className='tooltip-red'
        />;

        return <div className={cssClass} title={params.tooltip}>
          <span className={labelCss}>{label}</span>
          <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
          <div className='form-group' ref={(i) => { this.select = i; }}>
            {this.selectComponent(opts)}
          </div>
          {errorTooltip}
        </div>;
      }

      validateOnSubmit = () => {
        this.props.bind(`hbw:validate-form-${this.props.id}`, this.onFormSubmit);
      };

      onFormSubmit = () => {
        const el = this.select;

        if (this.props.isValid(this.state.value)) {
          el.classList.remove('invalid');
        } else {
          el.classList.add('invalid');

          this.setValidationState();
          this.props.trigger('hbw:form-submitting-failed');
        }
      };

      setValidationState = () => {
        this.setState({ valid: this.props.isValid(this.state.value) });
      };

      controlValidationTooltip = (toHide) => {
        if (toHide) {
          this.tooltip.hide();
        } else {
          this.tooltip.show();
        }
      };

      customStyles = () => {
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
          if (this.state.error) {
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

      selectComponent = (opts) => {
        if (this.props.params.mode === 'lookup') {
          return <Async loadOptions={this.loadOptions}
            {...opts} />;
        } else {
          return <Select {...opts} />;
        }
      };

      noOptionsMessage = (options) => {
        const { inputValue } = options;

        if (inputValue && inputValue.length >= 2) {
          return this.props.env.translator('components.select.no_results_found');
        } else {
          return this.props.env.translator('components.select.enter_more_chars');
        }
      };

      loadingMessage = () => this.props.env.translator('components.select.searching');

      loadOptions = (inputValue, callback) => {
        if (inputValue && inputValue.length >= 2) {
          this.fetchOptionsAsync(inputValue, callback);
        } else {
          callback();
        }
      };

      fetchOptionsAsync = async (inputValue, callback) => {
        const url = this.props.params.userLookup ? this.props.params.url
          : `${this.props.env.connection.serverURL}${this.props.params.url}`;
        const response = await this.props.env.connection.request({
          url,
          method: 'GET',
          data:   {
            q: inputValue
          }
        }).then(res => res.json())
          .catch((error) => {
            console.error(error);
            callback();
          });

        const res = response.map(({ text, id }) => ({
          label: text,
          value: id
        }));

        callback(res);
      };

      getDefaultValue = () => {
        const variants = this.buildOptions();

        if (this.state.value) {
          return variants.filter(opt => `${this.state.value}` === `${opt.value}`);
        }

        if (this.props.params.nullable) {
          return [];
        } else {
          return [variants[0]];
        }
      };

      setValue = (option) => {
        const newValue = option ? option.value : null;

        this.setState({
          value:   newValue,
          choices: this.getChoices(newValue),
          error:   (!this.props.hasValueInChoices(newValue) && newValue) || this.props.missFieldInVariables()
        });

        this.props.fireFieldValueUpdate(this.props.name, newValue);
      };

      buildOptions = () => this.state.choices.map((variant) => {
        const [value, label] = Array.isArray(variant) ? variant : [variant, variant];

        return {
          label,
          value: value || '',
          key:   value || 'null'
        };
      });

      addCurrentValueToChoices = (value) => {
        const choices = this.props.params.choices.slice();

        if (!this.props.hasValueInChoices(value) && this.props.value !== null) {
          choices.push(value);
        }

        return choices;
      };

      addNullChoice = () => null;

      debounce = (f, ms) => {
        let timer;

        return function (...args) {
          const functionCall = () => f.apply(this, args);

          clearTimeout(timer);
          timer = setTimeout(functionCall, ms);
        };
      };

      getChoices = (value) => {
        if (this.props.params.mode === 'select') {
          this.addCurrentValueToChoices(value);

          return this.props.params.choices.slice();
        } else if (this.props.params.mode === 'lookup') {
          return this.props.params.choices;
        } else {
          return null;
        }
      };

      serialize = () => {
        if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
          return null;
        } else {
          return { [this.props.name]: this.state.value };
        }
      };
    }

    return compose(withSelect, withCallbacks, withConditions, withValidations, withErrorBoundary)(FormSelect);
  });
