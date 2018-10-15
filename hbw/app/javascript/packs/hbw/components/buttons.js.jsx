modulejs.define(
  'HBWButtons',
  ['React',
    'HBWButton',
    'HBWCallbacksMixin',
    'HBWTranslationsMixin',
    'HBWError',
    'HBWPending'],
  (React,
    Button,
    CallbacksMixin,
    TranslationsMixin,
    Error,
    Pending) => React.createClass({
    mixins: [CallbacksMixin, TranslationsMixin],

    getInitialState () {
      this.setGuid();

      return {
        buttons:       [],
        subscription:  this.createSubscription(),
        pollInterval:  5000,
        syncing:       false,
        syncError:     null,
        submitError:   null,
        errorHeader:   '',
        disabled:      false,
        fetched:       false,
        submitting:    false,
        bpRunning:     false,
        fileUploading: false
      };
    },

    createSubscription () {
      const subscription = this.props.env.connection.subscribe({
        client: this.getComponentId(),
        path:   '/buttons',
        data:   {
          entity_code:  this.props.entityCode,
          entity_type:  this.props.entityTypeCode,
          entity_class: this.props.entityClassCode
        }
      });

      return subscription
        .syncing(() => this.setState({ syncing: true }))
        .fetch(() => this.setState({ fetched: true }))
        .always(() => this.setState({ syncing: false }))
        .fail(response => this.setState({
          syncError:   response,
          errorHeader: this.t('errors.cannot_obtain_available_actions')
        }))
        .progress(data => this.setState({
          buttons:   data.buttons,
          syncError: null,
          bpRunning: data.bp_running
        }));
    },

    submitButton (businessProcessCode) {
      return this.props.env.connection.request({
        url:    this.buttonsURL(),
        method: 'POST',
        data:   {
          entity_code:  this.props.entityCode,
          entity_type:  this.props.entityTypeCode,
          entity_class: this.props.entityClassCode,
          bp_code:      businessProcessCode
        }
      });
    },

    buttonsURL () {
      return `${this.props.env.connection.serverURL}/buttons`;
    },

    componentDidMount () {
      this.state.subscription.start(this.state.pollInterval);
      this.bind('hbw:button-activated', this.onButtonActivation);
      this.bind('hbw:file-upload-started', () => this.setState({ fileUploading: true }));
      this.bind('hbw:file-upload-finished', () => this.setState({ fileUploading: false }));
    },


    componentWillUnmount () {
      this.state.subscription.close();
    },

    render () {
      if (this.props.env.userExist) {
        if (this.props.showSpinner || !this.state.fetched) {
          return <div className="hbw-spinner"><i className="fa fa-spinner fa-spin fa-2x"></i></div>;
        } else if (this.state.bpRunning) {
          return <div className="hbw-spinner"><i className="fa fa-spinner fa-spin fa-2x"></i><h5 className="hbw-spinner-text">{this.t('bp_running')}</h5></div>;
        } else {
          const buttons = this.state.buttons.map((button, index) => {
            const self = this;
            return <Button key={index}
              button={button}
              disabled={self.state.submitting || self.state.fileUploading}
              env={self.props.env} />;
          });
          return <div className='hbw-bp-control-buttons btn-group'>
            <Error error={this.state.submitError || this.state.syncError} errorHeader={this.state.errorHeader} />
            {buttons}
          </div>;
        }
      } else {
        return <div></div>;
      }
    },

    onButtonActivation (button) {
      console.log(`Clicked button[${button.title}], submitting`);
      this.setState({
        syncing:    true,
        submitting: true
      });

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
          errorHeader: this.t('errors.cannot_start_process')
        }))
        .always(() => this.setState({ syncing: false }));
    },

    triggerBPStart (button) {
      this.trigger('hbw:process-started', button);
    }
  }));
