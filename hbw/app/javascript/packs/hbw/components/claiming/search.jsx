import React, { Component, createRef } from 'react';
import PropTypes from 'prop-types';

class HBWClaimingSearch extends Component {
  static propTypes = {
    env:      PropTypes.object.isRequired,
    query:    PropTypes.string.isRequired,
    fetching: PropTypes.bool.isRequired,
    onChange: PropTypes.func.isRequired,
    onClear:  PropTypes.func.isRequired,
  };

  input = createRef();

  render () {
    const {
      query, fetching, onChange, onClear
    } = this.props;
    const { translator: t } = this.props.env;

    const searchIconCN = fetching ? 'fa-sync-alt fa-spin' : 'fa-search';

    return (
      <div className="search-input-with-controls">
        <input
          ref={this.input}
          type="text"
          placeholder={t('components.claiming.table.description')}
          value={query}
          onChange={onChange}
        />
        <span className={`fas ${searchIconCN} icon search`} />
        {query.length > 0 && <span className="fas fa-times icon cross" onClick={onClear} />}
      </div>
    );
  }
}

export default HBWClaimingSearch;
