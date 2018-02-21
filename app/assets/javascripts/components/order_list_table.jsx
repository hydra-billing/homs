var OrderListTable = React.createClass({
  render() {
    var tableBody = this.props.orders.map(function(order, index) {
      return <OrderListRow key={index} values={order} profile={this.props.profile} />
    }.bind(this));

    return <table className="table table-hover">
      <thead>
        <OrderListHeaderRow profile={this.props.profile}/>
      </thead>
      <tbody>
        {tableBody}
      </tbody>
    </table>
  }
});
