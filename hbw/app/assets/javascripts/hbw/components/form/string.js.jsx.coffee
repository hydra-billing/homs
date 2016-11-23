modulejs.define 'HBWFormString', ['React', 'jQuery', 'HBWCallbacksMixin', 'HBWDeleteIfMixin'], (React, jQuery, CallbacksMixin, DeleteIfMixin) ->
  React.createClass
    mixins: [CallbacksMixin, DeleteIfMixin]

    SUBSTITUTION: 'foobar'

    getInitialState: ->
      values = this.getNormalizedInitialValues(this.props.value)
      { defaultValue: values[0], value: values[1], valid: true }

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
        defaultValue: @state.defaultValue
        onKeyUp: @onChange
        onKeyDown: @onChange
        onChange: @onChange
        onBlur: @onBlur
        onFocus: @onFocus
        readOnly: @props.params.editable == false
      }

      inputCSS = this.props.params.css_class
      inputCSS += ' hidden' if this.hidden

      `<div className={inputCSS} title={this.props.params.tooltip}>
        <div className="form-group">
          <span className={this.props.params.label_css}>{this.props.params.label}</span>
          <input {...opts} ref="input" className={'form-control ' + (!this.state.valid && ' invalid')} data-toggle='tooltip' data-placement='bottom' data-original-title={this.props.params.message} data-trigger='manual' />
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
      $el = @getElement().first()

      if this.props.params.pattern
        this.extractValueRegexp = this.buildExtractRegexp(this.props.params.pattern)
        this.valueParts = this.buildValueParts(this.props.params.pattern)

        $el.formatter(
          pattern: this.props.params.pattern
          persistent: true
        )

    getElement: ->
      jQuery(@refs['input'].getDOMNode())

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
      if @validationRequired() && !!this.state.value
        @controlValidationTooltip(@isValid())
        @setValidationState()

    onChange: (event) ->
      $el = jQuery(event.target)
      @updateValue($el)

      unless this.state.valid
        @controlValidationTooltip(@isValid())

        if @validationRequired()
          @setValidationState()

    onBlur: (event) ->
      @controlValidationTooltip(true)

      if @validationRequired()
        @setValidationState()

    onFocus: (event) ->
      unless this.state.valid
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

      jQuery('[name="' + this.props.name + '"]').tooltip(action)

    isValid: ->
      (this.state.value or '').search(new RegExp(this.props.params.regex)) >= 0

    validationRequired: ->
      !!this.props.params.regex

    updateValue: ($el) ->
      if @extractValueRegexp
        substitutions = this.getSubstitutions(@extractValueRegexp, $el.val())
        value = this.substitute(@valueParts, substitutions)
        newValue = @stripNonAlphanumericChars(value)
        @setState(value: newValue)
      else
        @setState(value: $el.val())

    buildExtractRegexp: (pattern) ->
      matches = this.getMatches(this.templateRegexp, pattern)

      result = matches.reduce(((res, match) =>
        replacement = match[1]
          .replace(/9/g, this.patterns['9'] + '?')
          .replace(/a/g, this.patterns['a'] + '?')
          .replace(/\*/g, this.patterns['*'] + '?')

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
      strings = pattern.split(this.partRegexp)
      i = 0

      for string in strings
        parts.push(string) if string
        parts.push(this.SUBSTITUTION) if i != strings.length - 1
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
      if this.isEveryBlank(values)
        ''
      else
        res = []
        s = 0

        for i in [0...template.length]
          if template[i] == this.SUBSTITUTION
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
      if this.props.params.pattern
        strippedPattern = this.props.params.pattern.replace(/[^a-z0-9\{\}]/ig, '')
        strippedParts = this.buildValueParts(strippedPattern)
        regexp = this.buildExtractRegexp(strippedPattern)
        substitutions = this.getSubstitutions(regexp, value)
        fullValue = this.substitute(strippedParts, substitutions)
        patternedValue = substitutions.join('')

        [patternedValue, fullValue]
      else
        [value, value]
