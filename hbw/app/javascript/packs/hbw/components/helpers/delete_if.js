/* eslint-disable no-eval */

import React from 'react';
import { getDisplayName } from './utils';

export default WrappedComponent => React.createClass({
  displayName: `WithDeleteIf(${getDisplayName(WrappedComponent)})`,

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
  },

  render () {
    return <WrappedComponent hidden={this.hidden}
                             {...this.state}
                             {...this.props} />;
  }
});
