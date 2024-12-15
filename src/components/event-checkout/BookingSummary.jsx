import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { parseEther } from 'viem';
import Modal from '../common/Modal';
import { useBuyTicket, useGetCart, useGetTicketClasses } from '../../hooks/useContract';

const BookingSummary = () => {
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();
  const { address } = useAccount();
  const { concertId } = useParams();
  
  // Get cart and ticket class data
  const { cart } = useGetCart(address, concertId);
  const { tickets } = useGetTicketClasses(concertId);
  const { buyTicket, isPending, isError, isSuccess } = useBuyTicket();

  // Find ticket class index
  const ticketClassIndex = React.useMemo(() => {
    if (!cart || !tickets) return null;
    return tickets.findIndex(ticket => ticket.type === cart.ticketClass.name);
  }, [cart, tickets]);

  // Handle transaction status changes
  useEffect(() => {
    if (isSuccess) {
      setShowModal(true);
      setError(null);
    }
  }, [isSuccess]);

  useEffect(() => {
    if (isError) {
      setError('Transaction failed. Please try again.');
    }
  }, [isError]);

  const formatEth = (value) => {
    return Number(value).toFixed(6);
  };

  const calculateSubtotal = () => {
    if (!cart) return 0;
    return formatEth(Number(cart.ticketClass.price) * cart.quantity);
  };

  const calculateVAT = () => {
    return formatEth(calculateSubtotal() * 0.05); // 1% VAT
  };

  const calculateServiceCharge = () => {
    return formatEth(calculateSubtotal() * 0.02); // 0.5% service charge
  };

  const calculateTotal = () => {
    const subtotal = Number(calculateSubtotal());
    const vat = Number(calculateVAT());
    const serviceCharge = Number(calculateServiceCharge());
    return formatEth(subtotal + vat + serviceCharge);
  };

  const handleProceed = async (e) => {
    e.preventDefault();
    setError(null);

    if (!cart || ticketClassIndex === null) {
      setError('Invalid cart data. Please try again.');
      return;
    }

    try {
      // Convert ETH amount to Wei for the contract
      const totalValueWei = parseEther(calculateTotal().toString());
      
      await buyTicket(
        concertId,
        ticketClassIndex,
        totalValueWei
      );
    } catch (error) {
      console.error('Error purchasing ticket:', error);
      setError(error?.message || 'Error purchasing ticket. Please try again.');
    }
  };

  const handleClose = () => setShowModal(false);
  const handleAutoClose = () => navigate('/concert-detail/' + concertId);

  const modalProps = {
    isOpen: showModal,
    onClose: handleClose,
    onAutoClose: handleAutoClose,
    title: "Payment Successful!",
    message: "Your NFT ticket has been minted successfully.",
    subMessage: "You can view your ticket in your wallet.",
    icon: "/assets/images/event/icon/event-icon03.png",
    autoClose: 5000
  };

  if (!cart || !tickets) return null;

return (
  <>
    <div className="booking-summery bg-one">
      <h4 className="title">booking summary</h4>
      <ul>
        <li>
          <h6 className="subtitle">Ticket Name</h6>
          <span className="info">{cart.concertName}</span>
        </li>
        <li>
          <h6 className="subtitle"><span>Ticket Tier</span></h6>
          <div className="info"><span>{cart.ticketClass.name}</span></div>
        </li>
        <li>
          <h6 className="subtitle mb-0">
            <span>Tickets Price</span>
            <span>{cart.ticketClass.price} ETH</span>
          </h6>
        </li>
        <li>
          <h6 className="subtitle mb-0">
            <span>Tickets Quantity</span>
            <span>x{cart.quantity}</span>
          </h6>
        </li>
      </ul>
      <ul className="side-shape">
        <li>
          <h6 className="subtitle">
            <span>Subtotal</span>
            <span>{calculateSubtotal()} ETH</span>
          </h6>
        </li>
      </ul>
      <ul>
        <li>
          <span className="info">
            <span>vat (5%)</span>
            <span>{calculateVAT()} ETH</span>
          </span>
          <span className="info">
            <span>service charge (2%)</span>
            <span>{calculateServiceCharge()} ETH</span>
          </span>
        </li>
      </ul>
    </div>
    <div className="proceed-area text-center">
      <h6 className="subtitle">
        <span>Amount Payable</span>
        <span>{calculateTotal()} ETH</span>
      </h6>
      <button 
          className="custom-button back-button" 
          onClick={handleProceed}
          disabled={isPending}
        >
          {isPending ? 'Processing...' : 'Proceed'}
        </button>
    </div>

    <Modal {...modalProps} />
  </>
);
};

export default BookingSummary;