import React from 'react';

const TicketItem = ({ type, icon, price, features, isHot }) => {
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
        <h2 className="amount">{price} ETH</h2>
        <ul>
          {features.map((feature, index) => (
            <li key={index} className={feature.disabled ? 'del' : ''}>
              {feature.disabled ? <del>{feature.text}</del> : feature.text}
            </li>
          ))}
        </ul>
        <a href="/concert-checkout" className="custom-button">book tickets</a>
      </div>
    </div>
  );
};

export default TicketItem;