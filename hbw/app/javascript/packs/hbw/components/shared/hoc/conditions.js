/* eslint-disable no-eval */

import React, { Component } from 'react';

export default WrappedComponent => class WithConditions extends Component {
  variables = () => this.props.params.variables || this.props.params.task.definition.variables;

  variableByName = (name) => {
    const variable = this.variables().find(v => v.name === name);

    if (variable) {
      return variable.value;
    }

    return null;
  };

  deleteIf = () => this.evaluateConditions(this.getDeleteIfConditions());

  disableIf = () => this.evaluateConditions(this.getDisableIfConditions());

  evaluateConditions = (conditions) => {
    if ((Array.isArray(conditions) && (conditions.length === 0)) || Object.keys(conditions).length === 0) {
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
  };

  getDeleteIfConditions = () => this.props.params.delete_if || [];

  getDisableIfConditions = () => this.props.params.disable_if || [];

  conditionType = (condition) => {
    if (condition.constructor === Array) {
      return 'or';
    } else {
      return 'and';
    }
  };

  evaluateAndCondition = data => eval(data.condition.replace('$var', this.getValue(data.variable)));

  getValue = (name) => {
    if (this.props.params.dynamic === true) {
      return this.props.formValues[name];
    } else {
      return this.variableByName(name);
    }
  };

  evaluateOrCondition = (data) => {
    const result = [...data].map(innerCondition => this.evaluateAndCondition(innerCondition));

    return this.every(result);
  };

  every = results => results.every(el => el !== false);

  some = results => results.some(el => el === true);

  fireFieldValueUpdate = (name, value) => {
    this.props.trigger('hbw:update-value', { name, value });
  };

  render () {
    const [hidden, disabled] = [this.deleteIf(), this.disableIf()];

    return <WrappedComponent hidden={hidden}
                             disabled={disabled}
                             fireFieldValueUpdate={this.fireFieldValueUpdate}
                             {...this.state}
                             {...this.props} />;
  }
};
