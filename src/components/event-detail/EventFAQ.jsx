import React, { useState } from 'react';

const FAQItem = ({ title, content, isActive, onClick }) => {
  return (
    <div className={`faq-item ${isActive ? 'active open' : ''}`}>
      <div className="faq-title" onClick={onClick}>
        <h6 className="title">{title}</h6>
        <span className="right-icon"></span>
      </div>
      <div className="faq-content">
        {content.map((paragraph, idx) => (
          <p key={idx}>{paragraph}</p>
        ))}
      </div>
    </div>
  );
};

const EventFAQ = () => {
  const [activeIndex, setActiveIndex] = useState(1); // Second item active by default

  const faqItems = [
    {
      title: "Can I Upgrade my Tickets after Placing an Order?",
      content: [
        "Being that Tickto does not own any of the tickets sold on our site, we do not have the ability to exchange or replace tickets with other inventory.",
        "If you would like to upgrade or change the location of your seats, you can relist your current tickets for sale here and purchase other tickets of your choice."
      ]
    },
    {
      title: "Why did the delivery method of my tickets change?",
      content: [
        "Being that Tickto does not own any of the tickets sold on our site, we do not have the ability to exchange or replace tickets with other inventory.",
        "If you would like to upgrade or change the location of your seats, you can relist your current tickets for sale here and purchase other tickets of your choice."
      ]
    },
    {
      title: "Why is there a different name printed on the tickets and will this give me problems at my event?",
      content: [
        "Being that Tickto does not own any of the tickets sold on our site, we do not have the ability to exchange or replace tickets with other inventory.",
        "If you would like to upgrade or change the location of your seats, you can relist your current tickets for sale here and purchase other tickets of your choice."
      ]
    },
    {
      title: "My tickets are not consecutive seats, are they still guaranteed together?",
      content: [
        "Being that Tickto does not own any of the tickets sold on our site, we do not have the ability to exchange or replace tickets with other inventory.",
        "If you would like to upgrade or change the location of your seats, you can relist your current tickets for sale here and purchase other tickets of your choice."
      ]
    },
    {
      title: "Why is there a different name printed on the tickets and will this give me problems at my event?",
      content: [
        "Being that Tickto does not own any of the tickets sold on our site, we do not have the ability to exchange or replace tickets with other inventory.",
        "If you would like to upgrade or change the location of your seats, you can relist your current tickets for sale here and purchase other tickets of your choice."
      ]
    }
  ];

  return (
    <section className="faq-section padding-top">
      <div className="container">
        <div className="section-header-3">
          <span className="cate">HOW CAN WE HELP?</span>
          <h2 className="title">Frequently Asked Questions</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida</p>
        </div>
        <div className="faq-area padding-bottom">
          <div className="faq-wrapper">
            {faqItems.map((item, index) => (
              <FAQItem 
                key={index}
                title={item.title}
                content={item.content}
                isActive={activeIndex === index}
                onClick={() => setActiveIndex(activeIndex === index ? -1 : index)}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default EventFAQ;