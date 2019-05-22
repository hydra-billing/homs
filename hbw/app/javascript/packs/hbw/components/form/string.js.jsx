/* eslint no-useless-escape: "off" */
/* eslint no-cond-assign: ["error", "except-parens"] */

import CustomFormatter from 'formatter';
import Tooltip from 'tooltip';
import { withCallbacks, withConditions, compose } from '../helpers';

modulejs.define('HBWFormString', ['React'], (React) => {
  class HBWFormString extends React.Component {
    constructor (props, context) {
      super(props, context);
      const values = this.getNormalizedInitialValues(props.value || '');

      this.state = {
        defaultValue:  values[0],
        value:         values[1],
        valid:         true,
        visualValue:   values[2],
        position:      values[3],
        previousValue: null
      };
    }

    SUBSTITUTION = 'foobar';

    patterns = {
      9:   '[0-9 ]',
      a:   '[A-Za-z ]',
      '*': '[A-Za-z0-9 ]'
    };

    partRegexp = new RegExp('{{[^}]+}}');

    templateRegexp = new RegExp('{{([^}]+)}}', 'g');

    render () {
      const opts = {
        name:      this.props.name,
        type:      'text',
        onKeyUp:   this.onChange,
        onKeyDown: this.onKeyDown,
        onChange:  this.onChange,
        onBlur:    this.onBlur,
        onFocus:   this.onFocus,
        readOnly:  this.props.params.editable === false || this.props.disabled
      };

      const errorTooltip = <div
        ref={(t) => { this.tooltipContainer = t; }}
        className={`${!this.state.valid && 'tooltip-red'}`}
      />;

      let inputCSS = this.props.params.css_class;

      if (this.props.hidden) {
        inputCSS += ' hidden';
      }

      return <div className={inputCSS} title={this.props.params.tooltip}>
        <div className="form-group">
          <span className={this.props.params.label_css}>{this.props.params.label}</span>
          <input {...opts}
                 ref={(i) => { this.input = i; }}
                 className={`form-control ${!this.state.valid && ' invalid'}`}
                 value={this.state.visualValue} />
          {!opts.readOnly && <input name={this.props.name} value={this.state.value} type="hidden" />}
          {errorTooltip}
        </div>
      </div>;
    }

    componentDidMount () {
      this.props.onRef(this);
      this.tooltip = new Tooltip(this.input, {
        title:     this.props.params.message || this.props.env.translator('errors.field_is_required'),
        container: this.tooltipContainer,
        trigger:   'manual',
        placement: 'top'
      });

      this.validateOnSubmit();
      this.hijackFormatter();
      this.onLoadValidation();
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    componentWillMount () {
      if (!this.guid) {
        this.props.setGuid();
      }
    }

    validateOnSubmit = () => {
      this.props.bind('hbw:validate-form', this.onFormSubmit);
    };

    hijackFormatter = () => {
      if (this.props.params.pattern) {
        this.extractValueRegexp = this.buildExtractRegexp(this.props.params.pattern);
        this.valueParts = this.buildValueParts(this.props.params.pattern);
      }
    };

    getElement = () => this.input;

    onFormSubmit = () => {
      if (this.validationRequired()) {
        const el = this.getElement();

        if (this.isValid()) {
          el.classList.remove('invalid');
        } else {
          el.classList.add('invalid');

          this.setValidationState();
          this.controlValidationTooltip(this.isValid());
          this.props.trigger('hbw:form-submitting-failed');
        }
      }
    };

    onLoadValidation = () => {
      if (this.validationRequired() && this.isFilled()) {
        this.controlValidationTooltip(this.isValid());
        this.setValidationState();
      }
    };

    onChange = (event) => {
      this.updateValue(event.target, false);

      if (this.validationRequired()) {
        this.runValidation();
      }
    };

    runValidation = () => {
      if (!this.state.valid) {
        this.controlValidationTooltip(this.isValid());

        if (this.validationRequired()) {
          this.setValidationState();
        }
      }
    };

    onKeyDown = (event) => {
      if (this.props.params.pattern) {
        if ((event.keyCode === 8) || (event.keyCode === 46)) {
          event.preventDefault();

          this.updateValue(event.target, true);
        } else {
          this.updateValue(event.target, false);
        }
      } else {
        this.updateValue(event.target, true);
      }

      if (this.validationRequired()) {
        this.runValidation();
      }
    };

    onBlur = () => {
      this.controlValidationTooltip(true);

      if (this.validationRequired()) {
        this.setValidationState();
      }
    };

    onFocus = () => {
      if (!this.state.valid) {
        this.controlValidationTooltip(this.isValid());

        if (this.validationRequired() && !this.isValid()) {
          this.setValidationState();
        }
      }
    };

    setValidationState = () => {
      this.setState({ valid: this.isValid() });
    };

    controlValidationTooltip = (toHide) => {
      if (toHide) {
        this.tooltip.hide();
      } else {
        this.tooltip.show();
      }
    };

    isValid = () => {
      const requiredOK = !this.props.params.required || this.isFilled();
      const regexOK = !this.props.params.regex || this.regexMatched();

      return requiredOK && regexOK;
    };

    validationRequired = () => {
      const { required, regex } = this.props.params;

      return required || !!regex;
    };

    isFilled = () => {
      const { value } = this.state;

      return value !== null && value !== undefined && value.length > 0;
    };

    regexMatched = () => (this.state.value || '').search(new RegExp(this.props.params.regex)) >= 0;

    buildVisualAndHiddenValues = (extractValueRegexp, valueParts, pattern, nextVal) => {
      const value = this.substitute(valueParts, this.getSubstitutions(extractValueRegexp, nextVal));

      return Object.assign(
        CustomFormatter.applyMaskForValue(pattern, value, this.templateRegexp),
        { strippedValue: this.stripNonAlphanumericChars(value) }
      );
    };

    updateValue = ($el, remove) => {
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

      this.props.fireFieldValueUpdate(this.props.name, this.state.value);
    };

    buildExtractRegexp = (pattern) => {
      const matches = this.getMatches(this.templateRegexp, pattern);

      const result = matches.reduce(((res, match) => {
        const replacement = match[1]
          .replace(/9/g, `${this.patterns['9']}?`)
          .replace(/a/g, `${this.patterns.a}?`)
          .replace(/\*/g, `${this.patterns['*']}?`);

        return res.replace(match[0], `(${replacement})`);
      }), pattern.replace(/([\(\)\+\-\[\]\*])/g, '\\\$1'));

      return new RegExp(`^${result}$`);
    };

    getMatches = (regexp, value) => {
      let match;
      const matches = [];

      while ((match = regexp.exec(value))) {
        matches.push(match);
      }

      return matches;
    };

    // "1" -> ['1']
    // "{{a}}" -> [S]
    // "1{{a}}1" -> ['1', S, '1']
    // "{{a}}1" -> [S, '1']
    // "1{{a}}" -> ['1', S]
    // "{{a}}{{a}}" -> [S, S]
    // "{{a}}1{{a}}" -> [S, '1', S]
    // "{{a}}{{a}}1" -> [S, S, '1']
    buildValueParts = (pattern) => {
      const parts = [];
      const strings = pattern.split(this.partRegexp);
      let i = 0;

      [...strings].forEach((string) => {
        if (string) {
          parts.push(string);
        }

        if (i !== (strings.length - 1)) {
          parts.push(this.SUBSTITUTION);
        }

        i += 1;
      });

      return parts;
    };

    getSubstitutions = (regexp, value) => {
      const match = regexp.exec(value);
      const res = [];

      if (match) {
        for (let i = 1; i <= match.length; i += 1) {
          res.push(match[i]);
        }
      }

      return res;
    };

    substitute = (template, values) => {
      if (this.isEveryBlank(values)) {
        return '';
      } else {
        const res = [];
        let s = 0;

        for (let i = 0; i < template.length; i += 1) {
          if (template[i] === this.SUBSTITUTION) {
            res.push(values[s] || '');
            s += 1;
          } else {
            res.push(template[i]);
          }
        }

        return res.join('');
      }
    };

    stripNonAlphanumericChars = value => value.replace(/[^a-z0-9]/ig, '');

    isEveryBlank = array => array.reduce(((res, val) => res && val && !val.replace(/\s/g, '')), true);

    getNormalizedInitialValues = (value) => {
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
    };

    serialize = () => ({ [this.props.name]: this.state.value });
  }

  return compose(withCallbacks, withConditions)(HBWFormString);
});
