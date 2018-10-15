modulejs.define('HBWFormSubmit', ['React', 'HBWTranslationsMixin'], (React, TranslationsMixin) => {
  const { t } = TranslationsMixin;

  return React.createClass({
    mixins: [TranslationsMixin],

    getDefaultProps () {
      return { name: t('submit') };
    },

    render () {
      let className = 'btn btn-primary';

      if (this.props.formSubmitting) {
        className += ' disabled';
      }

      return <div className="form-group">
        <button type="submit"
          className={className}
          disabled={this.props.formSubmitting}>
          <i className="fa fa-check" />
          {` ${this.props.name}`}
        </button>
      </div>;
    }
  });
});
