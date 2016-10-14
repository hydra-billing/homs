modulejs.define 'HBWFormCheckbox', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) ->
  React.createClass
    mixins: [DeleteIfMixin]

    render: ->
      opts = {
        name: @props.name
        disabled: @props.params.editable == false
        defaultChecked: @props.value
      }

      inputCSS = @props.params.css_class
      inputCSS += ' hidden' if this.hidden

      tooltip  = @props.params.tooltip
      label    = @props.params.label
      labelCSS = 'hbw-checkbox-label ' + (@props.params.label_css or '')

      `<div className={inputCSS} title={tooltip}>
        <div className="form-group">
          <label className={labelCSS}>
            <input type='checkbox' {...opts} />
            <span>{' ' + label}</span>
          </label>
        </div>
      </div>`
