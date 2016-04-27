modulejs.define 'HBWFormUser', ['React', 'jQuery'], (React, jQuery) ->
  React.createClass
    render: ->
      `<div className={this.props.params.css_class} title={this.props.params.tooltip}>
        <span className={this.props.params.label_css}>{this.props.params.label}</span>
        <div className='form-group'>
          <select name={this.props.name} type='text' />
        </div>
      </div>`

    componentDidMount: -> this.hijack_select2()

    componentDidUpdate: -> this.hijack_select2()

    hijack_select2: ->
      e = jQuery(React.findDOMNode(this))
      select = e.find('select')
      select.select2({
        width: '100%'
        allowClear: true
        theme: 'classic'
        placeholder: this.props.params.placeholder || 'User'
        ajax: {
          url: '/users/lookup'
          dataType: 'json'
          delay: 250
          data: (params) -> { q: params.term, page: params.page }
          processResults: (data, page) -> { results: data.users }
          formatSelection: (node) -> node.id
          cache: true
        }
        minimumInputLength: 1
      })
      # Doesn't set value, have no clue why
      select.select2('val', this.props.value) if this.props.value

      # kinda hack
      e.find(".select2-selection").height(32)
      e.find(".select2-selection__arrow").height(32)
      e.find(".select2-selection__rendered").height(32)
