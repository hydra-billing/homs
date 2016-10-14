modulejs.define 'HBWFormSelect',
  ['React', 'HBWTranslationsMixin', 'jQuery', 'HBWDeleteIfMixin'],
  (React, TranslationsMixin, jQuery, DeleteIfMixin) ->
    React.createClass
      mixins: [TranslationsMixin, DeleteIfMixin]

      getInitialState: ->
        value = @getChosenValue() or ''
        {
          value: value
          choices: @getChoices(value)
          error: not @hasValueInChoices(value) and value
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
        formGroupCss = 'form-group'

        formGroupCss += ' has-error' if @state.error

        `<div className={cssClass} title={tooltip}>
          <span className={labelCss}>{label}</span>
          <div className={formGroupCss}>
            <select {...opts}>
              {this.buildOptions(this.state.choices)}
            </select>
          </div>
        </div>`

      setValue: ->
        newValue = jQuery(React.findDOMNode(this)).find('select').val()
        @setState(
          value: newValue
          choices: @getChoices(newValue)
          error: not @hasValueInChoices(newValue) and newValue
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

        e = jQuery(React.findDOMNode(@))

        select = e.find('select').select2(jQuery.extend({}, {
          width: '100%'
          allowClear: @props.params.nullable
          theme: 'bootstrap'
          placeholder: @props.params.placeholder
          language: @getLanguage()
        }, ajaxOptions)).on('change', => @setValue())

      getChosenValue: ->
        if @props.params.mode == 'select'
          if @props.value is null
            if @props.params.nullable
              null
            else if @props.params.choices.length
              first = @props.params.choices[0]

              if jQuery.isArray(first)
                first[0]
              else
                first
            else
              null
          else
            @props.value
        else
          @props.value

      isEqual: (a, b) ->
        return true if a == b
        return true if a is null and b is null
        return true if a == '' and b is null or a is null and b == ''
        return false if a is null or b is null

        a.toString() == b.toString()

      isChoiceEqual: (choice, value)->
        if jQuery.isArray(choice)
          return true if @isEqual(choice[0], value)
        else if @isEqual(choice, value)
          return true

        return false

      hasValueInChoices: (value) ->
        return true if @props.params.mode == 'lookup'
        return true if @isEqual(value, null) and @props.params.nullable

        for c in @props.params.choices
          return true if @isChoiceEqual(c, value)

        return false

      getChoices: (value) ->
        if @props.params.mode == 'select'
          choices = @props.params.choices.slice()

          unless @hasValueInChoices(value)
            if @props.value is null
              @addNullChoice(choices)
            else
              choices.push(value)

          @addNullChoice(choices) if @props.params.nullable

          choices

        else if @props.params.mode == 'lookup'
          @props.params.choices

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
