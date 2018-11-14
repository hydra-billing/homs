modulejs.define('HBWFormUser', ['React', 'ReactDOM', 'HBWFormSelect'], (React, ReactDOM, Select) => React.createClass({
  render () {
    const params = Object.assign({}, this.props.params, {
      placeholder: this.props.params.placeholder || 'User',
      mode:        'lookup',
      url:         '/users/lookup',
      choices:     []
    });

    return <Select name={this.props.name} params={params} env={this.props.env}/>;
  }
}));
