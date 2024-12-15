import { useEffect } from 'react';

const useOwlCarousel = (selector, options = {}) => {
  useEffect(() => {
    const initCarousel = () => {
      const $ = window.jQuery;
      if ($ && $.fn.owlCarousel) {
        const $selector = $(selector);
        if ($selector.length) {
          // Destroy existing carousel instance if any
          if ($selector.data('owl.carousel')) {
            $selector.trigger('destroy.owl.carousel');
          }
          
          // Initialize new carousel
          setTimeout(() => {
            $selector.owlCarousel({
              loop: true,
              margin: 30,
              nav: false,
              dots: false,
              autoplay: false,
              responsive: {
                0: { items: 1 },
                576: { items: 2 },
                768: { items: 3 },
                992: { items: 4 }
              },
              ...options
            });
          }, 100);
        }
      }
    };

    initCarousel();

    return () => {
      const $ = window.jQuery;
      if ($) {
        const $selector = $(selector);
        if ($selector.length && $selector.data('owl.carousel')) {
          $selector.trigger('destroy.owl.carousel');
        }
      }
    };
  }, [selector, options]);
};

export default useOwlCarousel;