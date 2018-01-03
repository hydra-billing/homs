modulejs.define 'HBWFormSelectTable',
  ['React', 'HBWTranslationsMixin', 'jQuery', 'HBWDeleteIfMixin', 'HBWSelectMixin'],
  (React, TranslationsMixin, jQuery, DeleteIfMixin, SelectMixin) ->
    React.createClass
      mixins: [TranslationsMixin, DeleteIfMixin, SelectMixin]

      render: ->
        opts = {
          name: @props.name
          defaultValue: @state.value
          disabled: @props.params.editable == false
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

        `<div className={cssClass} title={tooltip}>
            <span className={labelCss}>{label}</span>
            <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
            <div className={formGroupCss}>
            <table className='select-table table table-bordered table-hover'>
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
          nullChoice = [-1]
          nullChoice.push('-') for [1..@props.params.row_params.length]

          choices.push(nullChoice)

      buildTableHeader: ->
        rowParams = @props.params.row_params

        for i of rowParams
          `<th className={this.buildCssFromConfig(rowParams[i])}>{rowParams[i].name}</th>`

      onClick: (event) ->
        event.target.parentElement.getElementsByTagName('input')[0].checked = true

        rows = event.target.parentElement.parentElement.getElementsByTagName('tr')
        for row in rows
          row.classList.remove('selected')

        event.target.parentElement.classList.add('selected')

      buildTableBody: (choices, name, value) ->
        opts = {
          onClick: @onClick
        }

        cssClassesList = []
        for _, config of @props.params.row_params
          cssClassesList.push(@buildCssFromConfig(config))

        choices.map (items) ->
          renderCells = (items) ->
            for i of items
              `<td className={cssClassesList[i]}>{items[i]}</td>`

          id = items[0]

          selected = 'selected' if id == value

          `<tr {...opts} className={selected}>
            <td className='hidden'>
              <input name={name} type="radio" value={id} id={id}/>
            </td>
            {renderCells(items.slice(1, items.length))}
          </tr>`

      buildCssFromConfig: (config) ->
        cssClasses = 'text-align-' + config.alignment

        cssClasses

      addCurrentValueToChoices: (value) ->
        return null
