import React from 'react';

const Banner = () => {
  const bannerStyle = {
    backgroundImage: `url('/assets/images/banner/banner-bg.jpg')`,
    backgroundSize: 'cover',
    backgroundPosition: 'center center',
    backgroundRepeat: 'no-repeat'
  };

  return (
    <section className="banner-section">
      <div className="banner-bg bg_img bg-fixed" style={bannerStyle}></div>
      <div className="container">
        <div className="banner-content">
          <h1 className="title cd-headline">
            Book Your <span className="color-theme">Concert</span> Tickets
          </h1>
          <p>Safe, secure, reliable ticketing. Your ticket to live entertainment!</p>
        </div>
      </div>
    </section>
  );
};

export default Banner;