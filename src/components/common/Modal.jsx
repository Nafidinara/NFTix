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
    // Wrapper dengan fixed position untuk menutupi seluruh layar
    <div className="fixed inset-0 flex items-center justify-center" style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(10, 18, 39, 0.9)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 9999
    }}>
      {/* Modal container */}
      <div style={{
        backgroundColor: '#0f1c3c',
        borderRadius: '12px',
        border: '1px solid rgba(59, 130, 246, 0.2)',
        padding: '24px',
        width: '400px',
        textAlign: 'center',
        position: 'relative',
        boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)'
      }}>
        {/* Icon */}
        {icon && (
          <div style={{
            display: 'flex',
            justifyContent: 'center',
            marginBottom: '20px'
          }}>
            <img 
              src={icon} 
              alt="modal icon"
              style={{
                width: '48px',
                height: '48px'
              }} 
            />
          </div>
        )}

        {/* Title */}
        <h3 style={{
          fontSize: '24px',
          fontWeight: 'bold',
          color: 'white',
          marginBottom: '12px'
        }}>
          {title}
        </h3>

        {/* Message */}
        <p style={{
          color: '#94a3b8',
          fontSize: '16px',
          marginBottom: '8px'
        }}>
          {message}
        </p>

        {/* Sub Message */}
        {subMessage && (
          <p style={{
            color: '#64748b',
            fontSize: '14px'
          }}>
            {subMessage}
          </p>
        )}
      </div>
    </div>
  );
};

export default Modal;