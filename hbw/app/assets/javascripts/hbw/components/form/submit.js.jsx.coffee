modulejs.define 'HBWFormSubmit', ['React', 'HBWTranslationsMixin'], (React, TranslationsMixin) ->
  t = TranslationsMixin.t

  React.createClass
    mixins: [TranslationsMixin]

    getDefaultProps: ->
      name: t('submit')

    render: ->
      className = 'btn btn-primary'
      className += ' disabled' if @props.formSubmitting
      `<div className="form-group">
        <button type="submit"
                className={className}
                disabled={this.props.formSubmitting}>
          <i className="fa fa-check" />
          {' ' + this.props.name}
        </button>
      </div>`
