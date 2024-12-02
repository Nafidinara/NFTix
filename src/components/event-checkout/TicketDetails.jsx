import React from 'react';

const TicketDetails = () => {
  return (
    <div className="checkout-widget checkout-contact">
      <h5 className="title">Ticket Details</h5>
      <form className="checkout-contact-form">
        <div className="form-group">
          <p className="ticket-title">Concert Name</p>
        </div>
        <div className="form-group">
          <p className="ticket-title">Artist Name</p>
        </div>
        <div className="form-group">
          <p className="ticket-title">Music of the Spheres World Tour</p>
        </div>
        <div className="form-group">
          <p className="ticket-title">Coldplay</p>
        </div>
      </form>
    </div>
  );
};

export default TicketDetails;