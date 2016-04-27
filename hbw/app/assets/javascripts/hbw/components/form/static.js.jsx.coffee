modulejs.define 'HBWFormStatic', ['React'], (React) ->
  React.createClass
    render: ->
      cssClass = @props.params.css_class
      `<div className={cssClass} dangerouslySetInnerHTML={{__html: this.props.params.html}} />`
