import React from 'react';

const EventAbout = () => {
  return (
    <section className="event-about padding-top padding-bottom">
      <div className="container">
        <div className="row justify-content-between flex-wrap-reverse">
          <div className="col-lg-7 col-xl-6">
            <div className="event-about-content">
              <div className="section-header-3 left-style m-0">
                <span className="cate">let's take a look</span>
                <h2 className="title">About the artist - <span>Coldplay</span></h2>
                <p>
                  Coldplay, British rock group whose melodic piano-driven anthems lifted the band to the top of the pop music world in the early 21st century. 
                  Coldplay was formed in 1998 at University College, London, with the pairing of pianist-vocalist Chris Martin and guitarist Jonny Buckland. 
                  The band was later filled out with fellow students Guy Berryman on bass and Will Champion, a guitarist who later switched to drums
                </p>
                <a href="/concert-ticket" className="custom-button">Book Tickets</a>
              </div>
            </div>
          </div>
          <div className="col-lg-5 col-md-7">
            <div className="event-about-thumb">
              <img src="/assets/images/event/event-about.jpg" alt="event" />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default EventAbout;