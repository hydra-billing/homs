var OrderListHeaderCell = React.createClass({
  render() {
    var cellClass = this.props.show ? '' : 'hidden';

    return <th className={cellClass}>
      {this.props.label}
    </th>
  }
});
