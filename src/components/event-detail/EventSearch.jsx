import React, { useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { formatEther } from 'viem';
import { unixToDatetime } from '../../hooks/UnixToDatetime';

const EventSearch = ({ concert }) => {
  const { id } = useParams();

  useEffect(() => {
    if (window.jQuery) {
      window.jQuery('.countdown').countdown({
        date: '12/31/2024 23:59:59',
        offset: +2,
        day: 'Day',
        days: 'Days'
      });
    }
  }, []);

  if (!concert) {
    return null;
  }

  // Find min and max price from ticket classes
  const prices = concert.ticketClasses.map(tc => Number(formatEther(tc.price)));
  const minPrice = Math.min(...prices);
  const maxPrice = Math.max(...prices);

  return (
    <section className="event-book-search padding-top pt-lg-0">
      <div className="container">
        <div 
          className="event-search bg_img" 
          style={{ 
            backgroundImage: concert.ticketClasses[0]?.backgroundUrl 
              ? `url('${concert.ticketClasses[0].backgroundUrl}')`
              : `url('/assets/images/ticket/ticket-bg01.jpg')`
          }}
        >
          <div className="event-search-top">
            <div className="left">
              <h3 className="title">{concert.name}</h3>
            </div>
            <div className="right">
              <ul className="countdown">
                <li>
                  <h2><span className="days">00</span></h2>
                  <p className="days_text">days</p>
                </li>
                <li>
                  <h2><span className="hours">00</span></h2>
                  <p className="hours_text">hrs</p>
                </li>
                <li>
                  <h2><span className="minutes">00</span></h2>
                  <p className="minu_text">min</p>
                </li>
                <li>
                  <h2><span className="seconds">00</span></h2>
                  <p className="seco_text">sec</p>
                </li>
              </ul>
              <Link to={`/concert-ticket/${id}`} className="custom-button">book tickets</Link>
            </div>
          </div>
          <div className="event-search-bottom">
            <div className="contact-side">
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon01.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">{minPrice.toFixed(3)} ETH - {maxPrice.toFixed(3)} ETH</span>
                </div>
              </div>
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon02.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">{concert.venue}</span>
                </div>
              </div>
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon03.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">{unixToDatetime(concert.startBuy)} - {unixToDatetime(concert.endBuy)}</span>
                </div>
              </div>
            </div>
            {/* <ul className="social-icons">
              {['facebook-f', 'twitter', 'pinterest-p', 'google', 'instagram'].map((social, index) => (
                <li key={index}>
                  <a href="#0">
                    <i className={`fab fa-${social}`}></i>
                  </a>
                </li>
              ))}
            </ul> */}
          </div>
        </div>
      </div>
    </section>
  );
};

export default EventSearch;