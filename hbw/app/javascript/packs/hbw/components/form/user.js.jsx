import React, { Component } from 'react';
import { withErrorBoundary } from 'shared/hoc';
import Select from './select.js';

class FormUser extends Component {
  componentDidMount () {
    this.props.onRef(this);
  }

  componentWillUnmount () {
    this.props.onRef(undefined);
  }

  render () {
    const {
      name, params, disabled, task
    } = this.props;

    const selectParams = {
      ...params,
      placeholder: params.placeholder || 'User',
      mode:        'lookup',
      url:         '/users/lookup',
      userLookup:  true,
      choices:     []
    };

    return <Select
      name={name}
      params={selectParams}
      task={task}
      disabled={disabled}
      onRef={(i) => { this[`${name}`] = i; }} />;
  }

  serialize = () => this[`${this.props.name}`].serialize();
}

const FormUserWrapped = withErrorBoundary(FormUser);

export default FormUserWrapped;
