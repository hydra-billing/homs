/* eslint no-console: "off" */
/* eslint consistent-return: "off" */

import { withCallbacks } from 'shared/hoc';
import Pending from './pending';

modulejs.define(
  'HBWButtons',
  ['React', 'HBWButton', 'HBWError'],
  (React, Button, Error) => {
    class HBWButtons extends React.Component {
      constructor (props, context) {
        super(props, context);

        this.state = {
          buttons:       [],
          fetchError:    null,
          submitError:   null,
          errorHeader:   '',
          disabled:      false,
          fetched:       false,
          submitting:    false,
          bpRunning:     false,
          fileUploading: false
        };
      }

      submitButton = businessProcessCode => this.props.env.connection.request({
        url:    this.buttonsURL(),
        method: 'POST',

        data: {
          entity_code:       this.props.entityCode,
          entity_type:       this.props.entityTypeCode,
          entity_class:      this.props.entityClassCode,
          bp_code:           businessProcessCode,
          initial_variables: this.props.env.initialVariables
        }
      });

      fetchInitialState = () => {
        const {
          entityCode, entityTypeCode, entityClassCode, env
        } = this.props;

        const data = {
          entity_code:  entityCode,
          entity_type:  entityTypeCode,
          entity_class: entityClassCode
        };

        return env.connection.request({
          url:    this.buttonsURL(),
          method: 'GET',
          data
        })
          .done(response => this.setState({
            fetched:    true,
            fetchError: null,
            buttons:    response.buttons,
            bpRunning:  response.bp_running
          }))
          .fail(response => this.setState({
            fetchError:  response,
            errorHeader: env.translator('errors.cannot_obtain_available_actions')
          }));
      }

      buttonsURL = () => `${this.props.env.connection.serverURL}/buttons`;

      componentDidMount () {
        this.fetchInitialState();
        this.props.bind('hbw:button-activated', this.onButtonActivation);
        this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
        this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
      }

      render () {
        if (this.props.env.userExist) {
          if (this.props.showSpinner || !this.state.fetched) {
            return <div className="hbw-spinner"><Pending /></div>;
          } else if (this.state.bpRunning) {
            return <div className="hbw-spinner">
              <Pending text={this.props.env.translator('bp_running')} />
            </div>;
          } else {
            const buttons = this.state.buttons.map((button, index) => {
              const self = this;
              return <Button key={index}
                             button={button}
                             disabled={self.state.submitting || self.state.fileUploading}
                             env={self.props.env}/>;
            });

            return <div className='hbw-bp-control-buttons btn-group'>
              <Error error={this.state.submitError || this.state.fetchError} errorHeader={this.state.errorHeader}
                     env={this.props.env}/>
              {buttons}
            </div>;
          }
        } else {
          return <div></div>;
        }
      }

      onButtonActivation = (button) => {
        console.log(`Clicked button[${button.title}], submitting`);
        this.setState({ submitting: true });

        this.submitButton(button.bp_code)
          .done(data => this.setState({
            submitError: null,
            buttons:     data.buttons,
            bpRunning:   data.bp_running
          }))
          .done(() => this.triggerBPStart(button))
          .fail(response => this.setState({
            submitError: response,
            submitting:  false,
            errorHeader: this.props.env.translator('errors.cannot_start_process')
          }));
      };

      triggerBPStart = (button) => {
        this.props.trigger('hbw:process-started', button);
      };
    }

    return withCallbacks(HBWButtons);
  }
);
