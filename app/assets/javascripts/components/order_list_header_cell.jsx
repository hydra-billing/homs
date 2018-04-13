var OrderListHeaderCell = React.createClass({
  render() {
    var cellClass = this.props.show ? '' : 'hidden';

    var orderIcon;

    if (this.props.rowCode == this.props.orderRowCode)
      if (this.props.order == 'desc')
        orderIcon = <i className='fa fa-sort-down'/>;
      else
        orderIcon = <i className='fa fa-sort-up'/>;

    return <th className={cellClass}
               onClick={this.props.orderRowCodeHandler.bind(null, this.props.rowCode)}>
      {this.props.label}
      {orderIcon}
    </th>
  }
});
