import { useEffect } from 'react';

const useOwlCarousel = (selector, options = {}) => {
  useEffect(() => {
    if (window.jQuery) {
      const $ = window.jQuery;
      const carousel = $(selector);
      
      const defaultOptions = {
        loop: true,
        responsiveClass: true,
        nav: false,
        dots: false,
        margin: 30,
        autoplay: true,
        autoplayTimeout: 2000,
        autoplayHoverPause: true,
        responsive: {
          0: { items: 1 },
          576: { items: 2 },
          768: { items: 2 },
          992: { items: 3 },
          1200: { items: 4 }
        }
      };

      const carouselOptions = { ...defaultOptions, ...options };
      
      // Initialize Owl Carousel
      carousel.owlCarousel(carouselOptions);

      // Cleanup
      return () => {
        carousel.owlCarousel('destroy');
      };
    }
  }, [selector, options]);
};

export default useOwlCarousel;