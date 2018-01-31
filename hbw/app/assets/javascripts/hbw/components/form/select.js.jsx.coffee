modulejs.define 'HBWFormSelect',
  ['React', 'HBWTranslationsMixin', 'jQuery', 'HBWDeleteIfMixin', 'HBWSelectMixin'],
  (React, TranslationsMixin, jQuery, DeleteIfMixin, SelectMixin) ->
    React.createClass
      mixins: [TranslationsMixin, DeleteIfMixin, SelectMixin]

      getInitialState: ->
        value = @getChosenValue() or ''

        {
          value: value
          choices: @getChoices(value)
          error: not @hasValueInChoices(value) and value or @missFieldInVariables()
        }

      render: ->
        lookup = @props.params.mode == 'lookup'
        opts = {
          name: @props.name
          type: 'text'
          defaultValue: if lookup then [@state.value] else @state.value
          disabled: @props.params.editable == false
          multiple: lookup
        }

        cssClass = @props.params.css_class
        cssClass += ' hidden' if this.hidden

        tooltip = @props.params.tooltip
        label = @props.params.label
        labelCss = @props.params.label_css

        selectErrorMessage = @t("errors.field_not_defined_in_bp", field_name: @props.name)
        selectErrorMessageCss = 'alert alert-danger'
        selectErrorMessageCss += ' hidden' unless @missFieldInVariables()

        formGroupCss = 'form-group'

        formGroupCss += ' has-error' if @state.error

        `<div className={cssClass} title={tooltip}>
          <span className={labelCss}>{label}</span>
          <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
          <div className={formGroupCss}>
            <select {...opts}>
              {this.buildOptions(this.state.choices)}
            </select>
          </div>
        </div>`

      setValue: ->
        newValue = jQuery(ReactDOM.findDOMNode(this)).find('select').val()
        @setState(
          value: newValue
          choices: @getChoices(newValue)
          error: not @hasValueInChoices(newValue) and newValue or @missFieldInVariables()
        )

      componentDidMount: -> @hijackSelect2()

      hijackSelect2: ->
        if @props.params.mode == 'lookup'
          ajaxOptions =
            minimumInputLength: 3
            maximumSelectionLength: 1
            ajax:
              url: @props.params.url
              dataType: 'json'
              delay: 250
              cache: true
              processResults: (data, page) -> { results: data }
              data: (params) ->
                q: params.term
                page: params.page
        else
          ajaxOptions = {}

        e = jQuery(ReactDOM.findDOMNode(@))

        select = e.find('select').select2(jQuery.extend({}, {
          width: '100%'
          allowClear: @props.params.nullable
          theme: 'bootstrap'
          placeholder: @props.params.placeholder
          language: @getLanguage()
        }, ajaxOptions)).on('change', => @setValue())

      addNullChoice: (choices) ->
        hasNullValue = false
        for choice in choices when @isChoiceEqual(choice, null)
          hasNullValue = true

        unless hasNullValue
          choices.unshift([null, @t('components.select.not_selected')])

      buildOptions: (choices) ->
        choices.map (variant) ->
          if jQuery.isArray(variant)
            rawValue = variant[0]
            visualValue = variant[1]
          else
            rawValue = variant
            visualValue = variant

          if rawValue is null
            `<option value="" key="null">{visualValue}</option>`
          else
            `<option value={rawValue} key={rawValue}>{visualValue}</option>`

      getLanguage: ->
        translations = jQuery.fn.select2.amd.require('select2/i18n/' + @props.env.locale)
        language = jQuery.extend({}, translations)
        language.maximumSelected = -> ''
        language

      addCurrentValueToChoices: (value) ->
        choices = @props.params.choices.slice()

        unless @hasValueInChoices(value)
          if @props.value is null
            @addNullChoice(choices)
          else
            choices.push(value)

        choices
