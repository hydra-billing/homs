modulejs.define('HBWFormSelect',
  ['React', 'ReactDOM', 'HBWTranslationsMixin', 'jQuery', 'HBWDeleteIfMixin', 'HBWSelectMixin'],
  (React, ReactDOM, TranslationsMixin, jQuery, DeleteIfMixin, SelectMixin) => React.createClass({
    mixins: [TranslationsMixin, DeleteIfMixin, SelectMixin],

    getInitialState () {
      const value = this.getChosenValue() || '';

      return {
        value,
        choices: this.getChoices(value),
        error:   (!this.hasValueInChoices(value) && value) || this.missFieldInVariables()
      };
    },

    render () {
      const lookup = this.props.params.mode === 'lookup';
      const opts = {
        name:         this.props.name,
        type:         'text',
        defaultValue: lookup ? [this.state.value] : this.state.value,
        disabled:     this.props.params.editable === false,
        multiple:     lookup
      };

      let cssClass = this.props.params.css_class;
      if (this.hidden) {
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
          <select {...opts}>
            {this.buildOptions(this.state.choices)}
          </select>
        </div>
      </div>;
    },

    setValue () {
      const newValue = jQuery(ReactDOM.findDOMNode(this)).find('select').val();
      this.setState({
        value:   newValue,
        choices: this.getChoices(newValue),
        error:   (!this.hasValueInChoices(newValue) && newValue) || this.missFieldInVariables()
      });
    },

    componentDidMount () {
      this.hijackSelect2();
    },

    hijackSelect2 () {
      let ajaxOptions;
      let select;

      if (this.props.params.mode === 'lookup') {
        ajaxOptions = {
          minimumInputLength:     1,
          maximumSelectionLength: 1,
          ajax:                   {
            url:      this.props.params.url,
            dataType: 'json',
            delay:    250,
            cache:    true,
            processResults (data, page) {
              return { results: data };
            },
            data (params) {
              return {
                q:    params.term,
                page: params.page
              };
            }
          }
        };
      } else {
        ajaxOptions = {};
      }

      const e = jQuery(ReactDOM.findDOMNode(this));

      return select = e.find('select').select2(jQuery.extend({}, {
        width:       '100%',
        allowClear:  this.props.params.nullable,
        theme:       'bootstrap',
        placeholder: this.props.params.placeholder,
        language:    this.getLanguage()
      }, ajaxOptions)).on('change', () => this.setValue());
    },

    addNullChoice (choices) {
      let hasNullValue = false;

      for (const choice of choices) {
        if (this.isChoiceEqual(choice, null)) {
          hasNullValue = true;
        }
      }

      if (!hasNullValue) {
        choices.unshift([null, this.t('components.select.not_selected')]);
      }
    },

    buildOptions (choices) {
      return choices.map((variant) => {
        let rawValue;
        let visualValue;

        if (Array.isArray(variant)) {
          rawValue = variant[0];
          visualValue = variant[1];
        } else {
          rawValue = variant;
          visualValue = variant;
        }

        if (rawValue === null) {
          return <option value="" key="null">{visualValue}</option>;
        } else {
          return <option value={rawValue} key={rawValue}>{visualValue}</option>;
        }
      });
    },

    getLanguage () {
      const translations = jQuery.fn.select2.amd.require(`select2/i18n/${this.props.env.locale}`);
      const language = jQuery.extend({}, translations);

      language.maximumSelected = () => '';

      return language;
    },

    addCurrentValueToChoices (value) {
      const choices = this.props.params.choices.slice();

      if (!this.hasValueInChoices(value)) {
        if (this.props.value === null) {
          this.addNullChoice(choices);
        } else {
          choices.push(value);
        }
      }

      return choices;
    }
  }));
