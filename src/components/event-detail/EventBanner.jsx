import React from 'react';
import PropTypes from 'prop-types';

const EventBanner = ({ name, artist, backgroundImage }) => {

  return (
    <section 
      className="event-banner-section bg_img" 
      style={{ 
        backgroundImage: backgroundImage 
          ? `url('${backgroundImage}')`
          : `url('/assets/images/banner/banner06.jpg')`
      }}
    >
      <div className="container">
        <div className="event-banner">
          {/* You might want to make this video URL dynamic too */}
          <a href="https://www.youtube.com/watch?v=cQOAsuw_F6Y" target='_blank' className="video-popup">
            <span></span>
            <i className="flaticon-play-button"></i>
          </a>
          <div className="event-banner-content">
            <h1 className="title text-white">{name}</h1>
            <h4 className="subtitle text-white">By {artist}</h4>
          </div>
        </div>
      </div>
    </section>
  );
};

EventBanner.propTypes = {
  name: PropTypes.string.isRequired,
  artist: PropTypes.string.isRequired,
  venue: PropTypes.string.isRequired,
  backgroundImage: PropTypes.string,
};

export default EventBanner;