import React from 'react';
import TicketItem from './TicketItem';

const TicketSection = ({ tickets }) => {
  return (
    <div className="event-facility padding-bottom padding-top">
      <div className="container">
        <div className="section-header-3">
          <span className="cate">Choose Your Ticket</span>
          <h2 className="title">Based on your needs</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua</p>
        </div>
        <div className="row justify-content-center mb-30-none">
          {tickets?.map((ticket, index) => (
            <div key={index} className="col-md-6 col-lg-4 col-sm-10">
              <TicketItem 
                {...ticket} 
                ticketClassIndex={index}
              />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default TicketSection;