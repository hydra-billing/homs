import React from 'react';

class OrderListHeaderCell extends React.Component {
  render () {
    const cellClass = this.props.show ? '' : 'hidden';

    let orderIcon;

    if (this.props.rowCode === this.props.orderRowCode) {
      if (this.props.order === 'desc') {
        orderIcon = <i className='fas fa-sort-down'/>;
      } else {
        orderIcon = <i className='fas fa-sort-up'/>;
      }
    }

    return <th className={cellClass}
      onClick={this.props.orderRowCodeHandler.bind(null, this.props.rowCode)}>
      {this.props.label}
      {orderIcon}
    </th>;
  }
}

export default OrderListHeaderCell;
