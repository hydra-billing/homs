/* eslint no-console: "off" */

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
          buttons:        [],
          fetchError:     null,
          submitError:    null,
          errorHeader:    '',
          fetched:        false,
          submitting:     false,
          bpRunning:      false,
          fileUploading:  false,
          BPStateChecker: null,
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

      fetchButtons = () => {
        const {
          entityCode, entityTypeCode, entityClassCode, resetProcess, env
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
          .done((response) => {
            if (response.bp_running) {
              this.setBPStateChecker();
            } else {
              resetProcess();
            }

            return this.setState({
              fetched:    true,
              fetchError: null,
              buttons:    response.buttons,
              bpRunning:  response.bp_running,
            });
          })
          .fail(response => this.setState({
            fetchError:  response,
            errorHeader: env.translator('errors.cannot_obtain_available_actions')
          }));
      };

      setBPStateChecker = () => {
        this.setState(prevState => ({
          BPStateChecker: prevState.BPStateChecker || setTimeout(this.fetchButtons, 5000)
        }));
      };

      resetBPStateChecker = () => {
        clearTimeout(this.state.fetcher);
      };

      buttonsURL = () => `${this.props.env.connection.serverURL}/buttons`;

      componentDidMount () {
        this.fetchButtons();
        this.props.bind('hbw:button-activated', this.onButtonActivation);
        this.props.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
        this.props.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
      }

      componentWillUnmount () {
        this.resetBPStateChecker();
      }

      render () {
        const { env, showSpinner } = this.props;
        const {
          fetched, bpRunning, buttons, submitting, fileUploading, submitError, fetchError, errorHeader
        } = this.state;

        if (env.userExist) {
          if (showSpinner || !fetched) {
            return <div className="hbw-spinner"><Pending /></div>;
          } else if (bpRunning) {
            return (
              <div className="hbw-spinner">
                <Pending text={env.translator('bp_running')} />
              </div>
            );
          } else {
            const buttonElements = buttons.map((button, index) => (
              <Button key={index}
                      button={button}
                      disabled={submitting || fileUploading}
                      env={env}
              />
            ));

            return (
              <div className='hbw-bp-control-buttons btn-group'>
                <Error error={submitError || fetchError}
                       errorHeader={errorHeader}
                       env={env}
                />
                {buttonElements}
              </div>
            );
          }
        } else {
          return <div />;
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
          .fail(response => this.setState({
            submitError: response,
            submitting:  false,
            errorHeader: this.props.env.translator('errors.cannot_start_process')
          }));
      };
    }

    return withCallbacks(HBWButtons);
  }
);
