modulejs.define 'HBWFormText', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) ->
  React.createClass
    mixins: [DeleteIfMixin]

    render: ->
      opts = { name: this.props.name, className: 'form-control' }
      opts.rows = this.props.params.rows
      opts['defaultValue'] = this.props.value
      opts['readOnly'] = true if this.props.params['editable'] == false

      title = this.props.params.tooltip
      label = this.props.params.label
      labelCss = this.props.params.label_css
      cssClass = this.props.params.css_class
      cssClass += ' hidden' if this.hidden

      `<div className={cssClass} title={title}>
        <div className='form-group'>
          <span className={labelCss}>{label}</span>
          <textarea {...opts}/>
        </div>
      </div>`
