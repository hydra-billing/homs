modulejs.define 'HBWFormFileList', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) ->
  React.createClass
    mixins: [DeleteIfMixin]

    getInitialState: ->
      { valid: true, deletedFiles: [] }

    render: ->
      cssClass = @props.params.css_class
      cssClass += ' hidden' if this.hidden
      label    = @props.params.label
      labelCSS = 'hbw-checkbox-label ' + (@props.params.label_css or '')

      if (@props.value)
        links = JSON.parse(@props.value)
      else
        links = []

      hiddenValue = JSON.stringify(links.filter((link) => (!@state.deletedFiles.includes(link.name))))

      `<div className={cssClass}>
        <input name={this.props.params.name} value={hiddenValue} type="hidden"/>
        <label className={labelCSS}>
          <span>{' ' + label}</span>
          <ul>
            {this.files(links)}
          </ul>
        </label>
      </div>`

    files: (list) ->
      onClick = this.deleteLink
      deletedFiles = @state.deletedFiles

      list.map (variant) ->
        if deletedFiles.includes(variant.name)
          `<li className={"danger"}><a href={variant.url}>{variant.name}</a>&nbsp;<a href="#" className="fa fa-reply" onClick={e => onClick(e, variant.name)}></a></li>`
        else
          `<li><a href={variant.url}>{variant.name}</a>&nbsp;<a href="#" className="fa fa-times" onClick={e => onClick(e, variant.name)}></a></li>`

    deleteLink: (evt, name) ->
      deletedFiles = @state.deletedFiles

      if deletedFiles.includes(name)
        index = deletedFiles.indexOf(name)
        deletedFiles.splice(index, 1)
      else
        deletedFiles.push(name)

      @setState(deletedFiles: deletedFiles)
