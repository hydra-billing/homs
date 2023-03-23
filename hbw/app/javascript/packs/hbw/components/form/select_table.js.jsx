import cx from 'classnames';
import Tooltip from 'tooltip';
import compose from 'shared/utils/compose';
import {
  withConditions, withSelect, withCallbacks, withValidations, withErrorBoundary
} from 'shared/hoc';
import TranslationContext from 'shared/context/translation';

modulejs.define(
  'HBWFormSelectTable',
  ['React'],
  (React) => {
    class HBWFormSelectTable extends React.Component {
      static contextType = TranslationContext;

      constructor (props, context) {
        super(props, context);

        const value = this.getInitTableValue(props.params.current_value);

        this.state = {
          value:   Array.isArray(value) ? value.map(el => String(el)) : String(value),
          choices: this.getChoices(),
          error:   props.missFieldInVariables(),
          valid:   true
        };
      }

      getInitNullableTableValue (value) {
        if (this.props.params.multi) {
          return JSON.parse(value) || [];
        } else {
          return value || '';
        }
      }

      getInitNotNullableTableValue (value) {
        if (this.props.params.multi) {
          return JSON.parse(value) || [this.getFirstRowId()];
        } else {
          return value || this.getFirstRowId();
        }
      }

      getInitTableValue (value) {
        if (this.props.params.nullable) {
          return this.getInitNullableTableValue(value);
        } else {
          return this.getInitNotNullableTableValue(value);
        }
      }

      getFirstRowId = () => this.getChoices()[0][0];

      componentDidMount () {
        this.props.onRef(this);
        this.tooltip = new Tooltip(this.label, {
          title:     this.context.translate('errors.field_is_required'),
          container: this.tooltipContainer,
          trigger:   'manual',
          placement: 'bottom'
        });

        this.validateOnSubmit();
      }

      componentWillUnmount () {
        this.props.onRef(undefined);
      }

      componentDidUpdate () {
        const hideTooltip = !this.props.isAvailable || this.state.valid;

        this.controlValidationTooltip(hideTooltip);
      }

      render () {
        const {
          name, params, disabled, hidden, task, missFieldInVariables
        } = this.props;

        const {
          choices, value, error
        } = this.state;

        const errorTooltip = <div ref={(t) => { this.tooltipContainer = t; }}
                                  className='tooltip-red' />;

        const selectErrorMessage = this.context.translate('errors.field_not_defined_in_bp', { field_name: name });

        const label = this.context.translateBP(`${task.process_key}.${task.key}.${name}.label`, {}, params.label);

        const labelCss = cx(params.label_css, 'select-table-label');
        const cssClass = cx(params.css_class, { hidden });
        const selectErrorMessageCss = cx('alert', 'alert-danger', { hidden: !missFieldInVariables() });
        const formGroupCss = cx('hbw-table', 'form-group', { 'has-error': error });
        const tableCss = cx('select-table', 'table', 'table-striped', 'table-bordered', {
          disabled: params.editable === false || disabled
        });

        return <div className={cssClass} title={params.tooltip}>
          <span className={labelCss} ref={(i) => { this.label = i; }}>{label}</span>
          <div className={selectErrorMessageCss}>{selectErrorMessage}</div>
          <div className={formGroupCss}>
            {errorTooltip}
            {params.description?.placement === 'top' && this.renderDescription()}
            <table className={tableCss}>
              <thead className='thead-inverse'>
              <tr>
                {this.buildTableHeader()}
              </tr>
              </thead>
              <tbody>
              {this.buildTableBody(choices, name, value)}
              </tbody>
            </table>
            {params.description?.placement === 'bottom' && this.renderDescription()}
          </div>
        </div>;
      }

      renderDescription = () => {
        const { placement, text } = this.props.params.description;

        return <div className="description" data-test={`description-${placement}`}>{text}</div>;
      };

      validateOnSubmit = () => {
        this.props.bind(`hbw:validate-form-${this.props.id}`, this.onFormSubmit);
      };

      onFormSubmit = () => {
        const el = this.label;

        if (this.props.isValid(this.state.value)) {
          el.classList.remove('invalid');
        } else {
          el.classList.add('invalid');

          this.setValidationState();
          this.props.trigger('hbw:form-submitting-failed');
        }
      };

      setValidationState = () => {
        this.setState({ valid: this.props.isValid(this.state.value) });
      };

      setErrorState = () => {
        this.setState({
          error: (this.state.value.length === 0 && !this.props.params.nullable) || this.props.missFieldInVariables()
        });
      };

      controlValidationTooltip = (toHide) => {
        if (toHide) {
          this.tooltip.hide();
        } else {
          this.tooltip.show();
        }
      };

      addNullChoice = (choices) => {
        let hasNullValue = false;

        [...choices].forEach((choice) => {
          if (this.props.isChoiceEqual(choice, null)) {
            hasNullValue = true;
          }
        });

        if (!hasNullValue) {
          const nullChoice = ['null'];

          [...new Array(this.props.params.row_params.length).keys()].forEach(() => nullChoice.push('-'));

          choices.unshift(nullChoice);
        }
      };

      buildTableHeader = () => {
        const rowParams = this.props.params.row_params;
        const result = [];

        [...rowParams].forEach((param) => {
          result.push(<th className={this.buildCssFromConfig(param)} key={param.name}>{param.name}</th>);
        });

        return result;
      };

      onValueUpdate = () => {
        this.setValidationState();
        this.setErrorState();
        this.props.fireFieldValueUpdate(this.props.name, this.state.value);
      };

      onClick = (event) => {
        if (this.props.params.editable === false || this.props.disabled) {
          return;
        }

        const newValue = event.target.parentElement.getElementsByTagName('input')[0].value;

        if (this.props.params.multi) {
          if (this.state.value.includes(newValue)) {
            const index = this.state.value.indexOf(newValue);
            this.setState((prevState) => { prevState.value.splice(index, 1); }, this.onValueUpdate);
          } else {
            this.setState((prevState) => { prevState.value.push(newValue); }, this.onValueUpdate);
          }
        } else {
          this.setState({ value: newValue }, this.onValueUpdate);
        }
      };

      buildTableBody = (choices, name, value) => {
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
          let checked = false;
          let type;

          const renderCells = (_items) => {
            const result = [];
            Object.keys(_items).forEach((i) => {
              result.push(<td className={cssClassesList[i]} key={i}>{_items[i]}</td>);
            });

            return result;
          };

          const id = items[0];

          if (this.props.params.multi) {
            type = 'checkbox';

            if (value.includes(id.toString())) {
              selected = 'selected';
              checked = true;
            }
          } else {
            type = 'radio';

            if (this.props.isEqual(id, value)) {
              selected = 'selected';
              checked = true;
            }
          }

          const stub = {
            onChange () {}
          };

          return <tr {...opts} className={selected} key={id}>
            <td className='hidden' key={`td-${id}`}>
              <input
                {...stub}
                name={name}
                type={type}
                value={id}
                id={id}
                checked={checked}
              />
            </td>
            {renderCells(items.slice(1, items.length))}
          </tr>;
        });
      };

      buildCssFromConfig = config => `text-align-${config.alignment}`;

      getChoices = () => {
        const { nullable, multi } = this.props.params;
        const choices = this.props.params.choices.slice();

        if (nullable && !multi) {
          this.addNullChoice(choices);
        }

        return choices;
      };

      serialize = () => {
        if (this.props.params.editable === false || this.props.disabled || this.props.hidden) {
          return null;
        } else {
          return { [this.props.name]: this.props.params.multi ? JSON.stringify(this.state.value) : this.state.value };
        }
      };
    }

    return compose(withSelect, withCallbacks, withConditions, withValidations, withErrorBoundary)(HBWFormSelectTable);
  }
);
