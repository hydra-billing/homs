modulejs.define 'HBWFormCheckbox', ['React'], (React) ->
  React.createClass
    render: ->
      opts = {
        name: @props.name
        disabled: @props.params.editable == false
        defaultChecked: @props.value
      }

      css_class = @props.params.css_class
      tooltip   = @props.params.tooltip
      label     = @props.params.label
      label_css = 'hbw-checkbox-label ' + (@props.params.label_css or '')

      `<div className={css_class} title={tooltip}>
        <div className="form-group">
          <label className={label_css}>
            <input type='checkbox' {...opts} />
            <span>{' ' + label}</span>
          </label>
        </div>
      </div>`
