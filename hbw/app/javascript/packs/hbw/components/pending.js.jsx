modulejs.define('HBWPending', ['React'], React => React.createClass({
  displayName: 'HBWPending',

  getDefaultProps () {
    return { text: '' };
  },

  render () {
    let styles;

    if (this.props.active) {
      styles = {};
    } else {
      styles = { display: 'none' };
    }

    return <div className="pending" style={styles}>
      <i className="fas fa-spin fa-lg fa-spinner"></i>
      {` ${this.props.text}`}
    </div>;
  },

  runEllipsisInterval () {
    let cnt = 1;

    setInterval(() => {
      cnt += 1;
      let ellipsis = '';

      while (((cnt % 3) + 1) > ellipsis.length) {
        ellipsis += '.';
      }

      this.setState({ ellipsis });
    }, 1000);
  }
}));
