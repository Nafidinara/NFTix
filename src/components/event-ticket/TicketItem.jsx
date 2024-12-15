import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAddToCart } from '../../hooks/useContract';
import { useAccount, useConnect } from 'wagmi';
import { injected } from 'wagmi/connectors';

const TicketItem = ({ type, price, isHot, ticketClassIndex }) => {
  const { id: concertId } = useParams();
  const { addToCart, isPending } = useAddToCart();
  const { isConnected } = useAccount();
  const { connect } = useConnect();

  const handleClick = async () => {
    if (!isConnected) {
      connect({ connector: injected() });
      return;
    }

    try {
      await addToCart(concertId, ticketClassIndex, 1);
    } catch (error) {
      console.error('Failed to add ticket to cart:', error);
    }
  };

  return (
    <div className={`ticket--item ${type === 'Premium' ? 'two' : type === 'VIP' ? 'three' : ''}`}>
      {isHot && (
        <div className="hot">
          <span>hot</span>
        </div>
      )}
      <div className="ticket-thumb">
        <img src={`/assets/images/event/ticket/ticket0${type === 'Standard' ? '1' : type === 'Premium' ? '2' : '3'}.png`} alt="event" />
      </div>
      <div className="ticket-content">
        <span className="ticket-title">{type} Ticket</span>
        <h2 className="amount mb-5">{price} ETH</h2>
        <button 
          className="custom-button"
          onClick={handleClick}
          disabled={isPending}
        >
          {isPending ? 'Processing...' : 'book tickets'}
        </button>
      </div>
    </div>
  );
};

export default TicketItem;