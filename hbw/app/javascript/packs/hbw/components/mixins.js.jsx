/* eslint no-eval: "off" */

modulejs.define('HBWTranslationsMixin', ['HBWTranslator'], Translator => ({
  t (key, vars) {
    return Translator.translate(key, vars);
  }
}));

modulejs.define('HBWSelectMixin', [], () => ({
  getChoices (value) {
    let choices;

    if (this.props.params.mode === 'select') {
      choices = this.props.params.choices.slice();

      this.addCurrentValueToChoices(value);

      if (this.props.params.nullable) {
        this.addNullChoice(choices);
      }

      return choices;
    } else if (this.props.params.mode === 'lookup') {
      return this.props.params.choices;
    }

    return null;
  },

  getChosenValue () {
    if (this.props.params.mode === 'select') {
      if (this.props.value === null) {
        if (this.props.params.nullable) {
          return null;
        } if (this.props.params.choices.length) {
          const first = this.props.params.choices[0];

          if (Array.isArray(first)) {
            return first[0];
          }
          return first;
        }
        return null;
      }
      return this.props.value;
    }
    return this.props.value;
  },

  hasValueInChoices (value) {
    if (this.props.params.mode === 'lookup') {
      return true;
    }

    if (this.isEqual(value, null) && this.props.params.nullable) {
      return true;
    }

    if (this.props.params.choices.some(c => this.isChoiceEqual(c, value))) {
      return true;
    }

    return false;
  },

  isEqual (a, b) {
    if (a === b) {
      return true;
    }
    if ((a === null) && (b === null)) {
      return true;
    }
    if (((a === '') && (b === null)) || ((a === null) && (b === ''))) {
      return true;
    }
    if ((a === null) || (b === null)) {
      return false;
    }

    return a.toString() === b.toString();
  },

  isChoiceEqual (choice, value) {
    if (Array.isArray(choice)) {
      return this.isEqual(choice[0], value);
    }
    return this.isEqual(choice, value);
  },

  missFieldInVariables () {
    return this.props.params.variables.every(v => v.name !== this.props.name);
  }
}));

modulejs.define('HBWDeleteIfMixin', ['jQuery'], jQuery => ({
  variables () {
    return this.props.params.variables || this.props.params.task.definition.variables;
  },

  variableByName (name) {
    const variable = this.variables().find(v => v.name === name);

    if (variable) {
      return variable.value;
    }

    return null;
  },

  deleteIf () {
    const conditions = this.getConditions();

    if ((Array.isArray(conditions) && (conditions.length === 0)) || jQuery.isEmptyObject(conditions)) {
      return false;
    }

    const conditionType = this.conditionType(conditions[0]);

    const result = [...conditions].map(condition => (conditionType === 'or'
      ? this.evaluateOrCondition(condition)
      : this.evaluateAndCondition(condition)));

    if (conditionType === 'or') {
      return this.some(result);
    }

    return this.every(result);
  },

  getConditions () {
    return this.props.params.delete_if || [];
  },

  conditionType (condition) {
    if (condition.constructor === Array) {
      return 'or';
    } else {
      return 'and';
    }
  },

  evaluateAndCondition (data) {
    return eval(data.condition.replace('$var', this.variableByName(data.variable)));
  },

  evaluateOrCondition (data) {
    const result = [...data].map(innerCondition => this.evaluateAndCondition(innerCondition));

    return this.every(result);
  },

  componentWillMount () {
    this.hidden = this.deleteIf();
  },

  every (results) {
    return results.every(el => el !== false);
  },

  some (results) {
    return results.some(el => el === true);
  }
}));
