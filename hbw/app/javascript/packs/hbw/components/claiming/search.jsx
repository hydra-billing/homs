import React, { useContext } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
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
      <FontAwesomeIcon icon={['fas', 'search']} className="fas icon search"/>
      {query.length > 0 && <FontAwesomeIcon icon={['fas', 'times']} className="fas icon cross" onClick={clear} />}
    </div>
  );
};

HBWClaimingSearch.propTypes = {
  query:  PropTypes.string.isRequired,
  search: PropTypes.func.isRequired,
  clear:  PropTypes.func.isRequired,
};

export default HBWClaimingSearch;
