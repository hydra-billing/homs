modulejs.define 'HBWFormFileList', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) ->
  React.createClass
    mixins: [DeleteIfMixin]

    render: ->
      cssClass = @props.params.css_class
      cssClass += ' hidden' if this.hidden
      label    = @props.params.label
      labelCSS = 'hbw-checkbox-label ' + (@props.params.label_css or '')
      if (@props.value != null)
        links = JSON.parse(@props.value)
      else
        links = []

      `<div className={cssClass}>
        <label className={labelCSS}>
          <span>{' ' + label}</span>
          <ul>
            {this.files(links)}
          </ul>
        </label>
      </div>`

    files: (list) ->
      list.map (variant) ->
        `<li><a href={variant.url}>{variant.name}</a></li>`
