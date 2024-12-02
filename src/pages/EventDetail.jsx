import React from 'react';
import EventBanner from '../components/event-detail/EventBanner';
import EventSearch from '../components/event-detail/EventSearch';
import EventAbout from '../components/event-detail/EventAbout';
import EventFAQ from '../components/event-detail/EventFAQ';

const EventDetail = () => {
  return (
    <>
      <EventBanner />
      <EventSearch />
      <EventAbout />
      <EventFAQ />
    </>
  );
};

export default EventDetail;