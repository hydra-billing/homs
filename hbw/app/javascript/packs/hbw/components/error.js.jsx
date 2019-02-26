/* eslint no-script-url: "off" */

modulejs.define('HBWError', ['React'], React => (
  class HBWError extends React.Component {
    state = { showFull: false };

    render () {
      let display;

      if (this.props.error) {
        let error;
        let iconClass;

        if (this.state.showFull) {
          display = 'block';
          iconClass = 'fas fa-chevron-down';
        } else {
          display = 'none';
          iconClass = 'fas fa-chevron-right';
        }

        if ({}.hasOwnProperty.call(this.props.error, 'responseText')) {
          error = this.props.error.responseText;
        } else {
          ({ error } = this.props);
        }

        return <div className="alert alert-danger hbw-error">
          <i className="fas fa-exclamation-triangle"></i>
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
    }

    toggleBacktrace = () => {
      this.setState({ showFull: !this.state.showFull });
    };
  }));
