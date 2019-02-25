modulejs.define('HBWPending', ['React'], (React) => {
  const HBWPending = ({ active, text = '' }) => {
    const styles = active ? {} : { display: 'none' };

    return <div className="pending" style={styles}>
      <i className="fas fa-spin fa-lg fa-spinner" />
      {` ${text}`}
    </div>;
  };

  return HBWPending;
});
