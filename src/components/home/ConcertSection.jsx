import React from 'react';
import { Link } from 'react-router-dom';
import useOwlCarousel from '../../hooks/UseOwlCarousel';

const ConcertSection = () => {
  useOwlCarousel('.tab-slider');
  
  return (
    <section className="movie-section padding-top padding-bottom">
      <div className="container">
        <div className="tab">
          <div className="section-header-2">
            <div className="left">
              <h2 className="title">Concert</h2>
              <p>Find all your favourite concerts</p>
            </div>
          </div>
          <div className="tab-area mb-30-none">
            <div className="tab-item active">
              <div className="owl-carousel owl-theme tab-slider">
                <div className="item">
                  <div className="movie-grid">
                    <div className="movie-thumb c-thumb">
                      <Link to="/concert-detail">
                        <img src="/assets/images/movie/movie01.jpg" alt="movie" />
                      </Link>
                    </div>
                    <div className="movie-content bg-one">
                      <h5 className="title m-0">
                        <Link to="/concert-detail">Coldplay</Link>
                      </h5>
                      <ul className="movie-rating-percent">
                        <li>
                          <div className="thumb">
                            <img src="https://raw.githubusercontent.com/coinwink/cryptocurrency-logos/refs/heads/master/coins/32x32/1027.png" alt="eth" />
                          </div>
                          <span className="content">0.2 ETH</span>
                        </li>
                        <li>
                          <div className="thumb">
                            <img 
                              style={{width: '32px', height: '32px'}} 
                              src="https://i.ibb.co.com/F6M4hrb/nft-ticket-oveit-mid-300x274-removebg-preview.png" 
                              alt="nft" 
                            />
                          </div>
                          <span className="content">100 NFTs</span>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
                {/* Duplicate items di sini */}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ConcertSection;