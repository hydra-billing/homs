modulejs.define('HBWFormSubmit', ['React'], (React) => {
  const HBWFormSubmit = ({ formSubmitting, env }) => {
    let className = 'btn btn-primary';

    if (formSubmitting) {
      className += ' disabled';
    }

    return <div className="form-group">
      <button type="submit"
        className={className}
        disabled={formSubmitting}>
        <i className="fas fa-check" />
        {` ${env.translator('submit')}`}
      </button>
    </div>;
  };

  return HBWFormSubmit;
});
