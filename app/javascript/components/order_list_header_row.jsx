import React from 'react';
import OrderListHeaderCell from './order_list_header_cell';

class OrderListHeaderRow extends React.Component {
  render () {
    const headerCells = [];

    Object.keys(this.props.profile).forEach((field) => {
      const { show } = this.props.profile[field];

      headerCells.push(<OrderListHeaderCell key={field}
                                            label={this.props.profile[field].label}
                                            show={show} orderRowCodeHandler={this.props.orderRowCodeHandler}
                                            rowCode={field}
                                            orderRowCode={this.props.orderRowCode}
                                            order={this.props.order}/>);
    });

    return <tr>
      {headerCells}
    </tr>;
  }
}

export default OrderListHeaderRow;
