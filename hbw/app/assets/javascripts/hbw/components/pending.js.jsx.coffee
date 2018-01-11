modulejs.define 'HBWPending', ['React'], (React) ->
  React.createClass
    getDefaultProps: ->
      text: ''

    render: ->
      if @props.active
        styles = {}
      else
        styles = {display: 'none'}

      `<div className="pending" style={styles}>
        <i className="fa fa-spin fa-lg fa-spinner"></i>
        {' ' + this.props.text}
      </div>`

    runEllipsisInterval: ->
      cnt = 1
      setInterval(=>
        cnt += 1
        ellipsis = ''

        while cnt % 3 + 1 > ellipsis.length
          ellipsis += '.'

        @setState(ellipsis: ellipsis)
      , 1000)
