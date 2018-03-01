var OrderListRow = React.createClass({
  render() {
    var cells = [];
    for (var value in this.props.profile) {
      cells.push(<OrderListCell key={value} value={this.props.values[value]} profile={this.props.profile[value]} />)
    }

    return <tr className={this.props.values.options.class}>
      {cells}
    </tr>
  }
});
