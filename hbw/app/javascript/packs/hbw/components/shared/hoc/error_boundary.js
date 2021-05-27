import React, { Component } from 'react';
import withCallbacks from './callbacks';

class ErrorBoundary extends Component {
  state = {
    error: false,
  };

  componentDidCatch () {
    this.setState({ error: true });
    this.props.trigger('hbw:have-errors');
  }

  render () {
    if (this.state.error) {
      return (
      <div className={this.props.cssClass}>
        <span>&nbsp;</span>
        <div className='alert alert-danger'>
          {this.props.translator('error')}
        </div>
      </div>
      );
    }

    return this.props.children;
  }
}

const withErrorBoundary = (WrappedComponent) => {
  class WithErrorBoundary extends Component {
    render () {
      return (
        <ErrorBoundary
          translator={this.props.env.translator}
          cssClass={this.props.params ? this.props.params.css_class : ''}
          trigger={this.props.trigger}
          bind={this.props.bind}
        >
          <WrappedComponent {...this.props} />
        </ErrorBoundary>
      );
    }
  }

  return withCallbacks(WithErrorBoundary);
};

export default withErrorBoundary;
