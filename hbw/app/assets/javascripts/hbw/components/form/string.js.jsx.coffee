modulejs.define 'HBWFormString', ['React', 'jQuery', 'HBWCallbacksMixin', 'HBWDeleteIfMixin'], (React, jQuery, CallbacksMixin, DeleteIfMixin) ->
  React.createClass
    mixins: [CallbacksMixin, DeleteIfMixin]

    SUBSTITUTION: 'foobar'

    getInitialState: ->
      values = @getNormalizedInitialValues(@props.value)
      { defaultValue: values[0], value: values[1], valid: true, visualValue: values[2], position: values[3], previousValue: null }

    patterns: {
      '9': '[0-9 ]'
      'a': '[A-Za-z ]'
      '*': '[A-Za-z0-9 ]'
    }

    partRegexp: new RegExp('{{[^}]+}}')
    templateRegexp: new RegExp('{{([^}]+)}}', 'g')

    render: ->
      opts = {
        name: @props.name
        type: 'text'
        onKeyUp: @onChange
        onKeyDown: @onKeyDown
        onChange: @onChange
        onBlur: @onBlur
        onFocus: @onFocus
        readOnly: @props.params.editable == false
      }

      inputCSS = @props.params.css_class
      inputCSS += ' hidden' if @hidden

      `<div className={inputCSS} title={this.props.params.tooltip}>
        <div className="form-group">
          <span className={this.props.params.label_css}>{this.props.params.label}</span>
          <input {...opts} ref="input" className={'form-control ' + (!this.state.valid && ' invalid')} data-toggle='tooltip' data-placement='bottom' data-original-title={this.props.params.message} data-trigger='manual' value={this.state.visualValue} />
          {!opts.readOnly && <input name={this.props.name} value={this.state.value} type="hidden" />}
        </div>
      </div>`

    componentDidMount: ->
      jQuery('[data-toggle="tooltip"]').tooltip(animation: false)

      @validateOnSubmit()
      @hijackFormatter()
      @onLoadValidation()

    componentWillMount: ->
      @setGuid() unless @guid

      @hidden = @deleteIf()

    validateOnSubmit: ->
      @bind('hbw:validate-form', @onFormSubmit)

    hijackFormatter: ->
      if @props.params.pattern
        @extractValueRegexp = @buildExtractRegexp(@props.params.pattern)
        @valueParts = @buildValueParts(@props.params.pattern)

    getElement: ->
      jQuery(@refs.input)

    onFormSubmit: ->
      if @validationRequired()
        $el = @getElement()

        if @isValid()
          $el.removeClass('invalid')
        else
          $el.addClass('invalid')

          @setValidationState()
          @controlValidationTooltip(@isValid())
          @trigger('hbw:form-submitting-failed')

    onLoadValidation: ->
      if @validationRequired() && !!@state.value
        @controlValidationTooltip(@isValid())
        @setValidationState()

    onChange: (event) ->
      @updateValue(event.target, false)

      if @validationRequired()
        @runValidation()

    runValidation: ->
      unless @state.valid
        @controlValidationTooltip(@isValid())

        if @validationRequired()
          @setValidationState()

    onKeyDown: (event) ->
      if @validationRequired()
        if event.keyCode == 8 or event.keyCode == 46
          event.preventDefault()

          @updateValue(event.target, true)
        else
          @updateValue(event.target, false)

        @runValidation()
      else
        @updateValue(event.target, true)

    onBlur: (_) ->
      @controlValidationTooltip(true)

      if @validationRequired()
        @setValidationState()

    onFocus: (_) ->
      unless @state.valid
        @controlValidationTooltip(@isValid())

        if @validationRequired() && !@isValid()
          @setValidationState()

    setValidationState: ->
      @setState(valid: @isValid())

    controlValidationTooltip: (toHide) ->
      if toHide
        action = 'hide'
      else
        action = 'show'

      jQuery('[name="' + @props.name + '"]').tooltip(action)

    isValid: ->
      (@state.value or '').search(new RegExp(@props.params.regex)) >= 0

    validationRequired: ->
      !!@props.params.regex or !!@props.params.pattern

    buildVisualAndHiddenValues: (extractValueRegexp, valueParts, pattern, nextVal) ->
      value = @substitute(valueParts, @getSubstitutions(extractValueRegexp, nextVal))

      Object.assign(CustomFormatter.applyMaskForValue(pattern, value, @templateRegexp),
        {strippedValue: @stripNonAlphanumericChars(value)})

    updateValue: ($el, remove) ->
      if @extractValueRegexp
        visualValue = @state.visualValue
        currentVisualValue = $el.value
        position = @state.position
        pattern = @props.params.pattern

        if visualValue != currentVisualValue
          nextVal = CustomFormatter.getNextValForAdd(visualValue, currentVisualValue, position, pattern)

          result = @buildVisualAndHiddenValues(@extractValueRegexp, @valueParts, pattern, nextVal)

          $el.setSelectionRange(result.position, result.position)
          @setState(
            value:         result.strippedValue,
            visualValue:   result.mask,
            previousValue: result.mask,
            position:      result.position)
        else if remove
          nextVal = CustomFormatter.getNextValForRemove(pattern, @templateRegexp, position, currentVisualValue)

          result = @buildVisualAndHiddenValues(@extractValueRegexp, @valueParts, pattern, nextVal)

          $el.setSelectionRange(result.position, result.position)
          @setState(
            value:         result.strippedValue,
            visualValue:   result.mask,
            previousValue: result.mask,
            position:      result.position)
        else
          $el.setSelectionRange(position, position)
      else
        @setState(value: $el.value, visualValue: $el.value)

    buildExtractRegexp: (pattern) ->
      matches = @getMatches(@templateRegexp, pattern)

      result = matches.reduce(((res, match) =>
        replacement = match[1]
          .replace(/9/g, @patterns['9'] + '?')
          .replace(/a/g, @patterns['a'] + '?')
          .replace(/\*/g, @patterns['*'] + '?')

        res.replace(match[0], '(' + replacement + ')')
      ), pattern.replace(/([\(\)\+\-\[\]\*])/g, '\\\$1'))

      new RegExp('^' + result + '$')

    getMatches: (regexp, value) ->
      matches = []
      i = 0

      while match = regexp.exec(value)
        matches.push(match)

      matches

    # "1" -> ['1']
    # "{{a}}" -> [S]
    # "1{{a}}1" -> ['1', S, '1']
    # "{{a}}1" -> [S, '1']
    # "1{{a}}" -> ['1', S]
    # "{{a}}{{a}}" -> [S, S]
    # "{{a}}1{{a}}" -> [S, '1', S]
    # "{{a}}{{a}}1" -> [S, S, '1']
    buildValueParts: (pattern) ->
      parts = []
      strings = pattern.split(@partRegexp)
      i = 0

      for string in strings
        parts.push(string) if string
        parts.push(@SUBSTITUTION) if i != strings.length - 1
        i += 1

      parts

    getSubstitutions: (regexp, value) ->
      match = regexp.exec(value)
      res = []

      if match
        for i in [1...match.length]
          res.push(match[i])

      res

    substitute: (template, values) ->
      if @isEveryBlank(values)
        ''
      else
        res = []
        s = 0

        for i in [0...template.length]
          if template[i] == @SUBSTITUTION
            res.push(values[s] or '')
            s += 1
          else
            res.push(template[i])

        res.join('')

    stripNonAlphanumericChars: (value) ->
      value.replace(/[^a-z0-9]/ig, '')

    isEveryBlank: (array) ->
      array.reduce(((res, val) -> res and not val.replace(/\s/g, '')), true) and true

    getNormalizedInitialValues: (value) ->
      if @props.params.pattern
        strippedPattern = @props.params.pattern.replace(/[^a-z0-9\{\}]/ig, '')
        strippedParts = @buildValueParts(strippedPattern)
        regexp = @buildExtractRegexp(strippedPattern)
        substitutions = @getSubstitutions(regexp, value)
        fullValue = @substitute(strippedParts, substitutions)
        patternedValue = substitutions.join('')

        result = CustomFormatter.applyMaskForValue(@props.params.pattern, value, @templateRegexp)
        [patternedValue, fullValue, result.mask, result.position]
      else
        [value, value, value, null]
