import React, { Component, useContext } from 'react';
import TranslationContext from '../context/translation';
import withCallbacks from './callbacks';

class ErrorBoundary extends Component {
  state = {
    error:     false,
    errorText: null,
  };

  componentDidCatch (errorText) {
    this.setState({ error: true, errorText });
    this.props.trigger('hbw:have-errors');
  }

  render () {
    if (this.state.error) {
      return (
      <div className={this.props.cssClass}>
        <span>&nbsp;</span>
        <div className='alert alert-danger'>
          {this.props.translate('error')}
          <p>
            {`${this.state.errorText}`}
          </p>
        </div>
      </div>
      );
    }

    return this.props.children;
  }
}

const withErrorBoundary = (WrappedComponent) => {
  const WithErrorBoundary = (props) => {
    const { translate } = useContext(TranslationContext);

    return (
      <ErrorBoundary
        translate={translate}
        cssClass={props.params ? props.params.css_class : ''}
        trigger={props.trigger}
        bind={props.bind}
      >
        <WrappedComponent {...props} />
      </ErrorBoundary>
    );
  };

  return withCallbacks(WithErrorBoundary);
};

export default withErrorBoundary;
