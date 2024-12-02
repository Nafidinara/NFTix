import React from 'react';
import Banner from '../components/event-ticket/Banner';
import PageTitle from '../components/event-ticket/PageTitle';
import TicketDetails from '../components/event-checkout/TicketDetails';
import TicketSelection from '../components/event-checkout/TicketSelection';
import BookingSummary from '../components/event-checkout/BookingSummary';

const EventCheckout = () => {
  return (
    <>
      <Banner />
      <PageTitle />
      <div className="event-facility padding-bottom padding-top">
        <div className="container">
          <div className="row">
            <div className="col-lg-8">
              <TicketDetails />
              <TicketSelection />
            </div>
            <div className="col-lg-4">
              <BookingSummary />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default EventCheckout;