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
    const result = window.confirm(this.props.env.translator('confirm_cancel'));

    if (result) {
      this.props.env.connection.request({
        url:    `${this.props.env.connection.serverURL}/tasks/${this.props.processInstanceId}`,
        method: 'DELETE',
        async:  false
      });
    }
  };

  render () {
    const { env } = this.props;

    const className = 'btn btn-primary';

    return <div className="row">
             <div className="tab-panel form-group col-xs-12 delete-process-btn">
               <button className={className}
                       type="button"
                       onClick={this.onClick}>
                 <i className="fas fa-trash" />
                   {`${env.translator('cancel')}`}
               </button>
             </div>
           </div>;
  }
}

export default withErrorBoundary(HBWFormCancelProcess);
