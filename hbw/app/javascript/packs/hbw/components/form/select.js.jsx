/* eslint no-console: "off" */

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
          error:   (!props.hasValueInChoices(value) && value) || props.missFieldInVariables()
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

      render () {
        const opts = {
          name:             this.props.name,
          options:          this.buildOptions(),
          defaultValue:     this.getDefaultValue(),
          placeholder:      this.props.params.placeholder || '',
          isClearable:      this.props.params.nullable,
          isDisabled:       this.props.params.editable === false || this.props.disabled,
          noOptionsMessage: this.noOptionsMessage,
          loadingMessage:   this.loadingMessage,
          className:        'react-select-container',
          classNamePrefix:  'react-select',
          styles:           this.customStyles(),
          onChange:         opt => this.setValue(opt)
        };

        let cssClass = this.props.params.css_class;
        if (this.props.hidden) {
          cssClass += ' hidden';
        }

        const { tooltip } = this.props.params;
        const { label } = this.props.params;
        const labelCss = this.props.params.label_css;

        const selectErrorMessage = this.props.env.translator('errors.field_not_defined_in_bp',
          { field_name: this.props.name });
        let selectErrorMessageCss = 'alert alert-danger';

        if (!this.props.missFieldInVariables()) {
          selectErrorMessageCss += ' hidden';
        }

        const errorTooltip = <div
          ref={(t) => { this.tooltipContainer = t; }}
          className={`${!this.state.valid && 'tooltip-red'}`}
        />;

        return <div className={cssClass} title={tooltip}>
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
          this.controlValidationTooltip(this.props.isValid(this.state.value));
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
            cursor:          'pointer',
            backgroundColor: controlBackgroundColor(state.isDisabled),

            '&:hover': {
              borderColor: 'var(--select-border-color-focus-hover, var(--base-select-border-color-focus-hover))',
              borderWidth: 'var(--form-control-border-width, var(--base-form-control-border-width))'
            }
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
        const response = await this.props.env.connection.request({
          url:    this.props.params.url,
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
        if (this.props.params.editable === false || this.props.disabled) {
          return null;
        } else {
          return { [this.props.name]: this.state.value };
        }
      };
    }

    return compose(withSelect, withConditions, withCallbacks, withValidations, withErrorBoundary)(FormSelect);
  });
