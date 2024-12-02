import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/common/Header';
import Footer from './components/common/Footer';
import Home from './pages/Home';
import Contact from './pages/Contact';
import About from './pages/About';

// Import CSS files
import 'bootstrap/dist/css/bootstrap.min.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import './assets/css/animate.css';
import './assets/css/owl.carousel.min.css';
import './assets/css/owl.theme.default.min.css';
import './assets/css/main.css';
import EventDetail from './pages/EventDetail';

const App = () => {
  return (
    <Router>
      <div className="App">
        <Header />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/about" element={<About />} />
          <Route path="/event-ticket" element={<EventDetail />} />
          <Route path="/event-ticket" element={<EventTicket />} />
          <Route path="/event-checkout" element={<EventCheckout />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
};

export default App;