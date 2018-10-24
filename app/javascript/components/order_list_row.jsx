import React from 'react';
import OrderListCell from './order_list_cell';

const OrderListRow = React.createClass({
  render () {
    const cells = [];
    for (let value in this.props.profile) {
      cells.push(<OrderListCell key={value} value={this.props.values[value]} profile={this.props.profile[value]} />);
    }

    return <tr className={this.props.values.options.class}>
      {cells}
    </tr>;
  }
});

export default OrderListRow;
