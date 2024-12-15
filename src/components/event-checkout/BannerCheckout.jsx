import React from 'react';
import { useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { useGetCart } from '../../hooks/useContract';

const BannerCheckout = () => {
  const { concertId } = useParams();
  const { address } = useAccount();
  const { cart, isLoading } = useGetCart(address, concertId);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!cart) {
    return null;
  }

  return (
    <section 
      className="details-banner event-details-banner hero-area bg_img seat-plan-banner"
      style={{ backgroundImage: `url('${cart.ticketClass.backgroundUrl || '/assets/images/banner/banner07.jpg'}')` }}
    >
      <div className="container">
        <div className="details-banner-wrapper">
          <div className="details-banner-content style-two">
            <h3 className="title">
              <span className="d-block">{cart.concertName}</span>
            </h3>
            <div className="tags">
              <span>{cart.artistName}</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default BannerCheckout;