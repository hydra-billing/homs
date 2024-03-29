import { withCallbacks } from 'shared/hoc';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

modulejs.define('HBWButton', ['React'], (React) => {
  const HBWButton = ({ button, disabled, trigger }) => {
    const classes = [];

    if (button.class) {
      classes.push(button.class);
    }

    if (disabled) {
      classes.push('disabled');
    }

    const opts = {
      className: classes.join(' '),
      title:     button.title,
      disabled
    };

    const onClick = (evt) => {
      evt.preventDefault();

      trigger('hbw:button-activated', button);
    };

    return (
      <span className="hbw-button">
        <a onClick={onClick} {...opts} href='#'>
        <FontAwesomeIcon icon={button.fa_class} />
        {` ${button.name}`}
        </a>
      </span>
    );
  };

  return withCallbacks(HBWButton);
});
