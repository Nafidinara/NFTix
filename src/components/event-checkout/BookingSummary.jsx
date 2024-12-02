import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Modal from '../common/Modal';

const BookingSummary = () => {
    const [showModal, setShowModal] = useState(false);
    const navigate = useNavigate();

    const handleProceed = (e) => {
    e.preventDefault();
    setShowModal(true);
    };

    const handleClose = () => {
    setShowModal(false);
    };

    const handleAutoClose = () => {
    navigate('/');
    };

    const modalProps = {
    isOpen: showModal,
    onClose: handleClose,
    onAutoClose: handleAutoClose,
    title: "Payment Successful!",
    message: "Your ticket has been booked successfully.",
    subMessage: "Please check your email for the NFT ticket.",
    icon: "/assets/images/event/icon/event-icon03.png",
    autoClose: 3000
    };

  return (
    <>
      <div className="booking-summery bg-one">
        <h4 className="title">booking summary</h4>
        <ul>
          <li>
            <h6 className="subtitle">Ticket Name</h6>
            <span className="info">Coldplay: Music of the Spheres World Tour</span>
          </li>
          <li>
            <h6 className="subtitle"><span>Ticket Tier</span></h6>
            <div className="info"><span>Standard</span></div>
          </li>
          <li>
            <h6 className="subtitle mb-0">
              <span>Tickets Price</span>
              <span>0.05 ETH</span>
            </h6>
          </li>
          <li>
            <h6 className="subtitle mb-0">
              <span>Tickets Quantity</span>
              <span>x3</span>
            </h6>
          </li>
        </ul>
        <ul className="side-shape">
          <li>
            <h6 className="subtitle">
              <span>Subtotal</span>
              <span>0.15 ETH</span>
            </h6>
          </li>
        </ul>
        <ul>
          <li>
            <span className="info">
              <span>vat</span>
              <span>0.002 ETH</span>
            </span>
            <span className="info">
              <span>service charge</span>
              <span>0.001 ETH</span>
            </span>
          </li>
        </ul>
      </div>
      <div className="proceed-area text-center">
        <h6 className="subtitle">
          <span>Amount Payable</span>
          <span>0.16 ETH</span>
        </h6>
        <a href="#0" className="custom-button back-button" onClick={handleProceed}>proceed</a>
      </div>

      <Modal {...modalProps} />
    </>
  );
};

export default BookingSummary;