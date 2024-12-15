import React from 'react';
import { useParams } from 'react-router-dom';
import EventBanner from '../components/event-detail/EventBanner';
import EventSearch from '../components/event-detail/EventSearch';
import EventAbout from '../components/event-detail/EventAbout';
import EventFAQ from '../components/event-detail/EventFAQ';
import { useGetConcertDetail } from '../hooks/useContract';
import { useNavigate } from 'react-router-dom';

const EventDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { concert, isLoading, error } = useGetConcertDetail(id);

  if (isLoading) {
    return <div>Loading...</div>; // Consider using your Preloader component here
  }

  if (error) {
    return <div>Error loading concert details</div>;
  }

  if (!concert) {
    return <div>Concert not found</div>;
  }

  const handleBuyTicket = () => {
    navigate(`/concert-checkout/${id}`);
  };

  return (
    <>
      <EventBanner 
        name={concert.name}
        artist={concert.artistName}
        date={concert.date}
        venue={concert.venue}
        backgroundImage={concert.ticketClasses[0]?.backgroundUrl}
      />
      <EventSearch concert={concert} />
      <EventAbout 
        description={concert.description}
        startDate={concert.startBuy}
        endDate={concert.endBuy}
        ticketClasses={concert.ticketClasses}
        artist={concert.artistName}
        onBuyTicket={handleBuyTicket}
      />
      <EventFAQ />
    </>
  );
};

export default EventDetail;