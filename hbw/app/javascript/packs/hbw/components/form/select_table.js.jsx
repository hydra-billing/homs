modulejs.define('HBWFormSelectTable',
  ['React', 'jQuery', 'HBWDeleteIfMixin', 'HBWSelectMixin'],
  (React, jQuery, DeleteIfMixin, SelectMixin) => React.createClass({
    mixins: [DeleteIfMixin, SelectMixin],

    getInitialState () {
      const value = this.props.current_value || '';

      return {
        value:   this.props.params.current_value,
        choices: this.getChoices(value),
        error:   (!this.hasValueInChoices(value) && value) || this.missFieldInVariables()
      };
    },

    render () {
      const opts = {
        name:         this.props.name,
        defaultValue: this.state.value
      };

      let cssClass = this.props.params.css_class;
      if (this.hidden) {
        cssClass += ' hidden';
      }

      const { tooltip } = this.props.params;
      const { label } = this.props.params;
      const labelCss = this.props.params.label_css;

      const selectErrorMessage = this.props.env.translator('errors.field_not_defined_in_bp',
        { field_name: this.props.name });
      let selectErrorMessageCss = 'alert alert-danger';
      if (!this.missFieldInVariables()) {
        selectErrorMessageCss += ' hidden';
      }

      let formGroupCss = 'form-group';
      if (this.state.error) {
        formGroupCss += ' has-error';
      }

      let tableCss = 'select-table table table-bordered table-hover';
      if (this.props.params.editable === false) {
        tableCss += ' disabled';
      }

      return <div className={cssClass} title={tooltip}>
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
      </div>;
    },

    addNullChoice (choices) {
      let hasNullValue = false;
      for (const choice of Array.from(choices)) {
        if (this.isChoiceEqual(choice, null)) {
          hasNullValue = true;
        }
      }

      if (!hasNullValue) {
        const nullChoice = ['null'];

        [...new Array(this.props.params.row_params.length).keys()].forEach(_ => nullChoice.push('-'));

        choices.push(nullChoice);
      }
    },

    buildTableHeader () {
      const rowParams = this.props.params.row_params;
      const result = [];

      for (let i in rowParams) {
        result.push(<th className={this.buildCssFromConfig(rowParams[i])} key={rowParams[i].name}>{rowParams[i].name}</th>);
      }

      return result;
    },

    onClick (event) {
      if (this.props.params.editable === false) {
        return;
      }

      this.setState({ value: event.target.parentElement.getElementsByTagName('input')[0].value });
    },

    buildTableBody (choices, name, value) {
      const opts = {
        onClick: this.onClick
      };

      const cssClassesList = [];
      for (let _ in this.props.params.row_params) {
        const config = this.props.params.row_params[_];
        cssClassesList.push(this.buildCssFromConfig(config));
      }

      return choices.map((items) => {
        let selected;
        const renderCells = (_items) => {
          const result = [];

          for (let i in _items) {
            result.push(<td className={cssClassesList[i]} key={i}>{_items[i]}</td>);
          }

          return result;
        };

        const id = items[0];

        if (this.isEqual(id, value)) {
          selected = 'selected';
        }

        const stub = {
          onChange () {}
        };

        const isEqualFunc = this.isEqual;

        return <tr {...opts} className={selected} key={id}>
          <td className='hidden' key={`td-${id}`}>
            <input {...stub} name={name} type="radio" value={id} id={id} checked={isEqualFunc(id, value)} />
          </td>
          {renderCells(items.slice(1, items.length))}
        </tr>;
      });
    },

    buildCssFromConfig (config) {
      return `text-align-${config.alignment}`;
    },

    addCurrentValueToChoices (value) {
      return null;
    }
  }));
