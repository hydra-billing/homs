import { withCallbacks } from './helpers';

modulejs.define('HBWButton', ['React'], (React) => {
  const Button = React.createClass({
    displayName: 'HBWButton',

    render () {
      const classes = [];
      if (this.props.button.class) {
        classes.push(this.props.button.class);
      }
      if (this.props.disabled) {
        classes.push('disabled');
      }

      const opts = {
        className: classes.join(' '),
        title:     this.props.button.title,
        disabled:  this.props.disabled
      };

      return <span className="hbw-button"><a onClick={this.onClick} {...opts} href='#'>
      <i className={this.props.button.fa_class}></i>
        {` ${this.props.button.name}`}
    </a></span>;
    },

    onClick (evt) {
      evt.preventDefault();

      this.props.trigger('hbw:button-activated', this.props.button);
    }
  });

  return withCallbacks(Button);
});
