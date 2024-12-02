import React from 'react';

const Modal = ({ isOpen, onClose, title, message, subMessage, icon, autoClose = 3000, onAutoClose }) => {
  React.useEffect(() => {
    if (isOpen && autoClose) {
      const timer = setTimeout(() => {
        onClose();
        if (onAutoClose) onAutoClose();
      }, autoClose);
      return () => clearTimeout(timer);
    }
  }, [isOpen, autoClose, onClose, onAutoClose]);

  if (!isOpen) return null;

  return (
    <div className="window-warning" style={{ display: 'block' }}>
      <div className="lay" onClick={onClose}></div>
      <div className="warning-item">
        {icon && (
          <div className="thumb">
            <img src={icon} alt="modal icon" />
          </div>
        )}
        <h5 className="title">{title}</h5>
        <p>{message}</p>
        {subMessage && <p>{subMessage}</p>}
      </div>
    </div>
  );
};

export default Modal;