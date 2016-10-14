modulejs.define 'HBWFormStatic', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) ->
  React.createClass
    mixins: [DeleteIfMixin]

    render: ->
      cssClass = @props.params.css_class
      cssClass += ' hidden' if this.hidden

      `<div className={cssClass} dangerouslySetInnerHTML={{__html: this.props.params.html}} />`
