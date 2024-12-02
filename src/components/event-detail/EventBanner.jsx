import React from 'react';

const EventBanner = () => {
  return (
    <section 
      className="event-banner-section bg_img" 
      style={{ backgroundImage: `url('/assets/images/banner/banner06.jpg')` }}
    >
      <div className="container">
        <div className="event-banner">
          <a href="https://www.youtube.com/embed/GT6-H4BRyqQ" className="video-popup">
            <span></span>
            <i className="flaticon-play-button"></i>
          </a>
        </div>
      </div>
    </section>
  );
};

export default EventBanner;