var OrderList = React.createClass({
  getInitialState() {
    return {
      profile: this.props.profile,
      page: 2,
      orders: [],
      hasMorePages: this.props.initialOrders.length == this.props.pageSize,
      requesting: false
    }
  },

  componentDidMount() {
    var selectElement = $('#column-settings');

    if (this.props.withCustomProfile) {
      var enabledOptions = [];
      for (var field in this.props.profile.data) {
        if (this.props.profile.data[field].show)
          enabledOptions.push(field)
      }

      selectElement.multiselect({
        maxHeight: 400,
        dropUp: true,
        buttonClass: 'btn btn-link dropup',
        buttonText: this.buttonText,
        onChange: this.handleOptionChange,
        onDropdownHide: this.saveProfile
      });

      selectElement.multiselect('select', enabledOptions);
    } else {
      selectElement.hide();
    }
  },

  buttonText() {
    return I18n.t('js.columns_settings');
  },

  handleOptionChange(option, checked) {
    var value = $(option).val();
    var newProfile = $.extend(true, {}, this.state.profile);

    newProfile.data[value].show = checked;
    this.setState({profile: newProfile});
  },

  saveProfile() {
    if (this.state.profile.id)
      this.updateProfile();
    else
      this.createProfile();
  },

  createProfile() {
    $.ajax('/profiles', {
      method: 'POST',
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify(this.state.profile),
      success: function(data) { this.setState({profile: data}) }.bind(this)
    })
  },

  updateProfile() {
    $.ajax('/profiles/' + this.state.profile.id, {
      method: 'PUT',
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify(this.state.profile),
      success: function(data) { this.setState({profile: data}) }.bind(this)
    })
  },

  showMoreOrders() {
    filterParams           = this.props.filterParams;
    filterParams.page_size = this.props.pageSize;
    filterParams.page      = this.state.page;

    this.setState({requesting: true});

    $.ajax('/orders/list', {
      method: 'GET',
      dataType: 'json',
      contentType: 'application/json',
      data: filterParams,
      success: function(data) { this.setState((prevState, props) =>
        ({
          orders: prevState.orders.concat(data),
          page: prevState.page + 1,
          hasMorePages: data.length == this.props.pageSize
        }))
      }.bind(this),
      complete: function() {
        this.setState({requesting: false})
      }.bind(this)
    })
  },

  render() {
    var options = [];
    for (var field in this.props.profile.data) {
      var disabled = field == 'code';
      options.push(<option key={field} value={field} disabled={disabled}>{this.props.profile.data[field].label}</option>)
    }

    var showMoreContainer;
    if (this.state.hasMorePages) {
      cssClass = 'show-more-container';

      if (this.state.requesting) {
        cssClass += ' requesting'
      }

      showMoreContainer = <div className={cssClass} onClick={this.showMoreOrders}>
        <i className="fa fa-caret-down fa-lg"/>
      </div>
    }

    return <div className="order-list-container">
      <select id="column-settings" multiple="multiple">
        {options}
      </select>
      <div className="order-list-table">
        <OrderListTable profile={this.state.profile.data} orders={this.props.initialOrders.concat(this.state.orders)}/>
        {showMoreContainer}
      </div>
    </div>
  }
});
