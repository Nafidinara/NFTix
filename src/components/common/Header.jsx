import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const Header = () => {
  const [isSticky, setSticky] = useState(false);
  const [isMobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Handle sticky header
  useEffect(() => {
    const handleScroll = () => {
      setSticky(window.scrollY > 1);
    };

    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  const toggleMobileMenu = () => {
    setMobileMenuOpen(!isMobileMenuOpen);
    document.querySelector('.overlay').classList.toggle('active');
  };

  return (
    <>
      <header className={`header-section ${isSticky ? 'header-active' : ''}`}>
        <div className="container">
          <div className="header-wrapper">
            <div className="logo">
              <Link to="/">
                <img 
                  style={{ maxWidth: '70%', maxHeight: '70%' }}
                  src="https://i.ibb.co.com/nnRLrXc/6217364158c6b-thumb900-removebg-preview.png" 
                  alt="logo"
                />
              </Link>
            </div>
            <ul className={`menu ${isMobileMenuOpen ? 'active' : ''}`}>
              <li>
                <Link to="/">Home</Link>
              </li>
              <li>
                <Link to="/contact">Contact</Link>
              </li>
              <li>
                <Link to="/about">About Us</Link>
              </li>
            </ul>
            <div 
              className={`header-bar d-lg-none ${isMobileMenuOpen ? 'active' : ''}`}
              onClick={toggleMobileMenu}
            >
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </header>
      <div className="overlay" onClick={toggleMobileMenu}></div>
    </>
  );
};

export default Header;