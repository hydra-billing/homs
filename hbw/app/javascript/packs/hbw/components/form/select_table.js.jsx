import Tooltip from 'tooltip';
import { withDeleteIf, withSelect, withCallbacks, compose } from '../helpers';

modulejs.define('HBWFormSelectTable',
  ['React'],
  (React) => {
    const FormSelectTable = React.createClass({

      displayName: 'HBWFormSelectTable',

      getInitialState () {
        const value = this.props.current_value || '';

        return {
          value:   this.props.params.current_value,
          choices: this.getChoices(),
          error:   (!this.props.hasValueInChoices(value) && value) || this.props.missFieldInVariables(),
          valid:   true
        };
      },

      componentDidMount () {
        this.tooltip = new Tooltip(this.label, {
          title:     this.props.env.translator('errors.field_is_required'),
          container: this.tooltipContainer,
          trigger:   'manual',
          placement: 'bottom'
        });

        this.validateOnSubmit();
      },

      render () {
        let cssClass = this.props.params.css_class;

        if (this.props.hidden) {
          cssClass += ' hidden';
        }

        const { tooltip, label } = this.props.params;
        const labelCss = this.props.params.label_css;

        const selectErrorMessage = this.props.env.translator('errors.field_not_defined_in_bp',
          { field_name: this.props.name });

        const errorTooltip = <div
          ref={(t) => { this.tooltipContainer = t; }}
          className={`${!this.state.valid && 'tooltip-red'}`}
        />;

        let selectErrorMessageCss = 'alert alert-danger';
        if (!this.props.missFieldInVariables()) {
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
          <span className={labelCss} ref={(i) => { this.label = i; }}>{label}</span>
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
              {errorTooltip}
            </table>
          </div>
        </div>;
      },

      validateOnSubmit () {
        this.props.bind('hbw:validate-form', this.onFormSubmit);
      },

      onFormSubmit () {
        const el = this.label;

        if (this.isValid()) {
          el.classList.remove('invalid');
        } else {
          el.classList.add('invalid');

          this.setValidationState();
          this.controlValidationTooltip(this.isValid());
          this.props.trigger('hbw:form-submitting-failed');
        }
      },

      isValid () {
        return this.props.params.nullable || this.isFilled();
      },

      isFilled () {
        const { value } = this.state;

        return value !== null && value !== undefined && value.length > 0;
      },

      setValidationState () {
        this.setState({ valid: this.isValid() });
      },

      controlValidationTooltip (toHide) {
        if (toHide) {
          this.tooltip.hide();
        } else {
          this.tooltip.show();
        }
      },

      addNullChoice (choices) {
        let hasNullValue = false;

        [...choices].forEach((choice) => {
          if (this.props.isChoiceEqual(choice, null)) {
            hasNullValue = true;
          }
        });

        if (!hasNullValue) {
          const nullChoice = ['null'];

          [...new Array(this.props.params.row_params.length).keys()].forEach(() => nullChoice.push('-'));

          choices.push(nullChoice);
        }
      },

      buildTableHeader () {
        const rowParams = this.props.params.row_params;
        const result = [];

        [...rowParams].forEach((param) => {
          result.push(<th className={this.buildCssFromConfig(param)} key={param.name}>{param.name}</th>);
        });

        return result;
      },

      onClick (event) {
        if (this.props.params.editable === false) {
          return;
        }

        this.setState({ value: event.target.parentElement.getElementsByTagName('input')[0].value });
        this.setValidationState();
        this.controlValidationTooltip(this.isValid());
      },

      buildTableBody (choices, name, value) {
        const opts = {
          onClick: this.onClick
        };

        const cssClassesList = [];

        Object.keys(this.props.params.row_params).forEach((_) => {
          const config = this.props.params.row_params[_];

          cssClassesList.push(this.buildCssFromConfig(config));
        });

        return choices.map((items) => {
          let selected;
          const renderCells = (_items) => {
            const result = [];

            Object.keys(_items).forEach((i) => {
              result.push(<td className={cssClassesList[i]} key={i}>{_items[i]}</td>);
            });

            return result;
          };

          const id = items[0];

          if (this.props.isEqual(id, value)) {
            selected = 'selected';
          }

          const stub = {
            onChange () {}
          };

          const isEqualFunc = this.props.isEqual;

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

      getChoices () {
        let choices;

        if (this.props.params.mode === 'select') {
          choices = this.props.params.choices.slice();

          if (this.props.params.nullable) {
            this.addNullChoice(choices);
          }

          return choices;
        } else {
          return null;
        }
      }
    });

    return compose(withSelect, withDeleteIf, withCallbacks)(FormSelectTable);
  });
