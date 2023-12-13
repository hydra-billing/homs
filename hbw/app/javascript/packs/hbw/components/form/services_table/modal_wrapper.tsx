import ReactDOM from 'react-dom';
import cn from 'classnames';
import React from 'react';
import compose from 'shared/utils/compose';

type Props = {
  show: boolean,
  id: string,
  title: string,
  onSubmit: () => void,
  onClose: () => void,
  body: React.ReactNode,
  footer: React.ReactNode
}

const HBWModalWrapper = (props: Props) => {
  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.stopPropagation();
    event.preventDefault();

    props.onSubmit();
  };

  const modalCss = cn('modal', { show: props.show });
  return ReactDOM.createPortal(<div className='hbw-form'>
    <div className='hbw-body'>
      <div
        className={modalCss}
        id={props.id}
        tabIndex={-1}
        role='dialog'
        aria-labelledby={`${props.id}-label`}
        aria-hidden={!props.show}
      >
        <div className='modal-dialog hbw-modal' role='document'>
          <div className='modal-content'>
            <div className='modal-header header'>
              <span className='modal-title title'>
                {props.title}
              </span>
              <button
                type='button'
                className='close'
                data-dismiss='modal'
                aria-label='close'
                onClick={props.onClose}
              >
                <span aria-hidden='true'>&times;</span>
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className='modal-body body'>
                {props.body}
              </div>
              <div className='modal-footer footer'>
                {props.footer}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>, document.body);
};

export default compose()(HBWModalWrapper);
