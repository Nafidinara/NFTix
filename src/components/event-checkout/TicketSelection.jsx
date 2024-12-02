import React, { useState } from 'react';

const TicketSelection = () => {
  const [quantity, setQuantity] = useState(2);

  const handleQuantityChange = (type) => {
    if (type === 'inc') {
      setQuantity(prev => prev + 1);
    } else if (type === 'dec' && quantity > 1) {
      setQuantity(prev => prev - 1);
    }
  };

  return (
    <div className="checkout-widget checkout-contact">
      <h5 className="title">Your Tickets</h5>
      <div className="ticket--area row justify-content-center">
        <div className="col-sm-6 col-md-4">
          <div className="ticket-item">
            <div className="ticket-thumb">
              <img src="/assets/images/event/ticket/ticket01.png" alt="event" />
            </div>
            <div className="ticket-content">
              <span className="ticket-title">Standard Ticket</span>
              <h2 className="amount">0.05 ETH</h2>
              <a href="#0" className="t-button">
                <i className="fas fa-check"></i>
              </a>
            </div>
          </div>
        </div>
      </div>
      <div className="row mb-30-none">
        <div className="col-md-6 col-xl-5">
          <form className="cart-button event-cart">
            <span className="d-inline-block">Ticket Quantity : </span>
            <div className="cart-plus-minus">
              <div className="dec qtybutton" onClick={() => handleQuantityChange('dec')}>-</div>
              <input 
                className="cart-plus-minus-box" 
                type="text" 
                name="qtybutton" 
                value={quantity}
                readOnly
              />
              <div className="inc qtybutton" onClick={() => handleQuantityChange('inc')}>+</div>
            </div>
          </form>
        </div>
        {/* <div className="col-md-7 col-xl-7">
          <form className="checkout-contact-form mb-0">
            <div className="form-group">
              <input type="submit" value="Verify" className="custom-button" />
            </div>
          </form>
        </div> */}
      </div>
    </div>
  );
};

export default TicketSelection;