import React from 'react';
import OrderListRow from './order_list_row';
import OrderListHeaderRow from './order_list_header_row';

class OrderListTable extends React.Component {
  render () {
    const tableBody = this.props.orders.map((order, index) => (
      <OrderListRow key={index} values={order} profile={this.props.profile} />
    ));

    return <table className="table table-hover">
      <thead>
        <OrderListHeaderRow profile={this.props.profile}
          orderRowCodeHandler={this.props.orderRowCodeHandler}
          orderRowCode={this.props.orderRowCode}
          order={this.props.order}/>
      </thead>
      <tbody>
        {tableBody}
      </tbody>
    </table>;
  }
}

export default OrderListTable;
