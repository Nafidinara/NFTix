import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/common/Header';
import Footer from './components/common/Footer';
import {Home, EventDetail, EventTicket, EventCheckout} from './pages';
import Preloader from './components/common/Preloader';

const App = () => {
  return (
    <Router>
      <div className="App">
      <Preloader />
      <div className="overlay"></div>
      <a href="#0" className="scrollToTop">
        <i className="fas fa-angle-up"></i>
      </a>
        <Header />
        <Routes>
          <Route exact path="/" element={<Home />} />
          {/* <Route path="/contact" element={<Contact />} />
          <Route path="/about" element={<About />} /> */}
          <Route path="/concert-detail" element={<EventDetail />} />
          <Route path="/concert-ticket" element={<EventTicket />} />
          <Route path="/concert-checkout" element={<EventCheckout />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
};

export default App;