import React from 'react';
import OrderListTable from './order_list_table';

class OrderList extends React.Component {
  state = {
    profile:      this.props.profile,
    page:         1,
    orders:       [],
    hasMorePages: true,
    requesting:   false,
    orderRowCode: '',
    order:        'asc'
  };

  changeOrderRowCode = (code) => {
    const newState = {};

    if (code === this.state.orderRowCode) {
      if (this.state.order === 'asc') {
        newState.order = 'desc';
      } else {
        newState.order = 'asc';
      }
    }

    newState.orderRowCode = code;

    this.setState(newState);

    const { filterParams } = this.props;

    filterParams.sort_by = code;
    filterParams.order = newState.order || this.state.order;
    filterParams.page = 1;

    $.ajax('/orders/list', {
      method:      'GET',
      dataType:    'json',
      contentType: 'application/json',
      data:        filterParams,
      success:     (data) => {
        this.setState(() => ({
          orders:       data,
          page:         2,
          hasMorePages: data.length === parseInt(this.props.pageSize)
        }));
      }
    });
  };

  componentDidMount () {
    const selectElement = $('#column-settings');

    if (this.props.withCustomProfile) {
      const enabledOptions = [];

      Object.keys(this.props.profile.data).forEach((field) => {
        if (this.props.profile.data[field].show) {
          enabledOptions.push(field);
        }
      });

      selectElement.multiselect({
        maxHeight:      400,
        dropUp:         true,
        buttonClass:    'btn btn-link dropup',
        buttonText:     this.buttonText,
        onChange:       this.handleOptionChange,
        onDropdownHide: this.saveProfile
      });

      selectElement.multiselect('select', enabledOptions);
    } else {
      selectElement.hide();
    }

    this.showMoreOrders();
  }

  buttonText = () => I18n.t('js.columns_settings');

  handleOptionChange = (option, checked) => {
    const value = $(option).val();
    const newProfile = $.extend(true, {}, this.state.profile);

    newProfile.data[value].show = checked;
    this.setState({ profile: newProfile });
  };

  saveProfile = () => {
    if (this.state.profile.id) {
      this.updateProfile();
    } else {
      this.createProfile();
    }
  };

  createProfile = () => {
    $.ajax('/profiles', {
      method:      'POST',
      dataType:    'json',
      contentType: 'application/json',
      data:        JSON.stringify(this.state.profile),
      success:     (data) => {
        this.setState({ profile: data });
      }
    });
  };

  updateProfile = () => {
    $.ajax(`/profiles/${this.state.profile.id}`, {
      method:      'PUT',
      dataType:    'json',
      contentType: 'application/json',
      data:        JSON.stringify(this.state.profile),
      success:     (data) => {
        this.setState({ profile: data });
      }
    });
  };

  showMoreOrders = () => {
    const { filterParams } = this.props;
    filterParams.page_size = this.props.pageSize;
    filterParams.page = this.state.page;
    filterParams.sort_by = this.state.orderRowCode;
    filterParams.order = this.state.order;

    this.setState({ requesting: true });

    $.ajax('/orders/list', {
      method:      'GET',
      dataType:    'json',
      contentType: 'application/json',
      data:        filterParams,
      success:     (data) => {
        this.setState(prevState => ({
          orders:       prevState.orders.concat(data),
          page:         prevState.page + 1,
          hasMorePages: data.length === parseInt(this.props.pageSize)
        }));
      },
      complete: () => {
        this.setState({ requesting: false });
      }
    });
  };

  render () {
    const options = [];

    Object.keys(this.props.profile.data).forEach((field) => {
      const disabled = field === 'code';
      options.push(
        <option key={field} value={field} disabled={disabled}>{this.props.profile.data[field].label}</option>
      );
    });

    let showMoreContainer;
    if (this.state.hasMorePages) {
      let cssClass = 'show-more-container';

      if (this.state.requesting) {
        cssClass += ' requesting';
      }

      showMoreContainer = <div className={cssClass} onClick={this.showMoreOrders}>
        <i className="fas fa-caret-down fa-lg"/>
      </div>;
    }

    return <div className="order-list-container">
      <select id="column-settings" multiple="multiple">
        {options}
      </select>
      <div className="order-list-table">
        <OrderListTable profile={this.state.profile.data}
          orders={this.state.orders}
          orderRowCodeHandler={this.changeOrderRowCode}
          orderRowCode={this.state.orderRowCode}
          order={this.state.order}/>
        {showMoreContainer}
      </div>
    </div>;
  }
}

export default OrderList;
