import React from 'react';
import { useAccount } from 'wagmi';
import { useParams } from 'react-router-dom';
import { useGetCart } from '../../hooks/useContract';

const TicketDetails = () => {
  const { address } = useAccount();
  const { concertId } = useParams();
  const { cart, isLoading } = useGetCart(address, concertId);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  console.log('Data Cart ticketDetails():', cart);

  return (
    <div className="checkout-widget checkout-contact">
      <h5 className="title">Ticket Details</h5>
      <form className="checkout-contact-form">
        <div className="form-group">
          <p style={{ fontWeight: 'bold' }} className="ticket-title">Concert Name</p>
          <p>{cart?.concertName || '-'}</p>
        </div>
        <div className="form-group">
          <p style={{ fontWeight: 'bold' }} className="ticket-title">Artist Name</p>
          <p>{cart?.artistName || '-'}</p>
        </div>
        <div className="form-group">
          <p style={{ fontWeight: 'bold' }} className="ticket-title">Ticket Type</p>
          <p>{cart?.ticketClass?.name || '-'}</p>
        </div>
        <div className="form-group">
          <p style={{ fontWeight: 'bold' }} className="ticket-title">Quantity</p>
          <p>{cart?.quantity || '-'}</p>
        </div>
      </form>
    </div>
  );
};

export default TicketDetails;