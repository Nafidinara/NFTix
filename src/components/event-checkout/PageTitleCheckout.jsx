import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { useGetCart, useGetConcertDetail } from '../../hooks/useContract';

const PageTitleCheckout = () => {
  const navigate = useNavigate();
  const { concertId } = useParams();
  const { address } = useAccount();
  
  // Fetch data sekali saja saat mount
  const { cart } = useGetCart(address, concertId);
  const { concert } = useGetConcertDetail(concertId);
  
  // State untuk timer
  const [timeLeft, setTimeLeft] = useState(300);

  // Format date function
  const formatDate = useMemo(() => (timestamp) => {
    if (!timestamp) return '';
    const date = new Date(Number(timestamp) * 1000);
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return `${days[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()} ${date.getFullYear()}`;
  }, []);

  // Format time 
  const formattedTime = useMemo(() => {
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }, [timeLeft]);

  // Timer effect
  useEffect(() => {
    if (timeLeft === 0) {
      navigate(-1);
      return;
    }

    const intervalId = setInterval(() => {
      setTimeLeft(prev => prev - 1);
    }, 3000);

    return () => clearInterval(intervalId);
  }, [timeLeft, navigate]);

  if (!cart || !concert) {
    return null;
  }

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
            <span className="date">{formatDate(concert.date)}</span>
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

export default React.memo(PageTitleCheckout);