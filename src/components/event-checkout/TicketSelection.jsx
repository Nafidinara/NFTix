import React from 'react';
import { useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { useGetCart } from '../../hooks/useContract';

const TicketSelection = () => {
  const { concertId } = useParams();
  const { address } = useAccount();
  const { cart, isLoading } = useGetCart(address, concertId);
  // const [quantity, setQuantity] = useState(cart?.quantity || 1);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!cart) {
    return <div>No ticket selected</div>;
  }

  return (
    <div className="checkout-widget checkout-contact">
      <h5 className="title">Your Tickets</h5>
      <div className="ticket--area row justify-content-center">
        <div className="col-sm-6 col-md-10">
          <div className="ticket-item">
            <div className="ticket-thumb">
              <img 
                src={cart.ticketClass.thumbnailUrl || "/assets/images/event/ticket/ticket01.png"} 
                alt="event" 
              />
            </div>
            <div className="ticket-content">
              <span className="ticket-title">{cart.ticketClass.name} Ticket</span>
              <h2 className="amount">{cart.ticketClass.price} ETH</h2>
              <a href="#0" className="t-button">
                <i className="fas fa-check"></i>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TicketSelection;