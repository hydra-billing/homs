import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import TranslationContext from '../shared/context/translation';

const HBWClaimingSearch = ({ query, search, clear }) => {
  const { translate: t } = useContext(TranslationContext);

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
  query:  PropTypes.string.isRequired,
  search: PropTypes.func.isRequired,
  clear:  PropTypes.func.isRequired,
};

export default HBWClaimingSearch;
