modulejs.define('HBWError', ['React', 'jQuery'], (React, jQuery) => {
  const Error = React.createClass({
    getInitialState () {
      return { showFull: false };
    },

    render () {
      let display;

      if (this.props.error) {
        let error;
        let iconClass;

        if (this.state.showFull) {
          display = 'block';
          iconClass = 'fa fa-chevron-down';
        } else {
          display = 'none';
          iconClass = 'fa fa-chevron-right';
        }

        if (this.props.error.hasOwnProperty('responseText')) {
          error = this.props.error.responseText;
        } else {
          ({ error } = this.props);
        }

        return <div className="alert alert-danger hbw-error">
          <i className="fa fa-exclamation-triangle"></i>
          <strong>{` ${this.props.env.translator('error')}`}</strong>
          <br />
          <a href="javascript:;"
            onClick={this.toggleBacktrace}
            className="show-more"
            style={{ display: error ? 'block' : 'none' }}>
            <i className={iconClass}></i>
            {this.props.env.translator('more')}
          </a>
          <pre style={{ display }}>{error}</pre>
        </div>;
      } else {
        return <div style={{ display: 'none' }}></div>;
      }
    },

    toggleBacktrace () {
      this.setState({ showFull: !this.state.showFull });
    }
  });

  return Error;
});
