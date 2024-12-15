import React from 'react';

const Banner = ({ concertInfo }) => {
  if (!concertInfo) return null;

  return (
    <section 
      className="details-banner event-details-banner hero-area bg_img seat-plan-banner"
      style={{ backgroundImage: concertInfo.ticketClasses[0]?.backgroundUrl 
        ? `url('${concertInfo.ticketClasses[0].backgroundUrl}')`
        : `url('/assets/images/ticket/ticket-bg01.jpg')` }}
    >
      <div className="container">
        <div className="details-banner-wrapper">
          <div className="details-banner-content style-two">
            <h3 className="title">
              <span className="d-block">{concertInfo.name}</span>
            </h3>
            <div className="tags">
              <span>{concertInfo.venue}</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Banner;