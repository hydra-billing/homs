/* eslint no-console: "off" */

import Select from 'react-select';
import Async from 'react-select/async';
import Tooltip from 'tooltip.js';
import {
  withConditions, withSelect, withCallbacks, withValidations, withErrorBoundary, compose
} from '../helpers';

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

        let formGroupCss = 'form-group';

        if (this.state.error) {
          formGroupCss += ' has-error';
        }

        return <div className={cssClass} title={tooltip}>
          <span className={labelCss}>{label}</span>
          <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
          <div className={formGroupCss} ref={(i) => { this.select = i; }}>
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
            return '#2C3E50';
          }

          if (state.isSelected) {
            return '#445C72';
          }

          return 'white';
        };

        return {
          control: (base, state) => ({
            ...base,
            minHeight:       45,
            borderColor:     state.isFocused ? 'black' : '#dce4ec',
            borderWidth:     2,
            boxShadow:       'none',
            cursor:          'pointer',
            backgroundColor: state.isDisabled ? '#ECF0F1' : 'white',

            '&:hover': {
              borderColor: 'inherit',
              borderWidth: 2
            }
          }),
          option: (base, state) => ({
            ...base,
            color:           (state.isFocused || state.isSelected) ? 'white' : '#2C3E50',
            backgroundColor: bgOptionColor(state),
            cursor:          'pointer',

            '&:active': {
              color:           'white',
              backgroundColor: '#2C3E50'
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

      componentWillMount () {
        this.fetchOptionsAsync = this.debounce(this.fetchOptionsAsync, 250);
      }

      loadOptions = (inputValue, callback) => {
        if (inputValue && inputValue.length >= 2) {
          this.fetchOptionsAsync(inputValue, callback);
        } else {
          callback();
        }
      };

      fetchOptionsAsync = (inputValue, callback) => {
        this.props.env.connection.request({
          url:    this.props.params.url,
          method: 'GET',
          data:   {
            q: inputValue
          }
        }).done((response) => {
          const res = response.map(({ text, id }) => ({
            label: text,
            value: id
          }));

          callback(res);
        }).fail((error) => {
          console.error(error);

          callback();
        });
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
