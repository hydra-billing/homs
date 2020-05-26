import { withErrorBoundary } from 'shared/hoc';
import React, { Component } from 'react';

class HBWFormCancelProcess extends Component {
  state = {
    error: false,
  };

  componentDidMount () {
    this.props.bind('hbw:have-errors', () => this.setState({ error: true }));
  }

  onClick = () => {
    const { env, processInstanceId } = this.props;
    const result = window.confirm(env.translator('confirm_cancel'));

    if (result) {
      env.connection.request({
        url:    `${env.connection.serverURL}/tasks/${processInstanceId}`,
        method: 'DELETE',
        async:  false
      });
    }
  };

  render () {
    const { env } = this.props;

    return (
      <button className="btn btn-primary"
              type="button"
              onClick={this.onClick}>
        {`${env.translator('cancel')}`}
      </button>
    );
  }
}

export default withErrorBoundary(HBWFormCancelProcess);
