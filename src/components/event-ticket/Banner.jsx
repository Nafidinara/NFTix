import React from 'react';

const Banner = () => {
  return (
    <section 
      className="details-banner event-details-banner hero-area bg_img seat-plan-banner"
      style={{ backgroundImage: `url('/assets/images/banner/banner07.jpg')` }}
    >
      <div className="container">
        <div className="details-banner-wrapper">
          <div className="details-banner-content style-two">
            <h3 className="title">
              <span className="d-block">Coldplay: Music of the Spheres World Tour</span>
            </h3>
            <div className="tags">
              <span>17 South Sherman Street Astoria, NY 11106</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Banner;