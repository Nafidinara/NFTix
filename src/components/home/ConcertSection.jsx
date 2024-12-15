// src/components/home/ConcertSection.jsx
import React, { useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import useOwlCarousel from '../../hooks/UseOwlCarousel';
import { useGetAllConcerts } from '../../hooks/useContract';
import { formatEther } from 'viem';

const ConcertSection = () => {
  const { concerts, isLoading, error } = useGetAllConcerts();
  const carouselInitialized = useRef(false);
  
  useOwlCarousel('.tab-slider', {
    loop: true,
    margin: 20,
    nav: false,
    dots: false,
    autoplay: false,
    responsive: {
      0: { items: 1 },
      576: { items: 2 },
      768: { items: 3 },
      992: { items: 4 }
    }
  });

  // Reset carousel when data changes
  useEffect(() => {
    if (concerts?.length && !carouselInitialized.current) {
      const $ = window.jQuery;
      if ($) {
        const $slider = $('.tab-slider');
        if ($slider.data('owl.carousel')) {
          $slider.trigger('destroy.owl.carousel');
        }
        $slider.owlCarousel({
          loop: true,
          margin: 20,
          nav: false,
          dots: false,
          autoplay: false,
          responsive: {
            0: { items: 1 },
            576: { items: 2 },
            768: { items: 3 },
            992: { items: 4 }
          }
        });
        carouselInitialized.current = true;
      }
    }
  }, [concerts]);

  if (isLoading) {
    return (
      <section className="movie-section padding-top padding-bottom bg-one">
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
                  {[1, 2, 3, 4].map((_, index) => (
                    <div className="item" key={index}>
                      <div className="movie-grid loading-skeleton">
                        <div className="movie-thumb c-thumb">
                          <div className="image-wrapper skeleton-bg"></div>
                        </div>
                        <div className="movie-content bg-one">
                          <div className="title-skeleton skeleton-bg"></div>
                          <div className="meta-skeleton">
                            <div className="skeleton-bg"></div>
                            <div className="skeleton-bg"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="movie-section padding-top padding-bottom bg-one">
        <div className="container">
          <div className="tab">
            <div className="section-header-2">
              <div className="left">
                <h2 className="title">Concert</h2>
                <p>Find all your favourite concerts</p>
              </div>
            </div>
            <div className="tab-area">
              <div className="alert alert-warning text-center">
                <h4 className="text-warning mb-3">Oops! Something went wrong</h4>
                <p className="mb-0">Unable to load concerts at the moment. Please try again later.</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }

  if (!concerts?.length) {
    return (
      <section className="movie-section padding-top padding-bottom bg-one">
        <div className="container">
          <div className="tab">
            <div className="section-header-2">
              <div className="left">
                <h2 className="title">Concert</h2>
                <p>Find all your favourite concerts</p>
              </div>
            </div>
            <div className="tab-area">
              <div className="alert alert-info text-center">
                <p className="mb-0">No concerts available at the moment.</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }

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
                {concerts?.map((concert, index) => (
                  <div className="item" key={index}>
                    <div className="movie-grid">
                      <div className="movie-thumb c-thumb">
                        <Link to={`/concert-detail/${index + 1}`}>
                          <div className="image-wrapper">
                            <img 
                              src={concert.ticketClasses[0]?.thumbnailUrl || "/assets/images/movie/movie01.jpg"} 
                              alt={concert.concertName}
                            />
                          </div>
                        </Link>
                      </div>
                      <div className="movie-content bg-one">
                        <h5 className="title m-0">
                          <Link to={`/concert-detail/${index + 1}`}>
                            {concert.concertName}
                          </Link>
                        </h5>
                        <ul className="movie-rating-percent">
                          <li>
                            <div className="thumb">
                              <img 
                                src="https://raw.githubusercontent.com/coinwink/cryptocurrency-logos/refs/heads/master/coins/32x32/1027.png" 
                                alt="eth"
                              />
                            </div>
                            <span className="content">
                              {concert.ticketClasses[0] ? 
                                `${formatEther(concert.ticketClasses[0].price.toString())} ETH` : 
                                '0 ETH'}
                            </span>
                          </li>
                          <li>
                            <div className="thumb">
                              <img 
                                style={{width: '32px', height: '32px'}} 
                                src="https://i.ibb.co.com/F6M4hrb/nft-ticket-oveit-mid-300x274-removebg-preview.png" 
                                alt="nft"
                              />
                            </div>
                            <span className="content">
                              {concert.ticketClasses[0] ? 
                                `${concert.ticketClasses[0].quantity} NFTs` : 
                                '0 NFTs'}
                            </span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ConcertSection;