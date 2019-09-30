import React from 'react';

class OrderListCell extends React.Component {
  getValueForType = () => {
    switch (this.props.profile.type) {
      case 'link':
        return <a href={this.props.value.href}>{this.props.value.title}</a>;
      case 'boolean':
        return this.props.value ? <i className="fas fa-check"></i> : '';
      case 'state': {
        const stateIconClass = `fas ${this.props.value.icon}`;
        return <span><i className={stateIconClass}></i> {this.props.value.title}</span>;
      }
      default:
        return this.props.value;
    }
  };

  render () {
    const cellClass = this.props.profile.show ? '' : 'hidden';
    const cellValue = this.getValueForType();

    return <td className={cellClass}>
      {cellValue}
    </td>;
  }
}

export default OrderListCell;
