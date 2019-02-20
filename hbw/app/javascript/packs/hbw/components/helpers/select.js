/* eslint-disable no-shadow */
import React, { Component } from 'react';

const withSelect = (WrappedComponent) => {
  class WithSelect extends Component {
    getChosenValue = () => {
      if (this.props.params.mode === 'select') {
        if (this.props.value === null) {
          if (this.props.params.nullable) {
            return null;
          } else if (this.props.params.choices.length) {
            const first = this.props.params.choices[0];

            if (Array.isArray(first)) {
              return first[0];
            } else {
              return first;
            }
          }
          return null;
        } else {
          return this.props.value;
        }
      } else {
        return this.props.value;
      }
    };

    hasValueInChoices = (value) => {
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
    };

    isEqual = (a, b) => {
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
    };

    isChoiceEqual = (choice, value) => {
      if (Array.isArray(choice)) {
        return this.isEqual(choice[0], value);
      } else {
        return this.isEqual(choice, value);
      }
    };

    missFieldInVariables = () => {
      return this.props.params.variables.every(v => v.name !== this.props.name);
    };

    render() {
      return <WrappedComponent getChosenValue={this.getChosenValue}
                               hasValueInChoices={this.hasValueInChoices}
                               isEqual={this.isEqual}
                               isChoiceEqual={this.isChoiceEqual}
                               missFieldInVariables={this.missFieldInVariables}
                               {...this.state}
                               {...this.props} />;
    }
  };

  return WithSelect;
};

export default withSelect;
