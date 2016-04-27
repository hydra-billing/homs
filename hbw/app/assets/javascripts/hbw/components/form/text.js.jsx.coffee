modulejs.define 'HBWFormText', ['React'], (React) ->
  React.createClass
    render: ->
      opts = { name: this.props.name, className: 'form-control' }
      opts.rows = this.props.params.rows
      opts['defaultValue'] = this.props.value
      opts['readOnly'] = true if this.props.params['editable'] == false

      title = this.props.params.tooltip
      label = this.props.params.label
      label_css = this.props.params.label_css
      css_class = this.props.params.css_class

      `<div className={css_class} title={title}>
        <div className='form-group'>
          <span className={label_css}>{label}</span>
          <textarea {...opts}/>
        </div>
      </div>`
