/* eslint no-console: "off" */

import Select from 'react-select';
import AsyncSelect from 'react-select/lib/Async';
import { withDeleteIf } from '../helpers';

modulejs.define('HBWFormSelect',
  ['React', 'ReactDOM', 'HBWTranslationsMixin', 'HBWSelectMixin'],
  (React, ReactDOM, TranslationsMixin, SelectMixin) => {
    const FormSelect = React.createClass({
      mixins: [TranslationsMixin, SelectMixin],

      getInitialState () {
        const value = this.getChosenValue() || '';

        return {
          value,
          choices: this.getChoices(value),
          error:   (!this.hasValueInChoices(value) && value) || this.missFieldInVariables()
        };
      },

      render () {
        const isMulti = !this.props.params.single && this.props.params.mode === 'lookup';
        const opts = {
          isMulti,
          name:             this.props.name,
          options:          this.buildOptions(),
          defaultValue:     this.getDefaultValue(isMulti),
          placeholder:      this.props.params.placeholder || '',
          isClearable:      this.props.params.nullable || this.props.value === null,
          isDisabled:       this.props.params.editable === false,
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

        const selectErrorMessage = this.t('errors.field_not_defined_in_bp', { field_name: this.props.name });
        let selectErrorMessageCss = 'alert alert-danger';

        if (!this.missFieldInVariables()) {
          selectErrorMessageCss += ' hidden';
        }

        let formGroupCss = 'form-group';

        if (this.state.error) {
          formGroupCss += ' has-error';
        }

        return <div className={cssClass} title={tooltip}>
          <span className={labelCss}>{label}</span>
          <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
          <div className={formGroupCss}>
            {this.selectComponent(opts)}
          </div>
        </div>;
      },

      customStyles () {
        const bgColor = (state) => {
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
            minHeight:   45,
            borderColor: state.isFocused ? 'black' : '#dce4ec',
            borderWidth: 2,
            boxShadow:   'none',
            cursor:      'pointer',

            '&:hover': {
              borderColor: 'inherit',
              borderWidth: 2
            }
          }),
          option: (base, state) => ({
            ...base,
            color:           (state.isFocused || state.isSelected) ? 'white' : '#2C3E50',
            backgroundColor: bgColor(state),
            cursor:          'pointer',

            '&:active': {
              color:           'white',
              backgroundColor: '#2C3E50'
            }
          })
        };
      },

      selectComponent (opts) {
        if (this.props.params.mode === 'lookup') {
          return <AsyncSelect loadOptions={this.loadOptions}
                              {...opts} />;
        } else {
          return <Select {...opts} />;
        }
      },

      noOptionsMessage (options) {
        const { inputValue } = options;

        if (inputValue && inputValue.length >= 2) {
          return this.t('components.select.no_results_found');
        } else {
          return this.t('components.select.enter_more_chars');
        }
      },

      loadingMessage () {
        return this.t('components.select.searching');
      },

      componentWillMount () {
        this.fetchOptionsAsync = this.debounce(this.fetchOptionsAsync, 250);
      },

      loadOptions (inputValue, callback) {
        if (inputValue && inputValue.length >= 2) {
          this.fetchOptionsAsync(inputValue, callback);
        } else {
          callback();
        }
      },

      fetchOptionsAsync (inputValue, callback) {
        const url = `${this.props.params.url}${(this.props.params.url.includes('?') ? '&' : '?')}`;

        fetch(`${url}q=${inputValue}`)
          .then(response => response.json())
          .then((json) => {
            const res = json.map(opt => ({
              label: opt.text,
              value: opt.id
            }));

            callback(res);
          })
          .catch((error) => {
            console.error(error);

            callback();
          });
      },

      getDefaultValue (isMulti) {
        const variants = this.buildOptions();

        if (this.state.value) {
          const value = (isMulti ? this.state.value : [this.state.value]).map(el => `${el}`);

          return variants.filter(opt => value.includes(`${opt.value}`));
        }

        if (this.props.params.nullable) {
          return [];
        } else {
          return [variants[0]];
        }
      },

      setValue (option) {
        let newValue;

        if (Array.isArray(option)) {
          newValue = option.map(opt => opt.value);
        } else {
          newValue = option ? option.value : null;
        }

        this.setState({
          value:   newValue,
          choices: this.getChoices(newValue),
          error:   (!this.hasValueInChoices(newValue) && newValue) || this.missFieldInVariables()
        });
      },

      buildOptions () {
        return this.state.choices.map((variant) => {
          const [value, label] = Array.isArray(variant) ? variant : [variant, variant];

          return {
            label,
            value: value || '',
            key:   value || 'null'
          };
        });
      },

      addCurrentValueToChoices (value) {
        const choices = this.props.params.choices.slice();

        if (!this.hasValueInChoices(value) && this.props.value !== null) {
          choices.push(value);
        }

        return choices;
      },

      addNullChoice () {
        return null;
      },

      debounce (f, ms) {
        let timer;

        return function (...args) {
          const functionCall = () => f.apply(this, args);

          clearTimeout(timer);
          timer = setTimeout(functionCall, ms);
        };
      }
    });

    return withDeleteIf(FormSelect);
  });
