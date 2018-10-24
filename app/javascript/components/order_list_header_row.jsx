import React from 'react';
import OrderListHeaderCell from './order_list_header_cell';

const OrderListHeaderRow = React.createClass({
  render () {
    const headerCells = [];
    for (let field in this.props.profile) {
      const show = this.props.profile[field].show;

      headerCells.push(<OrderListHeaderCell key={field}
        label={this.props.profile[field].label}
        show={show} orderRowCodeHandler={this.props.orderRowCodeHandler}
        rowCode={field}
        orderRowCode={this.props.orderRowCode}
        order={this.props.order}/>);
    }

    return <tr>
      {headerCells}
    </tr>;
  }
});

export default OrderListHeaderRow;
