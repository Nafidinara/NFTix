// pages/EventCheckout.jsx
import React from 'react';
import { useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import TicketDetails from '../components/event-checkout/TicketDetails';
import TicketSelection from '../components/event-checkout/TicketSelection';
import BookingSummary from '../components/event-checkout/BookingSummary';
import BannerCheckout from '../components/event-checkout/BannerCheckout';
import PageTitleCheckout from '../components/event-checkout/PageTitleCheckout';

const EventCheckout = () => {
  const { concertId } = useParams();
  const { isConnected } = useAccount();

  // Redirect if wallet not connected
  if (!isConnected) {
    return (
      <div className="event-facility padding-bottom padding-top">
        <div className="container">
          <div className="alert alert-warning">Please connect your wallet first</div>
        </div>
      </div>
    );
  }

  return (
    <>
      <BannerCheckout />
      <PageTitleCheckout />
      <div className="event-facility padding-bottom padding-top">
        <div className="container">
          <div className="row">
            <div className="col-lg-8">
              <TicketDetails concertId={concertId} />
              <TicketSelection concertId={concertId} />
            </div>
            <div className="col-lg-4">
              <BookingSummary concertId={concertId} />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default EventCheckout;