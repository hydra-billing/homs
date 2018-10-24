import CustomFormatter from 'formatter';

modulejs.define('HBWFormString', ['React', 'jQuery', 'HBWCallbacksMixin', 'HBWDeleteIfMixin'], (React, jQuery, CallbacksMixin, DeleteIfMixin) => React.createClass({
  mixins: [CallbacksMixin, DeleteIfMixin],

  SUBSTITUTION: 'foobar',

  getInitialState () {
    const values = this.getNormalizedInitialValues(this.props.value || '');
    return {
      defaultValue:  values[0],
      value:         values[1],
      valid:         true,
      visualValue:   values[2],
      position:      values[3],
      previousValue: null
    };
  },

  patterns: {
    '9': '[0-9 ]',
    'a': '[A-Za-z ]',
    '*': '[A-Za-z0-9 ]'
  },

  partRegexp:     new RegExp('{{[^}]+}}'),
  templateRegexp: new RegExp('{{([^}]+)}}', 'g'),

  render () {
    const opts = {
      name:      this.props.name,
      type:      'text',
      onKeyUp:   this.onChange,
      onKeyDown: this.onKeyDown,
      onChange:  this.onChange,
      onBlur:    this.onBlur,
      onFocus:   this.onFocus,
      readOnly:  this.props.params.editable === false
    };

    let inputCSS = this.props.params.css_class;

    if (this.hidden) {
      inputCSS += ' hidden';
    }

    return <div className={inputCSS} title={this.props.params.tooltip}>
      <div className="form-group">
        <span className={this.props.params.label_css}>{this.props.params.label}</span>
        <input {...opts}
               ref="input"
               className={`form-control ${!this.state.valid && ' invalid'}`}
               data-toggle='tooltip'
               data-placement='bottom'
               data-original-title={this.props.params.message}
               data-trigger='manual' value={this.state.visualValue} />
        {!opts.readOnly && <input name={this.props.name} value={this.state.value} type="hidden" />}
      </div>
    </div>;
  },

  componentDidMount () {
    jQuery('[data-toggle="tooltip"]').tooltip({ animation: false });

    this.validateOnSubmit();
    this.hijackFormatter();
    this.onLoadValidation();
  },

  componentWillMount () {
    if (!this.guid) {
      this.setGuid();
    }

    this.hidden = this.deleteIf();
  },

  validateOnSubmit () {
    this.bind('hbw:validate-form', this.onFormSubmit);
  },

  hijackFormatter () {
    if (this.props.params.pattern) {
      this.extractValueRegexp = this.buildExtractRegexp(this.props.params.pattern);
      this.valueParts = this.buildValueParts(this.props.params.pattern);
    }
  },

  getElement () {
    return jQuery(this.refs.input);
  },

  onFormSubmit () {
    if (this.validationRequired()) {
      const $el = this.getElement();

      if (this.isValid()) {
        $el.removeClass('invalid');
      } else {
        $el.addClass('invalid');

        this.setValidationState();
        this.controlValidationTooltip(this.isValid());
        this.trigger('hbw:form-submitting-failed');
      }
    }
  },

  onLoadValidation () {
    if (this.validationRequired() && !!this.state.value) {
      this.controlValidationTooltip(this.isValid());
      this.setValidationState();
    }
  },

  onChange (event) {
    this.updateValue(event.target, false);

    if (this.validationRequired()) {
      this.runValidation();
    }
  },

  runValidation () {
    if (!this.state.valid) {
      this.controlValidationTooltip(this.isValid());

      if (this.validationRequired()) {
        this.setValidationState();
      }
    }
  },

  onKeyDown (event) {
    if (this.validationRequired()) {
      if ((event.keyCode === 8) || (event.keyCode === 46)) {
        event.preventDefault();

        this.updateValue(event.target, true);
      } else {
        this.updateValue(event.target, false);
      }

      this.runValidation();
    } else {
      this.updateValue(event.target, true);
    }
  },

  onBlur (_) {
    this.controlValidationTooltip(true);

    if (this.validationRequired()) {
      this.setValidationState();
    }
  },

  onFocus (_) {
    if (!this.state.valid) {
      this.controlValidationTooltip(this.isValid());

      if (this.validationRequired() && !this.isValid()) {
        this.setValidationState();
      }
    }
  },

  setValidationState () {
    this.setState({ valid: this.isValid() });
  },

  controlValidationTooltip (toHide) {
    const action = toHide ? 'hide' : 'show';

    jQuery(`[name="${this.props.name}"]`).tooltip(action);
  },

  isValid () {
    return (this.state.value || '').search(new RegExp(this.props.params.regex)) >= 0;
  },

  validationRequired () {
    return !!this.props.params.regex || !!this.props.params.pattern;
  },

  buildVisualAndHiddenValues (extractValueRegexp, valueParts, pattern, nextVal) {
    const value = this.substitute(valueParts, this.getSubstitutions(extractValueRegexp, nextVal));

    return Object.assign(
      CustomFormatter.applyMaskForValue(pattern, value, this.templateRegexp),
      { strippedValue: this.stripNonAlphanumericChars(value) }
    );
  },

  updateValue ($el, remove) {
    let visualValue;

    if (this.extractValueRegexp) {
      let nextVal;
      let result;

      ({ visualValue } = this.state);
      const currentVisualValue = $el.value;
      const { position } = this.state;
      const { pattern } = this.props.params;

      if (visualValue !== currentVisualValue) {
        nextVal = CustomFormatter.getNextValForAdd(visualValue, currentVisualValue, position, pattern);

        result = this.buildVisualAndHiddenValues(this.extractValueRegexp, this.valueParts, pattern, nextVal);

        $el.setSelectionRange(result.position, result.position);
        this.setState({
          value:         result.strippedValue,
          visualValue:   result.mask,
          previousValue: result.mask,
          position:      result.position
        });
      } else if (remove) {
        nextVal = CustomFormatter.getNextValForRemove(pattern, this.templateRegexp, position, currentVisualValue);

        result = this.buildVisualAndHiddenValues(this.extractValueRegexp, this.valueParts, pattern, nextVal);

        $el.setSelectionRange(result.position, result.position);
        this.setState({
          value:         result.strippedValue,
          visualValue:   result.mask,
          previousValue: result.mask,
          position:      result.position
        });
      } else {
        $el.setSelectionRange(position, position);
      }
    } else {
      this.setState({
        value:       $el.value,
        visualValue: $el.value
      });
    }
  },

  buildExtractRegexp (pattern) {
    const matches = this.getMatches(this.templateRegexp, pattern);

    const result = matches.reduce(((res, match) => {
      const replacement = match[1]
        .replace(/9/g, `${this.patterns['9']}?`)
        .replace(/a/g, `${this.patterns.a}?`)
        .replace(/\*/g, `${this.patterns['*']}?`);

      return res.replace(match[0], `(${replacement})`);
    }
    ), pattern.replace(/([\(\)\+\-\[\]\*])/g, '\\\$1'));

    return new RegExp(`^${result}$`);
  },

  getMatches (regexp, value) {
    let match;
    const matches = [];

    while ((match = regexp.exec(value))) {
      matches.push(match);
    }

    return matches;
  },

  // "1" -> ['1']
  // "{{a}}" -> [S]
  // "1{{a}}1" -> ['1', S, '1']
  // "{{a}}1" -> [S, '1']
  // "1{{a}}" -> ['1', S]
  // "{{a}}{{a}}" -> [S, S]
  // "{{a}}1{{a}}" -> [S, '1', S]
  // "{{a}}{{a}}1" -> [S, S, '1']
  buildValueParts (pattern) {
    const parts = [];
    const strings = pattern.split(this.partRegexp);
    let i = 0;

    for (const string of Array.from(strings)) {
      if (string) {
        parts.push(string);
      }

      if (i !== (strings.length - 1)) {
        parts.push(this.SUBSTITUTION);
      }

      i += 1;
    }

    return parts;
  },

  getSubstitutions (regexp, value) {
    const match = regexp.exec(value);
    const res = [];

    if (match) {
      for (let i = 1, end = match.length, asc = end >= 1; asc ? i < end : i > end; asc ? i++ : i--) {
        res.push(match[i]);
      }
    }

    return res;
  },

  substitute (template, values) {
    if (this.isEveryBlank(values)) {
      return '';
    } else {
      const res = [];
      let s = 0;

      for (let i = 0, end = template.length, asc = end >= 0; asc ? i < end : i > end; asc ? i++ : i--) {
        if (template[i] === this.SUBSTITUTION) {
          res.push(values[s] || '');
          s += 1;
        } else {
          res.push(template[i]);
        }
      }

      return res.join('');
    }
  },

  stripNonAlphanumericChars (value) {
    return value.replace(/[^a-z0-9]/ig, '');
  },

  isEveryBlank (array) {
    return array.reduce(((res, val) => res && !val.replace(/\s/g, '')), true);
  },

  getNormalizedInitialValues (value) {
    if (this.props.params.pattern) {
      const strippedPattern = this.props.params.pattern.replace(/[^a-z0-9\{\}]/ig, '');
      const strippedParts = this.buildValueParts(strippedPattern);
      const regexp = this.buildExtractRegexp(strippedPattern);
      const substitutions = this.getSubstitutions(regexp, value);
      const fullValue = this.substitute(strippedParts, substitutions);
      const patternedValue = substitutions.join('');

      const result = CustomFormatter.applyMaskForValue(this.props.params.pattern, value, this.templateRegexp);
      return [patternedValue, fullValue, result.mask, result.position];
    } else {
      return [value, value, value, null];
    }
  }
}));
