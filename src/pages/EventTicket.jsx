import React from 'react';
import { useParams } from 'react-router-dom';
import Banner from '../components/event-ticket/Banner';
import PageTitle from '../components/event-ticket/PageTitle';
import TicketSection from '../components/event-ticket/TicketSection';
import { useGetTicketClasses } from '../hooks/useContract';

const EventTicket = () => {
  const { id } = useParams();
  const { tickets, concertInfo, isLoading, error } = useGetTicketClasses(id);

  console.log('Concert info:', concertInfo);
  console.log('Tickets:', tickets);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error loading tickets</div>;
  }

  return (
    <>
      <Banner concertInfo={concertInfo} />
      <PageTitle concertInfo={concertInfo} />
      <TicketSection tickets={tickets} />
    </>
  );
};

export default EventTicket;