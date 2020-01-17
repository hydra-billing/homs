import React from 'react';
import PropTypes from 'prop-types';

const HBWClaimingSearch = ({
  env, query, search, clear
}) => {
  const { translator: t } = env;

  return (
    <div className="search-input-with-controls">
      <input
        type="text"
        placeholder={t('components.claiming.table.description')}
        value={query}
        onChange={search}
      />
      <span className="fas fa-search icon search" />
      {query.length > 0 && <span className="fas fa-times icon cross" onClick={clear} />}
    </div>
  );
};

HBWClaimingSearch.propTypes = {
  env:    PropTypes.object.isRequired,
  query:  PropTypes.string.isRequired,
  search: PropTypes.func.isRequired,
  clear:  PropTypes.func.isRequired,
};

export default HBWClaimingSearch;
