modulejs.define 'HBWFormFileUpload',
  ['React', 'jQuery', 'HBWDeleteIfMixin'],
  (React, jQuery, DeleteIfMixin) ->
    React.createClass
      mixins: [DeleteIfMixin]

      render: ->
        cssClass = @props.params.css_class
        cssClass += ' hidden' if this.hidden

        label = @props.params.label
        labelCss = @props.params.label_css

        `<div className={cssClass}>
          <span className={labelCss}>{label}</span>
          <div className="form-group">
            <input type="file" multiple></input>
          </div>
        </div>`
