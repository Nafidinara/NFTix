import React, { useEffect } from 'react';

const Preloader = () => {
  useEffect(() => {
    // Implementasi fadeOut setelah load
    const preloader = document.querySelector('.preloader');
    if (preloader) {
      window.addEventListener('load', () => {
        setTimeout(() => {
          preloader.style.display = 'none';
        }, 1000);
      });
    }
  }, []);

  return (
    <div className="preloader">
      <div className="preloader-inner">
        <div className="preloader-icon">
          <span></span>
          <span></span>
        </div>
      </div>
    </div>
  );
};

export default Preloader;