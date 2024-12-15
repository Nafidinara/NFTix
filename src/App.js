import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/common/Header';
import Footer from './components/common/Footer';
import {Home, EventDetail, EventTicket, EventCheckout} from './pages';
import Preloader from './components/common/Preloader';

import { Web3Provider } from './config/web3';

const App = () => {
  return (
    <Web3Provider>
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
              <Route path="/concert-detail/:id" element={<EventDetail />} />
              <Route path="/concert-ticket/:id" element={<EventTicket />} />
              <Route path="/concert-checkout/:concertId" element={<EventCheckout />} />
            </Routes>
            <Footer />
          </div>
        </Router>
    </Web3Provider>
  );
};

export default App;