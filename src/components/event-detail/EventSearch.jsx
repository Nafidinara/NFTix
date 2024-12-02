import React, { useEffect } from 'react';

const EventSearch = () => {
  useEffect(() => {
    // Initialize countdown timer
    if (window.jQuery) {
      window.jQuery('.countdown').countdown({
        date: '12/05/2024 05:00:00',
        offset: +2,
        day: 'Day',
        days: 'Days'
      });
    }
  }, []);

  return (
    <section className="event-book-search padding-top pt-lg-0">
      <div className="container">
        <div 
          className="event-search bg_img" 
          style={{ backgroundImage: `url('/assets/images/ticket/ticket-bg01.jpg')` }}
        >
          <div className="event-search-top">
            <div className="left">
              <h3 className="title">Coldplay: Music of the Spheres World Tour</h3>
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
              <a href="/concert-ticket" className="custom-button">book tickets</a>
            </div>
          </div>
          <div className="event-search-bottom">
            <div className="contact-side">
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon01.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">0.3 ETH - 1 ETH</span>
                </div>
              </div>
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon02.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">17 South Sherman Street</span>
                  <span>Astoria, NY 11106</span>
                </div>
              </div>
              <div className="item">
                <div className="item-thumb">
                  <img src="/assets/images/event/icon/event-icon03.png" alt="event" />
                </div>
                <div className="item-content">
                  <span className="up">January 1, 2024 10:00 - January 31, 2024 10:00</span>
                </div>
              </div>
            </div>
            <ul className="social-icons">
              {['facebook-f', 'twitter', 'pinterest-p', 'google', 'instagram'].map((social, index) => (
                <li key={index}>
                  <a href="#0">
                    <i className={`fab fa-${social}`}></i>
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
};

export default EventSearch;