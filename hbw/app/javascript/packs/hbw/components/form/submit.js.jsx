import { Component } from 'react';

modulejs.define('HBWFormSubmit', ['React'], (React) => {
  class HBWFormSubmit extends Component {
    render () {
      let className = 'btn btn-primary';

      if (this.props.formSubmitting) {
        className += ' disabled';
      }

      return <div className="form-group">
        <button type="submit"
          className={className}
          disabled={this.props.formSubmitting}>
          <i className="fas fa-check" />
          {` ${this.props.env.translator('submit')}`}
        </button>
      </div>;
    }
  };

  return HBWFormSubmit;
});
