import React from 'react';

const OrderListHeaderCell = React.createClass({
  render () {
    const cellClass = this.props.show ? '' : 'hidden';

    let orderIcon;

    if (this.props.rowCode === this.props.orderRowCode) {
      if (this.props.order === 'desc') {
        orderIcon = <i className='fa fa-sort-down'/>;
      } else {
        orderIcon = <i className='fa fa-sort-up'/>;
      }
    }

    return <th className={cellClass}
      onClick={this.props.orderRowCodeHandler.bind(null, this.props.rowCode)}>
      {this.props.label}
      {orderIcon}
    </th>;
  }
});

export default OrderListHeaderCell;
