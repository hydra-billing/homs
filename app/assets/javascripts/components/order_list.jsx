var OrderList = React.createClass({
  getInitialState() {
    return {
      profile: this.props.profile
    }
  },

  componentDidMount() {
    var selectElement = $('#column-settings');

    if (this.props.with_custom_profile) {
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

  render() {
    var options = [];
    for (var field in this.props.profile.data) {
      var disabled = field == 'code';
      options.push(<option key={field} value={field} disabled={disabled}>{this.props.profile.data[field].label}</option>)
    }

    return <div className="order-list-container">
      <select id="column-settings" multiple="multiple">
        {options}
      </select>
      <div className="order-list-table">
        <OrderListTable profile={this.state.profile.data} orders={this.props.orders}/>
      </div>
    </div>
  }
});
