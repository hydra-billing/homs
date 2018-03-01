var OrderListHeaderRow = React.createClass({
  render() {
    var headerCells = [];
    for (var field in this.props.profile) {
      var show = this.props.profile[field].show;

      headerCells.push(<OrderListHeaderCell key={field} label={this.props.profile[field].label} show={show}/>)
    }

    return <tr>
      {headerCells}
    </tr>
  }
});
