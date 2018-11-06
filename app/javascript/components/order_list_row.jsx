import React from 'react';
import OrderListCell from './order_list_cell';

class OrderListRow extends React.Component {
  render () {
    const cells = [];

    Object.keys(this.props.profile).forEach((value) => {
      cells.push(<OrderListCell key={value} value={this.props.values[value]} profile={this.props.profile[value]} />);
    });

    return <tr className={this.props.values.options.class}>
      {cells}
    </tr>;
  }
}

export default OrderListRow;
