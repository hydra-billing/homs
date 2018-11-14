modulejs.define('HBWFormSubmit', ['React'], (React) => {
  const FormSubmit = React.createClass({
    render () {
      let className = 'btn btn-primary';

      if (this.props.formSubmitting) {
        className += ' disabled';
      }

      return <div className="form-group">
        <button type="submit"
          className={className}
          disabled={this.props.formSubmitting}>
          <i className="fa fa-check" />
          {` ${this.props.env.translator('submit')}`}
        </button>
      </div>;
    }
  });

  return FormSubmit;
});
