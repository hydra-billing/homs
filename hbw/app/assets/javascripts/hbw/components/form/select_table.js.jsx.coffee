modulejs.define 'HBWFormSelectTable',
  ['React', 'HBWTranslationsMixin', 'jQuery', 'HBWDeleteIfMixin', 'HBWSelectMixin'],
  (React, TranslationsMixin, jQuery, DeleteIfMixin, SelectMixin) ->
    React.createClass
      mixins: [TranslationsMixin, DeleteIfMixin, SelectMixin]

      getInitialState: ->
        value = @props.current_value or ''

        {
          value: @props.params.current_value
          choices: @getChoices(value)
          error: not @hasValueInChoices(value) and value or @missFieldInVariables()
        }

      render: ->
        opts = {
          name: @props.name
          defaultValue: @state.value
        }

        cssClass = @props.params.css_class
        cssClass += ' hidden' if this.hidden

        tooltip = @props.params.tooltip
        label = @props.params.label
        labelCss = @props.params.label_css

        selectErrorMessage = @t("errors.field_not_defined_in_bp", field_name: @props.name)
        selectErrorMessageCss = 'alert alert-danger'
        selectErrorMessageCss += ' hidden' unless @missFieldInVariables()

        formGroupCss = 'form-group'
        formGroupCss += ' has-error' if @state.error

        tableCss = 'select-table table table-bordered table-hover'
        tableCss += ' disabled' if @props.params.editable == false

        `<div className={cssClass} title={tooltip}>
            <span className={labelCss}>{label}</span>
            <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
            <div className={formGroupCss}>
            <table className={tableCss}>
              <thead className='thead-inverse'>
                <tr>
                  {this.buildTableHeader()}
                </tr>
              </thead>
              <tbody>
                {this.buildTableBody(this.state.choices, this.props.name, this.state.value)}
              </tbody>
            </table>
        </div>
        </div>`

      addNullChoice: (choices) ->
        hasNullValue = false
        for choice in choices when @isChoiceEqual(choice, null)
          hasNullValue = true

        unless hasNullValue
          nullChoice = ['null']
          nullChoice.push('-') for [1..@props.params.row_params.length]

          choices.push(nullChoice)

      buildTableHeader: ->
        rowParams = @props.params.row_params

        for i of rowParams
          `<th className={this.buildCssFromConfig(rowParams[i])} key={rowParams[i].name}>{rowParams[i].name}</th>`

      onClick: (event) ->
        if @props.params.editable == false
          return

        @setState(value: event.target.parentElement.getElementsByTagName('input')[0].value);

      buildTableBody: (choices, name, value) ->
        opts = {
          onClick: @onClick
        }

        cssClassesList = []
        for _, config of @props.params.row_params
          cssClassesList.push(@buildCssFromConfig(config))

        choices.map (items) =>
          renderCells = (items) ->
            for i of items
              `<td className={cssClassesList[i]} key={i}>{items[i]}</td>`

          id = items[0]

          selected = 'selected' if @isEqual(id, value)

          stub = {
            onChange: ->
              return
          }

          isEqualFunc = @isEqual

          `<tr {...opts} className={selected} key={id}>
            <td className='hidden' key={'td-' + id}>
              <input {...stub} name={name} type="radio" value={id} id={id} checked={isEqualFunc(id, value)} />
            </td>
            {renderCells(items.slice(1, items.length))}
          </tr>`

      buildCssFromConfig: (config) ->
        cssClasses = 'text-align-' + config.alignment

        cssClasses

      addCurrentValueToChoices: (value) ->
        return null
