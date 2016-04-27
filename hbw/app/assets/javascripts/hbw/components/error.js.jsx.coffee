modulejs.define 'HBWError', ['React', 'HBWTranslationsMixin', 'jQuery'], (React, TranslationsMixin, jQuery) ->
  t = TranslationsMixin.t

  React.createClass
    mixins: [TranslationsMixin]

    getDefaultProps: ->
      errorHeader: t('error')

    getInitialState: ->
      showFull: false

    render: ->
      if @props.error
        if @state.showFull
          display = 'block'
          iconClass = 'fa fa-chevron-down'
        else
          display = 'none'
          iconClass = 'fa fa-chevron-right'

        if jQuery.isPlainObject(@props.error)
          error = @props.error.responseText
        else
          error = @props.error

        `<div className="alert alert-danger hbw-error">
          <i className="fa fa-exclamation-triangle"></i>
          <strong>{' ' + this.props.errorHeader}</strong>
          <br />
          <a href="javascript:;"
             onClick={this.toggleBacktrace}
             className="show-more"
             style={{display: error ? 'block' : 'none'}}>
            <i className={iconClass}></i>
            {this.t('more')}
          </a>
          <pre style={{display: display}}>{error}</pre>
        </div>`
      else
        `<div style={{display: 'none'}}></div>`

    toggleBacktrace: ->
      @setState(showFull: not @state.showFull)
