import React from 'react';
import TicketItem from './TicketItem';

const TicketSection = () => {
  const tickets = [
    {
      type: 'Standard',
      price: '0.05',
      features: [
        { text: 'Full access to all lectures and workshops', disabled: false },
        { text: 'Video presentations', disabled: true },
        { text: 'Meet all of our event speakers', disabled: true }
      ]
    },
    {
      type: 'Premium',
      price: '0.07',
      isHot: true,
      features: [
        { text: 'Full access to all lectures and workshops', disabled: false },
        { text: 'Video presentations', disabled: false },
        { text: 'Meet all of our event speakers', disabled: true }
      ]
    },
    {
      type: 'VIP',
      price: '0.1',
      features: [
        { text: 'Full access to all lectures and workshops', disabled: false },
        { text: 'Video presentations', disabled: false },
        { text: 'Meet all of our event speakers', disabled: false }
      ]
    }
  ];

  return (
    <div className="event-facility padding-bottom padding-top">
      <div className="container">
        <div className="section-header-3">
          <span className="cate">Choose Your Ticket</span>
          <h2 className="title">Based on your needs</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua</p>
        </div>
        <div className="row justify-content-center mb-30-none">
          {tickets.map((ticket, index) => (
            <div key={index} className="col-md-6 col-lg-4 col-sm-10">
              <TicketItem {...ticket} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default TicketSection;