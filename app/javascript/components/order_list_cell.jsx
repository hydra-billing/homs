import React from 'react';

const OrderListCell = React.createClass({
  getValueForType () {
    switch (this.props.profile.type) {
      case 'link':
        return <a href={this.props.value.href}>{this.props.value.title}</a>;
        break;
      case 'boolean':
        return this.props.value ? <i className="fa fa-check"></i> : '';
        break;
      case 'state':
        var stateIconClass = `fa ${this.props.value.icon}`;
        return <span><i className={stateIconClass}></i> {this.props.value.title}</span>;
      default:
        return this.props.value;
    }
  },

  render () {
    const cellClass = this.props.profile.show ? '' : 'hidden';
    const cellValue = this.getValueForType();

    return <td className={cellClass}>
      {cellValue}
    </td>;
  }
});

export default OrderListCell;
