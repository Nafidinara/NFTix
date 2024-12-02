import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const PageTitle = () => {
  const navigate = useNavigate();
  const [timeLeft, setTimeLeft] = useState(300); // 5 minutes in seconds

  useEffect(() => {
    if (timeLeft === 0) return;

    const intervalId = setInterval(() => {
      setTimeLeft(timeLeft - 1);
    }, 1000);

    return () => clearInterval(intervalId);
  }, [timeLeft]);

  // Format time to MM:SS
  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;
  const formattedTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

  return (
    <section className="page-title bg-one">
      <div className="container">
        <div className="page-title-area">
          <div className="item md-order-1">
            <button onClick={() => navigate(-1)} className="custom-button back-button">
              <i className="flaticon-double-right-arrows-angles"></i>back
            </button>
          </div>
          <div className="item date-item">
            <span className="date">MON, SEP 09 2020</span>
          </div>
          <div className="item">
            <h5 className="title">{formattedTime}</h5>
            <p>Mins Left</p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default PageTitle;